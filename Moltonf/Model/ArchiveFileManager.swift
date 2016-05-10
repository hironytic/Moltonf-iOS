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
import RxSwift

class ArchiveFileManager {
    class FileItem {
        let filePath: String
        let title: String
        
        init(filePath: String, title: String) {
            self.filePath = filePath
            self.title = title
        }
    }
    
    var archiveFiles: Observable<[FileItem]>!
    
    private let _directory: String
    private let _fileList = Variable<[FileItem]>([])
    
    init(directory: String) {
        _directory = directory
        archiveFiles = _fileList.asObservable()
        
        loadFileList()
    }
    
    func loadFileList() {
        let fm = NSFileManager.defaultManager()
        let contents = (try? fm.contentsOfDirectoryAtPath(_directory)) ?? []
        _fileList.value = contents
            .map { FileItem(filePath: (_directory as NSString).stringByAppendingPathComponent($0), title: $0) }
            .filter { item in   // exclude directories
                var isDirectory: ObjCBool = false
                return fm.fileExistsAtPath(item.filePath, isDirectory: &isDirectory) && !isDirectory.boolValue
            }
    }
}