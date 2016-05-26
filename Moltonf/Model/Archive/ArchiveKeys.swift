//
// ArchiveKeys.swift
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

class ArchiveKeys {
    // MARK: playdata
    static let LANG = "lang"
    static let BASE = "base"
    static let FULL_NAME = "fullName"
    static let VID = "vid"
    static let COMMIT_TIME = "commitTime"
    static let STATE = "state"
    static let DISCLOSURE = "disclosure"
    static let IS_VALID = "isValid"
    static let LAND_NAME = "landName"
    static let FORMAL_NAME = "formalName"
    static let LAND_ID = "landId"
    static let LAND_PREFIX = "landPrefix"
    static let LOCALE = "locale"
    static let ORGENCODING = "origencoding"
    static let TIMEZONE = "timezone"
    static let GRAVE_ICON_URI = "graveIconURI"
    static let GENERATOR = "generator"
    static let AVATAR_LIST = "avatarList"
    static let PERIODS = "periods"
    
    // MARK: playdata["avatarList"][n]
    static let AVATAR_ID = "avatarId"
    // static let FULL_NAME = "fullName"    // defined in another place
    static let SHORT_NAME = "shortName"
    static let FACE_ICON_URI = "faceIconURI"
    
    // MARK: playdata["periods"][n] or period
    static let TYPE = "type"
    static let DAY = "day"
    static let NEXT_COMMIT_DAY = "nextCommitDay"
    // static let COMMIT_TIME = "commitTime"    // defined in another place
    static let SOURCE_URI = "sourceURI"
    static let LOADED_TIME = "loadedTime"
    static let LOADED_BY = "loadedBy"
    static let HREF = "href"
    static let ELEMENTS = "elements"
    
    // MARK: period["elements"][n]
    // static let TYPE = "type" // defined in another place
    static let LINES = "lines"
    
    // MARK: value of period["elements"][n]["type"]
    static let VAL_START_ENTRY = "startEntry"
    static let VAL_ON_STAGE = "onStage"
    static let VAL_START_MIRROR = "startMirror"
    static let VAL_OPEN_ROLE = "openRole"
    static let VAL_MURDERED = "murdered"
    static let VAL_START_ASSAULT = "startAssault"
    static let VAL_SURVIVOR = "survivor"
    static let VAL_COUNTING = "counting"
    static let VAL_VOTE = "vote"
    static let VAL_SUDDEN_DEATH = "suddenDeath"
    static let VAL_NO_MURDER = "noMurder"
    static let VAL_WIN_VILLAGE = "winVillage"
    static let VAL_WIN_WOLF = "winWolf"
    static let VAL_WIN_HAMSTER = "winHamster"
    static let VAL_PLAYER_LIST = "playerList"
    static let VAL_PANIC = "panic"
    static let VAL_EXECUTION = "execution"
    static let VAL_VANISH = "vanish"
    static let VAL_CHECKOUT = "checkout"
    static let VAL_SHORT_MEMBER = "shortMember"
    static let VAL_ASK_ENTRY = "askEntry"
    static let VAL_ASK_COMMIT = "askCommit"
    static let VAL_NO_COMMENT = "noComment"
    static let VAL_STAY_EPILOGUE = "stayEpilogue"
    static let VAL_GAME_OVER = "gameOver"
    static let VAL_JUDGE = "judge"
    static let VAL_GUARD = "guard"
    static let VAL_COUNTING2 = "counting2"
    static let VAL_ASSAULT = "assault"
    static let VAL_TALK = "talk"
    
    // MARK: period["elements"][n] (talk)
    static let TALK_TYPE = "talkType"
    // static let AVATAR_ID = "avatarId"        // defined in another place
    static let XNAME = "xname"
    static let TIME = "time"
    // static let FACE_ICON_URI = "faceIconURI" // defined in another place
    
    // MARK: period["elements"][n] (Event)
    static let EVENT_FAMILY = "eventFamily"

    // MARK: period["elements"][n] (onStage)
    static let ENTRY_NO = "entryNo"
    // static let AVATAR_ID = "avatarId"        // defined in another place
    
    // MARK: period["elements"][n] (openRole)
    static let ROLE_HEADS = "roleHeads"
    
    // MARK: period["elements"][n]["lines"][m]
    static let ENCODING = "encoding"
    static let HEX_BIN = "hexBin"
    static let CHAR = "char"
    
}