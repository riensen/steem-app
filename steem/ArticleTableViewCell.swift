import UIKit

class ArticleTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorTimeLabel: UILabel!
    @IBOutlet var commentsLabel: UILabel!
    @IBOutlet var voteLabel: UILabel!
    @IBOutlet var steemLabel: UILabel!
    @IBOutlet var articleImage: UIImageView!

    func setArticle(article: Article) {
        self.titleLabel.text = article.title
        self.authorTimeLabel.text = "\(article.author) · \(article.creationDate.getTimeSpanString())"
        self.commentsLabel.text = "\(String(article.commentSize)) Comments"
        self.voteLabel.text = "\(String(article.upvoteSize - article.downvoteSize)) Upvotes"
        self.steemLabel.text = "\(String(Int(article.dollar))) Steem"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func imageFromUrl(url: URL, _ reloadMethod: @escaping () -> Void){
        if self.imageView?.image != nil {
            return
        }
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            if let imageData = data as Data?   {
                self.articleImage.image = UIImage(data: imageData)
                reloadMethod()
            }
        }
        task.resume()
    }

}
