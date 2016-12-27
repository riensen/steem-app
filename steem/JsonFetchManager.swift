import Foundation
//import SocketRocket
//import SwiftyJSON


class JsonFetchManager : UIViewController, SRWebSocketDelegate {
//    
//  //  var ws : SRWebSocket;
//    
//    init(url:NSURL){
////        self.ws = SRWebSocket(URL: url)
////        super.init()
////        self.ws.delegate = self
////        self.ws.open()
//    }
//    
    
    public func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        let msg = JSON(parseJson: message as! String)
        print("received: " + msg.rawString()! )
        
        guard let num3 = msg["result"].arrayValue[0]["average_bandwidth"].int else {
            print(3)
            return
        }
        print(num3)
    }
    
    
     func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        print("open");
        //"{\"id\": 3, \"method\": \"call\", \"params\": [0, \"get_accounts\", [[\"ned\"]]]}"
        webSocket.send("{\"id\": 8, \"method\": \"call\", \"params\": [0, \"get_state\", [\"/hot/steemit\"]]}")
    }
}
