import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class Cell: UITableViewCell {
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var publishDate: UILabel!

    
    func initilaization(title: String?, author: [String]?, publishDate: Int?, cover_i: Int?){
        if(title != nil){
            self.title.text = title
        }
        if(author != nil){
            if(author!.count>0){
                self.author.text = author![0]
                for (i, c) in (author?.enumerated())!{
                    if(i>0){
                        self.author.text = self.author.text! + ", " + c
                    }
                }
            }
        }
        if(publishDate != nil){
            //datePublished = publishDate
            self.publishDate.text = "Published in " + "\(publishDate!)"
        }
        if(cover_i != nil && cover_i! > 0){
            fetchImage(cover_i: cover_i!)
            //self.cover_id = cover_i
        }else{
            imgNotFound()
        }

    }
    
    func imgNotFound(){
        self.bookImage.image = UIImage(named: "Image-not-found.gif")
    }
    
    func fetchImage(cover_i: Int){
        let url = "https://covers.openlibrary.org/b/id/" + "\(cover_i)" + "-M.jpg"
        //проверка, что URL-адрес действителен
            if let imageURL = URL(string: url){
                //выполнение работы в фоновом потоке
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: imageURL)
                    if let data = data {
                        let image = UIImage(data: data)
                //переключение обратно в основной поток и обговление интерфейса
                        DispatchQueue.main.async {
                            self.bookImage.image = image
                        }
                    }
                }
            }
    }
}

