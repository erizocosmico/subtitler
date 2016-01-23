import XCTest
@testable import Subtitler

class SubtitlerTests: XCTestCase {
    
    func testSubtitlesPath() {
        XCTAssertEqual(subtitlesPath("/var/foo/my_cool_movie.mp4"), "/var/foo/my_cool_movie.srt")
        XCTAssertEqual(subtitlesPath("/var/foo/my_cool_movie"), "/var/foo/my_cool_movie.srt")
    }

    // This test is only for checking the whole thing works, use it with a movie or tv show in your device
    // since the repository will not contain any of these files
    func testDownloadSubtitles() {
        let path = "YOUR FILE PATH HERE"
        let expectedPath = "YOUR EXPECTED FILE PATH HERE"
        let ready = expectationWithDescription("ready")
        let cli = Subtitler(lang: "es", userAgent: "OSTestUserAgent")
        cli.download(path) { result in
            switch result {
            case .Success(let path):
                XCTAssertEqual(path, expectedPath)
            case .Failure(let err):
                XCTAssertNil(err)
            }
            ready.fulfill()
        }

        waitForExpectationsWithTimeout(25, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    
}
