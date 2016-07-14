//
// Avatar.swift
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

public class Avatar {
    public weak var story: Story?
    public let avatarId: String
    public let fullName: String
    public let shortName: String
    public let faceIconURI: String?
    
    // for testing
    init(story: Story, avatarId: String, fullName: String, shortName: String, faceIconURI: String?) {
        self.story = story
        self.avatarId = avatarId
        self.fullName = fullName
        self.shortName = shortName
        self.faceIconURI = faceIconURI
    }
    
    public init(story: Story, avatarData: JSON) throws {
        self.story = story
        
        if let avatarId = avatarData[K.AVATAR_ID].string {
            self.avatarId = avatarId
        } else {
            throw StoryError.MissingData(data: K.AVATAR_ID)
        }
        
        if let fullName = avatarData[K.FULL_NAME].string {
            self.fullName = fullName
        } else {
            throw StoryError.MissingData(data: K.FULL_NAME)
        }
        
        if let shortName = avatarData[K.SHORT_NAME].string {
            self.shortName = shortName
        } else {
            throw StoryError.MissingData(data: K.SHORT_NAME)
        }
        
        faceIconURI = avatarData[K.FACE_ICON_URI].string
    }
}
