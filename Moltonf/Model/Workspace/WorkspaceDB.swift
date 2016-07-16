//
// WorkspaceDB.swift
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
import RealmSwift

private let WORKSPACE_DIR = "workspace"
private let WORKSPACE_DB = "workspace.realm"

public class WorkspaceDB {
    private static let _sharedInstanceLockObj = NSObject()
    private static weak var _sharedInstance: WorkspaceDB? = nil
    
    public let workspaceDirURL: NSURL
    public let realm: Realm
    
    private init() {
        workspaceDirURL = NSURL(fileURLWithPath: AppDelegate.privateDataDirectory).URLByAppendingPathComponent(WORKSPACE_DIR)
        _ = try? NSFileManager.defaultManager().createDirectoryAtURL(workspaceDirURL, withIntermediateDirectories: true, attributes: nil)
        
        let workspaceDBURL = workspaceDirURL.URLByAppendingPathComponent(WORKSPACE_DB)
        let config = Realm.Configuration(fileURL: workspaceDBURL)
        realm = try! Realm(configuration: config)
    }
    
    public static var sharedInstance: WorkspaceDB {
        var instance: WorkspaceDB? = nil
        synchronized(WorkspaceDB._sharedInstanceLockObj) {
            instance = WorkspaceDB._sharedInstance
            if (instance == nil) {
                instance = WorkspaceDB()
                WorkspaceDB._sharedInstance = instance
            }
        }
        return instance!
    }
}
