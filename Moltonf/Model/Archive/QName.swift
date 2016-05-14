//
// QName.swift
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

private let DEFAULT_NAMESPACE_URI = ""
private let DEFAULT_PREFIX = ""

public class QName: Hashable {
    public let namespaceURI: String?
    public let localName: String
    public let prefix: String?
    
    convenience init(localName: String) {
        self.init(namespaceURI: DEFAULT_NAMESPACE_URI, localName: localName, prefix: DEFAULT_PREFIX)
    }

    convenience init(namespaceURI: String?, localName: String) {
        self.init(namespaceURI: namespaceURI, localName: localName, prefix: DEFAULT_PREFIX)
    }
    
    init(namespaceURI: String?, localName: String, prefix: String?) {
        self.namespaceURI = namespaceURI
        self.localName = localName
        self.prefix = prefix
    }
    
    public var hashValue: Int {
        get {
            return (namespaceURI?.hashValue ?? 0) * 31 + localName.hashValue
        }
    }
}

public func ==(lhs: QName, rhs: QName) -> Bool {
    return lhs.namespaceURI == rhs.namespaceURI
        && lhs.localName == rhs.localName
}
