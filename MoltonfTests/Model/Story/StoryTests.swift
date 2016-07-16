//
// StoryTests.swift
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

class StoryTests: XCTestCase {
    func testStory() {
        let storyJSON = JSON([
            "base": "http://ninjin002.x0.com/wolff/",
            "fullName": "F1100 見捨てられた村",
            "vid": "1100",
            "commitTime": "20:30:00+09:00",
            "state": "gameover",
            "isValid": true,
            "landName": "人狼BBS:F国",
            "formalName": "人狼BBS:F",
            "landId": "wolff",
            "landPrefix": "F",
            "locale": "ja-JP",
            "origencoding": "Shift_JIS",
            "timezone": "GMT+09:00",
            "graveIconURI": "plugin_wolf/img/face99.jpg",
            "generator": "JinArchiver 1.502.2",
            "avatarList": [
                [
                    "avatarId": "gerd",
                    "fullName": "楽天家 ゲルト",
                    "shortName": "ゲルト",
                    "faceIconURI": "plugin_wolf/img/face01.jpg"
                ],
                [
                "avatarId": "peter",
                "fullName": "少年 ペーター",
                "shortName": "ペーター",
                "faceIconURI": "plugin_wolf/img/face08.jpg"
                ]
            ],
            "periods": [
                [
                "type": "prologue",
                "day": 0,
                "nextCommitDay": "--05-28+09:00",
                "commitTime": "20:30:00+09:00",
                "sourceURI": "index.rb?vid=1100&meslog=1100_ready_0&mes=all",
                "href": "period0.json"
                ],
                [
                "type": "progress",
                "day": 1,
                "nextCommitDay": "--05-28+09:00",
                "commitTime": "20:30:00+09:00",
                "sourceURI": "index.rb?vid=1100&meslog=1100_progress_0&mes=all",
                "href": "period1.json"
                ]
            ]
        ])
        
        guard let story = try? Story(playdata: storyJSON) else {
            XCTFail("Error")
            return
        }
        
        XCTAssertEqual(story.villageFullName, "F1100 見捨てられた村")
        XCTAssertEqual(story.graveIconURI, "plugin_wolf/img/face99.jpg")
        XCTAssertEqual(story.avatarList.count, 2)
        XCTAssertEqual(story.avatarList[0].avatarId, "gerd")
        XCTAssertEqual(story.periodRefs.count, 2)
        XCTAssertEqual(story.periodRefs[0].type, PeriodType.Prologue)
        XCTAssertEqual(story.periodRefs[0].periodPath, "period0.json")
    }
}
