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
    let viewModel: IWorkspaceListViewModel = WorkspaceListViewModel()
    
    @IBOutlet weak var addNewButton: UIBarButtonItem!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.Moltonf.background
        self.navigationItem.rightBarButtonItem = self.editButtonItem

        bindViewModel()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func bindViewModel() {
        let viewModel = self.viewModel
        disposeBag = DisposeBag()

        addNewButton.rx.tap.bindTo(viewModel.addNewAction).addDisposableTo(disposeBag)

        viewModel.workspaceListLine
            .bindTo(tableView.rx.items(dataSource: WorkspaceListDataSource()))
            .addDisposableTo(disposeBag)
        
        tableView.rx.modelDeleted(WorkspaceListViewModelItem.self)
            .bindTo(viewModel.deleteAction)
            .addDisposableTo(disposeBag)
        
        tableView.rx.modelSelected(WorkspaceListViewModelItem.self)
            .bindTo(viewModel.selectAction)
            .addDisposableTo(disposeBag)
        
        viewModel.messageLine
            .subscribe(onNext: { [weak self] message in
                switch message {
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
        case let viewModel as ISelectArchiveFileViewModel:
            let storyboard: UIStoryboard = UIStoryboard(name: "SelectArchiveFile", bundle: Bundle.main)
            let viewController: UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
            (viewController.topViewController as! SelectArchiveFileViewController).viewModel = viewModel
            present(viewController, animated: true, completion: nil)
        case let viewModel as IStoryWatchingViewModel:
            let storyboard: UIStoryboard = UIStoryboard(name: "StoryWatching", bundle: Bundle.main)
            let viewController: UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
            (viewController.topViewController as! StoryWatchingViewController).viewModel = viewModel
            present(viewController, animated: true, completion: nil)
        default:
            break
        }
    }
    

}

public class WorkspaceListTableViewCell: UITableViewCell {
    public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            self.backgroundColor = UIColor.Moltonf.backgroundHighlighted
        } else {
            self.backgroundColor = UIColor.Moltonf.background
        }
    }    
}

public class WorkspaceListDataSource: NSObject {
    public typealias Element = [WorkspaceListViewModelItem]
    fileprivate var _itemModels: Element = []
}

extension WorkspaceListDataSource: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _itemModels.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let element = _itemModels[(indexPath as NSIndexPath).row]
        
        cell.textLabel?.text = element.workspace.title
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension WorkspaceListDataSource: RxTableViewDataSourceType {
    public func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { (dataSource, element) in
            dataSource._itemModels = element
            tableView.reloadData()
        }
        .on(observedEvent)
    }
}

extension WorkspaceListDataSource: SectionedViewDataSourceType {
    public func model(_ indexPath: IndexPath) throws -> Any {
        precondition(indexPath.section == 0)
        return _itemModels[indexPath.row]
    }
}
