//
// WorkspaceListViewModel.swift
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
import RxCocoa

open class WorkspaceListViewModelItem {
    open let workspace: Workspace
    
    public init(workspace: Workspace) {
        self.workspace = workspace
    }
}

open class WorkspaceListViewModel: ViewModel {
    open let workspaceListLine: Observable<[WorkspaceListViewModelItem]>
    open let addNewAction: AnyObserver<Void>
    open let deleteAction: AnyObserver<IndexPath>
    open let selectAction: AnyObserver<IndexPath>
    
    fileprivate let _disposeBag = DisposeBag()
    fileprivate let _workspaceStore: IWorkspaceStore = WorkspaceStore()
    fileprivate let _workspaceList = Variable<[WorkspaceListViewModelItem]>([])
    fileprivate let _addNewAction = ActionObserver<Void>()
    fileprivate let _deleteAction = ActionObserver<IndexPath>()
    fileprivate let _selectAction = ActionObserver<IndexPath>()
    
    public override init() {
        workspaceListLine = _workspaceList.asDriver().asObservable()
        addNewAction = _addNewAction.asObserver()
        deleteAction = _deleteAction.asObserver()
        selectAction = _selectAction.asObserver()
        
        _workspaceStore.workspacesLine
            .scan([], accumulator: WorkspaceListViewModel.workspaceStoreChangeScanner)
            .bindTo(_workspaceList)
            .addDisposableTo(_disposeBag)
        
        super.init()
        
        _addNewAction.handler = { [weak self] in self?.addNew() }
        _deleteAction.handler = { [weak self] indexPath in self?.delete(at: indexPath) }
        _selectAction.handler = { [weak self] indexPath in self?.select(indexPath) }
    }
    
    fileprivate func addNew() {
        let selectArchiveFileViewModel = SelectArchiveFileViewModel()
        selectArchiveFileViewModel.onResult = { [weak self] result in
            self?.processSelectArchiveFileResult(result)
        }
        sendMessage(TransitionMessage(viewModel: selectArchiveFileViewModel))
    }
    
    fileprivate func processSelectArchiveFileResult(_ result: SelectArchiveFileViewModelResult) {
        switch result {
        case .selected(let path):
            _workspaceStore.createNewWorkspaceAction.onNext(path)
        default:
            break
        }
    }
    
    fileprivate func delete(at indexPath: IndexPath) {
        let listItem = _workspaceList.value[(indexPath as NSIndexPath).row]
        _workspaceStore.deleteWorkspaceAction.onNext(listItem.workspace)
    }

    fileprivate func select(_ indexPath: IndexPath) {
        let listItem = _workspaceList.value[(indexPath as NSIndexPath).row]
        let workspace = listItem.workspace
        do {
            let storyWatching = try StoryWatching(workspace: workspace)
            let storyWatchingViewModel = StoryWatchingViewModel(storyWatching: storyWatching)
            sendMessage(TransitionMessage(viewModel: storyWatchingViewModel))
        } catch let error {
            print(error)
            // TODO:
        }
    }
    
    fileprivate static func workspaceStoreChangeScanner(_ list: [WorkspaceListViewModelItem], changes: WorkspaceStoreChanges) -> [WorkspaceListViewModelItem] {
        var list = list
        
        // remove deleted items
        for index in changes.deletions.reversed() {
            list.remove(at: index)
        }
        
        // insert new items
        for index in changes.insertions {
            list.insert(WorkspaceListViewModelItem(workspace: changes.workspaces[AnyIndex(index)]), at: index)
        }
        
        // replace modified items
        for index in changes.modifications {
            let item = WorkspaceListViewModelItem(workspace: changes.workspaces[AnyIndex(index)])
            list[index] = item
        }

        return list
    }
}
