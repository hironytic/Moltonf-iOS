//
// SelectArchiveFileViewModel.swift
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

import Eventitic
import Foundation
import RxCocoa
import RxSwift

public enum SelectArchiveFileViewModelResult {
    case Selected(String)
    case Cancelled
}

public class SelectArchiveFileViewModel: ViewModel {
    public private(set) var archiveFiles: Observable<[FileItem]>
    public private(set) var noItemsMessageHidden: Observable<Bool>
    public private(set) var refreshing: Observable<Bool>
    public var cancelAction: AnyObserver<Void> {
        get {
            return _cancelAction
        }
    }
    public var refreshAction: AnyObserver<Void> {
        get {
            return _refreshAction
        }
    }
    public var selectAction: AnyObserver<FileItem> {
        get {
            return _selectAction
        }
    }
    
    public var onResult: (SelectArchiveFileViewModelResult -> Void)? = nil
    
    private let _listenerStore = ListenerStore()
    private let _fileList: FileList
    private let _archiveFilesSource = Variable<[FileItem]>([])
    private let _refreshingSource = Variable<Bool>(false)
    private var _cancelAction: AnyObserver<Void>!
    private var _refreshAction: AnyObserver<Void>!
    private var _selectAction: AnyObserver<FileItem>!
    
    public override init() {
        let directory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .AllDomainsMask, true)[0]
        _fileList = FileList(directory: directory)
        
        archiveFiles = _archiveFilesSource.asDriver().asObservable()
        noItemsMessageHidden = archiveFiles.map { !$0.isEmpty }
        refreshing = _refreshingSource.asDriver().asObservable()

        super.init()
        
        _cancelAction = ActionObserver.asObserver { [weak self] in self?.cancel() }
        _refreshAction = ActionObserver.asObserver { [weak self] in self?.refresh() }
        _selectAction = ActionObserver.asObserver { [weak self] item in self?.select(item) }
        
        _archiveFilesSource.value = _fileList.list
        _fileList.listChanged
            .listen { [weak self] fileItem in
                self?._archiveFilesSource.value = fileItem
            }
            .addToStore(_listenerStore)
        
        _refreshingSource.value = _fileList.refreshing
        _fileList.refreshingChanged
            .listen { [weak self] value in
                self?._refreshingSource.value = value
            }
            .addToStore(_listenerStore)
    }
    
    private func cancel() {
        sendMessage(DismissingMessage())
        onResult?(.Cancelled)
    }
    
    private func refresh() {
        _fileList.reloadFileList()
    }
    
    private func select(item: FileItem) {
        sendMessage(DismissingMessage())
        onResult?(.Selected(item.filePath))
    }
}
