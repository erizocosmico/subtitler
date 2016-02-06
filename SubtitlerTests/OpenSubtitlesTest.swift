import XCTest
@testable import Subtitler

private let testUserAgent = "OSTestUserAgent"
private let testFileSize: UInt64 = 231351520
private let testFileHash = "7f735dbc67e62e42"

class OpenSubtitlesTest: XCTestCase {

    func testLogin() {
        let readyExpectation = expectationWithDescription("ready")
        let client = OpenSubtitlesClient(userAgent: testUserAgent, lang:"es")
        client.login({ result in
            switch result {
            case .Failure(_):
                XCTAssertTrue(false)
            case .Success(let token):
                XCTAssertNotEqual(token, "")
            }

            readyExpectation.fulfill()
        })

        waitForExpectationsWithTimeout(25, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }

    func testSearchSubtitle() {
        let readyExpectation = expectationWithDescription("ready")
        let client = OpenSubtitlesClient(userAgent: testUserAgent, lang:"es")
        client.login({ result in
            switch result {
            case .Failure(_):
                XCTAssertTrue(false)
            case .Success(let token):
                client.searchSubtitle(testFileHash, testFileSize, "es", onComplete: { result in
                    switch result {
                    case .Failure(_):
                        XCTAssertTrue(false)
                    case .Success(let link):
                        XCTAssertEqual(link, "http://dl.opensubtitles.org/en/download/file/src-api/vrf-19aa0c55/sid-"+token+"/1955051666.gz")
                    }
                    readyExpectation.fulfill()
                })
            }
        })

        waitForExpectationsWithTimeout(25, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    
}
