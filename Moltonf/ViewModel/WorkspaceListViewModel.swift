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
import Eventitic

public class WorkspaceListViewModel: ViewModel {
    public class WorkspaceListItem {
        let workspace: Workspace
        
        public init(workspace: Workspace) {
            self.workspace = workspace
        }
    }
    
    public var messenger: Observable<Message>!
    public var workspaceList: Observable<[WorkspaceListItem]>!
    public var addNewAction: AnyObserver<Void>!
    
    private let _listenerStore = ListenerStore()
    private let _workspaceStore = WorkspaceStore()
    private let _messageSlot = MessageSlot()
    private let _workspaceListSource = Variable<[WorkspaceListItem]>([])
    
    public init() {
        messenger = _messageSlot.messenger
        workspaceList = _workspaceListSource.asDriver().asObservable()
        
        addNewAction = ActionObserver.asObserver { [weak self] in self?.addNew() }

        _workspaceListSource.value = Array(_workspaceStore.workspaces)
            .map { workspace in
                WorkspaceListItem(workspace: workspace)
            }
        _workspaceStore.workspacesChanged
            .listen { [weak self] changes in
                self?.workspaceChanged(changes)
            }
            .addToStore(_listenerStore)
    }
    
    private func addNew() {
        let selectArchiveFileViewModel = SelectArchiveFileViewModel()
        selectArchiveFileViewModel.onResult = { [weak self] result in
            self?.processSelectArchiveFileResult(result)
        }
        _messageSlot.send(TransitionMessage(viewModel: selectArchiveFileViewModel))
    }
    
    private func processSelectArchiveFileResult(result: SelectArchiveFileViewModelResult) {
        switch result {
        case .Selected(let path):
            _workspaceStore.createNewWorkspace(archiveFile: path)
        default:
            break
        }
    }
    
    private func workspaceChanged(changes: WorkspaceStoresChanges) {
        var list = _workspaceListSource.value
            
        // remove deleted items
        for index in changes.deletions.reverse() {
            list.removeAtIndex(index)
        }
        
        // insert new items
        for index in changes.insertions {
            list.insert(WorkspaceListItem(workspace: changes.workspaces[AnyRandomAccessIndex(index)]), atIndex: index)
        }
        
        // replace modified items
        for index in changes.modifications {
            let item = WorkspaceListItem(workspace: changes.workspaces[AnyRandomAccessIndex(index)])
            list[index] = item
        }

        _workspaceListSource.value = list
    }
}
