//
// ResourceConstants+Color.swift
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

public extension ResourceConstants {
    public struct Color {
        private init() { }
        
        /// Tint color (#ff8800)
        public static let tint = #colorLiteral(red: 1, green: 0.5333333333, blue: 0, alpha: 1)
        
        /// Generic background color (#000000)
        public static let background = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        /// Generic selected background color (#333333)
        public static let backgroundSelected = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        
        /// Generic text color (#ffffff)
        public static let text = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        /// Background color of overlapped view (#333333)
        public static let overlappedViewBackground = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        
        /// Selected background color of overlapped view (#555555)
        public static let overlappedViewBackgroundSelected = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
        
        /// announce event color (#dddddd)
        public static let eventAnnounce = #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)
        
        /// order event color (#ff4444)
        public static let eventOrder = #colorLiteral(red: 1, green: 0.2666666667, blue: 0.2666666667, alpha: 1)
        
        /// extra event color (#888888)
        public static let eventExtra = #colorLiteral(red: 0.5333333333, green: 0.5333333333, blue: 0.5333333333, alpha: 1)
        
        /// public balloon color (#ffffff)
        public static let balloonPublic = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        /// wolf balloon color (#ff7777)
        public static let balloonWolf = #colorLiteral(red: 1, green: 0.4666666667, blue: 0.4666666667, alpha: 1)
        
        /// grave balloon color (#9fb7cf)
        public static let balloonGrave = #colorLiteral(red: 0.6235294118, green: 0.7176470588, blue: 0.8117647059, alpha: 1)
        
        /// private balloon color (#9393a3)
        public static let balloonPrivate = #colorLiteral(red: 0.5764705882, green: 0.5764705882, blue: 0.6392156863, alpha: 1)
    }
}
