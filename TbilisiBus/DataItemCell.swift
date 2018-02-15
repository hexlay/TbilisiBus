import UIKit

class DataItemCell: UITableViewCell {

    @IBOutlet weak var busNumber: UILabel!
    @IBOutlet weak var busDestination: UILabel!
    @IBOutlet weak var busTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        busDestination.lineBreakMode = .byWordWrapping
        busDestination.numberOfLines = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
