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

public class SelectArchiveFileListViewController: UITableViewController {
    var disposeBag: DisposeBag!
    var viewModel: SelectArchiveFileViewModel!
    var noItemsLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        
        let noItemsLabelParent = UIView()
        tableView.backgroundView = noItemsLabelParent
        noItemsLabel = UILabel()
        noItemsLabel.text = "No files found"
        noItemsLabel.textColor = UIColor.lightGrayColor()
        noItemsLabel.sizeToFit()
        noItemsLabel.translatesAutoresizingMaskIntoConstraints = false
        noItemsLabelParent.addSubview(noItemsLabel)
        let horizontalConstraint = NSLayoutConstraint(item: noItemsLabel, attribute: .CenterX, relatedBy: .Equal, toItem: noItemsLabelParent, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let verticalConstraint = NSLayoutConstraint(item: noItemsLabel, attribute: .CenterY, relatedBy: .Equal, toItem: noItemsLabelParent, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        noItemsLabelParent.addConstraints([horizontalConstraint, verticalConstraint])
        
        bindViewModel()
    }

    private func bindViewModel() {
        disposeBag = DisposeBag()
        if let viewModel = self.viewModel {
            cancelButton.rx_tap
                .bindTo(viewModel.cancelAction)
                .addDisposableTo(disposeBag)
            
            viewModel.noItemsMessageHidden
                .subscribeNext { [weak self] hidden in
                    self?.tableView.separatorStyle = hidden ? .SingleLine : .None
                }
                .addDisposableTo(disposeBag)
            
            viewModel.noItemsMessageHidden
                .bindTo(noItemsLabel.rx_hidden)
                .addDisposableTo(disposeBag)
            
            viewModel.archiveFiles
                .bindTo(tableView.rx_itemsWithCellIdentifier("Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                    cell.textLabel?.text = element.title
                }
                .addDisposableTo(disposeBag)
            
            viewModel.refreshing
                .subscribeNext { [weak self] refreshing in
                    if (refreshing) {
                        self?.refreshControl?.beginRefreshing()
                    } else {
                        self?.refreshControl?.endRefreshing()
                    }
                }
                .addDisposableTo(disposeBag)
            
            refreshControl?.rx_controlEvent(.ValueChanged)
                .bindTo(viewModel.refreshAction)
                .addDisposableTo(disposeBag)
            
            tableView.rx_modelSelected(FileItem.self)
                .bindTo(viewModel.selectAction)
                .addDisposableTo(disposeBag)
            
            viewModel.messenger
                .subscribeNext { [weak self] message in
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
