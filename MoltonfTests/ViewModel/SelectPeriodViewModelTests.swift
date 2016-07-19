//
// SelectPeriodViewModelTests.swift
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
import Eventitic
import RxSwift
import RxCocoa
@testable import Moltonf

class SelectPeriodViewModelTests: XCTestCase {
    var disposeBag = DisposeBag()
    var selectPeriodViewModel: SelectPeriodViewModel! = nil
    
    class MockStoryWatching: StoryWatching {
        var _availablePeriodRefs: [PeriodReference] = []
        override var availablePeriodRefs: [PeriodReference] {
            get {
                return _availablePeriodRefs
            }
            set {
                _availablePeriodRefs = newValue
                availablePeriodRefsChanged.fire(availablePeriodRefs)
            }
        }

        var _currentPeriod: Period? = nil
        override var currentPeriod: Period? {
            get {
                return _currentPeriod
            }
            set {
                _currentPeriod = newValue
                currentPeriodChanged.fire(currentPeriod)
                
            }
        }
    }
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()

        let workspace = Workspace()
        let story = Story(villageFullName: "", graveIconURI: "")
        let storyWatching = MockStoryWatching(workspace: workspace, story: story)
        let periodRef0 = PeriodReference(story: story, type: .Prologue, day: 0, periodPath: "")
        let periodRef1 = PeriodReference(story: story, type: .Progress, day: 1, periodPath: "")
        let periodRef2 = PeriodReference(story: story, type: .Progress, day: 2, periodPath: "")
        let periodRef3 = PeriodReference(story: story, type: .Epilogue, day: 3, periodPath: "")
        storyWatching.availablePeriodRefs = [periodRef0, periodRef1, periodRef2, periodRef3]
        let period = Period(story: story, type: .Prologue, day: 0)
        storyWatching.currentPeriod = period
        selectPeriodViewModel = SelectPeriodViewModel(storyWatching: storyWatching)
    }
    
    func testPeriods() {
        let periodsExpectation = expectationWithDescription("periods")
        selectPeriodViewModel.periods
            .subscribeNext { items in
                XCTAssertEqual(items.map { $0.title }, ["Prologue", "Day 1", "Day 2", "Epilogue"])
                XCTAssertEqual(items.map { $0.checked }, [true, false, false, false])
                periodsExpectation.fulfill()
            }
            .addDisposableTo(disposeBag)
        
        waitForExpectationsWithTimeout(3.0) { error in }
    }
    
    func testResultSelected() {
        let resultExpectation = expectationWithDescription("result")
        selectPeriodViewModel.onResult = { result in
            switch result {
            case .Selected(let periodRef):
                XCTAssertEqual(periodRef.day, 2)
            default:
                XCTFail("the result should be .Selected")
            }
            resultExpectation.fulfill()
        }

        selectPeriodViewModel.selectAction
            .onNext(NSIndexPath(forRow: 2, inSection: 0))
        
        waitForExpectationsWithTimeout(3.0) { error in }
    }
    
    func testResultCancelled() {
        let resultExpectation = expectationWithDescription("result")
        selectPeriodViewModel.onResult = { result in
            switch result {
            case .Cancelled:
                break
            default:
                XCTFail("the result should be .Selected")
            }
            resultExpectation.fulfill()
        }
        
        selectPeriodViewModel.cancelAction
            .onNext(())
        
        waitForExpectationsWithTimeout(3.0) { error in }
    }
}
