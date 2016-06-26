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

public class WorkspaceListViewModel: ViewModel {
    public class WorkspaceListItem {
        let core: WorkspaceManager.WorkspaceItem
        
        public init(core: WorkspaceManager.WorkspaceItem) {
            self.core = core
        }
    }
    
    public var messenger: Observable<Message>!
    public var workspaceList: Observable<[WorkspaceListItem]>!
    public var addNewAction: AnyObserver<Void>!
    
    private let _workspaceManager = WorkspaceManager.sharedInstance
    private let _messageSlot = MessageSlot()
    private let _workspaceListSource = Variable<[WorkspaceListItem]>([])
    
    public init() {
        messenger = _messageSlot.messenger
        workspaceList = _workspaceListSource.asDriver().asObservable()
        
        addNewAction = ActionObserver.asObserver { [weak self] in self?.addNew() }
        
        // FIXME: dummy
        let list = [
            WorkspaceListItem(core: WorkspaceManager.WorkspaceItem(id: "1", title: "title 1", path: "foo")),
            WorkspaceListItem(core: WorkspaceManager.WorkspaceItem(id: "2", title: "title 2", path: "bar")),
            WorkspaceListItem(core: WorkspaceManager.WorkspaceItem(id: "3", title: "title 3", path: "baz")),
        ]
        _workspaceListSource.value = list
    }
    
    private func addNew() {
        let selectArchiveFileViewModel = SelectArchiveFileViewModel()
        selectArchiveFileViewModel.onResult = { [weak self] result in
            self?.processSelectArchiveFileResult(result)
        }
        _messageSlot.send(TransitionMessage(viewModel: selectArchiveFileViewModel))
    }
    
    private func processSelectArchiveFileResult(result: SelectArchiveFileViewModel.Result) {
        // FIXME:
        var list = _workspaceListSource.value
        list.append(WorkspaceListItem(core: WorkspaceManager.WorkspaceItem(id: "xxx", title: "xxx", path: "fff")))
        _workspaceListSource.value = list
    }
}
