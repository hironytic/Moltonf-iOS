//
// TimePart.swift
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

/// This class holds time components which doesn't specify a specific point of time.
/// It is not related to any time zome, eigher.
open class TimePart {
    fileprivate let _milliseconds: Int
    
    /// Creates a new instance from hour, minute, second and millisecond
    /// - parameter hour: hour (0-23)
    /// - parameter minute: minute (0-59)
    /// - parameter second: second (0-59)
    /// - parameter millisecond: millisecond (0-999)
    public convenience init(hour: Int, minute: Int, second: Int, millisecond: Int) {
        self.init(milliseconds: (((hour * 60 + minute) * 60) + second) * 1000 + millisecond)
    }

    /// Creates a new instance from milliseconds since 00:00 a.m.
    /// - parameter milliseconds: milliseconds
    public init(milliseconds: Int) {
        let millisecondsInADay: Int = 60 * 60 * 1000 * 24
        var value = milliseconds % millisecondsInADay
        if (value < 0) {
            value += millisecondsInADay
        }
        _milliseconds = value
    }

    /// Hour part value
    open var hourPart: Int {
        get {
            return _milliseconds / (1000 * 60 * 60)
        }
    }
    
    /// Minute part value
    open var minutePart: Int {
        get {
            return (_milliseconds / (1000 * 60)) % 60
        }
    }
    
    /// Second part value
    open var secondPart: Int {
        get {
            return (_milliseconds / 1000) % 60;
        }
    }
    
    /// Millisecond part value
    open var millisecondPart: Int {
        get {
            return _milliseconds % 1000
        }
    }
}

extension TimePart: CustomDebugStringConvertible {
    public var debugDescription: String {
        get {
            return String(format: "%02d:%02d:%02d.%03d", hourPart, minutePart, secondPart, millisecondPart)
        }
    }
}

extension TimePart {
    /// Creates a new instance from from a string appears in archive
    /// - parameter timeString: string
    /// - returns: created instance, or nil if it couldn't parse the string
    public convenience init?(archiveValue timeString: String) {
        // hh ':' mm ':' ss ('.' s+)? (zzzzzz)?
        //        -- see http://www.w3.org/TR/xmlschema-2/#dateTime
        guard timeString.characters.count >= 8 else { return nil }
        
        let hourIndex = timeString.startIndex
        let hourString = timeString.substring(with: hourIndex ..< <#T##String.CharacterView corresponding to `hourIndex`##String.CharacterView#>.index(hourIndex, offsetBy: 2))
        guard let hour = Int(hourString) else { return nil }
        
        let minuteIndex = timeString.characters.index(timeString.startIndex, offsetBy: 3)
        let minuteString = timeString.substring(with: minuteIndex ..< <#T##String.CharacterView corresponding to `minuteIndex`##String.CharacterView#>.index(minuteIndex, offsetBy: 2))
        guard let minute = Int(minuteString) else { return nil }
        
        let secondIndex = timeString.characters.index(timeString.startIndex, offsetBy: 6)
        let secondString = timeString.substring(with: secondIndex ..< <#T##String.CharacterView corresponding to `secondIndex`##String.CharacterView#>.index(secondIndex, offsetBy: 2))
        guard let second = Int(secondString) else { return nil }
        
        var millisecond = 0
        let dotIndex = timeString.characters.index(timeString.startIndex, offsetBy: 8)
        if dotIndex < timeString.endIndex && timeString[dotIndex] == "." {
            var charIndex = <#T##String.CharacterView corresponding to `dotIndex`##String.CharacterView#>.index(after: dotIndex)
            for factor in [100, 10, 1] {
                if timeString.endIndex <= charIndex {
                    break
                }
                let ch = timeString.substring(with: charIndex ..< <#T##Collection corresponding to `charIndex`##Collection#>.index(charIndex, offsetBy: 1))
                if ch < "0" || ch > "9" {
                    break
                }
                
                let value = Int(ch.utf8[ch.utf8.startIndex]) - 0x30 /* 0x30 == "0" */
                millisecond += value * factor
                
                charIndex = <#T##Collection corresponding to `charIndex`##Collection#>.index(after: charIndex)
            }
        }
        
        self.init(hour: hour, minute: minute, second: second, millisecond: millisecond)
    }
}
