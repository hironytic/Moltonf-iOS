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

public struct WorkspaceListViewModelItem {
    public let workspace: Workspace
}

public protocol IWorkspaceListViewModel: IViewModel {
    var workspaceListLine: Observable<[WorkspaceListViewModelItem]> { get }
    
    var addNewAction: AnyObserver<Void> { get }
    var deleteAction: AnyObserver<WorkspaceListViewModelItem> { get }
    var selectAction: AnyObserver<WorkspaceListViewModelItem> { get }
}

public class WorkspaceListViewModel: ViewModel, IWorkspaceListViewModel {
    public private(set) var workspaceListLine: Observable<[WorkspaceListViewModelItem]>
    public private(set) var addNewAction: AnyObserver<Void>
    public private(set) var deleteAction: AnyObserver<WorkspaceListViewModelItem>
    public private(set) var selectAction: AnyObserver<WorkspaceListViewModelItem>
    
    private let _factory: Factory
    private let _disposeBag = DisposeBag()
    private let _workspaceStore: IWorkspaceStore = WorkspaceStore()
    private let _workspaceList = Variable<[WorkspaceListViewModelItem]>([])
    private let _addNewAction = ActionObserver<Void>()
    private let _deleteAction = ActionObserver<WorkspaceListViewModelItem>()
    private let _selectAction = ActionObserver<WorkspaceListViewModelItem>()
    
    class Factory {
        func selectArchiveFileViewModel() -> ISelectArchiveFileViewModel {
            return SelectArchiveFileViewModel()
        }
        
        func storyWatching(workspace: Workspace) throws -> IStoryWatching {
            return try StoryWatching(workspace: workspace)
        }
        
        func storyWatchingViewModel(storyWatching: IStoryWatching) -> IStoryWatchingViewModel {
            return StoryWatchingViewModel(storyWatching: storyWatching)
        }
    }
    
    public convenience override init() {
        self.init(factory: Factory())
    }
    init(factory: Factory) {
        _factory = factory
        workspaceListLine = _workspaceList.asDriver().asObservable()
        addNewAction = _addNewAction.asObserver()
        deleteAction = _deleteAction.asObserver()
        selectAction = _selectAction.asObserver()
        
        _workspaceStore.workspacesLine
            .scan([], accumulator: WorkspaceListViewModel.workspaceStoreChangeScanner)
            .bindTo(_workspaceList)
            .addDisposableTo(_disposeBag)

        // TODO:
        _workspaceStore.errorLine
            .subscribe(onNext: { error in
                dump(error)
            })
            .addDisposableTo(_disposeBag)
        
        super.init()
        
        _addNewAction.handler = { [weak self] in self?.addNew() }
        _deleteAction.handler = { [weak self] listItem in self?.delete(listItem) }
        _selectAction.handler = { [weak self] listItem in self?.select(listItem) }
    }
    
    private func addNew() {
        let selectArchiveFileViewModel: ISelectArchiveFileViewModel = _factory.selectArchiveFileViewModel()
        selectArchiveFileViewModel.onResult = { [weak self] result in
            self?.processSelectArchiveFileResult(result)
        }
        sendMessage(TransitionMessage(viewModel: selectArchiveFileViewModel))
    }
    
    private func processSelectArchiveFileResult(_ result: SelectArchiveFileViewModelResult) {
        switch result {
        case .selected(let path):
            _workspaceStore.createNewWorkspaceAction.onNext(path)
        default:
            break
        }
    }
    
    private func delete(_ listItem: WorkspaceListViewModelItem) {
        _workspaceStore.deleteWorkspaceAction.onNext(listItem.workspace)
    }

    private func select(_ listItem: WorkspaceListViewModelItem) {
        let workspace = listItem.workspace
        do {
            let storyWatching = try _factory.storyWatching(workspace: workspace)
            let storyWatchingViewModel = _factory.storyWatchingViewModel(storyWatching: storyWatching)
            sendMessage(TransitionMessage(viewModel: storyWatchingViewModel))
        } catch let error {
            dump(error)
            // TODO:
        }
    }
    
    private static func workspaceStoreChangeScanner(_ list: [WorkspaceListViewModelItem], changes: WorkspaceStoreChanges) -> [WorkspaceListViewModelItem] {
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
