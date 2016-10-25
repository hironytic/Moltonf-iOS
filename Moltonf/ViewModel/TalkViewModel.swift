//
// TalkViewModel.swift
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

public protocol ITalkViewModel: IStoryElementViewModel {
    var numberLine: Observable<String?> { get }
    var speakerNameLine: Observable<String?> { get }
//    var speakerIconLine: Observable<UIImage> { get }
    var timeLine: Observable<String?> { get }
    var messageTextLine: Observable<NSAttributedString?> { get }
    var balloonColorLine: Observable<UIColor> { get }
}

public class TalkViewModel: ViewModel, ITalkViewModel {
    public private(set) var numberLine: Observable<String?>
    public private(set) var speakerNameLine: Observable<String?>
//    public private(set) var speakerIconLine: Observable<UIImage>
    public private(set) var timeLine: Observable<String?>
    public private(set) var messageTextLine: Observable<NSAttributedString?>
    public private(set) var balloonColorLine: Observable<UIColor>
    
    public init(talk: Talk) {
        numberLine = Observable
            .just(talk.publicTalkNo.flatMap({ "\($0)." }))
        speakerNameLine = Observable
            .just(talk.speaker.fullName)
        timeLine = Observable
            .just(String(format: "%02d:%02d", talk.time.hourPart, talk.time.minutePart))
        messageTextLine = Observable
            .just(TalkViewModel.makeMessageText(talk.messageLines))
        var color: UIColor
        switch talk.talkType {
        case .public:
            color = UIColor(red: 0xff / 0xff, green: 0xff / 0xff, blue: 0xff / 0xff, alpha: 1)
        case .wolf:
            color = UIColor(red: 0xff / 0xff, green: 0x77 / 0xff, blue: 0x77 / 0xff, alpha: 1)
        case .grave:
            color = UIColor(red: 0x9f / 0xff, green: 0x67 / 0xff, blue: 0xcf / 0xff, alpha: 1)
        case .private:
            color = UIColor(red: 0x93 / 0xff, green: 0x93 / 0xff, blue: 0x93 / 0xff, alpha: 1)
        }
        balloonColorLine = Observable
            .just(color)
        
        super.init()
    }
    
    static func makeMessageText(_ messageLines: [String]) -> NSAttributedString {
        let lines = (messageLines.isEmpty || messageLines.last != "") ? messageLines : Array(messageLines.dropLast())
        return NSAttributedString(string: lines.joined(separator: "\n"))
    }
}
