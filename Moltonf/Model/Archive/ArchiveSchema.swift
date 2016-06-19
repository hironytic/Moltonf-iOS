//
// ArchiveSchema.swift
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

// see this site about the common archive
// http://wolfbbs.jp/%B6%A6%C4%CC%A5%A2%A1%BC%A5%AB%A5%A4%A5%D6%B4%F0%C8%D7%C0%B0%C8%F7%B7%D7%B2%E8.html

// direct links to schemas
// http://jindolf.sourceforge.jp/xml/xsd/coreType-090929.xsd
// http://jindolf.sourceforge.jp/xml/xsd/coreXML-090929.xsd
// http://jindolf.sourceforge.jp/xml/xsd/bbsArchive-110421.xsd


class NamespaceCandidates {
    let candidates: [String]
    init(_ candidates: [String]) {
        self.candidates = candidates
    }
}
func ~=(pattern: NamespaceCandidates, value: String) -> Bool {
    return pattern.candidates.contains(value)
}

class ArchiveSchema {
    // namespace URI for common archive foundation schema (401)
    static let NS_ARCHIVE_401 = "http://jindolf.sourceforge.jp/xml/ns/401"
    
    // namespace URI for common archive foundation schema (501)
    static let NS_ARCHIVE_501 = "http://jindolf.sourceforge.jp/xml/ns/501"     // version 110420+

    // namespace URI candidates for common archive foundation schema
    static let NS_ARCHIVE = NamespaceCandidates([NS_ARCHIVE_401, NS_ARCHIVE_501])
    
    //
    // --------------------------------------------------
    // MARK: element "village"
    // --------------------------------------------------
    //
    
    // element "village"
    static let ELEM_VILLAGE = "village"

    // attribute "xml:lang"
    static let ATTR_LANG = "xml:lang"

    // lang: "ja-JP"
    static let VAL_LANG_JA_JP = "ja-JP"
    
    // attribute "xml:base"
    static let ATTR_BASE = "xml:base"

    // attribute "fullName"
    static let ATTR_FULL_NAME = "fullName"
    
    // attribute "vid"
    static let ATTR_VID = "vid"
    
    // attribute "commitTime"
    static let ATTR_COMMIT_TIME = "commitTime"

    // attribute "state"
    static let ATTR_STATE = "state"
    
    // state of village: prologue
    static let VAL_VILLAGE_STATE_PROLOGUE = "prologue"
    
    // state of village: in progress
    static let VAL_VILLAGE_STATE_PROGRESS = "progress"

    // state of village: epilogue
    static let VAL_VILLAGE_STATE_EPILOGUE = "epilogue"

    // state of village: game is over
    static let VAL_VILLAGE_STATE_GAMEOVER = "gameover"

    // attribute "disclosure"
    static let ATTR_DISCLOSURE = "disclosure"
    
    // value of disclosure: "hot"
    static let VAL_DISCLOSURE_HOT = "hot"
    
    // value of disclosure: "uncomplete"
    static let VAL_DISCLOSURE_UNCOMPLETE = "uncomplete"
    
    // value of disclosure: "complete"
    static let VAL_DISCLOSURE_COMPLETE = "complete"
    
    // attribute "isValid"
    static let ATTR_IS_VALID = "isValid"
    
    // boolean value: "true"
    static let VAL_BOOLEAN_TRUE = "true"

    // boolean value: "false"
    static let VAL_BOOLEAN_FALSE = "false"
    
    // attribute "landName"
    static let ATTR_LAND_NAME = "landName"
    
    // attribute "formalName"
    static let ATTR_FORMAL_NAME = "formalName"
    
    // attribute "landId"
    static let ATTR_LAND_ID = "landId"
    
    // attribute "landPrefix"
    static let ATTR_LAND_PREFIX = "landPrefix"
    
    // attribute "locale"
    static let ATTR_LOCALE = "locale"
    
    // attribute "orgencoding"
    static let ATTR_ORGENCODING = "origencoding"
    
    // encoding: "Shift_JIS"
    static let VAL_ENCODING_SHIFT_JIS = "Shift_JIS"
    
    // attribute "timezone"
    static let ATTR_TIMEZONE = "timezone"

    // timezone +0900
    static let VAL_TIMEZONE_0900 = "GMT+09:00"
    
    // attribute "graveIconURI"
    static let ATTR_GRAVE_ICON_URI = "graveIconURI"
    
    // attribute "generator"
    static let ATTR_GENERATOR = "generator"

