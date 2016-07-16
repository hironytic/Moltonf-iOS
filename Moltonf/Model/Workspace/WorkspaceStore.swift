//
// WorkspaceStore.swift
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
import RealmSwift
import SwiftyJSON
import SwiftTask

private let WORKSPACE_DIR = "workspace"
private let WORKSPACE_DB = "workspace.realm"

public enum WorkspaceStoreError: ErrorType {
    case CreateNewWorkspaceFailed(String)
}

public typealias WorkspaceStoresChanges = (workspaces: AnyRandomAccessCollection<Workspace>, deletions: [Int], insertions: [Int], modifications: [Int])

public class WorkspaceStore {
    public let errorOccurred = EventSource<ErrorType>()
    public let workspacesChanged = EventSource<WorkspaceStoresChanges>()
    public private(set) var workspaces: AnyRandomAccessCollection<Workspace>
    public let workspaceLoaded = EventSource<GameWatching>()
    
    private let _realm: Realm
    private var _notificationToken: NotificationToken!
    private let _workspaceDirURL: NSURL
    private let _workspaces: Results<Workspace>
    
    public init() {
        _workspaceDirURL = NSURL(fileURLWithPath: AppDelegate.privateDataDirectory).URLByAppendingPathComponent(WORKSPACE_DIR)
        _ = try? NSFileManager.defaultManager().createDirectoryAtURL(_workspaceDirURL, withIntermediateDirectories: true, attributes: nil)
        
        let workspaceDBURL = _workspaceDirURL.URLByAppendingPathComponent(WORKSPACE_DB)
        let config = Realm.Configuration(fileURL: workspaceDBURL)
        _realm = try! Realm(configuration: config)
        _workspaces = _realm.objects(Workspace)
        workspaces = AnyRandomAccessCollection<Workspace>(_workspaces)
      
        _notificationToken = _workspaces.addNotificationBlock { [weak self] changes in
            switch changes {
            case .Update(let results, let deletions, let insertions, let modifications):
                self?.workspacesChanged.fire((workspaces: AnyRandomAccessCollection(results), deletions: deletions, insertions: insertions, modifications: modifications))
                break
            default:
                break
            }
        }
    }
    
    deinit {
        _notificationToken.stop()
    }
    
    public func createNewWorkspace(archiveFile archiveFile: String) {
        let id = NSUUID().UUIDString

        guard let archiveJSONDir = _workspaceDirURL.URLByAppendingPathComponent(id).path else { return /* TODO: throw Error.CreateNewWorkspaceFailed("Failed to get playdata directory") */ }
        let playdataFilePath = (archiveJSONDir as NSString).stringByAppendingPathComponent(ArchiveConstants.FILE_PLAYDATA_JSON)
        
        Task<Void, String, ErrorType> { (fulfill, reject) in
            // convert archive file (XML) to JSON file in background
            // then notify on main thread
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                do {
                    // convert archive file (XML) to JSON file
                    let converter = ArchiveToJSON(fromArchive: archiveFile, toDirectory: archiveJSONDir)
                    try converter.convert()

                    // read converted playdata
                    guard let playdataData = NSData(contentsOfFile: playdataFilePath) else { throw WorkspaceStoreError.CreateNewWorkspaceFailed("Failed to load playdata.json") }
                    let playdata = JSON(data: playdataData)
                    let title = playdata[ArchiveConstants.FULL_NAME].stringValue
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        fulfill(title)
                    }
                } catch let error {
                    dispatch_async(dispatch_get_main_queue()) {
                        reject(error)
                    }
                }
            }
        }.success { [weak self] (title) -> Task<Void, Void, ErrorType> in
            do {
                // create new Workspace object
                if let realm = self?._realm {
                    let ws = Workspace()
                    ws.id = id
                    ws.title = title
                    
                    try realm.write {
                        realm.add(ws)
                    }
                }
                return Task<Void, Void, ErrorType>(value: ())
            } catch let error {
                return Task<Void, Void, ErrorType>(error: error)
            }
        }.failure { [weak self] (error, _) in
            print("error in creating a new workspace: \(error)")
            
            // remove failed workspace directory
            _ = try? NSFileManager.defaultManager().removeItemAtPath(archiveJSONDir)
            
            let error2 = error ?? WorkspaceStoreError.CreateNewWorkspaceFailed("unknown error")
            self?.errorOccurred.fire(error2)
        }
    }
    
    public func deleteWorkspace(workspace: Workspace) {
        do {
            if let archiveJSONDir = _workspaceDirURL.URLByAppendingPathComponent(workspace.id).path {
                _ = try? NSFileManager.defaultManager().removeItemAtPath(archiveJSONDir)
            }
            
            try _realm.write {
                _realm.delete(workspace)
            }
        } catch let error {
            errorOccurred.fire(error)
        }
    }
    
    public func loadWorkspace(workspace: Workspace) {
        do {
            let workspaceURL = _workspaceDirURL.URLByAppendingPathComponent(workspace.id)
            let playdataURL = workspaceURL.URLByAppendingPathComponent(ArchiveConstants.FILE_PLAYDATA_JSON)
            let story = try Story(playdataURL: playdataURL)
            let gameWatching = GameWatching(workspaceURL: workspaceURL, story: story)
            workspaceLoaded.fire(gameWatching)
        } catch let error {
            errorOccurred.fire(error)
        }
    }
}
