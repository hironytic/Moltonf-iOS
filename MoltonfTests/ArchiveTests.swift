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
import XMLPullitic
@testable import Moltonf

private class MockJSONWriter: ArchiveJSONWriter {
    var output: [(fileName: String, object: [String: AnyObject])] = []
    func writeArchiveJSON(fileName fileName: String, object: [String: AnyObject]) throws {
        output.append((fileName: fileName, object: object))
    }
}

private enum TestError: ErrorType {
    case CreateParser
}

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
            return
        }
        
        let playdataFilePath = (outDir as NSString).stringByAppendingPathComponent("playdata.json")
        let data = NSData(contentsOfFile: playdataFilePath)
        let playdata = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions())) as? [String: AnyObject]
        XCTAssertNotNil(playdata)
        
        let landName = playdata?[ArchiveKeys.LAND_NAME] as? String
        XCTAssertEqual(landName, "人狼BBS:F国")
    }
    
    func setupTargetElement(xml: String) throws -> (parser: XMLPullParser, element: XMLElement) {
        guard let parser = XMLPullParser(string: xml) else {
            throw TestError.CreateParser
        }
        parser.shouldProcessNamespaces = true

        while true {
            switch try parser.next() {
            case .StartElement(name: _, namespaceURI: _, element: let element):
                return (parser: parser, element: element)
            default:
                break
            }
        }
    }
    
    func testConvertVillage() {
        do {
            let (parser, element) = try setupTargetElement(
                "<village\n" +
                "  xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\"\n" +
                "  xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n" +
                "  xmlns:xlink=\"http://www.w3.org/1999/xlink\"\n" +
                "  xsi:schemaLocation=\"http://jindolf.sourceforge.jp/xml/ns/401 http://jindolf.sourceforge.jp/xml/xsd/bbsArchive-091001.xsd\"\n" +
                "  xml:lang=\"ja-JP\"\n" +
                "  xml:base=\"http://192.168.150.129/moltonf/\"\n" +
                "  fullName=\"F0 テスト用の村\" vid=\"0\"\n" +
                "  commitTime=\"08:15:00+09:00\"\n" +
                "  state=\"gameover\" isValid=\"true\"\n" +
                "  landName=\"人狼BBS:F国\" formalName=\"人狼BBS:F\"\n" +
                "  landId=\"wolff\" landPrefix=\"F\"\n" +
                "  locale=\"ja-JP\" origencoding=\"Shift_JIS\" timezone=\"GMT+09:00\"\n" +
                "  graveIconURI=\"plugin_wolf/img/face99.jpg\"\n" +
                "  generator=\"nobody1.0\"\n" +
                ">\n" +
                "  <avatarList>\n" +
                "    <avatar\n" +
                "      avatarId=\"gerd\"\n" +
                "      fullName=\"楽天家 ゲルト\" shortName=\"ゲルト\"\n" +
                "      faceIconURI=\"plugin_wolf/img/face01.jpg\"\n" +
                "    />\n" +
                "  </avatarList>\n" +
                "</village>\n"
            )
            
            let writer = MockJSONWriter()
            try ArchiveToJSON.VillageElementConverter(parser: parser).convert(element, writer: writer)
            
            let output = writer.output[0]
            let playdata = output.object

            XCTAssertEqual(output.fileName, "playdata.json")
            
            let landName = playdata[ArchiveKeys.LAND_NAME] as? String
            XCTAssertEqual(landName, "人狼BBS:F国")
            
            let vid = playdata[ArchiveKeys.VID] as? Int
            XCTAssertEqual(vid, 0)
            
            let isValid = playdata[ArchiveKeys.IS_VALID] as? Bool
            XCTAssertEqual(isValid, true)
            
            let avatarList = playdata[ArchiveKeys.AVATAR_LIST] as? [[String: AnyObject]]
            XCTAssertNotNil(avatarList)
        } catch let error {
            XCTFail("error: \(error)")
            return
        }
    }
}
