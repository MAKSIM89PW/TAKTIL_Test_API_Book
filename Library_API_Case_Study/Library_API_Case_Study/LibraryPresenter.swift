import UIKit
import CoreData
class LibraryPresenter: NSObject {
    var settings = searchSettings()
    
    
    //Импортирует данные JSON с заданного URL
    func importJson(url: String, completion: @escaping (BookObject) -> Void){
        let ValidUrl = URL(string: url)
        guard let jsonUrl = ValidUrl else {
            return
        }
        URLSession.shared.dataTask(with: jsonUrl, completionHandler: { (data, response, error) in
            guard let data = data else {
                return
            }
            do{
                let object = try JSONDecoder().decode(BookObject.self, from: data)

                print(object)
                DispatchQueue.main.async {
                    completion(object)
                }
            }catch{
                print(error)
            }
        }).resume()
        print("escaping")
    }
    
    func getUrl(rawUrl: String) -> String {
        let url = rawUrl.replacingOccurrences(of: " ", with: "+")
        print("url is " + "\(url)")
        return url
    }
    
    var timer: Timer?
    var searchCompletion: ((BookObject) -> Void)?

    func searchBooks(keyword: String, emptyCompletion: () -> Void, searchCompletion: @escaping (BookObject) -> Void) {
        timer?.invalidate()
        self.searchCompletion = searchCompletion
        if keyword.isEmpty {
            emptyCompletion()
            return
        }
        var url = "https://openlibrary.org/search.json?q=" + "\(keyword)"
        
        //Здесь URL-адрес изменяется в зависимости от параметров в настройках
        for (i,c) in settings.url_endings.enumerated(){
            if(UserDefaults.standard.bool(forKey: "\(i)") == true){
                if(c.1 == false){
                    url = url + c.0
                }else{
                    url = c.0 + "\(keyword)"
                }
            }
        }
        print("url is " + url)
        let passData = (url: url, completion: searchCompletion)
        timer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(startSearching), userInfo: url, repeats: false)
    }
    
    // Эта функция будет срабатывать один раз каждые 0,35 секунды
     // Поскольку мы не хотим перезагружать json при каждом нажатии кнопки
    @objc func startSearching() {
        let url = timer!.userInfo as! String
        let finalUrl = getUrl(rawUrl: url)
        guard let completion = searchCompletion else { return }
        importJson(url: finalUrl, completion: completion)
    }
}

//Fetches Json data
extension LibraryPresenter {
    func fetchData(completion: ([Item]) -> ()){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        do{
            let data = try managedContext.fetch(request) as! [Item]
            completion(data)
        }catch{
            completion([])
        }
    }
    
}
