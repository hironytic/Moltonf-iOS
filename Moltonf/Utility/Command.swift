//
// Command.swift
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

public class Command {
    let canExecute: Driver<Bool>
    let execute: () -> Void
    
    convenience init() {
        self.init(canExecute: Driver.just(false), execute: { })
    }

    convenience init(execute: () -> Void) {
        self.init(canExecute: Driver.just(true), execute: execute)
    }
    
    init(canExecute: Driver<Bool>, execute: () -> Void) {
        self.canExecute = canExecute
        self.execute = execute
    }
}

extension Command {
    public func drive(control: UIBarButtonItem) -> Disposable {
        let disposable = CompositeDisposable()
        disposable.addDisposable(self.canExecute.drive(control.rx_enabled))
        disposable.addDisposable(control.rx_tap.subscribeNext(self.execute))
        return disposable
    }
}
