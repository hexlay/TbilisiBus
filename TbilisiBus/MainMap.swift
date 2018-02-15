import UIKit
import MapKit
import CoreLocation
import Alamofire
import Toast_Swift
import SwiftSoup

class MainMap: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var currentPointLocation: CLLocation!
    var anotations: [MKAnnotation]?
    var anotationsBounded: [MKAnnotation]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        anotations = [MKAnnotation]()
        anotationsBounded = [MKAnnotation]()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        mapView.delegate = self
        setCameraTbilisi()
        //locationManager.requestLocation()
        DispatchQueue.global(qos: .background).async {
            self.syncMapWithJson()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setCameraTbilisi() {
        let tbilisi = CLLocationCoordinate2D(latitude: 41.72373, longitude: 44.79047)
        let reg = MKCoordinateRegionMakeWithDistance(tbilisi, 4000, 4000)
        mapView.setRegion(reg, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.first!
        self.mapView.centerCoordinate = location.coordinate
        let reg = MKCoordinateRegionMakeWithDistance(location.coordinate, 1500, 1500)
        self.mapView.setRegion(reg, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        addMarkerInRange()
    }
    
    func syncMapWithJson() {
        if let path = Bundle.main.path(forResource: "db", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonArray = jsonResult as? NSArray {
                    for objJson in jsonArray {
                        let jObj = objJson as! NSDictionary
                        let id = jObj.value(forKey: "id") as? String
                        let name = jObj.value(forKey: "name") as! String
                        let lat = jObj.value(forKey: "lat") as? CLLocationDegrees
                        let lon = jObj.value(forKey: "lon") as? CLLocationDegrees
                        anotations?.append(makeAnotation(lat: lat!, long: lon!, name: name, id: Int(id!)!))
                    }
                    //mapView.addAnnotations(anotations!)
                }
            } catch let error {
                print("Error info: \(error)")
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let annotation = view.annotation as? BusAnnotation {
                performSegue(withIdentifier: "openRoute", sender: annotation)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openRoute" {
            if let annotation = sender as? BusAnnotation {
                let svc = segue.destination as! BusInfo
                svc.id = annotation.identifier
                svc.vTitle = annotation.title
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        pinView?.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure) as UIButton
        return pinView!
    }
    
    func makeAnotation(lat: CLLocationDegrees, long: CLLocationDegrees, name: String, id: Int) -> MKAnnotation {
        let mapCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let mkAnotation = BusAnnotation(identifier: id, title: name, coordinate: mapCoordinate)
        return mkAnotation
    }
    
    func addMarkerInRange() {
        if mapView.zoomLevel >= 16 {
            anotationsBounded = anotations?.filter({mapView.contains(coordinate: $0.coordinate)})
            mapView.addAnnotations(anotationsBounded!)
        }
    }
    
}

extension MKMapView {
    
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        return MKMapRectContainsPoint(self.visibleMapRect, MKMapPointForCoordinate(coordinate))
    }
    
    var zoomLevel: Int {
        let zoomScale = self.visibleMapRect.size.width / Double(self.frame.size.width)
        let zoomExponent = log2(zoomScale)
        return Int(20 - ceil(zoomExponent))
    }
    
}
