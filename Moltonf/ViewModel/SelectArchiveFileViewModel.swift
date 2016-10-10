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

import Foundation
import RxCocoa
import RxSwift

public enum SelectArchiveFileViewModelResult {
    case selected(String)
    case cancelled
}

open class SelectArchiveFileViewModel: ViewModel {
    open let archiveFilesLine: Observable<[FileItem]>
    open let noItemsMessageHiddenLine: Observable<Bool>
    open let refreshingLine: Observable<Bool>
    open let cancelAction: AnyObserver<Void>
    open let refreshAction: AnyObserver<Void>
    open let selectAction: AnyObserver<FileItem>
    
    open var onResult: ((SelectArchiveFileViewModelResult) -> Void)? = nil
    
    fileprivate let _fileList: IFileList
    fileprivate let _cancelAction = ActionObserver<Void>()
    fileprivate let _refreshAction = ActionObserver<Void>()
    fileprivate let _selectAction = ActionObserver<FileItem>()
    
    public override init() {
        let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)[0]
        _fileList = FileList(directory: directory)
        
        archiveFilesLine = _fileList.listLine.asDriver(onErrorJustReturn: []).asObservable()
        noItemsMessageHiddenLine = archiveFilesLine.map { !$0.isEmpty }
        refreshingLine = _fileList.refreshingLine.asDriver(onErrorJustReturn: false).asObservable()
        
        cancelAction = _cancelAction.asObserver()
        refreshAction = _refreshAction.asObserver()
        selectAction = _selectAction.asObserver()

        super.init()
        
        _cancelAction.handler = { [weak self] in self?.cancel() }
        _refreshAction.handler = { [weak self] in self?.refresh() }
        _selectAction.handler = { [weak self] item in self?.select(item) }
    }
    
    fileprivate func cancel() {
        sendMessage(DismissingMessage())
        onResult?(.cancelled)
    }
    
    fileprivate func refresh() {
        _fileList.reloadAction.onNext(())
    }
    
    fileprivate func select(_ item: FileItem) {
        sendMessage(DismissingMessage())
        onResult?(.selected(item.filePath))
    }
}
