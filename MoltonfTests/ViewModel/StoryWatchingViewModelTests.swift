//
// StoryWatchingViewModelTests.swift
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
import RxSwift
@testable import Moltonf

class StoryWatchingViewModelTests: XCTestCase {

    var disposeBag = DisposeBag()
    var workspace = Workspace()
    var story: Story!
    var availablePeriodRefs: [PeriodReference] = []
    
    override func setUp() {
        super.setUp()
        
        disposeBag = DisposeBag()
        workspace = Workspace()
        story = Story(villageFullName: "", graveIconURI: "")
        let periodRef0 = PeriodReference(story: story, type: .Prologue, day: 0, periodPath: "")
        let periodRef1 = PeriodReference(story: story, type: .Progress, day: 1, periodPath: "")
        let periodRef2 = PeriodReference(story: story, type: .Progress, day: 2, periodPath: "")
        let periodRef3 = PeriodReference(story: story, type: .Epilogue, day: 3, periodPath: "")
        availablePeriodRefs = [periodRef0, periodRef1, periodRef2, periodRef3]
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSelectPeriod() {
        class MockStoryWatching: StoryWatching {
            let period0: Period
            let period1: Period
            
            let tests: StoryWatchingViewModelTests
            init(tests: StoryWatchingViewModelTests) {
                self.tests = tests
                period0 = Period(story: tests.story, type: .Prologue, day: 0)
                period1 = Period(story: tests.story, type: .Progress, day: 1)

                super.init(workspace: tests.workspace, story: tests.story)
                
                currentPeriod = period0
            }
            override var availablePeriodRefs: [PeriodReference] {
                get {
                    return tests.availablePeriodRefs
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
            
            override func selectPeriod(periodRef: PeriodReference) {
                switch periodRef.day {
                case 0:
                    currentPeriod = period0
                case 1:
                    currentPeriod = period1
                default:
                    break
                }
            }
        }
        
        let storyWatching = MockStoryWatching(tests: self)
        let storyWatchingViewModel = StoryWatchingViewModel(storyWatching: storyWatching)
        
        // -- initially Prologue is selected
        
        let currentPeriodTextObserver = FulfillObserver(expectationWithDescription("initial text")) { $0 == "Prologue" }
        storyWatchingViewModel.currentPeriodText
            .bindTo(currentPeriodTextObserver)
            .addDisposableTo(disposeBag)
        
        waitForExpectationsWithTimeout(1.0, handler: nil)

        // -- user taps "select period" button -> "Select Period" view appears
        
        var selectPeriodViewModel: SelectPeriodViewModel? = nil
        let messageObserver = FulfillObserver(expectationWithDescription("transition message")) { (message: Message) in
            if let transitionMessage = message as? TransitionMessage {
                if let viewModel = transitionMessage.viewModel as? SelectPeriodViewModel {
                    selectPeriodViewModel = viewModel
                    return true
                }
            }
            return false
        }
        storyWatchingViewModel.messenger
            .bindTo(messageObserver)
            .addDisposableTo(disposeBag)
    
        storyWatchingViewModel.selectPeriodAction.onNext(())
        waitForExpectationsWithTimeout(1.0, handler: nil)

        // -- user selects second period, Day 1
        
        XCTAssertNotNil(selectPeriodViewModel)
        XCTAssertNotNil(selectPeriodViewModel?.onResult)

        currentPeriodTextObserver.reset(expectationWithDescription("day 1")) { $0 == "Day 1" }
        selectPeriodViewModel?.onResult?(.Selected(availablePeriodRefs[1]))
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}
