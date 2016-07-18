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
import Eventitic

public class StoryWatchingViewModel: ViewModel {
    public let currentPeriodText: Observable<String>
    public let elementsList: Observable<[StoryElementViewModel]>
    public let selectPeriodAction: AnyObserver<Void>
    public let leaveWatchingAction: AnyObserver<Void>

    private let _factory: Factory
    private let _listenerStore = ListenerStore()
    private let _storyWatching: StoryWatching
    private let _currentPeriodText = Variable<String>("")
    private let _elementsList = Variable<[StoryElementViewModel]>([])
    private let _selectPeriodAction = ActionObserver<Void>()
    private let _leaveWatchingAction = ActionObserver<Void>()
    
    class Factory {
        func makeStoryEventViewModel(storyEvent storyEvent: StoryEvent) -> StoryEventViewModel {
            return StoryEventViewModel(storyEvent: storyEvent)
        }
        func makeTalkViewModel(talk talk: Talk) -> TalkViewModel {
            return TalkViewModel(talk: talk)
        }
        func makeSelectPeriodViewModel(storyWatching storyWatching: StoryWatching) -> SelectPeriodViewModel {
            return SelectPeriodViewModel(storyWatching: storyWatching)
        }
    }
    
    public convenience init(storyWatching: StoryWatching) {
        self.init(storyWatching: storyWatching, factory: Factory())
    }
    init(storyWatching: StoryWatching, factory: Factory) {
        _factory = factory
        _storyWatching = storyWatching
        
        currentPeriodText = _currentPeriodText.asDriver().asObservable()
        elementsList = _elementsList.asDriver().asObservable()
        selectPeriodAction = _selectPeriodAction.asObserver()
        leaveWatchingAction = _leaveWatchingAction.asObserver()
        
        super.init()

        _selectPeriodAction.handler = { [weak self] in self?.selectPeriod() }
        _leaveWatchingAction.handler = { [weak self] in self?.leaveWatching() }
        
        updateCurrentPeriodText()
        updateElementsList()
        
        _storyWatching.currentPeriodChanged
            .listen { [weak self] _ in
                self?.updateCurrentPeriodText()
            }
            .addToStore(_listenerStore)
        
        _storyWatching.storyElementsChanged
            .listen { [weak self] _ in
                self?.updateElementsList()
            }
            .addToStore(_listenerStore)
    }
    
    private func updateCurrentPeriodText() {
        var text = ""
        if let currentPeriod = _storyWatching.currentPeriod {
            switch currentPeriod.type {
            case .Prologue:
                text = "Prologue"
            case .Epilogue:
                text = "Epilogue"
            case .Progress:
                text = "Day \(currentPeriod.day)"
            }
        }
        _currentPeriodText.value = text
    }
    
    private func updateElementsList() {
        let viewModelList = _storyWatching.storyElements
            .map { element -> StoryElementViewModel in
                if let storyEvent = element as? StoryEvent {
                    return _factory.makeStoryEventViewModel(storyEvent: storyEvent)
                } else if let talk = element as? Talk {
                    return _factory.makeTalkViewModel(talk: talk)
                } else {
                    fatalError()
                }
            }
        _elementsList.value = viewModelList
    }
    
    private func selectPeriod() {
        let selectPeriodViewModel = _factory.makeSelectPeriodViewModel(storyWatching: _storyWatching)
        selectPeriodViewModel.onResult = { [weak self] result in
            self?.processSelectPeriodViewModelResult(result)
        }
        sendMessage(TransitionMessage(viewModel: selectPeriodViewModel))
    }
    
    private func processSelectPeriodViewModelResult(result: SelectPeriodViewModelResult) {
        switch result {
        case .Selected(let periodReference):
            _storyWatching.selectPeriod(periodReference)
        default:
            break
        }
    }
    
    private func leaveWatching() {
        
    }
}
