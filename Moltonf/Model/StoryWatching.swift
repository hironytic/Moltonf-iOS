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
import Eventitic

public enum StoryWatchingError: ErrorType {
    case InconsistencyError(String)
}

public class StoryWatching {
    public let errorOccurred = EventSource<ErrorType>()

    public let availablePeriodRefsChanged = EventSource<[PeriodReference]>()
    public private(set) var availablePeriodRefs: [PeriodReference] = [] {
        didSet {
            availablePeriodRefsChanged.fire(availablePeriodRefs)
        }
    }
    
    public let currentPeriodChanged = EventSource<Period?>()
    public private(set) var currentPeriod: Period? = nil {
        didSet {
            currentPeriodChanged.fire(currentPeriod)
        }
    }
    
    public let storyElementsChanged = EventSource<[StoryElement]>()
    public private(set) var storyElements: [StoryElement] = [] {
        didSet {
            storyElementsChanged.fire(storyElements)
        }
    }
    
    private let _workspace: Workspace
    private let _story: Story

    init(workspace: Workspace, story: Story) {
        _workspace = workspace
        _story = story
    }
    
    public init(workspace: Workspace) throws {
        _workspace = workspace

        let workspaceURL = WorkspaceDB.sharedInstance.workspaceDirURL.URLByAppendingPathComponent(_workspace.id)
        let playdataURL = workspaceURL.URLByAppendingPathComponent(ArchiveConstants.FILE_PLAYDATA_JSON)
        _story = try Story(playdataURL: playdataURL)
        
        availablePeriodRefs = _story.periodRefs
        currentPeriod = try loadPeriod(_story.periodRefs[0])
        
        storyElements = currentPeriod?.elements ?? []
    }
    
    public func selectPeriod(periodRef: PeriodReference) {
        if (currentPeriod?.day ?? -1) != periodRef.day {
            do {
                try loadPeriod(periodRef)
            } catch let error {
                errorOccurred.fire(error)
            }
        }
    }
    
    public func switchToNextPeriod() {
        guard let currentPeriod = currentPeriod else { return }
        if let currentIndex = _story.periodRefs.indexOf({ $0.day == currentPeriod.day }) {
            if currentIndex < _story.periodRefs.count {
                do {
                    try loadPeriod(_story.periodRefs[currentIndex + 1])
                } catch let error {
                    errorOccurred.fire(error)
                }
            }
        } else {
            errorOccurred.fire(StoryWatchingError.InconsistencyError("current day is not found!"))
        }
    }
    
    private func loadPeriod(periodRef: PeriodReference) throws -> Period {
        let workspaceURL = WorkspaceDB.sharedInstance.workspaceDirURL.URLByAppendingPathComponent(_workspace.id)
        let periodURL = workspaceURL.URLByAppendingPathComponent(periodRef.periodPath)
        return try Period(story: _story, periodURL: periodURL)
    }
}
