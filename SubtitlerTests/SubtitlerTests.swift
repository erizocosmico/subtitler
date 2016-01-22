//
//  SubtitlerTests.swift
//  SubtitlerTests
//
//  Created by Miguel on 22/01/16.
//  Copyright © 2016 mvader. All rights reserved.
//

import Foundation
import XCTest
@testable import Subtitler

class SubtitlerTests: XCTestCase {
    
    func file(name: String) -> String {
        return NSBundle(forClass: SubtitlerTests.self).resourcePath! + name
    }
    
    override func setUp() {
        super.setUp()
        
        let file = self.file("f1.txt")
        var txt = ""
        for _ in 1...105536 {
            txt += "a"
        }
        do {
            try txt.writeToFile(file, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {}
    }
    
    override func tearDown() {
        super.tearDown()
        
        let file = self.file("f1.txt")
        let fileManager = NSFileManager.defaultManager()
    
        do {
            try fileManager.removeItemAtPath(file)
        } catch {}
    }
    
    func testHashFile() {
        let file = self.file("f1.txt")
        let hash = Subtitler.fileHash(file)!
        XCTAssertEqual(hash.size, 105536)
        XCTAssertEqual(hash.hash, "585858585859dc40")
    }
    
}
