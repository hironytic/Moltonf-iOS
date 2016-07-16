//
// Talk.swift
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

/// This class represents a talk which appears in story.
public class Talk: StoryElement {
    /// Type of talk
    public let talkType: TalkType
    
    /// Avatar which makes this talk
    public let speaker: Avatar
    
    /// Time on which this talk is made
    public let time: TimePart
    
    /// Creates a new instance.
    /// - parameter period: period which contains this element
    /// - parameter element: JSON fragment in archive
    /// - throws: if the JSON fragment has errors
    public override init(period: Period, element: JSON) throws {
        if let talkTypeValue = element[K.TALK_TYPE].string {
            if let talkType = TalkType(archiveValue: talkTypeValue) {
                self.talkType = talkType
            } else {
                throw StoryError.UnknownValue(data: talkTypeValue)
            }
        } else {
            throw StoryError.MissingData(data: K.TALK_TYPE)
        }
        
        if let avatarId = element[K.AVATAR_ID].string {
            if let avatar = period.story.avatar(havingId: avatarId) {
                self.speaker = avatar
            } else {
                throw StoryError.UnknownAvatar(data: avatarId)
            }
        } else {
            throw StoryError.MissingData(data: K.AVATAR_ID)
        }
        
        if let timeString = element[K.TIME].string {
            if let time = TimePart(archiveValue: timeString) {
                self.time = time
            } else {
                throw StoryError.UnknownValue(data: timeString)
            }
        } else {
            throw StoryError.MissingData(data: K.TIME)
        }
        
        try super.init(period: period, element: element)
    }
}

/// This class represents a special talk, wolf's attack.
public class WolfAttackTalk: Talk {
    /// Creates a new instance.
    /// - parameter period: period which contains this element
    /// - parameter element: JSON fragment in archive
    /// - throws: if the JSON fragment has errors
    public override init(period: Period, element: JSON) throws {
        guard var talkElementDictionary = element.dictionaryObject else {
            throw StoryError.UnknownValue(data: "")
        }
        guard let byWhom = element[K.BY_WHOM].string else {
            throw StoryError.MissingData(data: K.BY_WHOM)
        }
        talkElementDictionary[K.TALK_TYPE] = K.VAL_WOLF
        talkElementDictionary[K.AVATAR_ID] = byWhom
        try super.init(period: period, element: JSON(talkElementDictionary))
    }
}
