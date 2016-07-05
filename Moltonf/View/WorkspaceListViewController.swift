//
// WorkspaceListViewController.swift
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

public class WorkspaceListViewController: UITableViewController {
    var disposeBag: DisposeBag!
    let viewModel = WorkspaceListViewModel()
    
    @IBOutlet weak var addNewButton: UIBarButtonItem!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()

        bindViewModel()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func bindViewModel() {
        let viewModel = self.viewModel
        disposeBag = DisposeBag()

        addNewButton.rx_tap.bindTo(viewModel.addNewAction).addDisposableTo(disposeBag)

        viewModel.workspaceList
            .bindTo(tableView.rx_itemsWithDataSource(WorkspaceListDataSource()))
            .addDisposableTo(disposeBag)
        
        tableView.rx_itemDeleted
            .bindTo(viewModel.deleteAction)
            .addDisposableTo(disposeBag)
        
        viewModel.messenger
            .subscribeNext { [weak self] message in
                switch message {
                case let transitionMessage as TransitionMessage:
                    self?.transition(transitionMessage)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    private func transition(message: TransitionMessage) {
        switch message.viewModel {
        case let viewModel as SelectArchiveFileViewModel:
            let storyboard: UIStoryboard = UIStoryboard(name: "SelectArchiveFile", bundle: NSBundle.mainBundle())
            let viewController: UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
            (viewController.topViewController as! SelectArchiveFileListViewController).viewModel = viewModel
            presentViewController(viewController, animated: true, completion: nil)
        default:
            break
        }
        print("presentViewController \(message.viewModel)")
    }
    

}

public class WorkspaceListDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {
    public typealias Element = [WorkspaceListViewModelItem]
    
    private var _itemModels: Element = []
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _itemModels.count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let element = _itemModels[indexPath.row]
        
        cell.textLabel?.text = element.workspace.title
        
        return cell
    }
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return tableView.editing
    }
    
    public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    public func tableView(tableView: UITableView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { (dataSource, element) in
            dataSource._itemModels = element
            tableView.reloadData()
        }
        .on(observedEvent)
    }
}
