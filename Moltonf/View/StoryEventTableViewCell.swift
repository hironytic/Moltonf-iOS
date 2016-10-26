//
// StoryEventTableViewCell.swift
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

public class StoryEventTableViewCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var borderedView: StoryEventBorderedView!

    var disposeBag: DisposeBag?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(StoryEventTableViewCell.preferredContentSizeChanged(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    public func preferredContentSizeChanged(_ notification: Notification) {
        messageLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
    }
    
    public var viewModel: IStoryEventViewModel? {
        didSet {
            self.disposeBag = nil
            guard let viewModel = viewModel else { return }
            
            let disposeBag = DisposeBag()

            viewModel.messageTextLine
                .bindTo(messageLabel.rx.text)
                .addDisposableTo(disposeBag)
            
            viewModel.messageColorLine
                .bindTo(borderedView.rx.borderColor)
                .addDisposableTo(disposeBag)
            
            viewModel.messageColorLine
                .bindTo(messageLabel.rx.textColor)
                .addDisposableTo(disposeBag)
            
            self.disposeBag = disposeBag
        }
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        
        self.viewModel = nil
    }    
}

public class StoryEventBorderedView: UIView {
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.layer.borderWidth = 1
    }
}

extension Reactive where Base: StoryEventBorderedView {
    public var borderColor: AnyObserver<UIColor> {
        return UIBindingObserver(UIElement: self.base) { view, color in
            view.layer.borderColor = color.cgColor
        }.asObserver()
    }
}
