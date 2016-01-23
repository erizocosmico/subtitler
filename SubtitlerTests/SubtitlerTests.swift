import XCTest
@testable import Subtitler

class SubtitlerTests: XCTestCase {
    
    func testSubtitlesPath() {
        XCTAssertEqual(subtitlesPath("/var/foo/my_cool_movie.mp4"), "/var/foo/my_cool_movie.srt")
        XCTAssertEqual(subtitlesPath("/var/foo/my_cool_movie"), "/var/foo/my_cool_movie.srt")
    }
    
}
