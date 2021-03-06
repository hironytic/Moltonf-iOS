//
// ImageLoader.swift
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

fileprivate typealias R = Resource

public enum ImageLoaderError: Error {
    case invalidURL
    case invalidData
}

public class ImageLoader {
    public static let shared = ImageLoader()
    private init() { }
    
    private let _disposeBag = DisposeBag()
    private let _syncQueue = DispatchQueue(label: "ImageLoader.sync")
    private var _observables: [URL: Observable<UIImage>] = [:]
    
    public func load(fromURL url: URL, altImage: UIImage? = nil) -> Observable<UIImage> {
//        print("request for url: \(url)")
        var observable: Observable<UIImage>!
        _syncQueue.sync {
            if let existing = _observables[url] {
                observable = existing
            } else {
//                print("not existing: \(url.absoluteString)")
                let obs = Observable<UIImage>
                    .create { observer in
                        // search from cache first
                        if let data = ImageCacheDB.shared.imageData(forURL: url) {
                            if let image = UIImage(data: data) {
                                observer.onNext(image)
                            } else {
                                observer.onError(ImageLoaderError.invalidData)
                            }
                            return Disposables.create()
                        }
                        
                        // load from network
                        return ImageLoader.loadNetworkImageData(fromURL: url, altImage: altImage)
                            .subscribe(observer)
                    }
                    .replay(1)
                obs.connect().addDisposableTo(_disposeBag)
                _observables[url] = obs
                observable = obs
            }
        }
        return observable
    }
    
    private static func loadNetworkImageData(fromURL url: URL, altImage: UIImage?) -> Observable<UIImage> {
        var result: Observable<UIImage> = URLSession.shared
            .rx.data(request: URLRequest(url: url))
//            .do(onNext: { _ in print("loaded: \(url.absoluteString)") })
//            .delay(5, scheduler: MainScheduler.instance)
            .map { data in
                try ImageCacheDB.shared.putImageData(forURL: url, data: data)
                if let image = UIImage(data: data) {
                    return image;
                } else {
                    throw ImageLoaderError.invalidData
                }
            }
        
        if let altImage = altImage {
            result = result
                .startWith(altImage)
                .catchErrorJustReturn(altImage)
        }
        return result
    }
}

public extension Avatar {
    public var faceIconImageLine: Observable<UIImage> {
        get {
            guard let story = story else { return Observable.error(ImageLoaderError.invalidURL) }
            guard let faceIconURI = faceIconURI else { return Observable.error(ImageLoaderError.invalidURL) }
            guard let baseURL = URL(string: story.baseURI) else { return Observable.error(ImageLoaderError.invalidURL) }
            guard let fullURL = URL(string: faceIconURI, relativeTo: baseURL) else { return Observable.error(ImageLoaderError.invalidURL) }
            
            return Observable.deferred { ImageLoader.shared.load(fromURL: fullURL, altImage: R.Image.face_unknown) }
        }
    }
}

public extension Story {
    public var graveIconImageLine: Observable<UIImage> {
        get {
            guard let baseURL = URL(string: baseURI) else { return Observable.error(ImageLoaderError.invalidURL) }
            guard let fullURL = URL(string: graveIconURI, relativeTo: baseURL) else { return Observable.error(ImageLoaderError.invalidURL) }
            
            return Observable.deferred { ImageLoader.shared.load(fromURL: fullURL, altImage: R.Image.face_unknown) }
        }
    }
}
