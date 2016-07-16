//
// Story.swift
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

/// This class represents a story.
public class Story {
    /// Full name of the village
    public let villageFullName: String
    
    /// URI string which speficies a grave icon image
    public let graveIconURI: String

    /// Reference to each period in this story
    public private(set) var periodRefs: [PeriodReference] = []
    
    /// Avatars in this story
    public private(set) var avatarList: [Avatar] = []
    
    private var _avatarMap = [String: Avatar]()
    
    // for testing
    init(villageFullName: String, graveIconURI: String) {
        self.villageFullName = villageFullName
        self.graveIconURI = graveIconURI
    }

    /// Creates a new instance.
    /// - parameter playdata: JSON fragment in archive
    /// - throws: if the JSON fragment has errors
    public init(playdata: JSON) throws {
        if let villageFullName = playdata[K.FULL_NAME].string {
            self.villageFullName = villageFullName
        } else {
            throw StoryError.MissingData(data: K.FULL_NAME)
        }

        if let graveIconURI = playdata[K.GRAVE_ICON_URI].string {
            self.graveIconURI = graveIconURI
        } else {
            throw StoryError.MissingData(data: K.GRAVE_ICON_URI)
        }
        
        if let avatarList = playdata[K.AVATAR_LIST].array {
            self.avatarList = try avatarList
                .map { data in
                    try Avatar(story: self, avatarData: data)
                }
        } else {
            throw StoryError.MissingData(data: K.AVATAR_LIST)
        }
        for avatar in avatarList {
            _avatarMap[avatar.avatarId] = avatar
        }
        
        if let periodList = playdata[K.PERIODS].array {
            self.periodRefs = try periodList
                .map { data in
                    try PeriodReference(story: self, periodRefData: data)
                }
        } else {
            throw StoryError.MissingData(data: K.PERIODS)
        }
    }

    /// Creates a new instance from the file.
    /// - parameter playdataURL: file URL
    /// - throws: if it couldn't read the file or its content has errors
    public convenience init(playdataURL: NSURL) throws {
        guard let playdataData = NSData(contentsOfURL: playdataURL) else {
            throw StoryError.CantLoadPlaydata
        }
        let playdata = JSON(data: playdataData)
        try self.init(playdata: playdata)
    }

    /// Retrieves an avatar from its ID.
    /// - parameter avatarId: ID of wanted avatar
    /// - returns: avatar, or nil if no avatar was found
    public func avatar(havingId avatarId: String) -> Avatar? {
        return _avatarMap[avatarId]
    }
}

/// This class represents a reference to a period.
public class PeriodReference {
    /// Story which contains this reference
    public weak var story: Story?
    
    /// Type of this period
    public let type: PeriodType
    
    /// Number of the day
    public let day: Int
    
    /// Path to a period file
    public let periodPath: String
    
    /// Creates a new instance
    /// - parameter story:         story which contains this reference
    /// - parameter periodRefData: JSON fragment in archive
    /// - throws: if JSON fragement has errors
    public init(story: Story, periodRefData: JSON) throws {
        self.story = story
        
        if let typeValue = periodRefData[K.TYPE].string {
            if let type = PeriodType(archiveValue: typeValue) {
                self.type = type
            } else {
                throw StoryError.UnknownValue(data: typeValue)
            }
        } else {
            throw StoryError.MissingData(data: K.TYPE)
        }
        
        if let day = periodRefData[K.DAY].int {
            self.day = day
        } else {
            throw StoryError.MissingData(data: K.DAY)
        }
        
        if let href = periodRefData[K.HREF].string {
            self.periodPath = href
        } else {
            throw StoryError.MissingData(data: K.HREF)
        }
    }
}

