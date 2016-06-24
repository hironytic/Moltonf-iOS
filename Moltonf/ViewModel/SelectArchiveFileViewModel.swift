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

public class SelectArchiveFileViewModel: ViewModel {
    public var messenger: Observable<Message>!
    
    public var archiveFiles: Observable<[ArchiveFileManager.FileItem]>!
    public var noItemsMessageHidden: Observable<Bool>!
    public var refreshing: Observable<Bool>!
    public var cancelAction: AnyObserver<Void>!
    public var refreshAction: AnyObserver<Void>!
    public var selectAction: AnyObserver<ArchiveFileManager.FileItem>!
    
    public enum Result {
        case Selected(String)
        case Cancelled
    }
    public var onResult: (Result -> Void)? = nil
    
    private let _listenerStore = ListenerStore()
    private let _messageSlot = MessageSlot()
    private let _archiveFileManager: ArchiveFileManager
    private let _archiveFilesSource = Variable<[ArchiveFileManager.FileItem]>([])
    private let _refreshingSource = Variable<Bool>(false)
    
    public init() {
        let directory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .AllDomainsMask, true)[0]
        _archiveFileManager = ArchiveFileManager(directory: directory)
        
        messenger = _messageSlot.messenger
        archiveFiles = _archiveFilesSource.asDriver().asObservable()
        noItemsMessageHidden = archiveFiles.map { !$0.isEmpty }
        refreshing = _refreshingSource.asDriver().asObservable()

        cancelAction = ActionObserver.asObserver { [weak self] in self?.cancel() }
        refreshAction = ActionObserver.asObserver { [weak self] in self?.refresh() }
        selectAction = ActionObserver.asObserver { [weak self] item in self?.select(item) }
        
        _archiveFilesSource.value = _archiveFileManager.archiveFiles
        _archiveFileManager.archiveFilesChanged.listen { [weak self] fileItem in
            self?._archiveFilesSource.value = fileItem
        }.addToStore(_listenerStore)
        
        _refreshingSource.value = _archiveFileManager.refreshing
        _archiveFileManager.refreshingChanged.listen { [weak self] value in
            self?._refreshingSource.value = value
        }.addToStore(_listenerStore)
    }
    
    private func cancel() {
        _messageSlot.send(DismissingMessage())
        onResult?(.Cancelled)
    }
    
    private func refresh() {
        _archiveFileManager.reloadFileList()
    }
    
    private func select(item: ArchiveFileManager.FileItem) {
        _messageSlot.send(DismissingMessage())
        onResult?(.Selected(item.filePath))
    }
}
