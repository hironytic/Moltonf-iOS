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

public class ArchiveConstants {
    // MARK: filename
    public static let FILE_PLAYDATA_JSON = "playdata.json"
    
    // MARK: playdata
    public static let LANG = "lang"
    public static let BASE = "base"
    public static let FULL_NAME = "fullName"
    public static let VID = "vid"
    public static let COMMIT_TIME = "commitTime"
    public static let STATE = "state"
    public static let DISCLOSURE = "disclosure"
    public static let IS_VALID = "isValid"
    public static let LAND_NAME = "landName"
    public static let FORMAL_NAME = "formalName"
    public static let LAND_ID = "landId"
    public static let LAND_PREFIX = "landPrefix"
    public static let LOCALE = "locale"
    public static let ORGENCODING = "origencoding"
    public static let TIMEZONE = "timezone"
    public static let GRAVE_ICON_URI = "graveIconURI"
    public static let GENERATOR = "generator"
    public static let AVATAR_LIST = "avatarList"
    public static let PERIODS = "periods"
    
    // MARK: playdata["avatarList"][n]
    public static let AVATAR_ID = "avatarId"
    // public static let FULL_NAME = "fullName"    // defined in another place
    public static let SHORT_NAME = "shortName"
    public static let FACE_ICON_URI = "faceIconURI"
    
    // MARK: playdata["periods"][n] or period
    public static let TYPE = "type"
    public static let DAY = "day"
    public static let NEXT_COMMIT_DAY = "nextCommitDay"
    // public static let COMMIT_TIME = "commitTime"    // defined in another place
    public static let SOURCE_URI = "sourceURI"
    public static let LOADED_TIME = "loadedTime"
    public static let LOADED_BY = "loadedBy"
    public static let HREF = "href"
    public static let ELEMENTS = "elements"
    
    // MARK: value of period["type"]
    public static let VAL_PROLOGUE = "prologue"
    public static let VAL_PROGRESS = "progress"
    public static let VAL_EPILOGUE = "epilogue"
    
    // MARK: period["elements"][n]
    // public static let TYPE = "type" // defined in another place
    public static let LINES = "lines"
    
    // MARK: value of period["elements"][n]["type"]
    public static let VAL_START_ENTRY = "startEntry"
    public static let VAL_ON_STAGE = "onStage"
    public static let VAL_START_MIRROR = "startMirror"
    public static let VAL_OPEN_ROLE = "openRole"
    public static let VAL_MURDERED = "murdered"
    public static let VAL_START_ASSAULT = "startAssault"
    public static let VAL_SURVIVOR = "survivor"
    public static let VAL_COUNTING = "counting"
    public static let VAL_VOTE = "vote"
    public static let VAL_SUDDEN_DEATH = "suddenDeath"
    public static let VAL_NO_MURDER = "noMurder"
    public static let VAL_WIN_VILLAGE = "winVillage"
    public static let VAL_WIN_WOLF = "winWolf"
    public static let VAL_WIN_HAMSTER = "winHamster"
    public static let VAL_PLAYER_LIST = "playerList"
    public static let VAL_PANIC = "panic"
    public static let VAL_EXECUTION = "execution"
    public static let VAL_VANISH = "vanish"
    public static let VAL_CHECKOUT = "checkout"
    public static let VAL_SHORT_MEMBER = "shortMember"
    public static let VAL_ASK_ENTRY = "askEntry"
    public static let VAL_ASK_COMMIT = "askCommit"
    public static let VAL_NO_COMMENT = "noComment"
    public static let VAL_STAY_EPILOGUE = "stayEpilogue"
    public static let VAL_GAME_OVER = "gameOver"
    public static let VAL_JUDGE = "judge"
    public static let VAL_GUARD = "guard"
    public static let VAL_COUNTING2 = "counting2"
    public static let VAL_ASSAULT = "assault"
    public static let VAL_TALK = "talk"
    
    // MARK: period["elements"][n] (talk)
    public static let TALK_TYPE = "talkType"
    // public static let AVATAR_ID = "avatarId"        // defined in another place
    public static let XNAME = "xname"
    public static let TIME = "time"
    // public static let FACE_ICON_URI = "faceIconURI" // defined in another place
    public static let PUBLIC_TALK_NO = "publicTalkNo"
    
    // MARK: value of period["elements"][n] (talk) ["talkType"]
    public static let VAL_PUBLIC = "public"
    public static let VAL_WOLF = "wolf"
    public static let VAL_PRIVATE = "private"
    public static let VAL_GRAVE = "grave"
    
    // MARK: period["elements"][n] (onStage)
    public static let ENTRY_NO = "entryNo"
    // public static let AVATAR_ID = "avatarId"        // defined in another place
    
    // MARK: period["elements"][n] (openRole)
    public static let ROLE_HEADS = "roleHeads"
    
    // MARK: period["elements"][n] (murdered)
    // public static let AVATAR_ID = "avatarId"        // defined in another place
    
    // MARK: period["elements"][n] (survivor)
    // public static let AVATAR_ID = "avatarId"        // defined in another place

    // MARK: period["elements"][n] (counting)
    public static let VICTIM = "victim"
    public static let VOTES = "votes"
    
    // MARK: period["elements"][n] (playerList)
    public static let PLAYER_INFOS = "playerInfos"
    public static let PLAYER_ID = "playerId"
    // public static let AVATAR_ID = "avatarId"        // defined in another place
    public static let SURVIVE = "survive"
    public static let ROLE = "role"
    public static let URI = "uri"
    
    // MARK: period["elements"][n] (execution)
    // public static let VICTIM = "victim"             // defined in another place
    public static let NOMINATEDS = "nominateds"
    
    // MARK: period["elements"][n] (askEntry)
    // public static let COMMIT_TIME = "commitTime"    // defined in another place
    public static let MIN_MEMBERS = "minMembers"
    public static let MAX_MEMBERS = "maxMembers"
    
    // MARK: period["elements"][n] (askCommit)
    public static let LIMIT_VOTE = "limitVote"
    public static let LIMIT_SPECIAL = "limitSpecial"
    
    // MARK: period["elements"][n] (noComment)
    // public static let AVATAR_ID = "avatarId"        // defined in another place
    
    // MARK: period["elements"][n] (stayEpilogue)
    public static let WINNER = "winner"
    public static let LIMIT_TIME = "limitTime"
    
    // MARK: period["elements"][n] (judge)
    public static let BY_WHOM = "byWhom"
    public static let TARGET = "target"

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
    public static let ENCODING = "encoding"
    public static let HEX_BIN = "hexBin"
    public static let CHAR = "char"
}
