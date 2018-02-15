import UIKit
import SQLite

class MainFavorites: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var favList: UITableView!
    var favs: [FavoriteModel]?
    let dbLite = DBPopulate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favList.dataSource = self
        favList.delegate = self
        favList.register(UITableViewCell.self, forCellReuseIdentifier: "dataFavItemCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        favs = [FavoriteModel]()
        do {
            for fav in (try dbLite.db?.prepare(dbLite.tablePrep.select(dbLite.id, dbLite.name)))! {
                favs!.append(FavoriteModel(id: fav[dbLite.id], name: fav[dbLite.name]))
            }
            self.favList!.reloadData()
        } catch let error {
            print("Error info: \(error)")
        }
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if((favs?.count)! <= 0) {
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            emptyLabel.text = "თქვენ არ გაქვთ ფავორიტი გაჩერებები"
            emptyLabel.textColor = UIColor.black
            emptyLabel.numberOfLines = 0;
            emptyLabel.textAlignment = .center;
            emptyLabel.font = UIFont(name: "TrebuchetMS", size: 15)
            emptyLabel.sizeToFit()
            tableView.backgroundView = emptyLabel;
            tableView.separatorStyle = .none;
            return 0
        } else {
            tableView.backgroundView = .none;
            tableView.separatorStyle = .singleLine;
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (favs?.count)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "openRouteFav", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openRouteFav" {
            if let idPath = sender as? Int {
                let svc = segue.destination as! BusInfo
                svc.id = self.favs?[idPath].id
                svc.vTitle = self.favs?[idPath].name
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = favList.dequeueReusableCell(withIdentifier: "dataFavItemCell")!
        cell.isUserInteractionEnabled = true
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = self.favs?[indexPath.row].name
        return cell
    }

}
