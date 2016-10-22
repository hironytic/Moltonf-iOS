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
import RxSwift
import RxCocoa
@testable import Moltonf

class SelectPeriodViewModelTests: XCTestCase {
    var disposeBag = DisposeBag()
    var selectPeriodViewModel: SelectPeriodViewModel! = nil
    var mockStoryWatching: MockStoryWatching! = nil
    
    class MockStoryWatching: IStoryWatching {
        var errorLine = Observable<Error>.never()
        var titleLine = Observable<String>.never()
        var availablePeriodRefsLine: Observable<[PeriodReference]>
        var currentPeriodLine: Observable<Period>
        var storyElementsLine = Observable<[StoryElement]>.never()
        
        var selectPeriodAction: AnyObserver<PeriodReference>
        var switchToNextPeriodAction: AnyObserver<Void>
        
        var _selectPeriodAction = ActionObserver<PeriodReference>()
        var _switchToNextPeriodAction = ActionObserver<Void>()
        
        let periodRef0: PeriodReference
        let periodRef1: PeriodReference
        let periodRef2: PeriodReference
        let periodRef3: PeriodReference
        
        init() {
            selectPeriodAction = _selectPeriodAction.asObserver()
            switchToNextPeriodAction = _switchToNextPeriodAction.asObserver()
            
            let story = Story(villageFullName: "", graveIconURI: "")
            periodRef0 = PeriodReference(story: story, type: .prologue, day: 0, periodPath: "")
            periodRef1 = PeriodReference(story: story, type: .progress, day: 1, periodPath: "")
            periodRef2 = PeriodReference(story: story, type: .progress, day: 2, periodPath: "")
            periodRef3 = PeriodReference(story: story, type: .epilogue, day: 3, periodPath: "")
            let period = Period(story: story, type: .prologue, day: 0)
            
            self.availablePeriodRefsLine = Observable.just([periodRef0, periodRef1, periodRef2, periodRef3])
            self.currentPeriodLine = Observable.just(period)
        }
    }
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()

        mockStoryWatching = MockStoryWatching()
        selectPeriodViewModel = SelectPeriodViewModel(storyWatching: mockStoryWatching)
    }
    
    func testPeriods() {
        let periodsObserver = FulfillObserver(expectation(description: "periods")) { (items: [SelectPeriodViewModelItem]) in
            return items.map({ $0.title }) == ["Prologue", "Day 1", "Day 2", "Epilogue"]
                && items.map({ $0.checked }) == [true, false, false, false]
        }
        selectPeriodViewModel.periodsLine
            .bindTo(periodsObserver)
            .addDisposableTo(disposeBag)
        
        waitForExpectations(timeout: 3.0) { error in }
    }
    
    func testResultSelected() {
        let resultExpectation = expectation(description: "result")
        selectPeriodViewModel.onResult = { result in
            switch result {
            case .selected(let periodRef):
                XCTAssertEqual(periodRef.day, 2)
            default:
                XCTFail("the result should be .Selected")
            }
            resultExpectation.fulfill()
        }
        
        selectPeriodViewModel.periodsLine
            .subscribe(onNext: { [unowned self] items in
                self.selectPeriodViewModel.selectAction.onNext(items[2])
            })
            .addDisposableTo(disposeBag)

        waitForExpectations(timeout: 3.0) { error in }
    }
    
    func testResultCancelled() {
        let resultExpectation = expectation(description: "result")
        selectPeriodViewModel.onResult = { result in
            switch result {
            case .cancelled:
                break
            default:
                XCTFail("the result should be .Selected")
            }
            resultExpectation.fulfill()
        }
        
        selectPeriodViewModel.cancelAction
            .onNext(())
        
        waitForExpectations(timeout: 3.0) { error in }
    }
}
