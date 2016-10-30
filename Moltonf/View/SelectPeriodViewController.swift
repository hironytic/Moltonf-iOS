//
// SelectPeriodViewController.swift
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

fileprivate typealias R = ResourceConstants

public class SelectPeriodViewController: UITableViewController {
    private var disposeBag: DisposeBag!
    public var viewModel: ISelectPeriodViewModel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = R.Color.overlappedViewBackground
        
        bindViewModel()
    }

    private func bindViewModel() {
        disposeBag = DisposeBag()
        
        viewModel.periodsLine
            .bindTo(tableView.rx.items(cellIdentifier:"Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = element.title
                cell.accessoryType = element.checked ? .checkmark : .none
                cell.backgroundColor = R.Color.overlappedViewBackground
                cell.selectedBackgroundView = UIView()
                cell.selectedBackgroundView?.backgroundColor = R.Color.overlappedViewBackgroundSelected
            }
            .addDisposableTo(disposeBag)
        
        tableView.rx.modelSelected(SelectPeriodViewModelItem.self)
            .bindTo(viewModel.selectAction)
            .addDisposableTo(disposeBag)
        
        viewModel.messageLine
            .subscribe(onNext: { [weak self] message in
                switch message {
                case _ as DismissingMessage:
                    self?.dismiss(animated: true, completion: nil)
                default:
                    break
                }
            })
            .addDisposableTo(disposeBag)
    }
}

public class SelectPeriodPresentationController: UIPresentationController {
    private var overlay: UIView!
    
    private func heightOfChildController(withParentContainerSize parentSize: CGSize) -> CGFloat {
        return min(parentSize.height, min(parentSize.height / 2, 242))
    }
    
    public override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width, height: heightOfChildController(withParentContainerSize: parentSize))
    }
    
    public override var frameOfPresentedViewInContainerView: CGRect {
        let bounds = self.containerView?.bounds ?? CGRect.zero
        let height = heightOfChildController(withParentContainerSize: bounds.size)
        return CGRect(x: bounds.minX,
                      y: bounds.maxY - height,
                      width: bounds.width,
                      height: height)
    }
    
    public override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        if let containerView = self.containerView {
            // install overlay
            let overlay = UIView(frame: containerView.bounds)
            self.overlay = overlay
            overlay.backgroundColor = UIColor.black
            overlay.alpha = 0.0
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.addSubview(overlay)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SelectPeriodPresentationController.processOverlayTapped(_:)))
            overlay.addGestureRecognizer(tapGestureRecognizer)
            
            presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
                overlay.alpha = 0.5
                }, completion: nil)
        }
    }
    
    public override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] context in
            if let strongSelf = self {
                strongSelf.overlay.alpha = 0.0
            }
            }, completion: nil)
        
        super.dismissalTransitionWillBegin()
    }
    
    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            self.overlay.removeFromSuperview()
        }
        
        super.dismissalTransitionDidEnd(completed)
    }
    
    public override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    @objc private func processOverlayTapped(_ sender: Any) {
        if let presentedViewController = presentedViewController as? SelectPeriodViewController {
            presentedViewController.viewModel.cancelAction.onNext(())
        }
    }
}
