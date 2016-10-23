//
// UIColor+Moltonf.swift
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

import UIKit

extension UIColor {
    struct Moltonf {
        private init() { }
        
        /// Tint color (#ff8800)
        static let tint = #colorLiteral(red: 1, green: 0.5333333333, blue: 0, alpha: 1)
        
        /// Generic background color (#000000)
        static let background = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        /// Generic selected background color (#333333)
        static let backgroundSelected = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        
        /// Generic text color (#ffffff)
        static let text = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        /// Background color of overlapped view (#333333)
        static let overlappedViewBackground = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        
        /// Selected background color of overlapped view (#555555)
        static let overlappedViewBackgroundSelected = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
    }
}
