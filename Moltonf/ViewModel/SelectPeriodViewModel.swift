//
// SelectPeriodViewModel.swift
// Moltonf
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

import Foundation
import Eventitic
import RxCocoa
import RxSwift

public enum SelectPeriodViewModelResult {
    case Selected(PeriodReference)
    case Cancelled
}

public class SelectPeriodViewModel: ViewModel {
    public let periods: Observable<[String]>
    public let cancelAction: AnyObserver<Void>
    public let selectAction: AnyObserver<NSIndexPath>
    
    public var onResult: (SelectPeriodViewModelResult -> Void)? = nil
    
    private let _storyWatching: StoryWatching
    private let _periods = Variable<[PeriodReference]>([])
    private let _cancelAction = ActionObserver<Void>()
    private let _selectAction = ActionObserver<NSIndexPath>()
    
    public init(storyWatching: StoryWatching) {
        _storyWatching = storyWatching
        
        periods = _periods.asDriver().asObservable()
            .map { periodList -> [String] in
                return periodList
                    .map { periodRef in
                        var text = ""
                        switch periodRef.type {
                        case .Prologue:
                            text = "Prologue"
                        case .Epilogue:
                            text = "Epilogue"
                        case .Progress:
                            text = "Day \(periodRef.day)"
                        }
                        return text
                    }
            }
        cancelAction = _cancelAction.asObserver()
        selectAction = _selectAction.asObserver()
        
        super.init()
        
        // TODO:
        
    }
}
