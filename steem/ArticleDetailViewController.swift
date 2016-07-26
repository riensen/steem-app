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


class ArticleDetailViewController: UIViewController {
    
    var article : Article!;
    @IBOutlet  var articleBody : UITextView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.article.getFirstImage()
        self.article.eventNotification = {self.load()}
        load()
    }
    
    func load(){
        do {
            var htmlText : String;
            try htmlText =   MMMarkdown.HTMLStringWithMarkdown(article.body, extensions: MMMarkdownExtensions.GitHubFlavored)
            
            htmlText += "<style>body{font-family: 'Arial'; font-size:16px;}</style>"
            
            let getLinkTagRegexStr = "(?i)<a([^>]+)>(.+?)</a>";
            let getLinkTagRegex = try NSRegularExpression(pattern: getLinkTagRegexStr, options: [])
            let linkRegexStr = "(?<=href\\=\")[-a-zA-Z0-9@:%_\\+.~#?&//=;]*";
            let getLinksRegex = try NSRegularExpression(pattern: linkRegexStr, options: [])
            
            let range = getLinkTagRegex.matchesInString(htmlText, options: [], range: NSMakeRange(0, htmlText.characters.count))
            for linkTag in (range.map { (htmlText as NSString).substringWithRange($0.range)}) {
                let range = getLinksRegex.matchesInString(linkTag, options: [], range: NSMakeRange(0, linkTag.characters.count))
                for rawLink in (range.map { (linkTag as NSString).substringWithRange($0.range)}) {
                    let link = rawLink.lowercaseString
                    if link.rangeOfString("jpg") != nil || link.rangeOfString("jpeg") != nil || link.rangeOfString("png") != nil || link.rangeOfString("gif") != nil || link.rangeOfString("img") != nil {
                         htmlText = htmlText.stringByReplacingOccurrencesOfString(linkTag, withString: "<img src=\"\(rawLink.unescapeUrl())\" width=\"\(self.view.bounds.width)\" />")
                    }
                }
            }
            
            //
            //            let range = getLinkTagRegex.matchesInString(htmlText, options: [], range: NSMakeRange(0, htmlText.characters.count))
            //            for linkTag in (range.map { (htmlText as NSString).substringWithRange($0.range)}) {
            //                let range = getLinksRegex.matchesInString(linkTag, options: [], range: NSMakeRange(0, linkTag.characters.count))
            //                for rawLink in (range.map { (linkTag as NSString).substringWithRange($0.range)}) {
            //                    let link = rawLink.lowercaseString
            //                    htmlText = htmlText.stringByReplacingOccurrencesOfString(linkTag, withString: "<img src=\"\(link.unescapeUrl())\" width=\"\(self.view.bounds.width)\" />")
            //                }
            //            }
            
            
            
            let htmlTextData = htmlText.dataUsingEncoding(NSUnicodeStringEncoding)!
            let options : [String : AnyObject] = [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType]
            var attrText : NSAttributedString!;
            try  attrText =  NSAttributedString(data: htmlTextData, options: options, documentAttributes: nil);
            
            
            let myText = NSMutableAttributedString(attributedString : attrText);
            myText.enumerateAttribute(NSAttachmentAttributeName, inRange: NSRange(location: 0, length: myText.length), options: []) { (attribute, range, stop) -> Void in
                if let attachment = attribute as? NSTextAttachment {
                    let ratio = attachment.bounds.height/attachment.bounds.width
                    let newWidth = self.view.bounds.width-40
                    let newHeight = newWidth*ratio
                    attachment.bounds = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
                    
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .Left
                    myText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: range)
                }
            }
            
            self.articleBody.attributedText = myText
        } catch {
            self.articleBody.text = article.body;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
