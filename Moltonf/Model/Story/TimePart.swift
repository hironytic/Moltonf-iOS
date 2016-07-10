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

public class TimePart {
    private let _milliseconds: Int
    
    public convenience init(hour: Int, minute: Int, second: Int, millisecond: Int) {
        self.init(milliseconds: (((hour * 60 + minute) * 60) + second) * 1000 + millisecond)
    }
    
    public init(milliseconds: Int) {
        let millisecondsInADay: Int = 60 * 60 * 1000 * 24
        var value = milliseconds % millisecondsInADay
        if (value < 0) {
            value += millisecondsInADay
        }
        _milliseconds = value
    }

    public var hourPart: Int {
        get {
            return _milliseconds / (1000 * 60 * 60)
        }
    }
    
    public var minutePart: Int {
        get {
            return (_milliseconds / (1000 * 60)) % 60
        }
    }
    
    public var secondPart: Int {
        get {
            return (_milliseconds / 1000) % 60;
        }
    }
    
    public var millisecondPart: Int {
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
    public convenience init?(archiveValue timeString: String) {
        // hh ':' mm ':' ss ('.' s+)? (zzzzzz)?
        //        -- see http://www.w3.org/TR/xmlschema-2/#dateTime
        guard timeString.characters.count >= 8 else { return nil }
        
        let hourIndex = timeString.startIndex
        let hourString = timeString.substringWithRange(hourIndex ..< hourIndex.advancedBy(2))
        guard let hour = Int(hourString) else { return nil }
        
        let minuteIndex = timeString.startIndex.advancedBy(3)
        let minuteString = timeString.substringWithRange(minuteIndex ..< minuteIndex.advancedBy(2))
        guard let minute = Int(minuteString) else { return nil }
        
        let secondIndex = timeString.startIndex.advancedBy(6)
        let secondString = timeString.substringWithRange(secondIndex ..< secondIndex.advancedBy(2))
        guard let second = Int(secondString) else { return nil }
        
        var millisecond = 0
        if timeString.characters.count > 8 && timeString[timeString.startIndex.advancedBy(8)] == "." {
            var charIndex = timeString.startIndex.advancedBy(9)
            for factor in [1000, 100, 10, 1] {
                if timeString.characters.endIndex < charIndex {
                    break
                }
                let ch = timeString.substringWithRange(charIndex ..< charIndex.advancedBy(1))
                if ch < "0" || ch > "9" {
                    break
                }
                
                let value = Int(ch.utf8[ch.utf8.startIndex]) - 0x30 /* 0x30 == "0" */
                millisecond += value * factor
                
                charIndex = charIndex.successor()
            }
        }
        
        self.init(hour: hour, minute: minute, second: second, millisecond: millisecond)
    }
}
