//
// TimePartTests.swift
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

class TimePartTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEachComponent() {
        let timePart = TimePart(hour: 3, minute: 5, second: 10, millisecond: 300)
        XCTAssertEqual(timePart.hourPart, 3)
        XCTAssertEqual(timePart.minutePart, 5)
        XCTAssertEqual(timePart.secondPart, 10)
        XCTAssertEqual(timePart.millisecondPart, 300)
    }
    
    func testParseArchiveValue1() {
        let timePart = TimePart(archiveValue: "12:34:56")
        XCTAssertEqual(timePart?.hourPart, 12)
        XCTAssertEqual(timePart?.minutePart, 34)
        XCTAssertEqual(timePart?.secondPart, 56)
        XCTAssertEqual(timePart?.millisecondPart, 0)
    }
    
    func testParseArchiveValue2() {
        let timePart = TimePart(archiveValue: "04:06:09.1234")
        XCTAssertEqual(timePart?.hourPart, 4)
        XCTAssertEqual(timePart?.minutePart, 6)
        XCTAssertEqual(timePart?.secondPart, 9)
        XCTAssertEqual(timePart?.millisecondPart, 123)
    }
    
    func testParseArchiveValue3() {
        let timePart = TimePart(archiveValue: "08:17:00+09:00")
        XCTAssertEqual(timePart?.hourPart, 8)
        XCTAssertEqual(timePart?.minutePart, 17)
        XCTAssertEqual(timePart?.secondPart, 0)
        XCTAssertEqual(timePart?.millisecondPart, 0)
    }
}
