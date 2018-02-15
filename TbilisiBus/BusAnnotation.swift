import MapKit
import AddressBook

class BusAnnotation: NSObject, MKAnnotation {
    
    let identifier: Int
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    
    init(identifier: Int, title: String, coordinate: CLLocationCoordinate2D) {
        self.identifier = identifier
        self.title = title
        self.coordinate = coordinate
        super.init()
    }
    
}
