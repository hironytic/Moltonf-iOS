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

fileprivate typealias R = Resource

public protocol ITalkViewModel: IStoryElementViewModel {
    var numberLine: Observable<String?> { get }
    var numberHiddenLine: Observable<Bool> { get }
    var speakerNameLine: Observable<String?> { get }
    var speakerIconLine: Observable<UIImage?> { get }
    var timeLine: Observable<String?> { get }
    var messageTextLine: Observable<NSAttributedString?> { get }
    var balloonColorLine: Observable<UIColor> { get }
}

public class TalkViewModel: ViewModel, ITalkViewModel {
    public private(set) var numberLine: Observable<String?>
    public private(set) var numberHiddenLine: Observable<Bool>
    public private(set) var speakerNameLine: Observable<String?>
    public private(set) var speakerIconLine: Observable<UIImage?>
    public private(set) var timeLine: Observable<String?>
    public private(set) var messageTextLine: Observable<NSAttributedString?>
    public private(set) var balloonColorLine: Observable<UIColor>
    
    public init(talk: Talk) {
        numberLine = Observable
            .just(talk.publicTalkNo.flatMap({ "\($0)." }))
        numberHiddenLine = Observable
            .just(talk.publicTalkNo == nil)
        speakerNameLine = Observable
            .just(talk.speaker.fullName)
        speakerIconLine = { () -> Observable<UIImage> in
                switch talk.talkType {
                case .grave:
                    return talk.story?.graveIconImageLine ?? Observable.never()
                default:
                    return talk.speaker.faceIconImageLine
                }
            }()
            .map { image -> UIImage? in return image }
            .asDriver(onErrorJustReturn: nil).asObservable()
        timeLine = Observable
            .just(ResourceUtils.getString(format: R.String.timeFormat, talk.time.hourPart, talk.time.minutePart))
        messageTextLine = Observable
            .just(TalkViewModel.makeMessageText(talk.messageLines))
        let color: UIColor = { () in
            switch talk.talkType {
            case .public:
                return R.Color.balloonPublic
            case .wolf:
                return R.Color.balloonWolf
            case .grave:
                return R.Color.balloonGrave
            case .private:
                return R.Color.balloonPrivate
            }
        }()
        balloonColorLine = Observable
            .just(color)
        
        super.init()
    }
    
    static func makeMessageText(_ messageLines: [String]) -> NSAttributedString {
        let lines = (messageLines.isEmpty || messageLines.last != "") ? messageLines : Array(messageLines.dropLast())
        return NSAttributedString(string: lines.joined(separator: "\n"))
    }
}
