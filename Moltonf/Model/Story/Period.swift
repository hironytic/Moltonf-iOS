//
// Period.swift
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
import SwiftyJSON

private typealias K = ArchiveConstants

/// This class represents a day, from dawn to dawn, in a story.
public class Period {
    /// Story which contains this period
    public let story: Story
    
    /// Type of this period
    public let type: PeriodType
    
    /// Number of the day
    public let day: Int
    
    /// Array of elements in this period
    public private(set) var elements: [StoryElement] = []

    // for testing
    init(story: Story, type: PeriodType, day: Int) {
        self.story = story
        self.type = type
        self.day = day
    }
    
    /// Creates a new instance.
    /// - parameter story:  story which contains this period
    /// - parameter period: JSON fragment in archive
    /// - throws: if the JSON fragment has errors
    public init(story: Story, period: JSON) throws {
        self.story = story
        
        if let typeValue = period[K.TYPE].string {
            if let type = PeriodType(archiveValue: typeValue) {
                self.type = type
            } else {
                throw StoryError.unknownValue(data: typeValue)
            }
        } else {
            throw StoryError.missingData(data: K.TYPE)
        }
        
        if let day = period[K.DAY].int {
            self.day = day
        } else {
            throw StoryError.missingData(data: K.DAY)
        }
        
        if let elements = period[K.ELEMENTS].array {
            self.elements = try elements
                .map { element in
                    return try self.makeElement(element)
                }
        } else {
            throw StoryError.missingData(data: K.ELEMENTS)
        }
    }
    
    /// Creates a new instance from the file.
    /// - parameter story:     story which contains this period
    /// - parameter periodURL: file URL
    /// - throws: if it couldn't read the file or its content has errors
    public convenience init(story: Story, periodURL: URL) throws {
        guard let periodData = try? Data(contentsOf: periodURL) else {
            throw StoryError.cantLoadPeriod
        }
        let period = JSON(data: periodData)
        try self.init(story: story, period: period)
    }
    
    private func makeElement(_ element: JSON) throws -> StoryElement {
        guard let type = element[K.TYPE].string else {
            throw StoryError.missingData(data: K.TYPE)
        }
        switch type {
        case K.VAL_TALK:
            return try Talk(period: self, element: element)
        case K.VAL_ASSAULT:
            return try WolfAttackTalk(period: self, element: element)
        default:
            return try StoryEvent(period: self, element: element)
        }
    }
}
