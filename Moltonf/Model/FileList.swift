//
// FileList.swift
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

public struct FileItem {
    let filePath: String
    let title: String
}

public protocol IFileList {
    var list: Observable<[FileItem]> { get }
    var refreshing: Observable<Bool> { get }
    
    var reloadAction: AnyObserver<Void> { get }
}

public class FileList: IFileList {
    public private(set) var list: Observable<[FileItem]>
    public private(set) var refreshing: Observable<Bool>
    public private(set) var reloadAction: AnyObserver<Void>
    
    private let _reloadAction = PublishSubject<Void>()
    
    private struct RefreshState {
        let list: [FileItem]?
        let refreshing: Bool
    }
    
    public init(directory: String) {
        reloadAction = _reloadAction.asObserver()
      
        let refreshState = _reloadAction
            .startWith(())
            .flatMapLatest {
                return FileList.reloadFileList(directory)
            }
            .shareReplay(1)
        
        list = refreshState
            .filter { $0.list != nil }
            .map { $0.list! }
        
        refreshing = refreshState
            .map { $0.refreshing }
    }
    
    private static func reloadFileList(directory: String) -> Observable<RefreshState> {
        return Observable
            .create { observer -> Disposable in
                observer.onNext(RefreshState(list: nil, refreshing: true))
                
                let fm = NSFileManager.defaultManager()
                let contents = (try? fm.contentsOfDirectoryAtPath(directory)) ?? []
                let list = contents
                    .filter { $0[$0.startIndex] != "." }    // exclude hidden files
                    .map { FileItem(filePath: (directory as NSString).stringByAppendingPathComponent($0), title: $0) }
                    .filter { item in   // exclude directories
                        var isDirectory: ObjCBool = false
                        return fm.fileExistsAtPath(item.filePath, isDirectory: &isDirectory) && !isDirectory.boolValue
                    }
                
                observer.onNext(RefreshState(list: list, refreshing: false))
                return NopDisposable.instance
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default))
    }
}
