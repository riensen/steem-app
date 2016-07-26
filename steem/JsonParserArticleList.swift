import Foundation

extension NSDate
{
    static func makeDate(dateString: String) -> NSDate {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ" //"2016-07-08T07:29:45"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateStringFormatter.dateFromString(dateString)!
    }
    

}

class JsonParserArticleList{
    static func makeArticleJSON(json: JSON) -> [Article]{
        var result: [Article] = []
        var articleDict: [String: Article] = [:]
        let articleList =  json["result"]["content"];
        for (key, article) in articleList{
            let author = article["author"].string!
            let title = article["title"].string!
            let dollarStr = article["pending_payout_value"].string!
            let dollar = Double(String(dollarStr.characters.dropLast(4)))!
            let date = NSDate.makeDate(article["created"].string!+"UTC")
            let voteAr = article["active_votes"].arrayValue

            var downvoteSize = 0;
            var upvoteSize  = 0;
            for vote in voteAr{
                if vote["percent"].int > 0 {
                    upvoteSize += 1;
                } else {
                    downvoteSize += 1;
                }
            }
            
            let commentSize = article["children"].int!;
            
            let body  = article["body"].string!;
            
            
            
            
            //onlyjpg png ...
           // let regexStr = "https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*(\\.(png|jpg|jpeg|gif))[-a-zA-Z0-9@:%_\\+.~#?&//=]*)"
        
//            guard let urlRange : Range<String.CharacterView.Index>= body.rangeOfString(regexStr, options: .RegularExpressionSearch) else{
//                articleDict[key] = Article(id: key,title: title,author: author,body: body, creationDate: date, commentSize: commentSize, upvoteSize: upvoteSize, downvoteSize: downvoteSize, dollar: dollar)
//                continue;
//                
//            }
            do {
                
                
               
                    
    //                if urlList.isEmpty {
    //                    articleDict[key] = Article(id: key,title: title,author: author,body: body, creationDate: date, commentSize: commentSize, upvoteSize: upvoteSize, downvoteSize: downvoteSize, dollar: dollar)
    //                    continue;
    //                }
                
                let regexUrlStr = "https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=;]*)";
                let regexUrl = try NSRegularExpression(pattern: regexUrlStr, options: [])
                let nsString = body as NSString
                var urlList :[String] = []
                let range = regexUrl.matchesInString(body, options: [], range: NSMakeRange(0, nsString.length))
                for url in (range.map { nsString.substringWithRange($0.range)}) {
                   urlList.append(url)
                }
                
//                 let regexUrlUnwrappedStr = "(?<!\\!\\[\\w\\]\\()https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=;]*)"
//                let regexUrlUnwrapped = try NSRegularExpression(pattern: regexUrlUnwrappedStr, options: [])
//                let rangeUnwrapped = regexUrlUnwrapped.matchesInString(body, options: [], range: NSMakeRange(0, nsString.length))
//                for url in (rangeUnwrapped.map { nsString.substringWithRange($0.range)}) {
//                    print(url)
//                   // print(body)
//                   body = body.stringByReplacingOccurrencesOfString(url, withString: "![](\(url))")
//                   //  print(body)
//                }
      
                articleDict[key] = Article(id: key,title: title,author: author,body: body, creationDate: date, commentSize: commentSize, upvoteSize: upvoteSize, downvoteSize: downvoteSize, dollar: dollar, imageUrlList:  urlList)
            } catch let error as NSError {
                print("invalid regex: \(error.localizedDescription)")
                return []
            }
        }
        
        var rankingJson : [String] = []
        let (_, rankMethodAr) : (String, JSON) =  json["result"]["discussion_idx"].first!;
        for (_,rankMethod) in rankMethodAr {
            if let method = rankMethod.arrayObject as? [String] {
                if method.count > 0 {
                    rankingJson = method;
                }
            }
        }
        for id in rankingJson {
            if let article = articleDict[id] {
                result.append(article);
                article.loadFirstImage()
            }
        }
        return result;
    }
    

}