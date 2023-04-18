import UIKit
import CoreData

class DetailViewController: UIViewController {

    var TitleName: String?
    var subtitle: String?//
    var author: [String]?
    var publishDate: Int?
    var cover_i: Int?
    var publisher: [String]?//
    var author_alternative_name: [String]?//
    var addToWishListTextOn: Bool?
    var internetArchive: String?
    
    @IBOutlet weak var addToWishlist: UIButton!
    @IBOutlet weak var Subtitle: UILabel!
    @IBOutlet weak var bookCoverImage: UIImageView!
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var Author: UILabel!
    @IBOutlet weak var publishYear: UILabel!
    
    @IBOutlet weak var Publisher: UILabel!
    
    @IBOutlet weak var author_alternative: UILabel!
    @IBOutlet weak var internetArchives: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        initilaization()
        addToWishlist.layer.cornerRadius = 8
        addToWishlist.layer.borderWidth = 1.3
        addToWishlist.layer.borderColor = UIColor.gray.cgColor
        if(!addToWishListTextOn!){
            addToWishlist.isHidden = true
        }
    }
    
    //Тут происходит обработка и  добавление в список желаний
     //каждое свойство проверяется, а затем сохраняется в CoreData
    @IBAction func addToWishlist(_ sender: UIButton) {
        
            guard let managedContext = appDelegate?.persistentContainer.viewContext else {
                return
            }
            let book = Item(context: managedContext)
        if(self.author != nil && self.author!.count > 0){
            book.author = self.author![0]
        }
        if(self.author_alternative_name != nil){
            var result = ""
            for i in self.author_alternative_name!{result += i + "\n"}
        }
        if(self.publisher != nil){
            book.publisher = self.publisher![0]
        }
        if(self.publishDate != nil){
            book.publishDate = Int32(self.publishDate!)
        }
        if(self.TitleName != nil){
            print("title name is " + "\(titleName)")
            book.title_suggest = self.TitleName
        }
        if(self.subtitle != nil){
            book.subtitle = self.subtitle
        }
        if(self.cover_i != nil && self.cover_i! > 0){
            book.cover_i = Int32(self.cover_i!)
        }
        if(self.internetArchive != nil){
            book.ia = self.internetArchive
        }
            do{
                appDelegate?.saveContext()
                try managedContext.save()
            }catch{
                print("failed to save", error.localizedDescription)
            }
    
    }
    
    //инициализирует detail view
     //Здесь мы проводим много проверок на ошибки
     //Здесь мы заполняем наши подробные метки и ImageView
    func initilaization(){
        
        if(TitleName != nil){
            self.titleName.text = TitleName
        }else{
            titleName.text = "No title found"
        }
        if(author != nil){
            if(author!.count>0){
                self.Author.text = author![0]
                for (i, c) in (author?.enumerated())!{
                    if(i>0){
                        self.Author.text = self.Author.text! + ", " + c
                    }
                }
            }
        }else{
            Author.text = "No author found"
        }
        if(publishDate != nil){
            self.publishYear.text = "Published in " + "\(publishDate!)"
        }else{
            publishYear.text = "publish year not found"
        }
        if(cover_i != nil && cover_i! > 0){
            fetchImage(cover_i: cover_i!)
        }else{
            bookCoverImage.image = UIImage(named: "Image-not-found.gif")
        }
        if(internetArchive != "" && internetArchive != nil){
            internetArchives.text = internetArchive
        }else{
            internetArchives.text = "could not find any internet archives"
        }
        if(subtitle != nil){
            Subtitle.text = subtitle
        }else{
            Subtitle.text = "no subtitle found"
        }
        if(author_alternative_name != nil && (author_alternative_name?.count)!>0){
            var result = ""
            for i in author_alternative_name!{
                result += i + "\n"
            }
            author_alternative.text = result
        }else{
            author_alternative.text = "cannot find any alternative names for the author"
        }
        if(publisher != nil && (publisher?.count)! > 0){
            var result = ""
            for i in publisher!{
                result += i + "\n"
            }
            Publisher.text = result
        }
        else{
            Publisher.text = "cannot find publisher"
        }
}

    
    //Получение обложки книги из заданного Json data.
    func fetchImage(cover_i: Int){
        let url = "https://covers.openlibrary.org/b/id/" + "\(cover_i)" + "-M.jpg"
        //проверка, что URL-адрес действителен
        if let imageURL = URL(string: url){
            //выполнение работы в фоновом потоке
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageURL)
                if let data = data {
                    let image = UIImage(data: data)
                    //переключение обратно в основной поток и обновление UI
                    DispatchQueue.main.async {
                        self.bookCoverImage.image = image
                    }
                }
            }
        }
    }
    
}
