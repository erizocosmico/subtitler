import Foundation
import Alamofire
import GZIP

public enum SubtitlerError: ErrorType {
    case UnableToWrite, UnknownError, NotReady, UnableToGetHash, UnzipError
    case ClientError(_: OpenSubtitlesError)
    case DownloadError(_: NSError)
}

private func unzip(data: NSData, to: String) -> Bool {
    if !data.isGzippedData() {
        return false
    }

    if let content = data.gunzippedData() {
        return content.writeToFile(to, atomically: true)
    } else {
        return false
    }
}

public func subtitlesPath(path: String) -> String {
    if let idx = path.characters.reverse().indexOf(".") {
        return path[path.startIndex ..< idx.base] + "srt"
    }
    return path + ".srt"
}

public class Subtitler: NSObject {
    var lang: String
    var userAgent: String
    var client: OpenSubtitlesClient
    var loggedIn: Bool = false

    public init(lang: String, userAgent: String) {
        self.lang = lang
        self.userAgent = userAgent
        self.client = OpenSubtitlesClient(userAgent: userAgent, lang: lang)
    }

    private func login(onComplete: OpenSubtitlesError? -> Void) {
        self.client.login { result in
            switch result {
            case .Success(_):
                self.loggedIn = true
                onComplete(nil)
            case .Failure(let error):
                onComplete(error)
            }
        }
    }

    private func downloadSubtitlesFile(url: String, _ path: String, _ onComplete: Result<String, SubtitlerError> -> Void) {
        Alamofire.request(.GET, url).response { (_, _, data, error) in
            if error != nil {
                onComplete(Result.Failure(SubtitlerError.DownloadError(error!)))
            } else if data != nil {
                if unzip(data!, to: path) {
                    onComplete(Result.Success(path))
                } else {
                    onComplete(Result.Failure(SubtitlerError.UnzipError))
                }
            } else {
                onComplete(Result.Failure(SubtitlerError.UnknownError))
            }
        }
    }

    private func searchSubtitles(path: String, _ lang: String, _ onComplete: Result<String, SubtitlerError> -> Void) {
        if let fh = fileHash(path) {
            self.client.searchSubtitle(fh.hash, fh.size, lang) { result in
                switch result {
                case .Success(let url):
                    let finalPath = subtitlesPath(path)
                    self.downloadSubtitlesFile(url, finalPath, onComplete)
                case .Failure(let error):
                    onComplete(Result.Failure(SubtitlerError.ClientError(error)))
                }
            }
        } else {
            onComplete(Result.Failure(SubtitlerError.UnableToGetHash))
        }
    }

    public func download(path: String, onComplete: Result<String, SubtitlerError> -> Void) {
        download(path, lang: self.lang, onComplete: onComplete)
    }

    public func download(path: String, lang: String, onComplete: Result<String, SubtitlerError> -> Void) {
        if !self.loggedIn {
            self.login { err in
                if let error = err {
                    onComplete(Result.Failure(SubtitlerError.ClientError(error)))
                } else {
                    self.searchSubtitles(path, lang, onComplete)
                }
            }
        } else {
            self.searchSubtitles(path, lang, onComplete)
        }
    }
}