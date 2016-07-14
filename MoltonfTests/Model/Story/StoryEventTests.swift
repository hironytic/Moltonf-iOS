//
// StoryEventTests.swift
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
import SwiftyJSON
@testable import Moltonf

private typealias K = ArchiveConstants

class StoryEventTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAnnounceEvent() {
        let story = Story(villageFullName: "", graveIconURI: "")
        let period = Period(story: story, type: .Prologue, day: 0)
        
        let element = JSON([
            K.TYPE: "startEntry",
            K.LINES: [
                "昼間は人間のふりをして、夜に正体を現すという人狼。",
                "その人狼が、この村に紛れ込んでいるという噂が広がった。",
                "",
                "村人達は半信半疑ながらも、村はずれの宿に集められることになった。",
                "",
            ],
        ])
 
        guard let event = try? StoryEvent(period: period, element: element) else {
            XCTFail("Error")
            return
        }
        
        XCTAssertEqual(event.eventFamily, EventFamily.Announce)
        XCTAssertTrue(event.period === period)
        XCTAssertTrue(event.story === story)
        XCTAssertEqual(event.messageLines[0], "昼間は人間のふりをして、夜に正体を現すという人狼。")
    }
    
    func testOrderEvent() {
        let story = Story(villageFullName: "", graveIconURI: "")
        let period = Period(story: story, type: .Prologue, day: 0)

        let element = JSON([
            K.TYPE: "askCommit",
            K.LIMIT_VOTE: "23:00:00+09:00",
            K.LIMIT_SPECIAL: "23:00:00+09:00",
            K.LINES: [
                "午後 11時 0分 までに、誰を処刑するべきかの投票先を決定して下さい。",
                "一番票を集めた人物が処刑されます。同数だった場合はランダムで決定されます。",
                "",
                "特殊な能力を持つ人は、午後 11時 0分 までに行動を確定して下さい。",
                "",
            ],
        ])
        
        guard let event = try? StoryEvent(period: period, element: element) else {
            XCTFail("Error")
            return
        }
        
        XCTAssertEqual(event.eventFamily, EventFamily.Order)
        XCTAssertTrue(event.period === period)
        XCTAssertTrue(event.story === story)
        XCTAssertEqual(event.messageLines[0], "午後 11時 0分 までに、誰を処刑するべきかの投票先を決定して下さい。")
    }
    
    func testExtraEvent() {
        let story = Story(villageFullName: "", graveIconURI: "")
        let period = Period(story: story, type: .Prologue, day: 0)

        let element = JSON([
            K.TYPE: "guard",
            K.BY_WHOM: "jacob",
            K.TARGET: "peter",
            K.LINES: [
                "農夫 ヤコブ は、少年 ペーター を守っている。",
            ],
        ])
        
        guard let event = try? StoryEvent(period: period, element: element) else {
            XCTFail("Error")
            return
        }
        
        XCTAssertEqual(event.eventFamily, EventFamily.Extra)
        XCTAssertTrue(event.period === period)
        XCTAssertTrue(event.story === story)
        XCTAssertEqual(event.messageLines[0], "農夫 ヤコブ は、少年 ペーター を守っている。")
    }
}
