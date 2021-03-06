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

private typealias S = ArchiveSchema
private typealias K = ArchiveConstants

private let PERIOD_JSON_FORMAT = "period-%ld.json"

protocol ArchiveJSONWriter {
    func writeArchiveJSON(fileName: String, object: [String: Any]) throws
}

public class ArchiveToJSON: ArchiveJSONWriter {
    public enum ConvertError: Error {
        case cantReadArchive
        case invalidOutputDirectory(innerError: Error)
        case parseError(innerError: Error)
        case invalidAttrValue(attribute: String, value: String)
        case missingAttr(attribute: String)
        case failedInWritingFile(filePath: String, innerError: Error?)
    }
    
    private let _archivePath: String
    private let _outDirPath: String
    
    public init(fromArchive archivePath: String, toDirectory outDirPath: String) {
        _archivePath = archivePath
        _outDirPath = outDirPath
    }

    public func convert() throws {
        // ready parser
        guard let parser = XMLPullParser(contentsOfURL: URL(fileURLWithPath: _archivePath)) else { throw ConvertError.cantReadArchive }
        parser.shouldProcessNamespaces = true
        let parseContext = ParseContext(parser: parser)
        
        // ready output directory
        do {
            let fileManager = FileManager.default
            try fileManager.createDirectory(atPath: _outDirPath, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            throw ConvertError.invalidOutputDirectory(innerError: error)
        }
        
        // parse and convert
        do {
            parsing: while true {
                let event = try parser.next()
                switch event {
                case .startElement(name: S.ELEM_VILLAGE, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    try VillageElementConverter(parseContext: parseContext).convert(element, writer: self)
                case .endDocument:
                    break parsing
                default:
                    break
                }
            }
        } catch XMLPullParserError.parseError(let error) {
            throw ConvertError.parseError(innerError: error)
        }
    }
    
    func writeArchiveJSON(fileName: String, object: [String: Any]) throws {
        let filePath = (_outDirPath as NSString).appendingPathComponent(fileName)
        guard let outStream = OutputStream(toFileAtPath: filePath, append: false) else {
            throw ConvertError.failedInWritingFile(filePath: filePath, innerError: nil)
        }
        do {
            outStream.open()
            defer { outStream.close() }
            
            var error: NSError?
            let result = JSONSerialization.writeJSONObject(object, to: outStream, options: JSONSerialization.WritingOptions(), error: &error)
            if (result == 0) {
                throw ConvertError.failedInWritingFile(filePath: filePath, innerError: error)
            }
        }
    }
    
    class ParseContext {
        let parser: XMLPullParser
        private var _lastPublicTalkNo: Int = 0
        
        init(parser: XMLPullParser) {
            self.parser = parser
        }
        
        func nextPublicTalkNo() -> Int {
            _lastPublicTalkNo += 1
            return _lastPublicTalkNo
        }
    }
    
    class ElementConverter {
        let _parseContext: ParseContext

        init(parseContext: ParseContext) {
            _parseContext = parseContext
        }
        
        func skipElement() throws {
            parsing: while true {
                let event = try _parseContext.parser.next()
                switch event {
                case .startElement:
                    try skipElement()
                    break
                case .endElement:
                    break parsing
                default:
                    break
                }
            }
        }
    }

    class VillageElementConverter: ElementConverter {
        func convert(_ element: XMLElement, writer: ArchiveJSONWriter) throws {
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
            var periods: [Any] = []
            parsing: while true {
                let event = try _parseContext.parser.next()
                switch event {
                case .startElement(name: S.ELEM_AVATAR_LIST, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    villageWrapper.object[K.AVATAR_LIST] = try AvatarListElementConverter(parseContext: _parseContext).convert(element)
                case .startElement(name: S.ELEM_PERIOD, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    periods.append(try PeriodElementConverter(parseContext: _parseContext).convert(element, writer: writer))
                case .startElement:
                    try skipElement()
                    break
                case .endElement:
                    break parsing
                default:
                    break
                }
            }
            villageWrapper.object[K.PERIODS] = periods as Any?
            
            // write to playdata.json
            let village = villageWrapper.object
            try writer.writeArchiveJSON(fileName: K.FILE_PLAYDATA_JSON, object: village)
        }
    }
    
    class AvatarListElementConverter: ElementConverter {
        func convert(_ element: XMLElement) throws -> [[String: Any]] {
            // children
            var avatars: [[String: Any]] = []
            parsing: while true {
                let event = try _parseContext.parser.next()
                switch event {
                case .startElement(name: S.ELEM_AVATAR, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    avatars.append(try AvatarElementConverter(parseContext: _parseContext).convert(element))
                case .startElement:
                    try skipElement()
                    break
                case .endElement:
                    break parsing
                default:
                    break
                }
            }
            
            return avatars
        }
    }
    
    class AvatarElementConverter: ElementConverter {
        func convert(_ element: XMLElement) throws -> [String: Any] {
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
            try skipElement()

            return avatarWrapper.object            
        }
    }
    
    class PeriodElementConverter: ElementConverter {
        func convert(_ element: XMLElement, writer: ArchiveJSONWriter) throws -> [String: Any] {
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
            var elements: [[String: Any]] = []
            parsing: while true {
                let event = try _parseContext.parser.next()
                switch event {
                case .startElement(name: S.ELEM_TALK, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try TalkElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_START_ENTRY, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try StartEntryElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_ON_STAGE, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try OnStageElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_START_MIRROR, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try StartMirrorElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_OPEN_ROLE, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try OpenRoleElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_MURDERED, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try MurderedElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_START_ASSAULT, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try StartAssaultElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_SURVIVOR, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try SurvivorElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_COUNTING, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try CountingElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_SUDDEN_DEATH, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try SuddenDeathElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_NO_MURDER, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try NoMurderElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_WIN_VILLAGE, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try WinVillageElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_WIN_WOLF, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try WinWolfElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_WIN_HAMSTER, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try WinHamsterElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_PLAYER_LIST, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try PlayerListElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_PANIC, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try PanicElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_EXECUTION, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try ExecutionElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_VANISH, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try VanishElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_CHECKOUT, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try CheckoutElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_SHORT_MEMBER, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try ShortMemberElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_ASK_ENTRY, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try AskEntryElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_ASK_COMMIT, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try AskCommitElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_NO_COMMENT, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try NoCommentElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_STAY_EPILOGUE, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try StayEpilogueElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_GAME_OVER, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try GameOverElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_JUDGE, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try JudgeElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_GUARD, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try GuardElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_COUNTING2, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try Counting2ElementConverter(parseContext: _parseContext).convert(element))
                case .startElement(name: S.ELEM_ASSAULT, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    elements.append(try AssaultElementConverter(parseContext: _parseContext).convert(element))
                case .startElement:
                    try skipElement()
                case .endElement:
                    break parsing
                default:
                    break
                }
            }
            deepPeriodWrapper.object[K.ELEMENTS] = elements as Any?

            // write to period[n].json
            let deepPeriod = deepPeriodWrapper.object
            let day = deepPeriod[K.DAY] as! Int
            let periodFileName = String(format: PERIOD_JSON_FORMAT, day)
            try writer.writeArchiveJSON(fileName: periodFileName, object: deepPeriod)

            shallowPeriodWrapper.object[K.HREF] = periodFileName as Any?
            return shallowPeriodWrapper.object
        }
    }
    
    class TalkElementConverter: TextLinesConverter {
        override init(parseContext: ParseContext) {
            super.init(parseContext: parseContext)
            _objectWrapper.object[K.TYPE] = K.VAL_TALK
        }
        
        override func convert(_ element: XMLElement) throws -> [String : Any] {
            // attributes
            let mapToTalk = map(toObject: _objectWrapper)
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
            
            if let talkType = _objectWrapper.object[K.TALK_TYPE] as? String {
                if talkType == K.VAL_PUBLIC {
                    _objectWrapper.object[K.PUBLIC_TALK_NO] = _parseContext.nextPublicTalkNo()
                }
            }
            
            return try super.convert(element)
        }
    }
    
    class StartEntryElementConverter: EventAnnounceConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_START_ENTRY)
        }
    }

    class OnStageElementConverter: EventAnnounceConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_ON_STAGE)
        }

        override func convert(_ element: XMLElement) throws -> [String : Any] {
            // attributes
            let mapToEvent = map(toObject: _objectWrapper)
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
            
            return try super.convert(element)
        }
    }
    
