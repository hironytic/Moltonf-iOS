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
        case MissingAttr(attribute: String)
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
        try convertAttribute(element,
            mapping: [
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
            ],
            required: [
                S.ATTR_BASE, S.ATTR_FULL_NAME, S.ATTR_VID, S.ATTR_STATE,
                S.ATTR_LAND_NAME, S.ATTR_FORMAL_NAME, S.ATTR_LAND_ID,
                S.ATTR_LAND_PREFIX, S.ATTR_GRAVE_ICON_URI,
            ],
            defaultValues: [
                S.ATTR_LANG:        S.VAL_LANG_JA_JP,
                S.ATTR_DISCLOSURE:  S.VAL_DISCLOSURE_COMPLETE,
                S.ATTR_IS_VALID:    S.VAL_BOOLEAN_TRUE,
                S.ATTR_LOCALE:      S.VAL_LANG_JA_JP,
                S.ATTR_ORGENCODING: S.VAL_ENCODING_SHIFT_JIS,
                S.ATTR_TIMEZONE:    S.VAL_TIMEZONE_0900,
            ]
        )
        
        // children
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
                break parsing
            default:
                break
            }
        }
        villageWrapper.object[K.PERIODS] = periods
        
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
        // children
        var avatars: [[String: AnyObject]] = []
        parsing: while true {
            let event = try _parser.next()
            switch event {
            case .StartElement(name: S.ELEM_AVATAR, namespaceURI: S.NS_ARCHIVE?, element: let element):
                avatars.append(try convertAvatarElement(element))
            case .StartElement:
                try skipElement()
                break
            case .EndElement:
                break parsing
            default:
                break
            }
        }
        
        return avatars
    }

    private func convertAvatarElement(element: XMLElement) throws -> [String: AnyObject] {
        let avatarWrapper = ObjectWrapper(object: [:])
        
        // attributes
        let mapToAvatar = map(toObject: avatarWrapper)
        try convertAttribute(element,
            mapping: [
                S.ATTR_AVATAR_ID:       mapToAvatar(K.AVATAR_ID,        asString),
                S.ATTR_FULL_NAME:       mapToAvatar(K.FULL_NAME,        asString),
                S.ATTR_SHORT_NAME:      mapToAvatar(K.SHORT_NAME,       asString),
                S.ATTR_FACE_ICON_URI:   mapToAvatar(K.FACE_ICON_URI,    asString),
            ],
            required: [
                S.ATTR_AVATAR_ID, S.ATTR_FULL_NAME, S.ATTR_SHORT_NAME
            ],
            defaultValues: [:]
        )

        // children
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

        return avatarWrapper.object
    }
    
    private func convertPeriodElement(element: XMLElement) throws -> [String: AnyObject] {
        let shallowPeriodWrapper = ObjectWrapper(object: [:])
        let deepPeriodWrapper = ObjectWrapper(object: [:])
        
        // attributes
        let mapToPeriod = map(toObjects: [shallowPeriodWrapper, deepPeriodWrapper])
        try convertAttribute(element,
            mapping: [
                S.ATTR_TYPE:            mapToPeriod(K.TYPE,             asString),
                S.ATTR_DAY:             mapToPeriod(K.DAY,              asInt),
                S.ATTR_DISCLOSURE:      mapToPeriod(K.DISCLOSURE,       asString),
                S.ATTR_NEXT_COMMIT_DAY: mapToPeriod(K.NEXT_COMMIT_DAY,  asString),
                S.ATTR_COMMIT_TIME:     mapToPeriod(K.COMMIT_TIME,      asString),
                S.ATTR_SOURCE_URI:      mapToPeriod(K.SOURCE_URI,       asString),
                S.ATTR_LOADED_TIME:     mapToPeriod(K.LOADED_TIME,      asString),
                S.ATTR_LOADED_BY:       mapToPeriod(K.LOADED_BY,        asString),
            ],
            required: [
                S.ATTR_TYPE, S.ATTR_DAY, S.ATTR_NEXT_COMMIT_DAY,
                S.ATTR_COMMIT_TIME, S.ATTR_SOURCE_URI
            ],
            defaultValues: [
                S.ATTR_DISCLOSURE:      S.VAL_DISCLOSURE_COMPLETE,
            ]
        )
        
        // children
        var elements: [[String: AnyObject]] = []
        parsing: while true {
            let event = try _parser.next()
            switch event {
            case .StartElement(name: S.ELEM_TALK, namespaceURI: S.NS_ARCHIVE?, element: let element):
                elements.append(try convertTalkElement(element))
            case .StartElement(name: S.ELEM_START_ENTRY, namespaceURI: S.NS_ARCHIVE?, element: let element):
                elements.append(try convertStartEntryElement(element))
            case .StartElement(name: S.ELEM_ON_STAGE, namespaceURI: S.NS_ARCHIVE?, element: let element):
                elements.append(try convertOnStageElement(element))
            case .StartElement(name: S.ELEM_START_MIRROR, namespaceURI: S.NS_ARCHIVE?, element: let element):
                elements.append(try convertStartMirrorElement(element))
            case .StartElement(name: S.ELEM_OPEN_ROLE, namespaceURI: S.NS_ARCHIVE?, element: let element):
                elements.append(try convertOpenRoleElement(element))
            case .StartElement(name: S.ELEM_MURDERED, namespaceURI: S.NS_ARCHIVE?, element: let element):
                try skipElement()   // TODO
            case .StartElement(name: S.ELEM_START_ASSAULT, namespaceURI: S.NS_ARCHIVE?, element: let element):
                try skipElement()   // TODO
            case .StartElement(name: S.ELEM_SURVIVOR, namespaceURI: S.NS_ARCHIVE?, element: let element):
                try skipElement()   // TODO
            case .StartElement(name: S.ELEM_COUNTING, namespaceURI: S.NS_ARCHIVE?, element: let element):
                try skipElement()   // TODO
            case .StartElement(name: S.ELEM_SUDDEN_DEATH, namespaceURI: S.NS_ARCHIVE?, element: let element):
                try skipElement()   // TODO
            case .StartElement(name: S.ELEM_NO_MURDER, namespaceURI: S.NS_ARCHIVE?, element: let element):
                try skipElement()   // TODO
            case .StartElement(name: S.ELEM_WIN_VILLAGE, namespaceURI: S.NS_ARCHIVE?, element: let element):
                try skipElement()   // TODO
            case .StartElement(name: S.ELEM_WIN_WOLF, namespaceURI: S.NS_ARCHIVE?, element: let element):
                try skipElement()   // TODO
            case .StartElement(name: S.ELEM_WIN_HAMSTER, namespaceURI: S.NS_ARCHIVE?, element: let element):
                try skipElement()   // TODO
            case .StartElement(name: S.ELEM_PLAYER_LIST, namespaceURI: S.NS_ARCHIVE?, element: let element):
                try skipElement()   // TODO
            case .StartElement(name: S.ELEM_PANIC, namespaceURI: S.NS_ARCHIVE?, element: let element):
                try skipElement()   // TODO
//            case .StartElement(name: S.ELEM_EXECUTION, namespaceURI: S.NS_ARCHIVE?, element: let element):
//                try skipElement()   // TODO
//            case .StartElement(name: S.ELEM_VANISH, namespaceURI: S.NS_ARCHIVE?, element: let element):
//                try skipElement()   // TODO
//            case .StartElement(name: S.ELEM_CHECKOUG, namespaceURI: S.NS_ARCHIVE?, element: let element):
//                try skipElement()   // TODO
//            case .StartElement(name: S.ELEM_SHORT_MEMBER, namespaceURI: S.NS_ARCHIVE?, element: let element):
//                try skipElement()   // TODO
            case .StartElement(name: S.ELEM_ASK_ENTRY, namespaceURI: S.NS_ARCHIVE?, element: let element):
                try skipElement()   // TODO
            case .StartElement(name: S.ELEM_ASK_COMMIT, namespaceURI: S.NS_ARCHIVE?, element: let element):
                try skipElement()   // TODO
            case .StartElement(name: S.ELEM_NO_COMMENT, namespaceURI: S.NS_ARCHIVE?, element: let element):
                try skipElement()   // TODO
            case .StartElement(name: S.ELEM_STAY_EPILOGUE, namespaceURI: S.NS_ARCHIVE?, element: let element):
                try skipElement()   // TODO
            case .StartElement(name: S.ELEM_GAME_OVER, namespaceURI: S.NS_ARCHIVE?, element: let element):
                try skipElement()   // TODO
            case .StartElement(name: S.ELEM_JUDGE, namespaceURI: S.NS_ARCHIVE?, element: let element):
                try skipElement()   // TODO
            case .StartElement(name: S.ELEM_GUARD, namespaceURI: S.NS_ARCHIVE?, element: let element):
                try skipElement()   // TODO
//            case .StartElement(name: S.ELEM_COUNTING2, namespaceURI: S.NS_ARCHIVE?, element: let element):
//                try skipElement()   // TODO
            case .StartElement(name: S.ELEM_ASSAULT, namespaceURI: S.NS_ARCHIVE?, element: let element):
                try skipElement()   // TODO
            case .StartElement:
                try skipElement()
            case .EndElement:
                break parsing
            default:
                break
            }
        }
        deepPeriodWrapper.object[K.ELEMENTS] = elements

        // write to period[n].json
        let deepPeriod = deepPeriodWrapper.object
        let day = deepPeriod[K.DAY] as! Int
        let periodFileName = String(format: PERIOD_JSON_FORMAT, day)
        let periodFilePath = (_outDirPath as NSString).stringByAppendingPathComponent(periodFileName)
        guard let outStream = NSOutputStream(toFileAtPath: periodFilePath, append: false) else {
            throw ConvertError.FailedInWritingFile(filePath: periodFilePath, innerError: nil)
        }
        do {
            outStream.open()
            defer { outStream.close() }
            
            var error: NSError?
            let result = NSJSONSerialization.writeJSONObject(deepPeriod, toStream: outStream, options: NSJSONWritingOptions(), error: &error)
            if (result == 0) {
                throw ConvertError.FailedInWritingFile(filePath: periodFilePath, innerError: error)
            }
        }

        shallowPeriodWrapper.object[K.HREF] = periodFileName
        return shallowPeriodWrapper.object
    }
    
    private func convertTalkElement(element: XMLElement) throws -> [String: AnyObject] {
        let talkWrapper = ObjectWrapper(object: [:])
        
        talkWrapper.object[K.TYPE] = K.VAL_TALK
        
        // attributes
        let mapToTalk = map(toObject: talkWrapper)
        try convertAttribute(element,
            mapping: [
                S.ATTR_TYPE:            mapToTalk(K.TALK_TYPE,      asString),
                S.ATTR_AVATAR_ID:       mapToTalk(K.AVATAR_ID,      asString),
                S.ATTR_XNAME:           mapToTalk(K.XNAME,          asString),
                S.ATTR_TIME:            mapToTalk(K.TIME,           asString),
                S.ATTR_FACE_ICON_URI:   mapToTalk(K.FACE_ICON_URI,  asString),
            ],
            required: [
                S.ATTR_TYPE, S.ATTR_AVATAR_ID, S.ATTR_XNAME, S.ATTR_TIME,
            ],
            defaultValues: [:]
        )
        
        try convertTextLines(element, toObject: talkWrapper, onChild: skipStartElement)
        
        return talkWrapper.object
    }
    
    private func convertStartEntryElement(element: XMLElement) throws -> [String: AnyObject] {
        let eventWrapper = ObjectWrapper(object: [:])

        eventWrapper.object[K.TYPE] = K.VAL_START_ENTRY
        
        try convertEvent(element, toObject: eventWrapper, family: S.VAL_EVENT_FAMILY_ANNOUNCE, onChild: skipStartElement)
        
        return eventWrapper.object
    }
    
    private func convertOnStageElement(element: XMLElement) throws -> [String: AnyObject] {
        let eventWrapper = ObjectWrapper(object: [:])

        eventWrapper.object[K.TYPE] = K.VAL_ON_STAGE

        // attributes
        let mapToEvent = map(toObject: eventWrapper)
        try convertAttribute(element,
            mapping: [
                S.ATTR_ENTRY_NO:    mapToEvent(K.ENTRY_NO,  asInt),
                S.ATTR_AVATAR_ID:   mapToEvent(K.AVATAR_ID, asString),
            ],
            required: [
                S.ATTR_ENTRY_NO, S.ATTR_AVATAR_ID,
            ],
            defaultValues: [:]
        )

        try convertEvent(element, toObject: eventWrapper, family: S.VAL_EVENT_FAMILY_ANNOUNCE, onChild: skipStartElement)
        
        return eventWrapper.object
    }
    
    private func convertStartMirrorElement(element: XMLElement) throws -> [String: AnyObject] {
        let eventWrapper = ObjectWrapper(object: [:])
        
        eventWrapper.object[K.TYPE] = K.VAL_START_MIRROR
        
        try convertEvent(element, toObject: eventWrapper, family: S.VAL_EVENT_FAMILY_ANNOUNCE, onChild: skipStartElement)
        
        return eventWrapper.object
    }
    
    private func convertOpenRoleElement(element: XMLElement) throws -> [String: AnyObject] {
        let eventWrapper = ObjectWrapper(object: [:])
        
        eventWrapper.object[K.TYPE] = K.VAL_OPEN_ROLE

        var roleHeads: [String: AnyObject] = [:]
        try convertEvent(element, toObject: eventWrapper, family: S.VAL_EVENT_FAMILY_ANNOUNCE) { event in
            switch event {
            case .StartElement(name: S.ELEM_ROLE_HEADS, namespaceURI: S.NS_ARCHIVE?, element: let element):
                let (role, heads) = try self.convertRoleHeadsElement(element)
                roleHeads[role] = heads
            case .StartElement:
                try self.skipElement()
            default:
                break
            }
        }
        eventWrapper.object[K.ROLE_HEADS] = roleHeads
        
        return eventWrapper.object
    }
    
    private func convertRoleHeadsElement(element: XMLElement) throws -> (role: String, heads: AnyObject) {
        guard let role = element.attributes[S.ATTR_ROLE] else { throw ArchiveToJSON.ConvertError.MissingAttr(attribute:S.ATTR_ROLE) }
        guard let headsStr = element.attributes[S.ATTR_HEADS] else { throw ArchiveToJSON.ConvertError.MissingAttr(attribute:S.ATTR_HEADS) }
        let heads = try asInt(headsStr)
        
        try self.skipElement()
        
        return (role: role, heads: heads)
    }
    
    private func convertEvent(element: XMLElement, toObject eventWrapper: ObjectWrapper, family: String, onChild: XMLEvent throws -> Void) throws {
        // attributes
        let mapToEvent = map(toObject: eventWrapper)
        try convertAttribute(element,
            mapping: [
                S.ATTR_EVENT_FAMILY:    mapToEvent(K.EVENT_FAMILY,  asString),
            ],
            required: [],
            defaultValues: [
                S.ATTR_EVENT_FAMILY:    family
            ]
        )
        
        try convertTextLines(element, toObject: eventWrapper, onChild: onChild)
    }
    
    private func convertTextLines(element: XMLElement, toObject objectWrapper: ObjectWrapper, onChild: XMLEvent throws -> Void) throws {
        // children
        var lines: [AnyObject] = []
        parsing: while true {
            let event = try _parser.next()
            switch event {
            case .StartElement(name: S.ELEM_LI, namespaceURI: S.NS_ARCHIVE?, element: let element):
                lines.append(try convertLiElement(element))
            case .EndElement:
                break parsing
            default:
                try onChild(event)
            }
        }
        objectWrapper.object[K.LINES] = lines
    }
    
    private func convertLiElement(element: XMLElement) throws -> AnyObject {
        var contents: [AnyObject] = []
        
        parsing: while true {
            let event = try _parser.next()
            switch event {
            case .Characters(let string):
                contents.append(string)
            case .StartElement(name: S.ELEM_RAWDATA, namespaceURI: S.NS_ARCHIVE?, element: _):
                contents.append(try convertRawdataElement(element))
            case .StartElement:
                try skipElement()
            case .EndElement:
                break parsing
            default:
                break
            }
        }

        switch contents.count {
        case 0:
            return ""
        case 1:
            return contents[0]
        default:
            return contents
        }
    }
    
    private func convertRawdataElement(element: XMLElement) throws -> AnyObject {
        let contentWrapper = ObjectWrapper(object: [:])
        
        // attributes
        let mapToContent = map(toObject: contentWrapper)
        try convertAttribute(element,
            mapping: [
                S.ATTR_ENCODING:        mapToContent(K.ENCODING,    asString),
                S.ATTR_HEX_BIN:         mapToContent(K.HEX_BIN,     asString),
            ],
            required: [
                S.ATTR_ENCODING, S.ATTR_HEX_BIN,
            ],
            defaultValues: [:]
        )
        
        // children
        parsing: while true {
            let event = try _parser.next()
            switch event {
            case .Characters(let string):
                contentWrapper.object[K.CHAR] = string
            case .StartElement:
                try skipElement()
            case .EndElement:
                break parsing
            default:
                break
            }
        }

        return contentWrapper.object
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
    
    private func skipStartElement(event: XMLEvent) throws {
        switch event {
        case .StartElement:
            try skipElement()
        default:
            break
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

private func convertAttribute(element: XMLElement, mapping converters: [String: String throws -> Void], required requiredAttrs: [String], defaultValues: [String: String]) throws {
    var attributes = element.attributes
    for (attrName, defaultValue) in defaultValues {
        if !attributes.keys.contains(attrName) {
            attributes[attrName] = defaultValue
        }
    }
    
    var requiredAttrSet = Set<String>(requiredAttrs)
    for (attrName, value) in attributes {
        if let converter = converters[attrName] {
            do {
                try converter(value)
            } catch CastError.InvalidValue {
                throw ArchiveToJSON.ConvertError.InvalidAttrValue(attribute: attrName, value: value)
            }
        }
        requiredAttrSet.remove(attrName)
    }

    if !requiredAttrSet.isEmpty {
        throw ArchiveToJSON.ConvertError.MissingAttr(attribute: requiredAttrSet.first!)
    }
}

private func map(toObject wrapper: ObjectWrapper) -> (String, (String throws -> AnyObject)) -> String throws -> Void {
    return { (key, valueConverter) in
        return { value in
            wrapper.object[key] = try valueConverter(value)
        }
    }
}

private func map(toObjects wrappers: [ObjectWrapper]) -> (String, (String throws -> AnyObject)) -> String throws -> Void {
    return { (key, valueConverter) in
        return { value in
            let convertedValue = try valueConverter(value)
            for wrapper in wrappers {
                wrapper.object[key] = convertedValue
            }
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
