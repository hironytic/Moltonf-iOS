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
import RxCocoa
import RxSwift

public enum SelectPeriodViewModelResult {
    case selected(PeriodReference)
    case cancelled
}

public struct SelectPeriodViewModelItem {
    public let periodReference: PeriodReference
    public let title: String
    public let checked: Bool
}

open class SelectPeriodViewModel: ViewModel {
    open let periodsLine: Observable<[SelectPeriodViewModelItem]>
    open let cancelAction: AnyObserver<Void>
    open let selectAction: AnyObserver<SelectPeriodViewModelItem>
    
    open var onResult: ((SelectPeriodViewModelResult) -> Void)? = nil
    
    fileprivate let _disposeBag = DisposeBag()
    fileprivate let _storyWatching: IStoryWatching
    fileprivate let _cancelAction = ActionObserver<Void>()
    fileprivate let _selectAction = ActionObserver<SelectPeriodViewModelItem>()
    
    public init(storyWatching: IStoryWatching) {
        _storyWatching = storyWatching

        periodsLine = Observable
            .combineLatest(_storyWatching.availablePeriodRefsLine, _storyWatching.currentPeriodLine, resultSelector: { ($0, $1) })
            .asDriver(onErrorDriveWith: Driver.empty())
            .asObservable()
            .map { (periodList, currentPeriod) -> [SelectPeriodViewModelItem] in
                let currentDay = currentPeriod.day ?? -1
                return periodList
                    .map { periodRef in
                        var title = ""
                        switch periodRef.type {
                        case .prologue:
                            title = "Prologue"
                        case .epilogue:
                            title = "Epilogue"
                        case .progress:
                            title = "Day \(periodRef.day)"
                        }
                        let checked = periodRef.day == currentDay
                        return SelectPeriodViewModelItem(periodReference: periodRef, title: title, checked: checked)
                    }
            }
        cancelAction = _cancelAction.asObserver()
        selectAction = _selectAction.asObserver()
        
        super.init()

        _cancelAction.handler = { [weak self] in self?.cancel() }
        _selectAction.handler = { [weak self] item in self?.select(item) }
    }
    
    fileprivate func cancel() {
        sendMessage(DismissingMessage())
        onResult?(.cancelled)
    }
    
    fileprivate func select(_ item: SelectPeriodViewModelItem) {
        sendMessage(DismissingMessage())
        onResult?(.selected(item.periodReference))
    }
}
