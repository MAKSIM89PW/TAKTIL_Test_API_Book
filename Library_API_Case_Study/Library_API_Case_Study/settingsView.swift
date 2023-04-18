import Foundation
import UIKit
class searchSettings: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    //Названия каждой из категорий в настройках
    var searchTypes = ["Relevance", "Most Editions", "First Published", "Most Recent", "By Title", "By Author"]
  
    
    //кортежи
     //Значение равно false, если url_endings[x] должно быть добавлено в конец другого url-адреса
     //Значение равно true, если url_endings[x] должен иметь префикс перед поисковым словом
    var url_endings = [("&mode=everything",false), ("&sort=editions&mode=everything",false), ("&sort=old&mode=everything",false), ("&sort=new&mode=everything",false), ("https://openlibrary.org/search.json?title=", true), ("https://openlibrary.org/search.json?author=", true)]
    
    //Базовая инициализация table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") as! settingsCell
      
        cell.wordGroupSwitch.isOn = isSwitchOn(at: indexPath.row)
        cell.wordLabel.text = searchTypes[indexPath.row]
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.switchChanged = { [weak self] isOn in
            self?.wordGroup(at: indexPath.row , changedTo: isOn)
        }
        return cell
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
   
    
    //Функция для проверки любых ошибок на странице настроек
     //Поскольку на странице настроек всегда должно быть ровно 1 переключатель, выбранный в любой момент времени
    func wordGroup(at index: Int, changedTo value: Bool) {
        let numberOfGroupsTurnedOn = Array(0..<7).map {
            isSwitchOn(at: $0)
            }.filter { $0 }.count
        
        if  (value == true) {
            //display a message
            for i in 0..<7{
                if(UserDefaults.standard.bool(forKey: "\(i)") == true && i != index){
                    UserDefaults.standard.set(false, forKey: "\(i)")
                }
            }
            UserDefaults.standard.set(value, forKey: "\(index)")
            UserDefaults.standard.synchronize()
            tableView.reloadData()
        }
        if  (value == false) {
            //display a message
            let alertController = UIAlertController(title: "Error", message: "you must select one search option", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel) { [weak self]  _ in
                self?.tableView.reloadData()
            }
            alertController.addAction(cancelAction)
            present(alertController, animated: true) {  }
            }
    }
    
    //вспомогательная функция
    func isSwitchOn(at index: Int) -> Bool {
        return UserDefaults.standard.value(forKey: "\(index)") as? Bool ?? true
    }
    
    
}
