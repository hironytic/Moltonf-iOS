//
// StoryEventViewModel.swift
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
import RxSwift
import UIKit

public protocol IStoryEventViewModel: IStoryElementViewModel {
    var messageTextLine: Observable<String?> { get }
    var messageColorLine: Observable<UIColor> { get }
}

public class StoryEventViewModel: ViewModel, IStoryEventViewModel {
    public private(set) var messageTextLine: Observable<String?>
    public private(set) var messageColorLine: Observable<UIColor>
    
    public init(storyEvent: StoryEvent) {
        messageTextLine = Observable
            .just(storyEvent.messageLines.joined(separator: "\n"))
        
        var color: UIColor
        switch storyEvent.eventFamily {
        case .announce:
            color = UIColor(red: 0xdd / 0xff, green: 0xdd / 0xff, blue: 0xdd / 0xff, alpha: 1)
        case .order:
            color = UIColor(red: 0xff / 0xff, green: 0x44 / 0xff, blue: 0x44 / 0xff, alpha: 1)
        case .extra:
            color = UIColor(red: 0x88 / 0xff, green: 0x88 / 0xff, blue: 0x88 / 0xff, alpha: 1)
        }
        messageColorLine = Observable
            .just(color)
        
        super.init()
    }
}
