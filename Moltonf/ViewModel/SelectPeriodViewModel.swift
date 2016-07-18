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

public class SelectPeriodViewModelItem {
    public let title: String
    public let checked: Bool
    
    public init(title: String, checked: Bool) {
        self.title = title
        self.checked = checked
    }
}

public class SelectPeriodViewModel: ViewModel {
    public let periods: Observable<[SelectPeriodViewModelItem]>
    public let cancelAction: AnyObserver<Void>
    public let selectAction: AnyObserver<NSIndexPath>
    
    public var onResult: (SelectPeriodViewModelResult -> Void)? = nil
    
    private let _listenerStore = ListenerStore()
    private let _storyWatching: StoryWatching
    private let _periods = Variable<([PeriodReference], Period?)>([], nil)
    private let _cancelAction = ActionObserver<Void>()
    private let _selectAction = ActionObserver<NSIndexPath>()
    
    public init(storyWatching: StoryWatching) {
        _storyWatching = storyWatching

        periods = _periods.asDriver().asObservable()
            .map { (periodList, currentPeriod) -> [SelectPeriodViewModelItem] in
                let currentDay = currentPeriod?.day ?? -1
                return periodList
                    .map { periodRef in
                        var title = ""
                        switch periodRef.type {
                        case .Prologue:
                            title = "Prologue"
                        case .Epilogue:
                            title = "Epilogue"
                        case .Progress:
                            title = "Day \(periodRef.day)"
                        }
                        let checked = periodRef.day == currentDay
                        return SelectPeriodViewModelItem(title: title, checked: checked)
                    }
            }
        cancelAction = _cancelAction.asObserver()
        selectAction = _selectAction.asObserver()
        
        super.init()

        _cancelAction.handler = { [weak self] in self?.cancel() }
        _selectAction.handler = { [weak self] indexPath in self?.select(indexPath) }

        _periods.value = (_storyWatching.availablePeriodRefs, _storyWatching.currentPeriod)
        _storyWatching.availablePeriodRefsChanged
            .listen { [weak self] _ in
                self?.updatePeriods()
            }
            .addToStore(_listenerStore)
        _storyWatching.currentPeriodChanged
            .listen { [weak self] _ in
                self?.updatePeriods()
            }
    }
    
    private func updatePeriods() {
        _periods.value = (_storyWatching.availablePeriodRefs, _storyWatching.currentPeriod)
    }
    
    private func cancel() {
        sendMessage(DismissingMessage())
        onResult?(.Cancelled)
    }
    
    private func select(indexPath: NSIndexPath) {
        sendMessage(DismissingMessage())
        let periodReference = _storyWatching.availablePeriodRefs[indexPath.row]
        onResult?(.Selected(periodReference))
    }
}
