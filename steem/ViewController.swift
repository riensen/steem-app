import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SRWebSocketDelegate {
    

    var articles: [Article] = []
    
    private static let HOT = "hot"
    private static let NEW = "created"
    private static let TRENDING = "trending"
    private var category = ViewController.TRENDING
    
    var ws: SRWebSocket!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openConnection()
    }
    
    func openConnection(){
        let url = "wss://this.piston.rocks"
        self.ws = SRWebSocket(url: URL(string: url))
        ws.delegate = self
        ws.open()
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        let msg = JSON(parseJSON: message as! String)
        self.articles =  JsonParserArticleList.makeArticleJSON(json: msg)
        if let t = self.table {
            t.reloadData()
        }
    }
    
    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        getArticlesFromSocket()
    }
    
    func getArticlesFromSocket(){
        if self.ws.readyState == SRReadyState.OPEN {
            self.ws.send("{\"id\": 8, \"method\": \"call\", \"params\": [0, \"get_state\", [\"/\(category)/\"]]}")
        } else if self.ws.readyState == SRReadyState.CONNECTING {
           return
        } else {
            openConnection()
        }
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        noInternet()
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        noInternet()
    }
    
    func noInternet(){
        let alertMessage = UIAlertController(title: "Service Unavailable", message:
            "Restart the App once an Internet Connection is available.",
                                             preferredStyle: .alert)
        alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler:
            nil))
        self.present(alertMessage, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBOutlet var table : UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->
        Int {
            // Return the number of rows in the section.
            return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return articles.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath) as! ArticleTableViewCell
        let article = articles[indexPath.section]
        cell.setArticle(article: article)
        
        article.eventNotification = { () -> Void in
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.fade)
        }
        
        if let imageFound = article.hasImages() {
            if imageFound {
                cell.articleImage.stopAnimating()
                cell.articleImage.image = article.getFirstImage()!
            } else {
                cell.articleImage.image = UIImage(named: "no-image")
            }
        } else {
            cell.articleImage.animationImages = [UIImage(named: "loading-1")!, UIImage(named: "loading-2")!, UIImage(named: "loading-3")!, UIImage(named: "loading-4")!, UIImage(named: "loading-5")!, UIImage(named: "loading-6")!, UIImage(named: "loading-7")!]
            cell.articleImage.startAnimating()
        }
        return cell
    }
    
    @IBAction func showMsg() {
        let optionMenu = UIAlertController(title: nil, message: "What do you want to do?", preferredStyle: .actionSheet)
        
        let callActionHandler = { (action:UIAlertAction!) -> Void in
            let alertMessage = UIAlertController(title: "Service Unavailable", message:
                "Sorry, the call feature is not available yet. Please retry later.",
                                                 preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler:
                nil))
            self.present(alertMessage, animated: true, completion: nil)
        }
        let callAction = UIAlertAction(title: "Show Trending Articles",
                                       style: UIAlertActionStyle.default, handler: callActionHandler)
        optionMenu.addAction(callAction)
    }
    
    
    @IBAction  func  showEditMenu() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // Add actions to the menu
        let categoryAction = UIAlertAction(title: "Choose Category", style: .default, handler:{(alert: UIAlertAction!) in self.showCategoryMenu()})
        optionMenu.addAction(categoryAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
            nil)
        
        optionMenu.addAction(cancelAction)
        // Display the menu
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func showCategoryMenu() {
        let categoryMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let trendingAction = UIAlertAction(title: "Trending", style: .default, handler:
            {(alert: UIAlertAction!) in self.category = ViewController.TRENDING; self.getArticlesFromSocket()})
        
        let hotAction = UIAlertAction(title: "Hot", style: .default, handler:
            {(alert: UIAlertAction!) in self.category = ViewController.HOT; self.getArticlesFromSocket()})
        
        let newAction = UIAlertAction(title: "New", style: .default, handler:
            {(alert: UIAlertAction!) in self.category = ViewController.NEW; self.getArticlesFromSocket()})
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
            nil)
        categoryMenu.addAction(trendingAction)
        categoryMenu.addAction(hotAction)
        categoryMenu.addAction(newAction)
        categoryMenu.addAction(cancelAction)
        // Display the menu
        self.present(categoryMenu, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showArticleDetail" {
            if let indexPath = self.table.indexPathForSelectedRow {
                let destinationController = segue.destination as!
                ArticleDetailViewController
                destinationController.article = articles[indexPath.section]
            }
        }
    }
}
