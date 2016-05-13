//
// ArchiveFileManager.swift
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
import Eventitic

class ArchiveFileManager {
    class FileItem {
        let filePath: String
        let title: String
        
        init(filePath: String, title: String) {
            self.filePath = filePath
            self.title = title
        }
    }

    let archiveFilesChanged = EventSource<[FileItem]>()
    private(set) var archiveFiles: [FileItem] = [] {
        didSet {
            archiveFilesChanged.fire(archiveFiles)
        }
    }
    
    let refreshingChanged = EventSource<Bool>()
    private(set) var refreshing: Bool = false {
        didSet {
            refreshingChanged.fire(refreshing)
        }
    }
    
    private let _directory: String
    
    init(directory: String) {
        _directory = directory
        
        reloadFileList()
    }

    func reloadFileList() {
        do {
            refreshing = true
            defer { refreshing = false }
        
            let fm = NSFileManager.defaultManager()
            let contents = (try? fm.contentsOfDirectoryAtPath(_directory)) ?? []
            archiveFiles = contents
                .filter { $0[$0.startIndex] != "." }    // exclude hidden files
                .map { FileItem(filePath: (_directory as NSString).stringByAppendingPathComponent($0), title: $0) }
                .filter { item in   // exclude directories
                    var isDirectory: ObjCBool = false
                    return fm.fileExistsAtPath(item.filePath, isDirectory: &isDirectory) && !isDirectory.boolValue
                }
        }
    }
}
