//все декодируемые структуры можно найти здесь
//эти структуры являются основой синтаксического анализа JSON
import Foundation

struct Books: Decodable{
    let object: [BookObject]
}
struct doc: Decodable{
    let title_suggest: String?
    let subtitle: String?
    let author_name: [String]?
    let first_publish_year: Int?
    let cover_i: Int?
    let publisher: [String]?
    let author_alternative_name: [String]?
    let ia: [String]?
    
    
}
struct BookObject: Decodable{
    let start: Int?
    let num_found: Int?
    let docs: [doc]
    
}

