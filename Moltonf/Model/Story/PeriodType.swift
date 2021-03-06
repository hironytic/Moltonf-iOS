//
// PeriodType.swift
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

/// Type of period
public enum PeriodType {
    /// Prologue
    case prologue
    
    /// Progress
    case progress
    
    /// Epilogue
    case epilogue
}

extension PeriodType {
    /**
     Creates a new value from a string appears in archive
     - parameter type: string
     - returns: new value, or nil if `type` is invalid.
     */
    public init?(archiveValue type: String) {
        switch type  {
        case K.VAL_PROLOGUE:
            self = .prologue
        case K.VAL_PROGRESS:
            self = .progress
        case K.VAL_EPILOGUE:
            self = .epilogue
        default:
            return nil
        }
    }
}
