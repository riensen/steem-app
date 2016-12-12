import Foundation


class Content : NSObject {
    let id, author, body: String
    let upvoteSize, downvoteSize: Int
    let dollar: Double
    let creationDate: Date
    var children: [Comment] = []
    
    init(id: String, author: String, body: String, creationDate: Date, upvoteSize: Int, downvoteSize: Int, dollar: Double) {
        self.id = id;
        self.author = author;
        self.body = body;
        self.creationDate = creationDate;
        
        self.upvoteSize = upvoteSize;
        self.downvoteSize = downvoteSize;
        self.dollar = dollar;
    }
    
    
     override var description: String {
        get {
            return "\(id)"
        }
    }
}
