//
// ArchiveTests.swift
// MoltonfTests
//
// Copyright (c) 2016 Hironori Ichimiya <hiron@hironytic.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import XCTest
@testable import Moltonf

class ArchiveTests: XCTestCase {
    var outDir: String = ""
    
    override func setUp() {
        super.setUp()
        
        outDir = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString)
            .stringByAppendingPathComponent("ArchiveTests")
        _ = try? NSFileManager.defaultManager().removeItemAtPath(outDir)
    }
    
    override func tearDown() {
        _ = try? NSFileManager.defaultManager().removeItemAtPath(outDir)
        
        super.tearDown()
    }

    func testConvertToJSON() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let archiveFilePath = bundle.pathForResource("jin_wolff_00000", ofType: "xml")!

        let converter = ArchiveToJSON(fromArchive: archiveFilePath, toDirectory: outDir)
        do {
            try converter.convert()
        } catch let error {
            XCTFail("error: \(error)")
        }
        
        let playdataFilePath = (outDir as NSString).stringByAppendingPathComponent("playdata.json")
        let data = NSData(contentsOfFile: playdataFilePath)
        let playdata = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions())) as? [String: AnyObject]
        XCTAssertNotNil(playdata)
        
        let landName = playdata![ArchiveKeys.LAND_NAME] as? String
        XCTAssertEqual(landName, "人狼BBS:F国")
        
        let vid = playdata![ArchiveKeys.VID] as? Int
        XCTAssertEqual(vid, 0)
        
        let isValid = playdata![ArchiveKeys.IS_VALID] as? Bool
        XCTAssertEqual(isValid, true)
    }
}
