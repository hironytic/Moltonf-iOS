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

class SelectArchiveFileViewModel: ViewModel {
    var messenger: Observable<Message>!
    var archiveFiles: Driver<[ArchiveFileManager.FileItem]>!
    var closeAction: AnyObserver<Void>!
    var refreshAction: AnyObserver<Void>!
    var selectAction: AnyObserver<ArchiveFileManager.FileItem>!
    
    private let _listenerStore = ListenerStore()
    private let _messageSlot = MessageSlot()
    private let _archiveFileManager: ArchiveFileManager
    private let _archiveFilesSource = Variable<[ArchiveFileManager.FileItem]>([])
    
    init() {
        let directory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .AllDomainsMask, true)[0]
        _archiveFileManager = ArchiveFileManager(directory: directory)
        
        messenger = _messageSlot.messenger
        archiveFiles = _archiveFilesSource.asDriver()

        closeAction = ActionObserver.asObserver { [weak self] in self?.close() }
        refreshAction = ActionObserver.asObserver { [weak self] in self?.refresh() }
        selectAction = ActionObserver.asObserver { [weak self] item in self?.select(item) }
        
        _archiveFilesSource.value = _archiveFileManager.archiveFiles
        _archiveFileManager.archiveFilesChanged.listen { [weak self] fileItem in
            self?._archiveFilesSource.value = fileItem
        }.addToStore(_listenerStore)
    }
    
    private func close() {
        _messageSlot.send(DismissingMessage())
    }
    
    private func refresh() {
        _archiveFileManager.reloadFileList()
    }
    
    private func select(item: ArchiveFileManager.FileItem) {
        print("selected: \(item.title)")
        _messageSlot.send(DismissingMessage())
    }
}
