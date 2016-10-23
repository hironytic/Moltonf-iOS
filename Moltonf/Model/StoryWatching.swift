//
// StoryWatching.swift
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

public enum StoryWatchingError: Error {
    case inconsistencyError(String)
}

public struct StoryWatchingElementList {
    let elements: [StoryElement]
    let shouldScrollToTop: Bool
}

public protocol IStoryWatching: class {
    var errorLine: Observable<Error> { get }
    var titleLine: Observable<String> { get }
    var availablePeriodRefsLine: Observable<[PeriodReference]> { get }
    var currentPeriodLine: Observable<Period> { get }
    var storyElementListLine: Observable<StoryWatchingElementList> { get }
    
    var selectPeriodAction: AnyObserver<PeriodReference> { get }
    var switchToNextPeriodAction: AnyObserver<Void> { get }
}

public class StoryWatching: IStoryWatching {
    public var errorLine: Observable<Error> { get { return _errorSubject } }
    public private(set) var titleLine: Observable<String>
    public private(set) var availablePeriodRefsLine: Observable<[PeriodReference]>
    public private(set) var currentPeriodLine: Observable<Period>
    public private(set) var storyElementListLine: Observable<StoryWatchingElementList>
    
    public private(set) var selectPeriodAction: AnyObserver<PeriodReference>
    public private(set) var switchToNextPeriodAction: AnyObserver<Void>
    
    private let _errorSubject = PublishSubject<Error>()
    private let _availablePeriodRefs: Variable<[PeriodReference]>
    private let _currentPeriod: Variable<Period>
    private let _storyElementList: Variable<StoryWatchingElementList>
    
    private let _selectPeriodAction = ActionObserver<PeriodReference>()
    private let _switchToNextPeriodAction = ActionObserver<Void>()
    
    private let _workspace: Workspace
    private let _story: Story
    
    public init(workspace: Workspace) throws {
        _workspace = workspace
        
        let workspaceURL = WorkspaceDB.sharedInstance.workspaceDirURL.appendingPathComponent(_workspace.id)
        let playdataURL = workspaceURL.appendingPathComponent(ArchiveConstants.FILE_PLAYDATA_JSON)
        _story = try Story(playdataURL: playdataURL)
        
        _availablePeriodRefs = Variable<[PeriodReference]>(_story.periodRefs)
        _currentPeriod = Variable<Period>(try type(of: self).loadPeriod(_story.periodRefs[0], story: _story, workspace: _workspace))
        _storyElementList = Variable<StoryWatchingElementList>(StoryWatchingElementList(elements: _currentPeriod.value.elements, shouldScrollToTop: true))
        
        titleLine = Observable.just(_story.villageFullName)
        availablePeriodRefsLine = _availablePeriodRefs.asObservable()
        currentPeriodLine = _currentPeriod.asObservable()
        storyElementListLine = _storyElementList.asObservable()
        selectPeriodAction = _selectPeriodAction.asObserver()
        switchToNextPeriodAction = _switchToNextPeriodAction.asObserver()
        
        _selectPeriodAction.handler = { [weak self] in self?.selectPeriod($0) }
        _switchToNextPeriodAction.handler = { [weak self] in self?.switchToNextPeriod() }
    }

    private func selectPeriod(_ periodRef: PeriodReference) {
        if _currentPeriod.value.day != periodRef.day {
            do {
                let nextPeriod = try loadPeriod(periodRef)
                _currentPeriod.value = nextPeriod
                _storyElementList.value = StoryWatchingElementList(elements: nextPeriod.elements, shouldScrollToTop: true)
            } catch let error {
                _errorSubject.onNext(error)
            }
        }
    }
    
    private func switchToNextPeriod() {
        if let currentIndex = _story.periodRefs.index(where: { $0.day == _currentPeriod.value.day }) {
            if currentIndex < _story.periodRefs.count {
                do {
                    let nextPeriod = try loadPeriod(_story.periodRefs[currentIndex + 1])
                    _currentPeriod.value = nextPeriod
                    _storyElementList.value = StoryWatchingElementList(elements: nextPeriod.elements, shouldScrollToTop: true)
                } catch let error {
                    _errorSubject.onNext(error)
                }
            }
        } else {
            _errorSubject.onNext(StoryWatchingError.inconsistencyError("current day is not found!"))
        }
    }

    private func loadPeriod(_ periodRef: PeriodReference) throws -> Period {
        return try type(of: self).loadPeriod(periodRef, story: _story, workspace: _workspace)
    }
    
    private static func loadPeriod(_ periodRef: PeriodReference, story: Story, workspace: Workspace) throws -> Period {
        let workspaceURL = WorkspaceDB.sharedInstance.workspaceDirURL.appendingPathComponent(workspace.id)
        let periodURL = workspaceURL.appendingPathComponent(periodRef.periodPath)
        return try Period(story: story, periodURL: periodURL)
    }
}
