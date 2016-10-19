//
// StoryWatchingViewModel.swift
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
import RxSwift
import RxCocoa

public protocol IStoryWatchingViewModel: IViewModel {
    var currentPeriodTextLine: Observable<String> { get }
    var elementsListLine: Observable<[IStoryElementViewModel]> { get }
    var selectPeriodAction: AnyObserver<Void> { get }
    var leaveWatchingAction: AnyObserver<Void> { get }
}

public class StoryWatchingViewModel: ViewModel, IStoryWatchingViewModel {
    public private(set) var currentPeriodTextLine: Observable<String>
    public private(set) var elementsListLine: Observable<[IStoryElementViewModel]>
    public private(set) var selectPeriodAction: AnyObserver<Void>
    public private(set) var leaveWatchingAction: AnyObserver<Void>

    private let _factory: Factory
    private let _storyWatching: IStoryWatching
    private let _selectPeriodAction = ActionObserver<Void>()
    private let _leaveWatchingAction = ActionObserver<Void>()
    
    class Factory {
        func storyEventViewModel(storyEvent: StoryEvent) -> IStoryEventViewModel {
            return StoryEventViewModel(storyEvent: storyEvent)
        }
        func talkViewModel(talk: Talk) -> ITalkViewModel {
            return TalkViewModel(talk: talk)
        }
        func selectPeriodViewModel(storyWatching: IStoryWatching) -> ISelectPeriodViewModel {
            return SelectPeriodViewModel(storyWatching: storyWatching)
        }
    }
    
    public convenience init(storyWatching: IStoryWatching) {
        self.init(storyWatching: storyWatching, factory: Factory())
    }
    init(storyWatching: IStoryWatching, factory: Factory) {
        _factory = factory
        _storyWatching = storyWatching

        currentPeriodTextLine = type(of: self).configureCurrentPeriodTextLine(_storyWatching.currentPeriodLine)
        elementsListLine = type(of: self).configureElementsListLine(_storyWatching.storyElementsLine, factory: _factory)
        selectPeriodAction = _selectPeriodAction.asObserver()
        leaveWatchingAction = _leaveWatchingAction.asObserver()
        
        super.init()

        _selectPeriodAction.handler = { [weak self] in self?.selectPeriod() }
        _leaveWatchingAction.handler = { [weak self] in self?.leaveWatching() }
    }
    
    private static func configureCurrentPeriodTextLine(_ currentPeriodLine: Observable<Period>) -> Observable<String> {
        return currentPeriodLine
            .map { period in
                return { () -> String in
                    switch period.type {
                    case .prologue:
                        return "Prologue"
                    case .epilogue:
                        return "Epilogue"
                    case .progress:
                        return "Day \(period.day)"
                    }
                }()
            }
            .asDriver(onErrorJustReturn: "").asObservable()
    }
    
    private static func configureElementsListLine(_ storyElementsLine: Observable<[StoryElement]>, factory: Factory) -> Observable<[IStoryElementViewModel]> {
        return storyElementsLine
            .map { storyElements in
                return storyElements
                    .map { element -> IStoryElementViewModel in
                        if let storyEvent = element as? StoryEvent {
                            return factory.storyEventViewModel(storyEvent: storyEvent)
                        } else if let talk = element as? Talk {
                            return factory.talkViewModel(talk: talk)
                        } else {
                            fatalError()
                        }
                    }
            }
            .asDriver(onErrorJustReturn: []).asObservable()
    }
    
    private func selectPeriod() {
        let selectPeriodViewModel = _factory.selectPeriodViewModel(storyWatching: _storyWatching)
        selectPeriodViewModel.onResult = { [weak self] result in
            self?.processSelectPeriodViewModelResult(result)
        }
        sendMessage(TransitionMessage(viewModel: selectPeriodViewModel))
    }
    
    private func processSelectPeriodViewModelResult(_ result: SelectPeriodViewModelResult) {
        switch result {
        case .selected(let periodReference):
            _storyWatching.selectPeriodAction.onNext(periodReference)
        default:
            break
        }
    }
    
    private func leaveWatching() {
        sendMessage(DismissingMessage())
    }
}
