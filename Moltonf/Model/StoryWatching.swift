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

public enum StoryWatchingError: ErrorType {
    case InconsistencyError(String)
}

public protocol IStoryWatching {
    var error: Observable<ErrorType> { get }
    var availablePeriodRefs: Observable<[PeriodReference]> { get }
    var currentPeriod: Observable<Period> { get }
    var storyElements: Observable<[StoryElement]> { get }
    
    var selectPeriodAction: AnyObserver<PeriodReference> { get }
    var switchToNextPeriodAction: AnyObserver<Void> { get }
}

public class StoryWatching: IStoryWatching {
    public var error: Observable<ErrorType> { get { return _error } }
    public private(set) var availablePeriodRefs: Observable<[PeriodReference]>
    public private(set) var currentPeriod: Observable<Period>
    public private(set) var storyElements: Observable<[StoryElement]>
    
    public private(set) var selectPeriodAction: AnyObserver<PeriodReference>
    public private(set) var switchToNextPeriodAction: AnyObserver<Void>
    
    private let _error = PublishSubject<ErrorType>()
    private let _availablePeriodRefs: Variable<[PeriodReference]>
    private let _currentPeriod: Variable<Period>
    private let _storyElements: Variable<[StoryElement]>
    
    private let _selectPeriodAction = ActionObserver<PeriodReference>()
    private let _switchToNextPeriodAction = ActionObserver<Void>()
    
    private let _workspace: Workspace
    private let _story: Story
    
    public init(workspace: Workspace) throws {
        _workspace = workspace
        
        let workspaceURL = WorkspaceDB.sharedInstance.workspaceDirURL.URLByAppendingPathComponent(_workspace.id)
        let playdataURL = workspaceURL.URLByAppendingPathComponent(ArchiveConstants.FILE_PLAYDATA_JSON)
        _story = try Story(playdataURL: playdataURL)
        
        _availablePeriodRefs = Variable<[PeriodReference]>(_story.periodRefs)
        _currentPeriod = Variable<Period>(try self.dynamicType.loadPeriod(_story.periodRefs[0], story: _story, workspace: _workspace))
        _storyElements = Variable<[StoryElement]>(_currentPeriod.value.elements)
        
        availablePeriodRefs = _availablePeriodRefs.asObservable()
        currentPeriod = _currentPeriod.asObservable()
        storyElements = _storyElements.asObservable()
        selectPeriodAction = _selectPeriodAction.asObserver()
        switchToNextPeriodAction = _switchToNextPeriodAction.asObserver()
        
        _selectPeriodAction.handler = { [weak self] in self?.selectPeriod($0) }
        _switchToNextPeriodAction.handler = { [weak self] in self?.switchToNextPeriod() }
    }

    private func selectPeriod(periodRef: PeriodReference) {
        if _currentPeriod.value.day != periodRef.day {
            do {
                _currentPeriod.value = try loadPeriod(periodRef)
            } catch let error {
                _error.onNext(error)
            }
        }
    }
    
    private func switchToNextPeriod() {
        if let currentIndex = _story.periodRefs.indexOf({ $0.day == _currentPeriod.value.day }) {
            if currentIndex < _story.periodRefs.count {
                do {
                    _currentPeriod.value = try loadPeriod(_story.periodRefs[currentIndex + 1])
                } catch let error {
                    _error.onNext(error)
                }
            }
        } else {
            _error.onNext(StoryWatchingError.InconsistencyError("current day is not found!"))
        }
    }

    private func loadPeriod(periodRef: PeriodReference) throws -> Period {
        return try self.dynamicType.loadPeriod(periodRef, story: _story, workspace: _workspace)
    }
    
    private static func loadPeriod(periodRef: PeriodReference, story: Story, workspace: Workspace) throws -> Period {
        let workspaceURL = WorkspaceDB.sharedInstance.workspaceDirURL.URLByAppendingPathComponent(workspace.id)
        let periodURL = workspaceURL.URLByAppendingPathComponent(periodRef.periodPath)
        return try Period(story: story, periodURL: periodURL)
    }
}