    //
    // --------------------------------------------------
    // MARK: element "avatarList"
    // --------------------------------------------------
    //
    
    // element "avatarList"
    static let ELEM_AVATAR_LIST = "avatarList"
    
    //
    // --------------------------------------------------
    // MARK: element "avatar"
    // --------------------------------------------------
    //
    
    // element "avatar"
    static let ELEM_AVATAR = "avatar"
    
    // attribute "avatarId"
    static let ATTR_AVATAR_ID = "avatarId"
    
    // attribute "fullName"
    // static let ATTR_FULL_NAME = "fullName"   // defined in other place
    
    // attribute "shortName"
    static let ATTR_SHORT_NAME = "shortName"
    
    // attribute "faceIconURI"
    static let ATTR_FACE_ICON_URI = "faceIconURI"
    
    //
    // --------------------------------------------------
    // MARK: element "period"
    // --------------------------------------------------
    //
    
    // element "period"
    static let ELEM_PERIOD = "period"

    // attribute "type"
    // static let ATTR_TYPE = "type"  // defined in other place

    // type of period: prologue
    static let VAL_PERIOD_TYPE_PROLOGUE = "prologue"

    // type of period: in progress
    static let VAL_PERIOD_TYPE_PROGRESS = "progress"
    
    // type of period: epilogue
    static let VAL_PERIOD_TYPE_EPILOGUE = "epilogue"
    
    // attribute "day"
    static let ATTR_DAY = "day"
    
    // attribute "disclosure"
    // static let ATTR_DISCLOSURE = "disclosure"    // defined in other place
    
    // attribute "nextCommitDay"
    static let ATTR_NEXT_COMMIT_DAY = "nextCommitDay"
    
    // attribute "commitTime"
    // static let ATTR_COMMIT_TIME = "commitTime"   // defined in other place
    
    // attribute "sourceURI"
    static let ATTR_SOURCE_URI = "sourceURI"

    // attribute "loadedTime"
    static let ATTR_LOADED_TIME = "loadedTime"
    
    // attribute "loadedBy"
    static let ATTR_LOADED_BY = "loadedBy"

    //
    // --------------------------------------------------
    // MARK: event
    // --------------------------------------------------
    //

    // attribute "eventFamily"
    static let ATTR_EVENT_FAMILY = "eventFamily"
    
    // type of eventFamily: announce
    static let VAL_EVENT_FAMILY_ANNOUNCE = "announce"
    
    // type of eventFamily: announce
    static let VAL_EVENT_FAMILY_ORDER = "order"
    
    // type of eventFamily: extra
    static let VAL_EVENT_FAMILY_EXTRA = "extra"
    
    //
    // --------------------------------------------------
    // MARK: elements of EventAnnounceGroup
    // --------------------------------------------------
    //
    
    // element "startEntry"
    static let ELEM_START_ENTRY = "startEntry"

    // element "startMirror"
    static let ELEM_START_MIRROR = "startMirror"
    
    // element "openRole"
    static let ELEM_OPEN_ROLE = "openRole"
    
    // element "murdered"
    static let ELEM_MURDERED = "murdered"
    
    // element "startAssault"
    static let ELEM_START_ASSAULT = "startAssault"
    
    // element "survivor"
    static let ELEM_SURVIVOR = "survivor"
    
    // element "suddenDeath"
    static let ELEM_SUDDEN_DEATH = "suddenDeath"
    
    // element "noMurder"
    static let ELEM_NO_MURDER = "noMurder"
    
    // element "winVillage"
    static let ELEM_WIN_VILLAGE = "winVillage"
    
    // element "winWolf"
    static let ELEM_WIN_WOLF = "winWolf"
    
    // element "winHamster"
    static let ELEM_WIN_HAMSTER = "winHamster"
    
    // element "playerList"
    static let ELEM_PLAYER_LIST = "playerList"
    
    // element "panic"
    static let ELEM_PANIC = "panic"

    // element "shortMember"
    static let ELEM_SHORT_MEMBER = "shortMember"
    
    //
    // --------------------------------------------------
    // MARK: element "onStage" of EventAnnounceGroup
    // --------------------------------------------------
    //
    
    // element "onStage"
    static let ELEM_ON_STAGE = "onStage"
    
    // attribute "entryNo"
    static let ATTR_ENTRY_NO = "entryNo"
    
    // attribute "avatarId"
    // static let ATTR_AVATAR_ID = "avatarId" // defined in other place
    
    //
    // --------------------------------------------------
    // MARK: element "counting" of EventAnnounceGroup
    // --------------------------------------------------
    //
    
