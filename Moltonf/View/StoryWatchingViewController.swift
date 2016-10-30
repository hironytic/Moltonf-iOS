//
// StoryWatchingViewController.swift
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

fileprivate typealias R = Resource

public class StoryWatchingViewController: UITableViewController {
    @IBOutlet weak var selectPeriodButtonItem: UIBarButtonItem!
    var backButtonItem: UIBarButtonItem!
    
    var disposeBag: DisposeBag!
    var viewModel: IStoryWatchingViewModel!

    public override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = R.Color.background
        
        tableView.estimatedRowHeight = 132
        tableView.rowHeight = UITableViewAutomaticDimension
        
        backButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)
        navigationItem.leftBarButtonItem = backButtonItem
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        disposeBag = DisposeBag()
        
        let dataSource = StoryWatchingDataSource()
        viewModel.elementListLine
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)

        viewModel.titleLine
            .bindTo(rx.title)
            .addDisposableTo(disposeBag)
        
        viewModel.currentPeriodTextLine
            .bindTo(selectPeriodButtonItem.rx.title)
            .addDisposableTo(disposeBag)
        
        backButtonItem.rx.tap
            .bindTo(viewModel.leaveWatchingAction)
            .addDisposableTo(disposeBag)
        
        selectPeriodButtonItem.rx.tap
            .bindTo(viewModel.selectPeriodAction)
            .addDisposableTo(disposeBag)
        
        viewModel.messageLine
            .subscribe(onNext: { [weak self] message in
                switch message {
                case _ as DismissingMessage:
                    self?.dismiss(animated: true, completion: nil)
                case let transitionMessage as TransitionMessage:
                    self?.transition(transitionMessage)
                default:
                    break
                }
                })
            .addDisposableTo(disposeBag)
    }

    private func transition(_ message: TransitionMessage) {
        switch message.viewModel {
        case let viewModel as ISelectPeriodViewModel:
            let storyboard: UIStoryboard = UIStoryboard(name: R.Id.selectPeriod, bundle: Bundle.main)
            let viewController = storyboard.instantiateInitialViewController() as! SelectPeriodViewController
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = self
            viewController.viewModel = viewModel
            present(viewController, animated: true, completion: nil)
        default:
            break
        }
    }
}

extension StoryWatchingViewController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        switch presented {
        case _ as SelectPeriodViewController:
            return SelectPeriodPresentationController(presentedViewController: presented, presenting: presenting)
        default:
            fatalError("Don't know custom presentation controller about this view controller.")
        }
    }
}

public class StoryWatchingDataSource: NSObject {
    fileprivate var _itemModels: [IStoryElementViewModel] = []
}

extension StoryWatchingDataSource: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _itemModels.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let elementViewModel = _itemModels[(indexPath as NSIndexPath).row]
        let cell = { () -> UITableViewCell in
            switch elementViewModel {
            case let eventViewModel as IStoryEventViewModel:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.Id.event, for: indexPath) as! StoryEventTableViewCell
                cell.viewModel = eventViewModel
                return cell
            case let talkViewModel as ITalkViewModel:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.Id.talk, for: indexPath) as! TalkTableViewCell
                cell.viewModel = talkViewModel
                return cell
            default:
                fatalError()
            }
        }()
        
        cell.backgroundColor = R.Color.background
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = R.Color.backgroundSelected
        return cell
    }
}

extension StoryWatchingDataSource: RxTableViewDataSourceType {
    public typealias Element = StoryWatchingViewModelElementList
    
    public func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { (dataSource, elementList) in
            dataSource._itemModels = elementList.items
            tableView.reloadData()
            if elementList.shouldScrollToTop {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
        .on(observedEvent)
    }
}
