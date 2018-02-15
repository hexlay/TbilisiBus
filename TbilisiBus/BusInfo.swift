import UIKit
import Alamofire
import Toast_Swift
import SwiftSoup
import MapKit

class BusInfo: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let serviceUrl = "http://transit.ttc.com.ge/pts-portal-services/servlet/stopArrivalTimesServlet?stopId=%d"
    var buses: [BusModel]?
    var id: Int?
    var vTitle: String?
    let refreshControl = UIRefreshControl()
    let dbFavs = DBPopulate()
    @IBOutlet var busSchedule: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buses = [BusModel]()
        busSchedule.dataSource = self
        busSchedule.delegate = self
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.tintColor = UIColor.blue
        busSchedule.refreshControl = refreshControl
        requestBusTimes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = vTitle
        if dbFavs.isExist(gid: id!) == 1 {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeFavorite))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFavorite))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (buses?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = busSchedule.dequeueReusableCell(withIdentifier: "dataItemCell", for: indexPath) as! DataItemCell
        cell.isUserInteractionEnabled = false
        if !refreshControl.isRefreshing {
            let bNum = self.buses?[indexPath.row].busNum
            let bDir = self.buses?[indexPath.row].busDirection
            let bTime = self.buses?[indexPath.row].busTime
            cell.busNumber.text = bNum
            cell.busDestination.text = bDir
            cell.busTime.text = bTime! + " წუთი"
        }
        return cell
    }
    
    @objc func handleRefresh(_ sender: Any) {
        self.buses?.removeAll()
        self.requestBusTimes()
    }
    
    @objc func addFavorite() {
        dbFavs.addFavorite(gid: id!, gname: vTitle!)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removeFavorite))
    }
    
    @objc func removeFavorite() {
        dbFavs.deleteFavorite(gid: id!)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFavorite))
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if((buses?.count)! <= 0) {
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            emptyLabel.text = "მონიშნული გაჩერებისთვის ავტობუსების მოსვლის დროები მიუწვდომელია"
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
    
    func requestBusTimes() {
        Alamofire.request(String(format: serviceUrl, id!)).responseString { response in
            if response.result.isSuccess {
                let result = response.result.value
                do {
                    let doc: Document = try! SwiftSoup.parse(result!)
                    let elements: Elements = try! doc.select(".arrivalTimesScrol tr")
                    for element: Element in elements.array() {
                        let bNum = try element.child(0).text()
                        let bDir = try element.child(1).text()
                        let bTime = try element.child(2).text()
                        self.buses?.append(BusModel(busNum: bNum, busDirection: bDir, busTime: bTime))
                    }
                    self.busSchedule!.reloadData()
                    self.refreshControl.endRefreshing()
                } catch let error {
                    print("Error info: \(error)")
                }
            } else {
                print(response)
                self.view.makeToast("დაფიქსირდა შეცდომა...")
            }
        }
    }
    
}