    // element "counting"
    static let ELEM_COUNTING = "counting"
    
    // attribute "victim"
    static let ATTR_VICTIM = "victim"
    
    //
    // --------------------------------------------------
    // MARK: element "vote"
    // --------------------------------------------------
    //
    
    // element "vote"
    static let ELEM_VOTE = "vote"

    // attribute "byWhom"
    static let ATTR_BY_WHOM = "byWhom"
    
    // attribute "target"
    static let ATTR_TARGET = "target"
    
    //
    // --------------------------------------------------
    // MARK: element "execution" of EventAnnounceGroup
    // --------------------------------------------------
    //
    
    // element "execution"
    static let ELEM_EXECUTION = "execution"
    
    // attribute "victim"
    // static let ATTR_VICTIM = "victim"    // defined in other place
    
    //
    // --------------------------------------------------
    // MARK: element "nominated"
    // --------------------------------------------------
    //
    
    // element "nominated"
    static let ELEM_NOMINATED = "nominated"
    
    // attribute "avatarId"
    // static let ATTR_AVATAR_ID = "avatarId" // defined in other place
    
    // attribute "count"
    static let ATTR_COUNT = "count"
    
    //
    // --------------------------------------------------
    // MARK: element "vanish" of EventAnnounceGroup
    // --------------------------------------------------
    //
    
    // element "vanish"
    static let ELEM_VANISH = "vanish"
    
    // attribute "avatarId"
    // static let ATTR_AVATAR_ID = "avatarId" // defined in other place

    //
    // --------------------------------------------------
    // MARK: element "checkout" of EventAnnounceGroup
    // --------------------------------------------------
    //
    
    // element "vanish"
    static let ELEM_CHECKOUT = "checkout"
    
    // attribute "avatarId"
    // static let ATTR_AVATAR_ID = "avatarId" // defined in other place
    
    //
    // --------------------------------------------------
    // MARK: elements of EventOrderGroup
    // --------------------------------------------------
    //
    
    // element "noComment"
    static let ELEM_NO_COMMENT = "noComment"
    
    // element "gameOver"
    static let ELEM_GAME_OVER = "gameOver"

    //
    // --------------------------------------------------
    // MARK: element "askEntry" of EventOrderGroup
    // --------------------------------------------------
    //
    
    // element "askEntry"
    static let ELEM_ASK_ENTRY = "askEntry"
    
    // attribute "commitTime"
    // static let ATTR_COMMIT_TIME = "commitTime"   // defined in other place
    
    // attribute "minMembers"
    static let ATTR_MIN_MEMBERS = "minMembers"
    
    // attribute "maxMembers"
    static let ATTR_MAX_MEMBERS = "maxMembers"

    //
    // --------------------------------------------------
    // MARK: element "askCommit" of EventOrderGroup
    // --------------------------------------------------
    //

    // element "askCommit"
    static let ELEM_ASK_COMMIT = "askCommit"

    // attribute "limitVote"
    static let ATTR_LIMIT_VOTE = "limitVote"
    
    // attribute "limitSpecial"
    static let ATTR_LIMIT_SPECIAL = "limitSpecial"
    
    //
    // --------------------------------------------------
    // MARK: element "stayEpilogue" of EventOrderGroup
    // --------------------------------------------------
    //
    
    // element "stayEpilogue"
    static let ELEM_STAY_EPILOGUE = "stayEpilogue"
    
    // attribute "winner"
    static let ATTR_WINNER = "winner"
    
    // attribute "limitTime"
    static let ATTR_LIMIT_TIME = "limitTime"
    
    //
    // --------------------------------------------------
    // MARK: element "judge" of EventExtraGroup
    // --------------------------------------------------
    //

    // element "judge"
    static let ELEM_JUDGE = "judge"
    
    // attribute "byWhom"
    // static let ATTR_BY_WHOM = "byWhom"   // defined in other place
    
    // attribute "target"
    // static let ATTR_TARGET = "target"    // defined in other place
    
    //
    // --------------------------------------------------
    // MARK: element "guard" of EventExtraGroup
    // --------------------------------------------------
    //
    
    // element "guard"
    static let ELEM_GUARD = "guard"
    
    // attribute "byWhom"
    // static let ATTR_BY_WHOM = "byWhom"   // defined in other place
    
    // attribute "target"
    // static let ATTR_TARGET = "target"    // defined in other place
    
    //
    // --------------------------------------------------
    // MARK: element "counting2 of EventExtraGroup
    // --------------------------------------------------
    //
    
