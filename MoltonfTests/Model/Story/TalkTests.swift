//
// TalkTests.swift
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

class TalkTests: XCTestCase {
    class MockStory: Story {
        var avatarGerd: Avatar!
        var avatarPeter: Avatar!
        override var avatarList: [Avatar] {
            get {
                return [
                    avatarGerd,
                    avatarPeter,
                ]
            }
        }
        
        override func avatar(havingId avatarId: String) -> Avatar? {
            switch avatarId {
            case "gerd":
                return avatarGerd
            case "peter":
                return avatarPeter
            default:
                return nil
            }
        }
        
        init() {
            super.init(villageFullName: "", graveIconURI: "")
            avatarGerd = Avatar(story: self, avatarId: "gerd", fullName: "楽天家 ゲルト", shortName: "ゲルト", faceIconURI: "plugin_wolf/img/face01.jpg")
            avatarPeter = Avatar(story: self, avatarId: "peter", fullName: "少年 ペーター", shortName: "ペーター", faceIconURI: "plugin_wolf/img/face08.jpg")
        }
    }
    
    var story: MockStory!
    
    override func setUp() {
        super.setUp()
        self.story = MockStory()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testPublicTalk() {
        let period = Period(story: story, type: .Prologue, day: 0)
        
        let element = JSON([
            K.TYPE: "talk",
            K.TALK_TYPE: "public",
            K.AVATAR_ID: "gerd",
            K.XNAME: "mes1179549002",
            K.TIME: "13:30:00+09:00",
            K.LINES: [
                "人狼なんているわけないじゃん。みんな大げさだなあ",
                "",
            ],
        ])
        
        guard let talk = try? Talk(period: period, element: element) else {
            XCTFail("Error")
            return
        }
        
        XCTAssertEqual(talk.talkType, TalkType.Public)
        XCTAssertTrue(talk.speaker === story.avatarGerd)
        XCTAssertEqual(talk.time.hourPart, 13)
        XCTAssertEqual(talk.time.minutePart, 30)
        XCTAssertEqual(talk.time.secondPart, 0)
        XCTAssertEqual(talk.time.millisecondPart, 0)
        XCTAssertTrue(talk.period === period)
        XCTAssertTrue(talk.story === story)
        XCTAssertEqual(talk.messageLines[0], "人狼なんているわけないじゃん。みんな大げさだなあ")
    }
    
    func testTalkWithRawdata() {
        let period = Period(story: story, type: .Prologue, day: 0)
        
        let element = JSON([
            K.TYPE: "talk",
            K.TALK_TYPE: "wolf",
            K.AVATAR_ID: "peter",
            K.XNAME: "mes1181841039",
            K.TIME: "02:10:00+09:00",
            K.LINES: [
                [
                    "パメおかえりー。",
                    [
                        K.ENCODING: "Shift_JIS",
                        K.HEX_BIN: "8794",
                        K.CHAR: "∑",
                    ],
                    "閉村までって！"
                ],
                "",
                "＞フリーデル",
                "大丈夫。親子愛だから。危ない関係はディタとかでお腹いっぱいだから。",
            ],
        ])
        
        guard let talk = try? Talk(period: period, element: element) else {
            XCTFail("Error")
            return
        }
        
        XCTAssertEqual(talk.talkType, TalkType.Wolf)
        XCTAssertTrue(talk.speaker === story.avatarPeter)
        XCTAssertEqual(talk.messageLines[0], "パメおかえりー。∑閉村までって！")
    }
    
    func testTalkOfWolfsAttack() {
        let period = Period(story: story, type: .Progress, day: 2)

        let element = JSON([
            K.TYPE: "assault",
            K.BY_WHOM: "peter",
            K.TARGET: "simon",
            K.XNAME: "mes1268151301",
            K.TIME: "01:15:00+09:00",
            K.LINES: [
                "負傷兵 シモン ！ 今日がお前の命日だ！",
            ],
        ])
        
        guard let talk = try? WolfAttackTalk(period: period, element: element) else {
            XCTFail("Error")
            return
        }
        
        XCTAssertEqual(talk.talkType, TalkType.Wolf)
        XCTAssertTrue(talk.speaker === story.avatarPeter)
        XCTAssertEqual(talk.time.hourPart, 1)
        XCTAssertEqual(talk.time.minutePart, 15)
        XCTAssertEqual(talk.time.secondPart, 0)
        XCTAssertEqual(talk.time.millisecondPart, 0)
        XCTAssertTrue(talk.period === period)
        XCTAssertTrue(talk.story === story)
        XCTAssertEqual(talk.messageLines[0], "負傷兵 シモン ！ 今日がお前の命日だ！")
    }
}
