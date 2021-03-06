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
import RxSwift
import RealmSwift
import SwiftyJSON

public enum WorkspaceStoreError: Error {
    case createNewWorkspaceFailed(String)
}

public struct WorkspaceStoreChanges {
    let workspaces: AnyRandomAccessCollection<Workspace>
    let deletions: [Int]
    let insertions: [Int]
    let modifications: [Int]
}

public protocol IWorkspaceStore: class {
    var errorLine: Observable<Error> { get }
    var workspacesLine: Observable<WorkspaceStoreChanges> { get }

    var createNewWorkspaceAction: AnyObserver</* archiveFile: */ String> { get }
    var deleteWorkspaceAction: AnyObserver<Workspace> { get }
}

public class WorkspaceStore: IWorkspaceStore {
    public var errorLine: Observable<Error> { get { return _errorSubject } }
    public var workspacesLine: Observable<WorkspaceStoreChanges> { get { return _workspacesSubject } }
    
    public private(set) var createNewWorkspaceAction: AnyObserver<String>
    public private(set) var deleteWorkspaceAction: AnyObserver<Workspace>
    
    private let _disposeBag = DisposeBag()
    
    private let _workspaceDB = WorkspaceDB.sharedInstance
    private var _notificationToken: NotificationToken!
    private let _workspacesSubject = BehaviorSubject<WorkspaceStoreChanges>(value: WorkspaceStoreChanges(workspaces: AnyRandomAccessCollection([]), deletions: [], insertions: [], modifications: []))
    private let _errorSubject = PublishSubject<Error>()
    
    private let _createNewWorkspaceAction = PublishSubject<String>()
    private let _deleteWorkspaceAction = PublishSubject<Workspace>()

    public init() {
        createNewWorkspaceAction = _createNewWorkspaceAction.asObserver()
        deleteWorkspaceAction = _deleteWorkspaceAction.asObserver()

        configureWorkspaces()
        configureCreateNewWorkspaceAction()
        configureDeleteWorkspaceAction()
    }
    
    deinit {
        self._notificationToken.stop()
    }

    private func configureWorkspaces() {
        self._workspaceDB.withRealm { realm in
            let workspaceResults = realm.objects(Workspace.self)
            let changes = WorkspaceStoreChanges(workspaces: AnyRandomAccessCollection<Workspace>(workspaceResults),
                                                deletions: [],
                                                insertions: (0..<workspaceResults.count).map { $0 },
                                                modifications: [])
            self._workspacesSubject.onNext(changes)
            self._notificationToken = workspaceResults.addNotificationBlock { [unowned self] changes in
                switch changes {
                case .update(let results, let deletions, let insertions, let modifications):
                    self._workspacesSubject.onNext(WorkspaceStoreChanges(workspaces: AnyRandomAccessCollection(results), deletions: deletions, insertions: insertions, modifications: modifications))
                default:
                    break
                }
            }
        }
    }
    
    private func configureCreateNewWorkspaceAction() {
        _createNewWorkspaceAction
            // convert archive file (XML) to JSON file in background
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .map { [unowned self] archiveFile in
                let id = UUID().uuidString
                let archiveJSONDir = self._workspaceDB.workspaceDirURL.appendingPathComponent(id).path
                let playdataFilePath = (archiveJSONDir as NSString).appendingPathComponent(ArchiveConstants.FILE_PLAYDATA_JSON)
                
                // convert archive file (XML) to JSON file
                let converter = ArchiveToJSON(fromArchive: archiveFile, toDirectory: archiveJSONDir)
                try converter.convert()
                
                // read converted playdata
                guard let playdataData = try? Data(contentsOf: URL(fileURLWithPath: playdataFilePath)) else { throw WorkspaceStoreError.createNewWorkspaceFailed("Failed to load playdata.json") }
                let playdata = JSON(data: playdataData)
                let title = playdata[ArchiveConstants.FULL_NAME].stringValue
                
                // create new Workspace object
                let ws = Workspace()
                ws.id = id
                ws.title = title
                
                try self._workspaceDB.withRealm { realm in
                    try realm.write {
                        realm.add(ws)
                    }
                }
            }
            .do(onError: { [unowned self] error in
                self._errorSubject.onNext(error)
            })
            .retry()
            .publish().connect().addDisposableTo(_disposeBag)
    }
    
    private func configureDeleteWorkspaceAction() {
        _deleteWorkspaceAction
            .do(onNext: { [unowned self] workspace in
                let archiveJSONDir = self._workspaceDB.workspaceDirURL.appendingPathComponent(workspace.id).path
                _ = try? FileManager.default.removeItem(atPath: archiveJSONDir)

                try self._workspaceDB.withRealm { realm in
                    try realm.write {
                        realm.delete(workspace)
                    }
                }
            })
            .do(onError: { [unowned self] error in
                self._errorSubject.onNext(error)
                })
            .retry()
            .publish().connect().addDisposableTo(_disposeBag)
    }
}
