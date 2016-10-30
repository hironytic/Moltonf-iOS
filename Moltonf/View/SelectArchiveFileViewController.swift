//
// SelectArchiveFileViewController.swift
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

fileprivate typealias R = ResourceConstants

public class SelectArchiveFileViewController: UITableViewController {
    var disposeBag: DisposeBag!
    var viewModel: ISelectArchiveFileViewModel!
    var noItemsLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = R.Color.background
        
        refreshControl = UIRefreshControl()
        
        let noItemsLabelParent = UIView()
        tableView.backgroundView = noItemsLabelParent
        noItemsLabel = UILabel()
        noItemsLabel.text = "No files found"
        noItemsLabel.textColor = UIColor.lightGray
        noItemsLabel.sizeToFit()
        noItemsLabel.translatesAutoresizingMaskIntoConstraints = false
        noItemsLabelParent.addSubview(noItemsLabel)
        let horizontalConstraint = NSLayoutConstraint(item: noItemsLabel, attribute: .centerX, relatedBy: .equal, toItem: noItemsLabelParent, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let verticalConstraint = NSLayoutConstraint(item: noItemsLabel, attribute: .centerY, relatedBy: .equal, toItem: noItemsLabelParent, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        noItemsLabelParent.addConstraints([horizontalConstraint, verticalConstraint])
        
        bindViewModel()
    }

    private func bindViewModel() {
        disposeBag = DisposeBag()
        if let viewModel = self.viewModel {
            cancelButton.rx.tap
                .bindTo(viewModel.cancelAction)
                .addDisposableTo(disposeBag)
            
            viewModel.noItemsMessageHiddenLine
                .subscribe(onNext: { [weak self] hidden in
                    self?.tableView.separatorStyle = hidden ? .singleLine : .none
                })
                .addDisposableTo(disposeBag)
            
            viewModel.noItemsMessageHiddenLine
                .bindTo(noItemsLabel.rx.isHidden)
                .addDisposableTo(disposeBag)
            
            viewModel.archiveFilesLine
                .bindTo(tableView.rx.items(cellIdentifier:"Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                    cell.textLabel?.text = element.title
                    
                    cell.backgroundColor = R.Color.background
                    cell.selectedBackgroundView = UIView()
                    cell.selectedBackgroundView?.backgroundColor = R.Color.backgroundSelected
                }
                .addDisposableTo(disposeBag)
            
            viewModel.refreshingLine
                .subscribe(onNext: { [weak self] refreshing in
                    if (refreshing) {
                        self?.refreshControl?.beginRefreshing()
                    } else {
                        self?.refreshControl?.endRefreshing()
                    }
                })
                .addDisposableTo(disposeBag)
            
            refreshControl?.rx.controlEvent(.valueChanged)
                .bindTo(viewModel.refreshAction)
                .addDisposableTo(disposeBag)
            
            tableView.rx.modelSelected(FileItem.self)
                .bindTo(viewModel.selectAction)
                .addDisposableTo(disposeBag)
            
            viewModel.messageLine
                .subscribe(onNext: { [weak self] message in
                    switch message {
                    case _ as DismissingMessage:
                        self?.dismiss(animated: true, completion: nil)
                    default:
                        break
                    }
                })
                .addDisposableTo(disposeBag)
        }
    }
}