    // element "counting2"
    static let ELEM_COUNTING2 = "counting2"
    
    //
    // --------------------------------------------------
    // MARK: element "assault" of EventExtraGroup
    // --------------------------------------------------
    //
    
    // element "assault"
    static let ELEM_ASSAULT = "assault"
    
    // attribute "byWhom"
    // static let ATTR_BY_WHOM = "byWhom"   // defined in other place

    // attribute "target"
    // static let ATTR_TARGET = "target"    // defined in other place
    
    // attribute "xname"
    // static let ATTR_XNAME = "xname"      // defined in other place
    
    // attribute "time"
    // static let ATTR_TIME = "time"        // defined in other place
    
    // attribute "faceIconURI"
    // static let ATTR_FACE_ICON_URI = "faceIconURI"    // defined in other place
    
    //
    // --------------------------------------------------
    // MARK: element "talk"
    // --------------------------------------------------
    //
    
    // element "talk"
    static let ELEM_TALK = "talk"
    
    // attribute "type"
    static let ATTR_TYPE = "type"
    
    // talk type: public (white balloon)
    static let VAL_TALK_TYPE_PUBLIC = "public"
    
    // talk type: wolf (red balloon)
    static let VAL_TALK_TYPE_WOLF = "wolf"
    
    // talk type: private (gray balloon)
    static let VAL_TALK_TYPE_PRIVATE = "private"
    
    // talk type: grave (blue balloon)
    static let VAL_TALK_TYPE_GRAVE = "grave"
    
    // attribute "avatarId"
    // static let ATTR_AVATAR_ID = "avatarId" // defined in other place

    // attribute "xname"
    static let ATTR_XNAME = "xname"
    
    // attribute "time"
    static let ATTR_TIME = "time"
    
    // attribute "faceIconURI"
    // static let ATTR_FACE_ICON_URI = "faceIconURI"    // defined in other place
    
    //
    // --------------------------------------------------
    // MARK: element "li"
    // --------------------------------------------------
    //
    
    // element "li"
    static let ELEM_LI = "li"
    
    //
    // --------------------------------------------------
    // MARK: element "rawdata"
    // --------------------------------------------------
    //
    
    // element "rawdata"
    static let ELEM_RAWDATA = "rawdata"
    
    // attribute "encoding"
    static let ATTR_ENCODING = "encoding"
    
    // attribute "hexBin"
    static let ATTR_HEX_BIN = "hexBin"

    //
    // --------------------------------------------------
    // MARK: element "roleHeads"
    // --------------------------------------------------
    //
    
    // element "roleHeads"
    static let ELEM_ROLE_HEADS = "roleHeads"
    
    // attribute "role"
    static let ATTR_ROLE = "role"
    
    // attribute "heads"
    static let ATTR_HEADS = "heads"
    
    //
    // --------------------------------------------------
    // MARK: element "avatarRef"
    // --------------------------------------------------
    //
    
    // element "avatarRef"
    static let ELEM_AVATAR_REF = "avatarRef"
    
    // attribute "avatarId"
    // static let ATTR_AVATAR_ID = "avatarId" // defined in other place
        
    //
    // --------------------------------------------------
    // MARK: element "playerInfo"
    // --------------------------------------------------
    //
    
    // element "playerInfo"
    static let ELEM_PLAYER_INFO = "playerInfo"

    // attribute "playerId"
    static let ATTR_PLAYER_ID = "playerId"
    
    // attribute "avatarId"
    // static let ATTR_AVATAR_ID = "avatarId" // defined in other place

    // attribute "survive"
    static let ATTR_SURVIVE = "survive"
    
    // attribute "role"
    // static let ATTR_ROLE = "role" // defined in other place
    
    // role: ordinary villager
    static let VAL_ROLE_INNOCENT = "innocent"
    
    // role: werewolf
    static let VAL_ROLE_WOLF = "wolf"
    
    // role: fortune teller
    static let VAL_ROLE_SEER = "seer"
    
    // role: medium
    static let VAL_ROLE_SHAMAN = "shaman"
    
    // role: maniac
    static let VAL_ROLE_MADMAN = "madman"
    
    // role: hunter
    static let VAL_ROLE_HUNTER = "hunter"
    
    // role: mason
    static let VAL_ROLE_FRATER = "frater"
    
    // role: werehamster
    static let VAL_ROLE_HAMSTER = "hamster"
    
    // attribute "uri"
    static let ATTR_URI = "uri"
}
