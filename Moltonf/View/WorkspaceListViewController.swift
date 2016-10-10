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

open class WorkspaceListViewController: UITableViewController {
    var disposeBag: DisposeBag!
    let viewModel = WorkspaceListViewModel()
    
    @IBOutlet weak var addNewButton: UIBarButtonItem!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem

        bindViewModel()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func bindViewModel() {
        let viewModel = self.viewModel
        disposeBag = DisposeBag()

        addNewButton.rx_tap.bindTo(viewModel.addNewAction).addDisposableTo(disposeBag)

        viewModel.workspaceListLine
            .bindTo(tableView.rx_itemsWithDataSource(WorkspaceListDataSource()))
            .addDisposableTo(disposeBag)
        
        tableView.rx_itemDeleted
            .bindTo(viewModel.deleteAction)
            .addDisposableTo(disposeBag)
        
        tableView.rx_itemSelected
            .bindTo(viewModel.selectAction)
            .addDisposableTo(disposeBag)
        
        viewModel.messageLine
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
    
    fileprivate func transition(_ message: TransitionMessage) {
        switch message.viewModel {
        case let viewModel as SelectArchiveFileViewModel:
            let storyboard: UIStoryboard = UIStoryboard(name: "SelectArchiveFile", bundle: Bundle.main)
            let viewController: UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
            (viewController.topViewController as! SelectArchiveFileListViewController).viewModel = viewModel
            present(viewController, animated: true, completion: nil)
        case let viewModel as StoryWatchingViewModel:
            let storyboard: UIStoryboard = UIStoryboard(name: "StoryWatching", bundle: Bundle.main)
            let viewController: UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
            (viewController.topViewController as! StoryWatchingViewController).viewModel = viewModel
            present(viewController, animated: true, completion: nil)
        default:
            break
        }
        print("presentViewController \(message.viewModel)")
    }
    

}

open class WorkspaceListDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {
    public typealias Element = [WorkspaceListViewModelItem]
    
    fileprivate var _itemModels: Element = []
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _itemModels.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let element = _itemModels[(indexPath as NSIndexPath).row]
        
        cell.textLabel?.text = element.workspace.title
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing
    }
    
    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    open func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { (dataSource, element) in
            dataSource._itemModels = element
            tableView.reloadData()
        }
        .on(observedEvent)
    }
}
