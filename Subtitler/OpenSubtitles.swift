import Foundation
import Alamofire
import AlamofireXMLRPC

private let OpenSubtitlesApi: String = "http://api.opensubtitles.org/xml-rpc"

private enum Method: String {
    case Login, SearchSubtitles
}

class OpenSubtitlesClient: NSObject {
    private var userAgent: String
    private var lang: String
    private var token: String = ""
    
    init(userAgent: String, lang: String) {
        self.userAgent = userAgent
        self.lang = lang
    }
    
    func login() {
        self.request(.Login, ["", "", self.lang, self.userAgent])({response in
            // TODO: Do stuff
        })
    }
    
    func searchSubtitle(hash: String, _ size: UInt64) {
        let params = ["moviehash": hash, "moviesize": size] as XMLRPCStructure
        self.request(.SearchSubtitles, [self.token, [params]])({ response in
            // TODO: Do stuff
        })
    }
    
    private func request(method: Method, _ params: [Any]) -> (Response<XMLRPCNode, NSError> -> Void) -> Request {
        return AlamofireXMLRPC.request(OpenSubtitlesApi, methodName:method.rawValue, parameters:params).responseXMLRPC
    }
    
}