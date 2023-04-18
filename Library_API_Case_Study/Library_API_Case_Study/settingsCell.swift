import UIKit

class settingsCell: UITableViewCell {
    
    @IBOutlet weak var wordLabel: UILabel!
    var switchChanged: (Bool) -> () = {  _ in }
    
    @IBOutlet weak var wordGroupSwitch: UISwitch!
    
    @IBAction func switchValueChanged( _ switch: UISwitch) {
        switchChanged(`switch`.isOn)
        
    }
}
