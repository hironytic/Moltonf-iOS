//
// TalkType.swift
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

private typealias K = ArchiveConstants

/// Type of talk
public enum TalkType {
    /// Normal talk, log in white
    case Public
    
    /// Wolf's talk, log in red
    case Wolf
    
    /// Monology, log in gray
    case Private
    
    /// Talk under the grave, log in blue
    case Grave
}

extension TalkType {
    /// Creates a new value from from a string appears in archive
    /// - parameter talkType: string
    /// - returns: new value, or nil if `type` is invalid.
    public init?(archiveValue talkType: String) {
        switch talkType  {
        case K.VAL_PUBLIC:
            self = .Public
        case K.VAL_WOLF:
            self = .Wolf
        case K.VAL_PRIVATE:
            self = .Private
        case K.VAL_GRAVE:
            self = .Grave
        default:
            return nil
        }
    }
}
