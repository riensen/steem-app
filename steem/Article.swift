import Foundation
import UIKit

extension String{
    
    func unescapeUrl() -> String {
        var newString : String = self
        let char_dictionary = [
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&apos;": "'"
        ];
        for (escaped_char, unescaped_char) in char_dictionary {
            newString = newString.stringByReplacingOccurrencesOfString(escaped_char, withString: unescaped_char)
        }
        newString = newString.stringByReplacingOccurrencesOfString("amp;", withString: "")
        return newString
    }
    
}
class Article: Content{
    let title: String;
    let imageUrlList: [String];
    private var isImageMap: [String:Bool] = [:];
  //  var image: UIImage? = nil;
    private var imageMap: [String:UIImage]  = [:];
    let commentSize: Int;
    var eventNotification : () -> Void = {};
    
    init(id: String, title: String, author: String, body: String, creationDate: NSDate, commentSize: Int, upvoteSize:Int, downvoteSize: Int, dollar: Double, imageUrlList: [String]) {
        self.commentSize = commentSize;
        self.title = title;
        var tmpImageUrlList : [String] = []
        for url in imageUrlList{
            tmpImageUrlList.append(url.unescapeUrl())
        }
        self.imageUrlList = tmpImageUrlList
        super.init(id: id, author: author, body: body, creationDate: creationDate, upvoteSize: upvoteSize, downvoteSize: downvoteSize, dollar: dollar);
    }
    
    
    private func isImage(url: String) -> Bool? {
       return isImageMap[url.unescapeUrl()]
    }
    
    func getImage(url: String) -> UIImage? {
        return imageMap[url.unescapeUrl()]
    }
    
    func hasImages() -> Bool? {
        let img = getFirstImage();
        if img != nil {
            return true
        }
        if isImageMap.count < imageUrlList.count {
            return nil
        }
        return false;
    }
    
    func getFirstImage() -> UIImage? {
        for url in imageUrlList {
            if let usable = isImage(url) {
                if usable {
                     return getImage(url)!
                }
            } else {
                return nil
            }
        }
        return nil
    }
    
    func loadImages(){
        for url in imageUrlList{
            guard let  myUrl = NSURL(string: url) else {
                self.isImageMap[url] = false
                if self.isImageMap.count == self.imageUrlList.count{
                    self.eventNotification()
                }
                continue
            }
            let request = NSURLRequest(URL: myUrl)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                if let imageData = data as NSData?   {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                        dispatch_async(dispatch_get_main_queue()) {
                            if let myImg = UIImage(data: imageData){
                                self.imageMap[url] = myImg
                                self.isImageMap[url] = true
                                if self.getFirstImage() == myImg {
                                    self.eventNotification()
                                }
                            } else {
                                self.isImageMap[url] = false
                                if self.isImageMap.count == self.imageUrlList.count{
                                    self.eventNotification()
                                }
                            }
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    
    func loadImageWithIdx(index :Int){
        if index >= imageUrlList.count {
            return
        }
        let url = imageUrlList[index]
        guard let  myUrl = NSURL(string: url) else {
            self.isImageMap[url] = false
            self.loadImageWithIdx(index+1)
            if self.isImageMap.count == self.imageUrlList.count{
                self.eventNotification()
            }
            return
        }
        let request = NSURLRequest(URL: myUrl)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let imageData = data as NSData?   {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                    dispatch_async(dispatch_get_main_queue()) {
                        if let myImg = UIImage(data: imageData){
                            self.imageMap[url] = myImg
                            self.isImageMap[url] = true
                            if self.getFirstImage() == myImg {
                                self.eventNotification()
                            }
                        } else {
                            self.isImageMap[url] = false
                            self.loadImageWithIdx(index+1)
                        }
                        if self.isImageMap.count == self.imageUrlList.count{
                            self.eventNotification()
                        }
                    }
                }
            }
        }
        task.resume()
//        let url = imageUrlList[index]
//        print("Load:"+self.title)
//        print("Load:"+url)
//        let request = NSURLRequest(URL: NSURL(string: url)!)
//        let session = NSURLSession.sharedSession()
//        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
//            if let imageData = data as NSData?   {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
//                    dispatch_async(dispatch_get_main_queue()) {
//                        if let myImg = UIImage(data: imageData){
//                            self.image = myImg;
//                            print("Got:"+self.title)
//                            print("got:"+url)
//                            eventNotification()
//                        } else {
//                            print("failed")
//                            self.loadImageWithIdx(index+1, eventNotification: eventNotification)
//                        }
//                    }
//                }
//            }
//        }
//        task.resume()
    }
    
    
    func loadFirstImage(){
        loadImageWithIdx(0)
    }
}