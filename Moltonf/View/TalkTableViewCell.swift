//
// TalkTableViewCell.swift
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
import RxSwift
import RxCocoa

class TalkTableViewCell: UITableViewCell {
    @IBOutlet weak var talkNumberLabel: UILabel!
    @IBOutlet weak var speakerNameLabel: UILabel!
    @IBOutlet weak var talkTimeLabel: UILabel!
    @IBOutlet weak var speakerIconImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var balloonView: TalkBalloonView!
    
    var disposeBag: DisposeBag?

    public override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(TalkTableViewCell.preferredContentSizeChanged(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }

    public func preferredContentSizeChanged(_ notification: Notification) {
        messageLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
    }
    
    public var viewModel: ITalkViewModel? {
        didSet {
            self.disposeBag = nil
            guard let viewModel = viewModel else { return }
            
            let disposeBag = DisposeBag()
            
            viewModel.numberLine
                .bindTo(talkNumberLabel.rx.text)
                .addDisposableTo(disposeBag)
            
            viewModel.numberHiddenLine
                .bindTo(talkNumberLabel.rx.isHidden)
                .addDisposableTo(disposeBag)
            
            viewModel.speakerNameLine
                .bindTo(speakerNameLabel.rx.text)
                .addDisposableTo(disposeBag)
            
            viewModel.timeLine
                .bindTo(talkTimeLabel.rx.text)
                .addDisposableTo(disposeBag)
            
            viewModel.speakerIconLine
                .bindTo(speakerIconImageView.rx.image)
                .addDisposableTo(disposeBag)
            
            viewModel.messageTextLine
                .bindTo(messageLabel.rx.attributedText)
                .addDisposableTo(disposeBag)
            
            viewModel.balloonColorLine
                .bindTo(balloonView.rx.backgroundColor)
                .addDisposableTo(disposeBag)
            
            self.disposeBag = disposeBag
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        self.viewModel = nil
    }
}

public class TalkBalloonView: UIView {
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.layer.cornerRadius = 5
    }
}

extension Reactive where Base: TalkBalloonView {
    public var backgroundColor: AnyObserver<UIColor> {
        return UIBindingObserver(UIElement: self.base) { view, color in
            view.backgroundColor = color
        }.asObserver()
    }
}
