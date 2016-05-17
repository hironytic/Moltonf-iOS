//
// ArchiveToJSON.swift
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
import XMLPullitic

private let PLAYDATA_JSON = "playdata.json"
private let PERIOD_JSON_FORMAT = "period-%ld.json"

class ArchiveToJSON {
    private typealias S = ArchiveSchema
    private typealias K = ArchiveKeys
    
    enum ConvertError: ErrorType {
        case CantReadArchive
        case InvalidOutputDirectory(innerError: ErrorType)
        case ParseError(innerError: ErrorType)
        case InvalidAttrValue(attribute: String, value: String)
        case FailedInWritingFile(filePath: String, innerError: ErrorType?)
    }
    
    let _archivePath: String
    let _outDirPath: String
    var _parser: XMLPullParser!

    init(fromArchive archivePath: String, toDirectory outDirPath: String) {
        _archivePath = archivePath
        _outDirPath = outDirPath
    }
    
    func convert() throws {
        // ready parser
        guard let parser = XMLPullParser(contentsOfURL: NSURL.fileURLWithPath(_archivePath)) else { throw ConvertError.CantReadArchive }
        _parser = parser
        _parser.shouldProcessNamespaces = true
        
        // ready output directory
        do {
            let fileManager = NSFileManager.defaultManager()
            try fileManager.createDirectoryAtPath(_outDirPath, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            throw ConvertError.InvalidOutputDirectory(innerError: error)
        }

        // parse and convert
        do {
            parsing: while true {
                let event = try _parser.next()
                switch event {
                case .StartElement(name: S.ELEM_VILLAGE, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    try convertVillageElement(element)
                case .EndDocument:
                    break parsing
                default:
                    break
                }
            }
        } catch XMLPullParserError.ParseError(let error) {
            throw ConvertError.ParseError(innerError: error)
        }
        
    }

    private func convertVillageElement(element: XMLElement) throws {
        let villageWrapper = ObjectWrapper(object: [:])
        
        // attributes
        let mapToVillage = map(toObject: villageWrapper)
        try convertAttribute(element, [
            S.ATTR_LANG:            mapToVillage(K.LANG,            asString),
            S.ATTR_BASE:            mapToVillage(K.BASE,            asString),
            S.ATTR_FULL_NAME:       mapToVillage(K.FULL_NAME,       asString),
            S.ATTR_VID:             mapToVillage(K.VID,             asInt),
            S.ATTR_COMMIT_TIME:     mapToVillage(K.COMMIT_TIME,     asString),
            S.ATTR_STATE:           mapToVillage(K.STATE,           asString),
            S.ATTR_DISCLOSURE:      mapToVillage(K.DISCLOSURE,      asString),
            S.ATTR_IS_VALID:        mapToVillage(K.IS_VALID,        asBool),
            S.ATTR_LAND_NAME:       mapToVillage(K.LAND_NAME,       asString),
            S.ATTR_FORMAL_NAME:     mapToVillage(K.FORMAL_NAME,     asString),
            S.ATTR_LAND_ID:         mapToVillage(K.LAND_ID,         asString),
            S.ATTR_LAND_PREFIX:     mapToVillage(K.LAND_PREFIX,     asString),
            S.ATTR_LOCALE:          mapToVillage(K.LOCALE,          asString),
            S.ATTR_ORGENCODING:     mapToVillage(K.ORGENCODING,     asString),
            S.ATTR_TIMEZONE:        mapToVillage(K.TIMEZONE,        asString),
            S.ATTR_GRAVE_ICON_URI:  mapToVillage(K.GRAVE_ICON_URI,  asString),
            S.ATTR_GENERATOR:       mapToVillage(K.GENERATOR,       asString),
        ])
        
        // chidren
        var periods: [AnyObject] = []
        parsing: while true {
            let event = try _parser.next()
            switch event {
            case .StartElement(name: S.ELEM_AVATAR_LIST, namespaceURI: S.NS_ARCHIVE?, element: let element):
                villageWrapper.object[K.AVATAR_LIST] = try convertAvatarListElement(element)
            case .StartElement(name: S.ELEM_PERIOD, namespaceURI: S.NS_ARCHIVE?, element: let element):
                periods.append(try convertPeriodElement(element))
            case .StartElement:
                try skipElement()
                break
            case .EndElement:
                villageWrapper.object[K.PERIODS] = periods
                break parsing
            default:
                break
            }
        }
        
        // write to playdata.json
        let village = villageWrapper.object
        let playdataFilePath = (_outDirPath as NSString).stringByAppendingPathComponent(PLAYDATA_JSON)
        guard let outStream = NSOutputStream(toFileAtPath: playdataFilePath, append: false) else {
            throw ConvertError.FailedInWritingFile(filePath: playdataFilePath, innerError: nil)
        }
        do {
            outStream.open()
            defer { outStream.close() }
            
            var error: NSError?
            let result = NSJSONSerialization.writeJSONObject(village, toStream: outStream, options: NSJSONWritingOptions(), error: &error)
            if (result == 0) {
                throw ConvertError.FailedInWritingFile(filePath: playdataFilePath, innerError: error)
            }
        }
    }

    private func convertAvatarListElement(element: XMLElement) throws -> [[String: AnyObject]] {
        return []   // TODO
    }
    
    private func convertPeriodElement(element: XMLElement) throws -> [String: AnyObject] {
        return [:]  // TODO
    }
    
    private func skipElement() throws {
        parsing: while true {
            let event = try _parser.next()
            switch event {
            case .StartElement:
                try skipElement()
                break
            case .EndElement:
                break parsing
            default:
                break
            }
        }
    }
}

// MARK: - Helper Class and Functions

private class ObjectWrapper {
    var object: [String: AnyObject]
    init(object: [String: AnyObject]) {
        self.object = object
    }
}

private func convertAttribute(element: XMLElement, _ converters: [String: String throws -> Void]) throws {
    for (attrName, value) in element.attributes {
        if let converter = converters[attrName] {
            do {
                try converter(value)
            } catch CastError.InvalidValue {
                throw ArchiveToJSON.ConvertError.InvalidAttrValue(attribute: attrName, value: value)
            }
        }
    }
}

private func map(toObject wrapper: ObjectWrapper) -> (String, (String throws -> AnyObject)) -> String throws -> Void {
    return { (key, valueConverter) in
        return { value in
            wrapper.object[key] = try valueConverter(value)
        }
    }
}

private enum CastError: ErrorType {
    case InvalidValue
}

private func asString(value: String) -> AnyObject {
    return value
}

private func asInt(value: String) throws -> AnyObject {
    guard let integer = Int(value) else { throw CastError.InvalidValue }
    return integer
}

private func asBool(value: String) throws -> AnyObject {
    switch value {
    case "0":
        fallthrough
    case "false":
        return false
    
    case "1":
        fallthrough
    case "true":
        return true
        
    default:
        throw CastError.InvalidValue
    }
}
