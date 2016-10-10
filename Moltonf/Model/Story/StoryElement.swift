//
// StoryElement.swift
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

/// This class reporesents an element of a story.
/// This is a base class of `StoryEvent` and `Talk`.
public class StoryElement {
    /// Period which contains this element
    public private(set) weak var period: Period?
    
    /// Lines of messages
    public let messageLines: [String]

    /// Creates a new instance
    /// - parameter period:  period which contains this element
    /// - parameter element: JSON fragment in archive
    /// - throws: if the JSON fragment has errors
    public init(period: Period, element: JSON) throws {
        self.period = period
        
        guard let lines = element[K.LINES].array else {
            throw StoryError.missingData(data: K.LINES)
        }
        messageLines = try lines
            .map { line in
                if let message = line.string {
                    return message
                } else if let char = line[K.CHAR].string {
                    return char
                } else if let messageParts = line.array {
                    return try messageParts
                        .reduce("") { acc, part in
                            if let stringPart = part.string {
                                return acc + stringPart
                            } else if let rawChar = part[K.CHAR].string {
                                return acc + rawChar
                            }
                            throw StoryError.unknownValue(data: line.description)
                    }
                }
                throw StoryError.unknownValue(data: line.description)
            }
    }
    
    /// Story which contains this element
    public var story: Story? {
        get {
            return period?.story
        }
    }
}
