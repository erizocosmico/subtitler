import Foundation
import Alamofire
import AlamofireXMLRPC

private let OpenSubtitlesApi: String = "http://api.opensubtitles.org/xml-rpc"

private enum Method: String {
    case LogIn, SearchSubtitles
}

public enum OpenSubtitlesError: ErrorType {
    case NotLoggedIn, Empty
    case RequestError(_: NSError)
    case StatusError(_: String)
}

private struct Status {
    var code: Int
    var msg: String
    var success: Bool {
        get {
            return code == 200
        }
    }
}

class OpenSubtitlesClient: NSObject {
    private var userAgent: String
    private var lang: String
    private var token: String = ""
    
    init(userAgent: String, lang: String) {
        self.userAgent = userAgent
        self.lang = lang
    }
    
    func login(onComplete: Result<String, OpenSubtitlesError> -> Void) {
        self.request(.LogIn, ["", "", self.lang, self.userAgent], onComplete: { response in
            switch response.result {
            case .Success(let node):
                let status = self.status(node)
                if status.success {
                    self.token = node[0]["token"].string!
                    onComplete(Result.Success(self.token))
                } else {
                    onComplete(Result.Failure(OpenSubtitlesError.StatusError(status.msg)))
                }
            case .Failure(let error):
                onComplete(Result.Failure(OpenSubtitlesError.RequestError(error)))
            }
        })
    }
    
    func searchSubtitle(hash: String, _ size: UInt64, onComplete: Result<String, OpenSubtitlesError> -> Void) {
        if self.token == "" {
            onComplete(Result.Failure(OpenSubtitlesError.NotLoggedIn))
            return
        }
        
        let params = ["moviehash": hash, "moviesize": size] as XMLRPCStructure
        self.request(.SearchSubtitles, [self.token, [params] as XMLRPCArray], onComplete: { response in
            switch response.result {
            case .Success(let node):
                let status = self.status(node)
                if status.success {
                    let data = node[0]["data"]
                    if let link = self.findSubtitle(data) {
                        onComplete(Result.Success(link))
                        return
                    }

                    onComplete(Result.Failure(OpenSubtitlesError.Empty))
                } else {
                    onComplete(Result.Failure(OpenSubtitlesError.StatusError(status.msg)))
                }
            case .Failure(let error):
                onComplete(Result.Failure(OpenSubtitlesError.RequestError(error)))
            }
        })
    }

    private func findSubtitle(subtitles: XMLRPCNode) -> String? {
        for i in 0..<subtitles.count! {
            let sub = subtitles[i]
            if sub["ISO639"].string! == self.lang {
                return sub["SubDownloadLink"].string!
            }
        }

        return nil
    }

    private func status(root: XMLRPCNode) -> Status {
        let status = root[0]["status"].string!
        let statusCode = Int(status.componentsSeparatedByString(" ")[0])!
        return Status(code: statusCode, msg: status)
    }

    private func request(method: Method, _ params: [Any], onComplete: Response<XMLRPCNode, NSError> -> Void)  {
        AlamofireXMLRPC.request(OpenSubtitlesApi, methodName:method.rawValue, parameters:params).responseXMLRPC(onComplete)
    }
    
}