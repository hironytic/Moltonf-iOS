//
// ArchiveConstants.swift
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

open class ArchiveConstants {
    // MARK: filename
    open static let FILE_PLAYDATA_JSON = "playdata.json"
    
    // MARK: playdata
    open static let LANG = "lang"
    open static let BASE = "base"
    open static let FULL_NAME = "fullName"
    open static let VID = "vid"
    open static let COMMIT_TIME = "commitTime"
    open static let STATE = "state"
    open static let DISCLOSURE = "disclosure"
    open static let IS_VALID = "isValid"
    open static let LAND_NAME = "landName"
    open static let FORMAL_NAME = "formalName"
    open static let LAND_ID = "landId"
    open static let LAND_PREFIX = "landPrefix"
    open static let LOCALE = "locale"
    open static let ORGENCODING = "origencoding"
    open static let TIMEZONE = "timezone"
    open static let GRAVE_ICON_URI = "graveIconURI"
    open static let GENERATOR = "generator"
    open static let AVATAR_LIST = "avatarList"
    open static let PERIODS = "periods"
    
    // MARK: playdata["avatarList"][n]
    open static let AVATAR_ID = "avatarId"
    // public static let FULL_NAME = "fullName"    // defined in another place
    open static let SHORT_NAME = "shortName"
    open static let FACE_ICON_URI = "faceIconURI"
    
    // MARK: playdata["periods"][n] or period
    open static let TYPE = "type"
    open static let DAY = "day"
    open static let NEXT_COMMIT_DAY = "nextCommitDay"
    // public static let COMMIT_TIME = "commitTime"    // defined in another place
    open static let SOURCE_URI = "sourceURI"
    open static let LOADED_TIME = "loadedTime"
    open static let LOADED_BY = "loadedBy"
    open static let HREF = "href"
    open static let ELEMENTS = "elements"
    
    // MARK: value of period["type"]
    open static let VAL_PROLOGUE = "prologue"
    open static let VAL_PROGRESS = "progress"
    open static let VAL_EPILOGUE = "epilogue"
    
    // MARK: period["elements"][n]
    // public static let TYPE = "type" // defined in another place
    open static let LINES = "lines"
    
    // MARK: value of period["elements"][n]["type"]
    open static let VAL_START_ENTRY = "startEntry"
    open static let VAL_ON_STAGE = "onStage"
    open static let VAL_START_MIRROR = "startMirror"
    open static let VAL_OPEN_ROLE = "openRole"
    open static let VAL_MURDERED = "murdered"
    open static let VAL_START_ASSAULT = "startAssault"
    open static let VAL_SURVIVOR = "survivor"
    open static let VAL_COUNTING = "counting"
    open static let VAL_VOTE = "vote"
    open static let VAL_SUDDEN_DEATH = "suddenDeath"
    open static let VAL_NO_MURDER = "noMurder"
    open static let VAL_WIN_VILLAGE = "winVillage"
    open static let VAL_WIN_WOLF = "winWolf"
    open static let VAL_WIN_HAMSTER = "winHamster"
    open static let VAL_PLAYER_LIST = "playerList"
    open static let VAL_PANIC = "panic"
    open static let VAL_EXECUTION = "execution"
    open static let VAL_VANISH = "vanish"
    open static let VAL_CHECKOUT = "checkout"
    open static let VAL_SHORT_MEMBER = "shortMember"
    open static let VAL_ASK_ENTRY = "askEntry"
    open static let VAL_ASK_COMMIT = "askCommit"
    open static let VAL_NO_COMMENT = "noComment"
    open static let VAL_STAY_EPILOGUE = "stayEpilogue"
    open static let VAL_GAME_OVER = "gameOver"
    open static let VAL_JUDGE = "judge"
    open static let VAL_GUARD = "guard"
    open static let VAL_COUNTING2 = "counting2"
    open static let VAL_ASSAULT = "assault"
    open static let VAL_TALK = "talk"
    
    // MARK: period["elements"][n] (talk)
    open static let TALK_TYPE = "talkType"
    // public static let AVATAR_ID = "avatarId"        // defined in another place
    open static let XNAME = "xname"
    open static let TIME = "time"
    // public static let FACE_ICON_URI = "faceIconURI" // defined in another place
    
    // MARK: value of period["elements"][n] (talk) ["talkType"]
    open static let VAL_PUBLIC = "public"
    open static let VAL_WOLF = "wolf"
    open static let VAL_PRIVATE = "private"
    open static let VAL_GRAVE = "grave"
    
    // MARK: period["elements"][n] (onStage)
    open static let ENTRY_NO = "entryNo"
    // public static let AVATAR_ID = "avatarId"        // defined in another place
    
    // MARK: period["elements"][n] (openRole)
    open static let ROLE_HEADS = "roleHeads"
    
    // MARK: period["elements"][n] (murdered)
    // public static let AVATAR_ID = "avatarId"        // defined in another place
    
    // MARK: period["elements"][n] (survivor)
    // public static let AVATAR_ID = "avatarId"        // defined in another place

    // MARK: period["elements"][n] (counting)
    open static let VICTIM = "victim"
    open static let VOTES = "votes"
    
    // MARK: period["elements"][n] (playerList)
    open static let PLAYER_INFOS = "playerInfos"
    open static let PLAYER_ID = "playerId"
    // public static let AVATAR_ID = "avatarId"        // defined in another place
    open static let SURVIVE = "survive"
    open static let ROLE = "role"
    open static let URI = "uri"
    
    // MARK: period["elements"][n] (execution)
    // public static let VICTIM = "victim"             // defined in another place
    open static let NOMINATEDS = "nominateds"
    
    // MARK: period["elements"][n] (askEntry)
    // public static let COMMIT_TIME = "commitTime"    // defined in another place
    open static let MIN_MEMBERS = "minMembers"
    open static let MAX_MEMBERS = "maxMembers"
    
    // MARK: period["elements"][n] (askCommit)
    open static let LIMIT_VOTE = "limitVote"
    open static let LIMIT_SPECIAL = "limitSpecial"
    
    // MARK: period["elements"][n] (noComment)
    // public static let AVATAR_ID = "avatarId"        // defined in another place
    
    // MARK: period["elements"][n] (stayEpilogue)
    open static let WINNER = "winner"
    open static let LIMIT_TIME = "limitTime"
    
    // MARK: period["elements"][n] (judge)
    open static let BY_WHOM = "byWhom"
    open static let TARGET = "target"

    // MARK: period["elements"][n] (guard)
    // public static let BY_WHOM = "byWhom"            // defined in another place
    // public static let TARGET = "target"             // defined in another place
    
    // MARK: perild["elements"][n] (assault)
    // public static let BY_WHOM = "byWhom"            // defined in another place
    // public static let TARGET = "target"             // defined in another place
    // public static let XNAME = "xname"               // defined in another place
    // public static let TIME = "time"                 // defined in another place
    // public static let FACE_ICON_URI = "faceIconURI" // defined in another place
    
    // MARK: period["elements"][n]["lines"][m]
    open static let ENCODING = "encoding"
    open static let HEX_BIN = "hexBin"
    open static let CHAR = "char"
}
