//
// SelectPeriodViewController.swift
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

class SelectPeriodViewController: UITableViewController {
    private var disposeBag: DisposeBag!
    public var viewModel: ISelectPeriodViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
    }

    private func bindViewModel() {
        disposeBag = DisposeBag()
        
        viewModel.periodsLine
            .bindTo(tableView.rx.items(cellIdentifier:"Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel?.text = element.title
                cell.accessoryType = element.checked ? .checkmark : .none
            }
            .addDisposableTo(disposeBag)
        
        tableView.rx.modelSelected(SelectPeriodViewModelItem.self)
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
