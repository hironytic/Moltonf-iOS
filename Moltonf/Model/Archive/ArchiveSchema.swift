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
    // namespace URI for prefix "xml"
    static let NS_XML = "http://www.w3.org/XML/1998/namespace"
    
    // namespace prefix "xml"
    static let PREFIX_XML = "xml"
    
    // namespace URI for prefix "xlink"
    static let NS_XLINK = "http://www.w3.org/1999/xlink"
    
    // namespace prefix "xlink"
    static let PREFIX_XLINK = "xlink"

    // namespace URI for common archive foundation schema (401)
    static let NS_ARCHIVE_401 = "http://jindolf.sourceforge.jp/xml/ns/401"
    
    // namespace URI for common archive foundation schema (501)
    static let NS_ARCHIVE_501 = "http://jindolf.sourceforge.jp/xml/ns/501"     // version 110420+

    // namespace URI candidates for common archive foundation schema
    static let NS_ARCHIVE = NamespaceCandidates([NS_ARCHIVE_401, NS_ARCHIVE_501])
    
    //
    // --------------------------------------------------
    // MARK: xlink
    // --------------------------------------------------
    //
    
    // attribute "xlink:type"
    static let NAME_XLINK_TYPE = "xlink:type"

    // value "simple" of attribute "xlink:type"
    static let VAL_XLINK_TYPE_SIMPLE = "simple"
    
    // attribute "xlink:href"
    static let NAME_XLINK_HREF = "xlink:href"

    //
    // --------------------------------------------------
    // MARK: village
    // --------------------------------------------------
    //
    
    // element "village"
    static let NAME_VILLAGE = "village"

    // attribute "xml:base"
    static let NAME_BASE = "xml:base"

    // attribute "fullName"
    static let NAME_FULL_NAME = "fullName"

    // sttribute "state"
    static let NAME_STATE = "state"

    // state of village: prologue
    static let VAL_VILLAGE_STATE_PROLOGUE = "prologue"
    
    // state of village: in progress
    static let VAL_VILLAGE_STATE_PROGRESS = "progress"

    // state of village: epilogue
    static let VAL_VILLAGE_STATE_EPILOGUE = "epilogue"

    // state of village: game is over
    static let VAL_VILLAGE_STATE_GAMEOVER = "gameover"

    // attribute "graveIconURI"
    static let NAME_GRAVE_ICON_URI = "graveIconURI"

    //
    // --------------------------------------------------
    // MARK: avatarList
    // --------------------------------------------------
    //
    
    // element "avatarList"
    static let NAME_AVATAR_LIST = "avatarList"
    
    //
    // --------------------------------------------------
    // MARK: avatar
    // --------------------------------------------------
    //
    
    // element "avatar"
    static let NAME_AVATAR = "avatar"
    
    // attribute "avatarId"
    static let NAME_AVATAR_ID = "avatarId"
    
    // attribute "fullName"
    // static let NAME_FULL_NAME = "fullName"   // defined in other place
    
    // attribute "shortName"
    static let NAME_SHORT_NAME = "shortName"
    
    // attribute "faceIconURI"
    static let NAME_FACE_ICON_URI = "faceIconURI"
    
    //
    // --------------------------------------------------
    // MARK: period
    // --------------------------------------------------
    //
    
    // element "period"
    static let NAME_PERIOD = "period"

    // attribute "type"
    // static let NAME_TYPE = "type"  // defined in other place

    // type of period: prologue
    static let VAL_PERIOD_TYPE_PROLOGUE = "prologue"

    // type of period: in progress
    static let VAL_PERIOD_TYPE_PROGRESS = "progress"
    
    // type of period: epilogue
    static let VAL_PERIOD_TYPE_EPILOGUE = "epilogue"
    
    // attribute "day"
    static let NAME_DAY = "day"
    
    //
    // --------------------------------------------------
    // MARK: EventAnnounceGroup の要素
    // --------------------------------------------------
    //
    
    // element "startEntry"
    static let NAME_START_ENTRY = "startEntry"
    
    // element "onStage"
    static let NAME_ON_STAGE = "onStage"
    
    // element "startMirror"
    static let NAME_START_MIRROR = "startMirror"
    
    // element "openRole"
    static let NAME_OPEN_ROLE = "openRole"
    
    // element "murdered"
    static let NAME_MURDERED = "murdered"
    
    // element "startAssault"
    static let NAME_START_ASSAULT = "startAssault"
    
    // element "survivor"
    static let NAME_SURVIVOR = "survivor"
    
    // element "counting"
    static let NAME_COUNTING = "counting"
    
    // element "suddenDeath"
    static let NAME_SUDDEN_DEATH = "suddenDeath"
    
    // element "noMurder"
    static let NAME_NO_MURDER = "noMurder"
    
    // element "winVillage"
    static let NAME_WIN_VILLAGE = "winVillage"
    
    // element "winWolf"
    static let NAME_WIN_WOLF = "winWolf"
    
    // element "winHamster"
    static let NAME_WIN_HAMSTER = "winHamster"
    
    // element "playerList"
    static let NAME_PLAYER_LIST = "playerList"
    
    // element "panic"
    static let  NAME_PANIC = "panic"

    //
    // --------------------------------------------------
    // MARK: elements in EventOrderGroup
    // --------------------------------------------------
    //
    
    // element "askEntry"
    static let NAME_ASK_ENTRY = "askEntry"
    
    // element "askCommit"
    static let NAME_ASK_COMMIT = "askCommit"
    
    // element "noComment"
    static let NAME_NO_COMMENT = "noComment"
    
    // element "stayEpilogue"
    static let NAME_STAY_EPILOGUE = "stayEpilogue"
    
    // element "gameOver"
    static let NAME_GAME_OVER = "gameOver"

    //
    // --------------------------------------------------
    // MARK: elements in EventExtraGroup
    // --------------------------------------------------
    //
    
    // element "judge"
    static let NAME_JUDGE = "judge"
    
    // element "guard"
    static let NAME_GUARD = "guard"
    
    //
    // --------------------------------------------------
    // MARK: assault
    // --------------------------------------------------
    //
    
    // element "assault"
    static let NAME_ASSAULT = "assault"
    
    // attribute "byWhom"
    static let NAME_BY_WHOM = "byWhom"
    
    //
    // --------------------------------------------------
    // MARK: talk
    // --------------------------------------------------
    //
    
    // element "talk"
    static let NAME_TALK = "talk"
    
    // attribute "type"
    static let NAME_TYPE = "type"
    
    // talk type: public (white balloon)
    static let VAL_TALK_TYPE_PUBLIC = "public"
    
    // talk type: wolf (red balloon)
    static let VAL_TALK_TYPE_WOLF = "wolf"
    
    // talk type: private (gray balloon)
    static let VAL_TALK_TYPE_PRIVATE = "private"
    
    // talk type: grave (blue balloon)
    static let VAL_TALK_TYPE_GRAVE = "grave"
    
    // attribute "avatarId"
    // static let NAME_AVATAR_ID = "avatarId" // defined in other place

    // attribute "time"
    static let NAME_TIME = "time"
    
    //
    // --------------------------------------------------
    // MARK: li
    // --------------------------------------------------
    //
    
    // element "li"
    static let NAME_LI = "li"
    
    //
    // --------------------------------------------------
    // MARK: rawdata
    // --------------------------------------------------
    //
    
    // element "rawdata"
    static let NAME_RAWDATA = "rawdata"
    
    //
    // --------------------------------------------------
    // MARK: playerInfo
    // --------------------------------------------------
    //
    
    // element "playerInfo"
    static let NAME_PLAYER_INFO = "playerInfo"
    
    // attribute "avatarId"
    // static let NAME_AVATAR_ID = "avatarId" // defined in other place

    // attribute "role"
    static let NAME_ROLE = "role"
    
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
}
