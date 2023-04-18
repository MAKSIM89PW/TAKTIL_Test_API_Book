import UIKit
import CoreData
class ViewController:   UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    let presenter = LibraryPresenter()
    @IBOutlet weak var tabBar: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //imported Json data
    var bookArray: [doc] = []
    
    var coreDataBooks = [Item]()
    //переменная, используемая searchBar
    //выполняется через X секунд после последнего пользовательского ввода с клавиатуры
    //var timer:Таймер?
    override func viewWillAppear(_ animated: Bool) {
        searchFunction()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        tableView.tableFooterView = UIView()
        let imageView = UIImageView()
        imageView.image = UIImage(named: "BeginSearch.png")
        self.tableView.backgroundView = imageView
        self.tableView.backgroundView?.contentMode = UIImageView.ContentMode.scaleAspectFit
        //установите значения по умолчанию для страницы настроек
        if(UserDefaults.standard.object(forKey: "0")==nil){
            for i in 0..<7{
                if(i==0){
                    UserDefaults.standard.set(true, forKey: "\(i)")
                }else{
                    UserDefaults.standard.set(false, forKey: "\(i)")
                }
            }
        }
    }
    //Перейдите к контроллеру подробного просмотра
    
    //отправка данных на наш  view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        
        if segue.identifier == "toDetail"{
            let DestVC = segue.destination as! DetailViewController
            if(tabBar.selectedSegmentIndex == 0){
                let book = bookArray[(indexPath?.row)!]
                DestVC.TitleName = book.title_suggest
                print("book title suggest is " + "\(String(describing: book.title_suggest))")
                DestVC.subtitle = book.subtitle
                DestVC.author = book.author_name
                DestVC.cover_i = book.cover_i
                DestVC.publisher = book.publisher
                DestVC.author_alternative_name = book.author_alternative_name
                DestVC.publishDate = book.first_publish_year
                DestVC.addToWishListTextOn = true
                DestVC.internetArchive = internetArchives(input: book.ia)
            } else {
                let book = coreDataBooks[(indexPath?.row)!]
                DestVC.TitleName = book.title_suggest
                DestVC.subtitle = book.subtitle
                if(book.author != nil){
                    DestVC.author = [book.author!]
                }
                if(book.author_alternative_name != nil){
                    DestVC.author_alternative_name = [book.author_alternative_name!]
                }
                if(book.publisher != nil){
                    DestVC.publisher = [book.publisher!]
                }
                DestVC.cover_i = Int(book.cover_i)
                DestVC.publishDate = Int(book.publishDate)
                DestVC.addToWishListTextOn = false
                if(book.ia != nil){
                    DestVC.internetArchive = internetArchives(input: [book.ia!])
                }
            }
        }
    }
    //берет массив ссылок из интернет-архива и превращает его в единую строку,
    //каждая запись массива разделяется новой строкой \n
    func internetArchives(input: [String]?) -> String{
        var result = ""
        if input != nil {
            for i in input!{
                result += i + "\n"
            }
        }
        return result
    }
    
    //Tab Bar Method (переключение между списком желаний и поиском)
    //обновление данных таблицы после каждого переключения
    @IBAction func tabBar(_ sender: UISegmentedControl) {
        if(tabBar.selectedSegmentIndex == 0){
            searchBar.isHidden = false
            if(searchBar.text?.count == 0 || searchBar.text == nil){
                let imageView = UIImageView()
                imageView.image = UIImage(named: "BeginSearch.png")
                self.tableView.backgroundView = imageView
                self.tableView.backgroundView?.contentMode = UIImageView.ContentMode.scaleAspectFit
            }else{
                self.tableView.backgroundView = nil
            }
        }else if(tabBar.selectedSegmentIndex == 1){
            searchBar.isHidden = true
            fetchCoreData()
        }
        tableView.reloadData()
        
    }
    
    //Вспомогательная функция для извлечения основных данных и обновления пользовательского интерфейса при необходимости
    func fetchCoreData(){
        presenter.fetchData { (items) in
            self.coreDataBooks = items
            if(items.count < 1){
                // searchBar.isHidden = true
                searchBar.resignFirstResponder()
                let imageView = UIImageView()
                imageView.image = UIImage(named: "emptyWishlist.png")
                self.tableView.backgroundView = imageView
                self.tableView.backgroundView?.contentMode = UIImageView.ContentMode.scaleAspectFit
            }else{
                //searchBar.isHidden
                tableView.backgroundView = nil
            }
        }
    }
    
    //Это запускает поиск по заданному URL и возвращает проанализированный JSON в table view
    
    func searchFunction(){
        presenter.searchBooks(keyword: searchBar.text!,
                              emptyCompletion: {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "BeginSearch.png")
            self.tableView.backgroundView = imageView
            self.tableView.backgroundView?.contentMode = UIImageView.ContentMode.scaleAspectFit
            bookArray = []
            tableView.reloadData()
        }, searchCompletion: { object in
            self.bookArray = object.docs
            if(self.bookArray.count == 0){
                let imageView = UIImageView()
                imageView.image = UIImage(named: "noResults.png")
                self.tableView.backgroundView = imageView
                self.tableView.backgroundView?.contentMode = UIImageView.ContentMode.scaleAspectFit
            }else{
                self.tableView.backgroundView = nil
            }
            self.tableView.reloadData()
        })
    }
    
    //Следующие две функции относятся к панели поиска
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchFunction()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    //Стандартная настройка Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tabBar.selectedSegmentIndex == 0){
            return bookArray.count
        }
        return coreDataBooks.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! Cell
        //если 0, то мы находимся в режиме поиска
        if(tabBar.selectedSegmentIndex == 0){
            let book = bookArray[indexPath.row]
            cell.initilaization(title: book.title_suggest, author: book.author_name, publishDate: book.first_publish_year, cover_i: book.cover_i)
            
        }
        else{
            let book = coreDataBooks[indexPath.row]
            var tempAuthorArray: [String] = []
            if let author = book.author {
                tempAuthorArray.append(author)
            }
            
            cell.initilaization(title: book.title_suggest, author: tempAuthorArray, publishDate: Int(book.publishDate), cover_i: Int(book.cover_i))
            //cell.indexPath = indexPath
            //cell.segmentedControl = 1
        }
        return cell
    }
    
    
    //Эти три функции обрабатывают удаление ячейки
    //Чтобы удалить ячейку, вы должны провести пальцем по ячейке влево
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete"){  (action, indexPath) in
            self.deleteData(indexPath: indexPath)
            self.fetchCoreData()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(tabBar.selectedSegmentIndex == 1){
            return true
        }
        return false
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
}


//Расширение для обработки сохранения и удаления данных
extension ViewController{
    func deleteData(indexPath: IndexPath){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        managedContext.delete(coreDataBooks[indexPath.row])
        do{
            try managedContext.save()
            tableView.reloadData()
        }catch{
            print("could not save updated data")
        }
    }
    
}
