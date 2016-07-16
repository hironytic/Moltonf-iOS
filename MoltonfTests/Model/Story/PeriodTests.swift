//
// PeriodTests.swift
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

class PeriodTests: XCTestCase {
    func testProgress() {
        let story = Story(villageFullName: "", graveIconURI: "")
        let periodJSON = JSON([
            "type": "progress",
            "day": 1,
            "nextCommitDay": "--05-28+09:00",
            "commitTime": "20:30:00+09:00",
            "sourceURI": "index.rb?vid=1100&meslog=1100_progress_0&mes=all",
            "elements": [
                [
                    "type": "startMirror",
                    "lines": [
                    "さあ、自らの姿を鏡に映してみよう。",
                    "そこに映るのはただの村人か、それとも血に飢えた人狼か。",
                    "",
                    "例え人狼でも、多人数で立ち向かえば怖くはない。",
                    "問題は、だれが人狼なのかという事だ。",
                    "占い師の能力を持つ人間ならば、それを見破れるだろう。"
                    ]
                ],
                [
                    "type": "openRole",
                    "roleHeads": [
                        "innocent": 7,
                        "wolf": 3,
                        "seer": 1,
                        "shaman": 1,
                        "madman": 1,
                        "hunter": 1,
                        "frater": 2
                    ],
                    "lines": [
                    "どうやらこの中には、村人が7名、人狼が3名、占い師が1名、霊能者が1名、狂人が1名、狩人が1名、共有者が2名いるようだ。"
                    ]
                ]
            ]
        ])
        
        guard let period = try? Period(story: story, period: periodJSON) else {
            XCTFail("Error")
            return
        }
        
        XCTAssertEqual(period.type, PeriodType.Progress)
        XCTAssertTrue(period.story === story)
        XCTAssertEqual(period.day, 1)
        guard let event = period.elements[0] as? StoryEvent else {
            XCTFail("It should be StoryEvent")
            return
        }
        XCTAssertEqual(event.eventFamily, EventFamily.Announce)
    }
    
}
