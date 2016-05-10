//
// SelectArchiveFileListViewController.swift
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

import UIKit
import RxSwift
import RxCocoa

class SelectArchiveFileListViewController: UITableViewController {
    var disposeBag: DisposeBag!
    var viewModel: SelectArchiveFileViewModel!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
    }

    private func bind() {
        disposeBag = DisposeBag()
        if let viewModel = self.viewModel {
            cancelButton.rx_tap
                .bindTo(viewModel.closeAction)
                .addDisposableTo(disposeBag)
            
            refreshButton.rx_tap
                .bindTo(viewModel.refreshAction)
                .addDisposableTo(disposeBag)
            
            viewModel.archiveFiles
                .drive(tableView.rx_itemsWithCellIdentifier("Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                    cell.textLabel?.text = element.title
                }
                .addDisposableTo(disposeBag)
            
            tableView.rx_modelSelected(ArchiveFileManager.FileItem.self)
                .bindTo(viewModel.selectAction)
                .addDisposableTo(disposeBag)
            
            viewModel.messenger
                .driveNext { [weak self] message in
                    switch message {
                    case _ as DismissingMessage:
                        self?.dismissViewControllerAnimated(true, completion: nil)
                    default:
                        break
                    }
                }
                .addDisposableTo(disposeBag)
        }
    }
}
