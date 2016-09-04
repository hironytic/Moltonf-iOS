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
    var disposeBag: DisposeBag!
    var viewModel: StoryWatchingViewModel!

    public override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
    }
    
    private func bindViewModel() {
        let viewModel = self.viewModel
        disposeBag = DisposeBag()
        
        viewModel.elementsList
            .bindTo(tableView.rx_itemsWithDataSource(StoryWatchingDataSource()))
            .addDisposableTo(disposeBag)
    }

}

public class StoryWatchingDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {
    public typealias Element = [StoryElementViewModel]
    
    private var _itemModels: Element = []
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _itemModels.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let elementViewModel = _itemModels[indexPath.row]
        switch elementViewModel {
        case let eventViewModel as StoryEventViewModel:
            let cell = tableView.dequeueReusableCellWithIdentifier("Event", forIndexPath: indexPath) as! StoryEventTableViewCell
            cell.viewModel = eventViewModel
            return cell
        case /* let talkViewModel as */ is TalkViewModel:
            return tableView.dequeueReusableCellWithIdentifier("Talk", forIndexPath: indexPath)
//            let cell = tableView.dequeueReusableCellWithIdentifier("Talk", forIndexPath: indexPath) as! TalkTableViewCell
//            cell.viewModel = talkViewModel
//            return cell
        default:
            break
        }

        fatalError()
    }
    
    public func tableView(tableView: UITableView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { (dataSource, element) in
            dataSource._itemModels = element
            tableView.reloadData()
        }
        .on(observedEvent)
    }
}