    class StartMirrorElementConverter: EventAnnounceConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_START_MIRROR)
        }
    }
    
    class OpenRoleElementConverter: EventAnnounceConverter {
        var _roleHeads: [String: Any] = [:]
        
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_OPEN_ROLE)
        }

        override func onBegin() throws {
            try super.onBegin()
            
            _roleHeads = [:]
        }
        
        override func onEvent(_ event: XMLEvent) throws {
            switch event {
            case .startElement(name: S.ELEM_ROLE_HEADS, namespaceURI: S.NS_ARCHIVE?, element: let element):
                let (role, heads) = try RoleHeadsElementConverter(parseContext: _parseContext).convert(element)
                _roleHeads[role] = heads
            default:
                try super.onEvent(event)
            }
        }
        
        override func onEnd() throws {
            _objectWrapper.object[K.ROLE_HEADS] = _roleHeads as Any?
            
            try super.onEnd()
        }
    }
    
    class RoleHeadsElementConverter: ElementConverter {
        func convert(_ element: XMLElement) throws -> (role: String, heads: Any) {
            guard let role = element.attributes[S.ATTR_ROLE] else { throw ArchiveToJSON.ConvertError.missingAttr(attribute:S.ATTR_ROLE) }
            guard let headsStr = element.attributes[S.ATTR_HEADS] else { throw ArchiveToJSON.ConvertError.missingAttr(attribute:S.ATTR_HEADS) }
            let heads = try asInt(headsStr)
            
            try self.skipElement()
            
            return (role: role, heads: heads)
        }
    }
    
    class MurderedElementConverter: EventAnnounceConverter {
        var _avatarId: [String] = []
        
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_MURDERED)
        }

        override func onBegin() throws {
            try super.onBegin()
            
            _avatarId = []
        }
        
        override func onEvent(_ event: XMLEvent) throws {
            switch event {
            case .startElement(name: S.ELEM_AVATAR_REF, namespaceURI: S.NS_ARCHIVE?, element: let element):
                _avatarId.append(try AvatarRefElementConverter(parseContext: _parseContext).convert(element))
            default:
                try super.onEvent(event)
            }
        }
        
        override func onEnd() throws {
            _objectWrapper.object[K.AVATAR_ID] = _avatarId as Any?
            
            try super.onEnd()
        }
    }
    
    class StartAssaultElementConverter: EventAnnounceConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_START_ASSAULT)
        }
    }
    
    class SurvivorElementConverter: EventAnnounceConverter {
        var _avatarId: [String] = []
        
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_SURVIVOR)
        }
        
        override func onBegin() throws {
            try super.onBegin()
            
            _avatarId = []
        }
        
        override func onEvent(_ event: XMLEvent) throws {
            switch event {
            case .startElement(name: S.ELEM_AVATAR_REF, namespaceURI: S.NS_ARCHIVE?, element: let element):
                _avatarId.append(try AvatarRefElementConverter(parseContext: _parseContext).convert(element))
            default:
                try super.onEvent(event)
            }
        }
        
        override func onEnd() throws {
            _objectWrapper.object[K.AVATAR_ID] = _avatarId as Any?
            
            try super.onEnd()
        }
    }
    
    class AvatarRefElementConverter: ElementConverter {
        func convert(_ element: XMLElement) throws -> String {
            guard let avatarId = element.attributes[S.ATTR_AVATAR_ID] else { throw ArchiveToJSON.ConvertError.missingAttr(attribute:S.ATTR_AVATAR_ID) }
            try skipElement()
            return avatarId
        }
    }
    
    class CountingElementConverter: EventAnnounceConverter {
        var _votes: [String: Any] = [:]
        
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_COUNTING)
        }
        
        override func convert(_ element: XMLElement) throws -> [String : Any] {
            // attributes
            let mapToEvent = map(toObject: _objectWrapper)
            try convertAttribute(element,
                mapping: [
                    S.ATTR_VICTIM:    mapToEvent(K.VICTIM,  asString),
                ],
                required: [
                ],
                defaultValues: [:]
            )
            
            return try super.convert(element)
        }

        override func onBegin() throws {
            try super.onBegin()
            
            _votes = [:]
        }

        override func onEvent(_ event: XMLEvent) throws {
            switch event {
            case .startElement(name: S.ELEM_VOTE, namespaceURI: S.NS_ARCHIVE?, element: let element):
                let (byWhom, target) = try VoteElementConverter(parseContext: _parseContext).convert(element)
                _votes[byWhom] = target
            default:
                try super.onEvent(event)
            }
        }
        
        override func onEnd() throws {
            _objectWrapper.object[K.VOTES] = _votes as Any?
            
            try super.onEnd()
        }
    }
    
    class VoteElementConverter: ElementConverter {
        func convert(_ element: XMLElement) throws -> (byWhom: String, target: Any) {
            guard let byWhom = element.attributes[S.ATTR_BY_WHOM] else { throw ArchiveToJSON.ConvertError.missingAttr(attribute:S.ATTR_BY_WHOM) }
            guard let target = element.attributes[S.ATTR_TARGET] else { throw ArchiveToJSON.ConvertError.missingAttr(attribute:S.ATTR_TARGET) }
            
            try self.skipElement()
            
            return (byWhom: byWhom, target: target)
        }
    }
    
    class SuddenDeathElementConverter: EventAnnounceConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_SUDDEN_DEATH)
        }
        
        override func convert(_ element: XMLElement) throws -> [String : Any] {
            // attributes
            let mapToEvent = map(toObject: _objectWrapper)
            try convertAttribute(element,
                mapping: [
                    S.ATTR_AVATAR_ID:   mapToEvent(K.AVATAR_ID,  asString),
                ],
                required: [
                    S.ATTR_AVATAR_ID
                ],
                defaultValues: [:]
            )
            
            return try super.convert(element)
        }
    }

    class NoMurderElementConverter: EventAnnounceConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_NO_MURDER)
        }
    }

    class WinVillageElementConverter: EventAnnounceConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_WIN_VILLAGE)
        }
    }
    
    class WinWolfElementConverter: EventAnnounceConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_WIN_WOLF)
        }
    }
    
    class WinHamsterElementConverter: EventAnnounceConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_WIN_HAMSTER)
        }
    }
    
    class PlayerListElementConverter: EventAnnounceConverter {
        var _playerInfos: [[String: Any]] = []
        
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_PLAYER_LIST)
        }
        
        override func onBegin() throws {
            try super.onBegin()
            
            _playerInfos = []
        }
        
        override func onEvent(_ event: XMLEvent) throws {
            switch event {
            case .startElement(name: S.ELEM_PLAYER_INFO, namespaceURI: S.NS_ARCHIVE?, element: let element):
                _playerInfos.append(try PlayerInfoElementConverter(parseContext: _parseContext).convert(element))
            default:
                try super.onEvent(event)
            }
        }
        
        override func onEnd() throws {
            _objectWrapper.object[K.PLAYER_INFOS] = _playerInfos as Any?
            
            try super.onEnd()
        }
    }

    class PlayerInfoElementConverter: ElementConverter {
        func convert(_ element: XMLElement) throws -> [String: Any] {
            let playerInfoWrapper = ObjectWrapper(object: [:])
            
            // attributes
            let mapToPlayerInfo = map(toObject: playerInfoWrapper)
            try convertAttribute(element,
                mapping: [
                    S.ATTR_PLAYER_ID:   mapToPlayerInfo(K.PLAYER_ID,    asString),
                    S.ATTR_AVATAR_ID:   mapToPlayerInfo(K.AVATAR_ID,    asString),
                    S.ATTR_SURVIVE:     mapToPlayerInfo(K.SURVIVE,      asBool),
                    S.ATTR_ROLE:        mapToPlayerInfo(K.ROLE,         asString),
                    S.ATTR_URI:         mapToPlayerInfo(K.URI,          asString),
                ],
                required: [
                    S.ATTR_PLAYER_ID, S.ATTR_AVATAR_ID, S.ATTR_SURVIVE, S.ATTR_ROLE
                ],
                defaultValues: [:]
            )

            // children
            try skipElement()
            
            return playerInfoWrapper.object
        }
    }
    
    class PanicElementConverter: EventAnnounceConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_PANIC)
        }
    }
    
    class ExecutionElementConverter: EventAnnounceConverter {
        var _nominateds: [String: Any] = [:]
        
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_EXECUTION)
        }
        
        override func convert(_ element: XMLElement) throws -> [String : Any] {
            // attributes
            let mapToEvent = map(toObject: _objectWrapper)
            try convertAttribute(element,
                mapping: [
                    S.ATTR_VICTIM:    mapToEvent(K.VICTIM,  asString),
                ],
                required: [
                ],
                defaultValues: [:]
            )
            
            return try super.convert(element)
        }
        
        override func onBegin() throws {
            try super.onBegin()
            
            _nominateds = [:]
        }
        
        override func onEvent(_ event: XMLEvent) throws {
            switch event {
            case .startElement(name: S.ELEM_NOMINATED, namespaceURI: S.NS_ARCHIVE?, element: let element):
                let (avatarId, count) = try NominatedElementConverter(parseContext: _parseContext).convert(element)
                _nominateds[avatarId] = count
            default:
                try super.onEvent(event)
            }
        }
        
        override func onEnd() throws {
            _objectWrapper.object[K.NOMINATEDS] = _nominateds as Any?
            
            try super.onEnd()
        }
    }
    
    class NominatedElementConverter: ElementConverter {
        func convert(_ element: XMLElement) throws -> (avatarId: String, count: Any) {
            guard let avatarId = element.attributes[S.ATTR_AVATAR_ID] else { throw ArchiveToJSON.ConvertError.missingAttr(attribute:S.ATTR_AVATAR_ID) }
            guard let countStr = element.attributes[S.ATTR_COUNT] else { throw ArchiveToJSON.ConvertError.missingAttr(attribute:S.ATTR_COUNT) }
            let count = try asInt(countStr)
            
            try self.skipElement()
            
            return (avatarId: avatarId, count: count)
        }
    }

    class VanishElementConverter: EventAnnounceConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_VANISH)
        }
        
        override func convert(_ element: XMLElement) throws -> [String : Any] {
            // attributes
            let mapToEvent = map(toObject: _objectWrapper)
            try convertAttribute(element,
                mapping: [
                    S.ATTR_AVATAR_ID:   mapToEvent(K.AVATAR_ID,  asString),
                ],
                required: [
                    S.ATTR_AVATAR_ID
                ],
                defaultValues: [:]
            )
            
            return try super.convert(element)
        }
    }

    class CheckoutElementConverter: EventAnnounceConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_CHECKOUT)
        }
        
        override func convert(_ element: XMLElement) throws -> [String : Any] {
            // attributes
            let mapToEvent = map(toObject: _objectWrapper)
            try convertAttribute(element,
                mapping: [
                    S.ATTR_AVATAR_ID:   mapToEvent(K.AVATAR_ID,  asString),
                ],
                required: [
                    S.ATTR_AVATAR_ID
                ],
                defaultValues: [:]
            )
            
            return try super.convert(element)
        }
    }

    class ShortMemberElementConverter: EventAnnounceConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_SHORT_MEMBER)
        }
    }

    class AskEntryElementConverter: EventOrderConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_ASK_ENTRY)
        }
        
        override func convert(_ element: XMLElement) throws -> [String : Any] {
            // attributes
            let mapToEvent = map(toObject: _objectWrapper)
            try convertAttribute(element,
                mapping: [
                    S.ATTR_COMMIT_TIME:   mapToEvent(K.COMMIT_TIME,  asString),
                    S.ATTR_MIN_MEMBERS:   mapToEvent(K.MIN_MEMBERS,  asInt),
                    S.ATTR_MAX_MEMBERS:   mapToEvent(K.MAX_MEMBERS,  asInt),
                ],
                required: [
                    S.ATTR_COMMIT_TIME,
                    S.ATTR_MIN_MEMBERS,
                    S.ATTR_MAX_MEMBERS,
                ],
                defaultValues: [:]
            )
            
            return try super.convert(element)
        }
    }

    class AskCommitElementConverter: EventOrderConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_ASK_COMMIT)
        }
        
        override func convert(_ element: XMLElement) throws -> [String : Any] {
            // attributes
            let mapToEvent = map(toObject: _objectWrapper)
            try convertAttribute(element,
                mapping: [
                    S.ATTR_LIMIT_VOTE:      mapToEvent(K.LIMIT_VOTE,    asString),
                    S.ATTR_LIMIT_SPECIAL:   mapToEvent(K.LIMIT_SPECIAL, asString),
                ],
                required: [
                    S.ATTR_LIMIT_VOTE,
                    S.ATTR_LIMIT_SPECIAL,
                ],
                defaultValues: [:]
            )
            
            return try super.convert(element)
        }
    }
    
    class NoCommentElementConverter: EventOrderConverter {
        var _avatarId: [String] = []
        
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_NO_COMMENT)
        }

        override func onBegin() throws {
            try super.onBegin()
            
            _avatarId = []
        }
        
        override func onEvent(_ event: XMLEvent) throws {
            switch event {
            case .startElement(name: S.ELEM_AVATAR_REF, namespaceURI: S.NS_ARCHIVE?, element: let element):
                _avatarId.append(try AvatarRefElementConverter(parseContext: _parseContext).convert(element))
            default:
                try super.onEvent(event)
            }
        }
        
        override func onEnd() throws {
            _objectWrapper.object[K.AVATAR_ID] = _avatarId as Any?
            
            try super.onEnd()
        }
    }
    
    class StayEpilogueElementConverter: EventOrderConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_STAY_EPILOGUE)
        }
        
        override func convert(_ element: XMLElement) throws -> [String : Any] {
            // attributes
            let mapToEvent = map(toObject: _objectWrapper)
            try convertAttribute(element,
                mapping: [
                    S.ATTR_WINNER:      mapToEvent(K.WINNER,        asString),
                    S.ATTR_LIMIT_TIME:  mapToEvent(K.LIMIT_TIME,    asString),
                ],
                required: [
                    S.ATTR_WINNER,
                    S.ATTR_LIMIT_TIME,
                ],
                defaultValues: [:]
            )
            
            return try super.convert(element)
        }
    }
    
    class GameOverElementConverter: EventOrderConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_GAME_OVER)
        }
    }
    
    class JudgeElementConverter: EventExtraConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_JUDGE)
        }
        
        override func convert(_ element: XMLElement) throws -> [String : Any] {
            // attributes
            let mapToEvent = map(toObject: _objectWrapper)
            try convertAttribute(element,
                mapping: [
                    S.ATTR_BY_WHOM: mapToEvent(K.BY_WHOM,   asString),
                    S.ATTR_TARGET:  mapToEvent(K.TARGET,    asString),
                ],
                required: [
                    S.ATTR_BY_WHOM,
                    S.ATTR_TARGET,
                ],
                defaultValues: [:]
            )
            
            return try super.convert(element)
        }
    }

    class GuardElementConverter: EventExtraConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_GUARD)
        }
        
        override func convert(_ element: XMLElement) throws -> [String : Any] {
            // attributes
            let mapToEvent = map(toObject: _objectWrapper)
            try convertAttribute(element,
                mapping: [
                    S.ATTR_BY_WHOM: mapToEvent(K.BY_WHOM,   asString),
                    S.ATTR_TARGET:  mapToEvent(K.TARGET,    asString),
                ],
                required: [
                    S.ATTR_BY_WHOM,
                    S.ATTR_TARGET,
                ],
                defaultValues: [:]
            )
            
            return try super.convert(element)
        }
    }

    class Counting2ElementConverter: EventExtraConverter {
        var _votes: [String: Any] = [:]
        
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_COUNTING2)
        }
        
        override func onBegin() throws {
            try super.onBegin()
            
            _votes = [:]
        }

        override func onEvent(_ event: XMLEvent) throws {
            switch event {
            case .startElement(name: S.ELEM_VOTE, namespaceURI: S.NS_ARCHIVE?, element: let element):
                let (byWhom, target) = try VoteElementConverter(parseContext: _parseContext).convert(element)
                _votes[byWhom] = target
            default:
                try super.onEvent(event)
            }
        }
        
        override func onEnd() throws {
            _objectWrapper.object[K.VOTES] = _votes as Any?
            
            try super.onEnd()
        }
    }

    class AssaultElementConverter: EventExtraConverter {
        init(parseContext: ParseContext) {
            super.init(parseContext: parseContext, type: K.VAL_ASSAULT)
        }
        
        override func convert(_ element: XMLElement) throws -> [String : Any] {
            // attributes
            let mapToEvent = map(toObject: _objectWrapper)
            try convertAttribute(element,
                mapping: [
                    S.ATTR_BY_WHOM:         mapToEvent(K.BY_WHOM,       asString),
                    S.ATTR_TARGET:          mapToEvent(K.TARGET,        asString),
                    S.ATTR_XNAME:           mapToEvent(K.XNAME,         asString),
                    S.ATTR_TIME:            mapToEvent(K.TIME,          asString),
                    S.ATTR_FACE_ICON_URI:   mapToEvent(K.FACE_ICON_URI, asString),
                ],
                required: [
                    S.ATTR_BY_WHOM,
                    S.ATTR_TARGET,
                    S.ATTR_XNAME,
                    S.ATTR_TIME,
                ],
                defaultValues: [:]
            )
            
            return try super.convert(element)
        }
    }
    
    class EventAnnounceConverter: EventConverter {
    }
    
    class EventOrderConverter: EventConverter {
    }
    
    class EventExtraConverter: EventConverter {
    }
    
    class EventConverter: TextLinesConverter {
        init(parseContext: ParseContext, type: String) {
            super.init(parseContext: parseContext)
            _objectWrapper.object[K.TYPE] = type
        }
    }
    
    class TextLinesConverter: ElementConverter {
        let _objectWrapper = ObjectWrapper(object: [:])
        var _parsing = true
        var _lines: [Any] = []
        
        func convert(_ element: XMLElement) throws -> [String: Any] {
            try onBegin()
            
            while _parsing {
                let event = try _parseContext.parser.next()
                try onEvent(event)
            }
            
            try onEnd()
            
            return _objectWrapper.object
        }
        
        func onBegin() throws {
            _parsing = true
            _lines = []
        }
        
        func onEvent(_ event: XMLEvent) throws {
            switch event {
            case .startElement(name: S.ELEM_LI, namespaceURI: S.NS_ARCHIVE?, element: let element):
                _lines.append(try LiElementConverter(parseContext: _parseContext).convert(element))
            case .startElement:
                try self.skipElement()
            case .endElement:
                _parsing = false
            default:
                break
            }
        }
        
        func onEnd() throws {
            _objectWrapper.object[K.LINES] = _lines as Any?
        }
    }
    
    class LiElementConverter: ElementConverter {
        func convert(_ element: XMLElement) throws -> Any {
            var contents: [Any] = []
            
            parsing: while true {
                let event = try _parseContext.parser.next()
                switch event {
                case .characters(let string):
                    contents.append(string)
                case .startElement(name: S.ELEM_RAWDATA, namespaceURI: S.NS_ARCHIVE?, element: let element):
                    contents.append(try RawdataElementConverter(parseContext: _parseContext).convert(element))
                case .startElement:
                    try skipElement()
                case .endElement:
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
    }
    
    class RawdataElementConverter: ElementConverter {
        func convert(_ element: XMLElement) throws -> Any {
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
                let event = try _parseContext.parser.next()
                switch event {
                case .characters(let string):
                    contentWrapper.object[K.CHAR] = string
                case .startElement:
                    try skipElement()
                case .endElement:
                    break parsing
                default:
                    break
                }
            }
            
            return contentWrapper.object
        }
    }
}

// MARK: - Helper Class and Functions

class ObjectWrapper {
    var object: [String: Any]
    init(object: [String: Any]) {
        self.object = object
    }
}

private func convertAttribute(_ element: XMLElement, mapping converters: [String: (String) throws -> Void], required requiredAttrs: [String], defaultValues: [String: String]) throws {
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
            } catch CastError.invalidValue {
                throw ArchiveToJSON.ConvertError.invalidAttrValue(attribute: attrName, value: value)
            }
        }
        requiredAttrSet.remove(attrName)
    }

    if !requiredAttrSet.isEmpty {
        throw ArchiveToJSON.ConvertError.missingAttr(attribute: requiredAttrSet.first!)
    }
}

private func map(toObject wrapper: ObjectWrapper) -> (String, (@escaping (String) throws -> Any)) -> (String) throws -> Void {
    return { (key, valueConverter) in
        return { value in
            wrapper.object[key] = try valueConverter(value)
        }
    }
}

private func map(toObjects wrappers: [ObjectWrapper]) -> (String, (@escaping (String) throws -> Any)) -> (String) throws -> Void {
    return { (key, valueConverter) in
        return { value in
            let convertedValue = try valueConverter(value)
            for wrapper in wrappers {
                wrapper.object[key] = convertedValue
            }
        }
    }
}

private enum CastError: Error {
    case invalidValue
}

private func asString(_ value: String) -> Any {
    return value as Any
}

private func asInt(_ value: String) throws -> Any {
    guard let integer = Int(value) else { throw CastError.invalidValue }
    return integer as Any
}

private func asBool(_ value: String) throws -> Any {
    switch value {
    case "0":
        fallthrough
    case "false":
        return false as Any
    
    case "1":
        fallthrough
    case "true":
        return true as Any
        
    default:
        throw CastError.invalidValue
    }
}
