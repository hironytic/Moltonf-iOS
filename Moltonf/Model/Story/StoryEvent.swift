//
// StoryEvent.swift
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

/// This class represents an event which appears in story.
open class StoryEvent: StoryElement {
    /// Event family
    open let eventFamily: EventFamily
    
    /// Creates a new instance
    /// - parameter period:  period which contains this element
    /// - parameter element: JSON fragment in archive
    /// - throws: if the JSON fragment has errors
    public override init(period: Period, element: JSON) throws {
        guard let type = element[K.TYPE].string else {
            throw StoryError.missingData(data: K.TYPE)
        }
        switch type {
        case    K.VAL_START_ENTRY, K.VAL_ON_STAGE, K.VAL_START_MIRROR,
                K.VAL_OPEN_ROLE, K.VAL_MURDERED, K.VAL_START_ASSAULT,
                K.VAL_SURVIVOR, K.VAL_COUNTING, K.VAL_SUDDEN_DEATH,
                K.VAL_NO_MURDER, K.VAL_WIN_VILLAGE, K.VAL_WIN_WOLF,
                K.VAL_WIN_HAMSTER, K.VAL_PLAYER_LIST, K.VAL_PANIC,
                K.VAL_EXECUTION, K.VAL_VANISH, K.VAL_CHECKOUT,
                K.VAL_SHORT_MEMBER:
            eventFamily = .announce

        case    K.VAL_ASK_ENTRY, K.VAL_ASK_COMMIT, K.VAL_NO_COMMENT,
                K.VAL_STAY_EPILOGUE, K.VAL_GAME_OVER:
            eventFamily = .order

        case    K.VAL_JUDGE, K.VAL_GUARD, K.VAL_COUNTING2 /* , K.VAL_ASSAULT */ :
            eventFamily = .extra
            
        default:
            throw StoryError.unknownValue(data: type)
        }
        
        try super.init(period: period, element: element)
    }
}
