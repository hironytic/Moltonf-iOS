//
// ImageCacheDB.swift
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

private let IMAGE_CACHE_DIR = "images"
private let IMAGE_CACHE_DB = "images.realm"

public class ImageCacheDB {
    public static let shared = ImageCacheDB()
    
    public let imageCacheDirURL: URL
    
    private init() {
        let cachesDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        imageCacheDirURL = URL(fileURLWithPath: cachesDir).appendingPathComponent(IMAGE_CACHE_DIR)
        _ = try? FileManager.default.createDirectory(at: imageCacheDirURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    private func createRealm() -> Realm {
        let imageCacheDBURL = imageCacheDirURL.appendingPathComponent(IMAGE_CACHE_DB)
        let config = Realm.Configuration(fileURL: imageCacheDBURL)
        return try! Realm(configuration: config)
    }
    
    private func withRealm<Result>(_ proc: (Realm) throws -> Result) rethrows -> Result {
        return try proc(createRealm())
    }
    
    public func imageData(forURL url: URL) -> Data? {
        let urlString = url.absoluteString
        let cacheFileNameOrNil = withRealm { realm -> String? in
            let cachedImages = realm.objects(CachedImage.self)
                .filter(NSPredicate(format: "url = %@", urlString))
            
            return cachedImages.first?.cacheFileName
        }
        guard let cacheFileName = cacheFileNameOrNil else { return nil }
        
        let cacheFileURL = imageCacheDirURL.appendingPathComponent(cacheFileName)
        return try? Data(contentsOf: cacheFileURL)
    }
    
    public func putImageData(forURL url: URL, data: Data) throws {
        let baseName = UUID().uuidString
        let ext = url.pathExtension
        let cacheFileName = (baseName as NSString).appendingPathExtension(ext) ?? baseName
        let cacheFileURL = imageCacheDirURL.appendingPathComponent(cacheFileName)
        try data.write(to: cacheFileURL, options: [.atomic])
        try withRealm { realm in
            let cachedImage = CachedImage()
            cachedImage.url = url.absoluteString
            cachedImage.cacheFileName = cacheFileName
            try realm.write {
                realm.add(cachedImage)
            }
        }
    }
}
