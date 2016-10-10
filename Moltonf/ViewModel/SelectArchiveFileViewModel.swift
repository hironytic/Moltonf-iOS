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
    case Selected(String)
    case Cancelled
}

public class SelectArchiveFileViewModel: ViewModel {
    public let archiveFilesLine: Observable<[FileItem]>
    public let noItemsMessageHiddenLine: Observable<Bool>
    public let refreshingLine: Observable<Bool>
    public let cancelAction: AnyObserver<Void>
    public let refreshAction: AnyObserver<Void>
    public let selectAction: AnyObserver<FileItem>
    
    public var onResult: (SelectArchiveFileViewModelResult -> Void)? = nil
    
    private let _fileList: IFileList
    private let _cancelAction = ActionObserver<Void>()
    private let _refreshAction = ActionObserver<Void>()
    private let _selectAction = ActionObserver<FileItem>()
    
    public override init() {
        let directory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .AllDomainsMask, true)[0]
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
    
    private func cancel() {
        sendMessage(DismissingMessage())
        onResult?(.Cancelled)
    }
    
    private func refresh() {
        _fileList.reloadAction.onNext(())
    }
    
    private func select(item: FileItem) {
        sendMessage(DismissingMessage())
        onResult?(.Selected(item.filePath))
    }
}
