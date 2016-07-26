import UIKit

extension NSDate {
    private func getTimeSpanString() -> String {
        let elapsedTime = NSDate().timeIntervalSinceDate(self);
        let ti = NSInteger(elapsedTime)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        let days = (hours / 24)
        
        if days > 0 {
            if days == 1 {
                return String(days) + " day ago";
            }
            return String(days) + " days ago";
        }
        
        if hours > 0 {
            if hours == 1 {
                return String(hours) + " hour ago";
            }
            return String(hours) + " hours ago";
        }
        
        if minutes > 0 {
            if minutes == 1 {
                return String(minutes) + " minute ago";
            }
            return String(minutes) + " minutes ago";
        }
        
        if seconds == 1 {
            return String(seconds) + " second ago";
        }
        return String(seconds) + " seconds ago";
    }
}




class ArticleTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorTimeLabel: UILabel!
    @IBOutlet var commentsLabel: UILabel!
    @IBOutlet var voteLabel: UILabel!
    @IBOutlet var steemLabel: UILabel!
    @IBOutlet var articleImage: UIImageView!

    func setArticle(article : Article){
        self.titleLabel.text = article.title
        self.authorTimeLabel.text = "\(article.author) · \(article.creationDate.getTimeSpanString())";
        self.commentsLabel.text = "\(String(article.commentSize)) Comments"
        self.voteLabel.text = "\(String(article.upvoteSize - article.downvoteSize)) Upvotes"
        self.steemLabel.text = "\(String(Int(article.dollar))) Steem";
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func imageFromUrl(url: NSURL, _ reloadMethod: () -> Void){
        if self.imageView?.image != nil {
            return;
        }
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let imageData = data as NSData?   {
                self.articleImage.image = UIImage(data: imageData);
                reloadMethod();
            }
        }
        task.resume()
    }

}
