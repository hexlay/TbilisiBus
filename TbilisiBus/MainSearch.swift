import UIKit

class MainSearch: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var searchItems: [FavoriteModel]?
    var searchItemsFiltered: [FavoriteModel]?
    var isSearching = false
    @IBOutlet var searchTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchItems = [FavoriteModel]()
        searchItemsFiltered = [FavoriteModel]()
        searchTable.dataSource = self
        searchTable.delegate = self
        searchTable.register(UITableViewCell.self, forCellReuseIdentifier: "dataSeItemCell")
        createSearch()
        fillSearch()
    }

    func createSearch() {
        let searchMaint = UISearchBar()
        searchMaint.showsCancelButton = false
        searchMaint.placeholder = "გაჩერების სახელი"
        searchMaint.delegate = self
        navigationItem.titleView = searchMaint
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func fillSearch() {
        if let path = Bundle.main.path(forResource: "db", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonArray = jsonResult as? NSArray {
                    for objJson in jsonArray {
                        let jObj = objJson as! NSDictionary
                        let id = jObj.value(forKey: "id") as? String
                        let name = jObj.value(forKey: "name") as! String
                        searchItems?.append(FavoriteModel(id: Int(id!)!, name: name))
                    }
                }
            } catch let error {
                print("Error info: \(error)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? searchItemsFiltered!.count  : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = searchTable.dequeueReusableCell(withIdentifier: "dataSeItemCell")!
        cell.isUserInteractionEnabled = true
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = self.searchItemsFiltered?[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "openRouteSe", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openRouteSe" {
            if let idPath = sender as? Int {
                let svc = segue.destination as! BusInfo
                svc.id = self.searchItemsFiltered?[idPath].id
                svc.vTitle = self.searchItemsFiltered?[idPath].name
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            isSearching = false
        } else {
            isSearching = true
            searchItemsFiltered = searchItems?.filter({$0.name.range(of: searchText) != nil})
        }
        searchTable.reloadData()
    }
    
}
