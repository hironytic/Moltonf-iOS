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

public class StoryWatchingViewController: UITableViewController {
    var backButtonItem: UIBarButtonItem!
    
    var disposeBag: DisposeBag!
    var viewModel: IStoryWatchingViewModel!

    public override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 132
        tableView.rowHeight = UITableViewAutomaticDimension
        
        backButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)
        navigationItem.leftBarButtonItem = backButtonItem
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        disposeBag = DisposeBag()
        
        let dataSource = StoryWatchingDataSource()
        viewModel.elementsListLine
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)

        backButtonItem.rx.tap
            .bindTo(viewModel.leaveWatchingAction)
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

public class StoryWatchingDataSource: NSObject {
    fileprivate var _itemModels: Element = []
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
        switch elementViewModel {
        case let eventViewModel as IStoryEventViewModel:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Event", for: indexPath) as! StoryEventTableViewCell
            cell.viewModel = eventViewModel
            return cell
        case let talkViewModel as ITalkViewModel:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Talk", for: indexPath) as! TalkTableViewCell
            cell.viewModel = talkViewModel
            return cell
        default:
            break
        }

        fatalError()
    }
}

extension StoryWatchingDataSource: RxTableViewDataSourceType {
    public typealias Element = [IStoryElementViewModel]
    
    public func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { (dataSource, element) in
            dataSource._itemModels = element
            tableView.reloadData()
        }
        .on(observedEvent)
    }
}
