//
// ArchiveTests.swift
// MoltonfTests
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

import XCTest
import XMLPullitic
import SwiftyJSON
@testable import Moltonf

private class MockJSONWriter: ArchiveJSONWriter {
    var output: [(fileName: String, object: [String: AnyObject])] = []
    func writeArchiveJSON(fileName fileName: String, object: [String: AnyObject]) throws {
        output.append((fileName: fileName, object: object))
    }
}

private enum TestError: ErrorType {
    case CreateParser
}

class ArchiveTests: XCTestCase {
    typealias K = ArchiveKeys
    var outDir: String = ""
    
    override func setUp() {
        super.setUp()
        
        outDir = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString)
            .stringByAppendingPathComponent("ArchiveTests")
        _ = try? NSFileManager.defaultManager().removeItemAtPath(outDir)
    }
    
    override func tearDown() {
        _ = try? NSFileManager.defaultManager().removeItemAtPath(outDir)
        
        super.tearDown()
    }

    func testConvertToJSON() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let archiveFilePath = bundle.pathForResource("jin_wolff_00000", ofType: "xml")!

        let converter = ArchiveToJSON(fromArchive: archiveFilePath, toDirectory: outDir)
        do {
            try converter.convert()
        } catch let error {
            XCTFail("error: \(error)")
            return
        }
        
        let playdataFilePath = (outDir as NSString).stringByAppendingPathComponent("playdata.json")
        guard let playdataData = NSData(contentsOfFile: playdataFilePath) else {
            XCTFail("failed to load playdata.json")
            return
        }
        let playdata = JSON(data: playdataData)
        let landName = playdata[K.LAND_NAME].string
        XCTAssertEqual(landName, "人狼BBS:F国")

        let period0FilePath = (outDir as NSString).stringByAppendingPathComponent("period-0.json")
        guard let period0Data = NSData(contentsOfFile: period0FilePath) else {
            XCTFail("failed to load period-0.json")
            return
        }
        let period0 = JSON(data: period0Data)
        let line = period0[K.ELEMENTS][2][K.LINES][0].string
        XCTAssertEqual(line, "人狼なんているわけないじゃん。みんな大げさだなあ")
    }
    
    func setupTargetElement(xml: String) throws -> (parser: XMLPullParser, element: XMLElement) {
        guard let parser = XMLPullParser(string: xml) else {
            throw TestError.CreateParser
        }
        parser.shouldProcessNamespaces = true

        while true {
            switch try parser.next() {
            case .StartElement(name: _, namespaceURI: _, element: let element):
                return (parser: parser, element: element)
            default:
                break
            }
        }
    }
    
    func testConvertVillage() {
        do {
            let (parser, element) = try setupTargetElement(
                "<village\n" +
                "  xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\"\n" +
                "  xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n" +
                "  xmlns:xlink=\"http://www.w3.org/1999/xlink\"\n" +
                "  xsi:schemaLocation=\"http://jindolf.sourceforge.jp/xml/ns/401 http://jindolf.sourceforge.jp/xml/xsd/bbsArchive-091001.xsd\"\n" +
                "  xml:lang=\"ja-JP\"\n" +
                "  xml:base=\"http://192.168.150.129/moltonf/\"\n" +
                "  fullName=\"F0 テスト用の村\" vid=\"0\"\n" +
                "  commitTime=\"08:15:00+09:00\"\n" +
                "  state=\"gameover\" isValid=\"true\"\n" +
                "  landName=\"人狼BBS:F国\" formalName=\"人狼BBS:F\"\n" +
                "  landId=\"wolff\" landPrefix=\"F\"\n" +
                "  locale=\"ja-JP\" origencoding=\"Shift_JIS\" timezone=\"GMT+09:00\"\n" +
                "  graveIconURI=\"plugin_wolf/img/face99.jpg\"\n" +
                "  generator=\"nobody1.0\"\n" +
                ">\n" +
                "  <avatarList>\n" +
                "    <avatar\n" +
                "      avatarId=\"gerd\"\n" +
                "      fullName=\"楽天家 ゲルト\" shortName=\"ゲルト\"\n" +
                "      faceIconURI=\"plugin_wolf/img/face01.jpg\"\n" +
                "    />\n" +
                "  </avatarList>\n" +
                "</village>\n"
            )
            
            let writer = MockJSONWriter()
            try ArchiveToJSON.VillageElementConverter(parser: parser).convert(element, writer: writer)
            
            let output = writer.output[0]
            let playdata = JSON(output.object)

            XCTAssertEqual(output.fileName, "playdata.json")
            
            let landName = playdata[K.LAND_NAME].string
            XCTAssertEqual(landName, "人狼BBS:F国")
            
            let vid = playdata[K.VID].int
            XCTAssertEqual(vid, 0)
            
            let isValid = playdata[K.IS_VALID].bool
            XCTAssertEqual(isValid, true)
            
            let avatarList = playdata[K.AVATAR_LIST].array
            XCTAssertNotNil(avatarList)
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertAvaterList() {
        do {
            let (parser, element) = try setupTargetElement(
                "<avatarList xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\">\n" +
                "  <avatar\n" +
                "    avatarId=\"gerd\"\n" +
                "    fullName=\"楽天家 ゲルト\" shortName=\"ゲルト\"\n" +
                "    faceIconURI=\"plugin_wolf/img/face01.jpg\"\n" +
                "  />\n" +
                "  <avatar\n" +
                "    avatarId=\"clara\"\n" +
                "    fullName=\"司書 クララ\" shortName=\"クララ\"\n" +
                "    faceIconURI=\"plugin_wolf/img/face19.jpg\"\n" +
                "  />\n" +
                "  <avatar\n" +
                "    avatarId=\"fridel\"\n" +
                "    fullName=\"シスター フリーデル\" shortName=\"フリーデル\"\n" +
                "    faceIconURI=\"plugin_wolf/img/face17.jpg\"\n" +
                "  />\n" +
                "</avatarList>\n"
            )
            let avatarList = JSON(try ArchiveToJSON.AvatarListElementConverter(parser: parser).convert(element))
            XCTAssertEqual(avatarList.count, 3)
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertAvatar() {
        do {
            let (parser, element) = try setupTargetElement(
                "<avatar xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\"\n" +
                "  avatarId=\"gerd\"\n" +
                "  fullName=\"楽天家 ゲルト\" shortName=\"ゲルト\"\n" +
                "  faceIconURI=\"plugin_wolf/img/face01.jpg\"\n" +
                "/>\n"
            )
            let avatar = JSON(try ArchiveToJSON.AvatarElementConverter(parser: parser).convert(element))
            XCTAssertEqual(avatar[K.AVATAR_ID].string, "gerd")
            XCTAssertEqual(avatar[K.FULL_NAME].string, "楽天家 ゲルト")
            XCTAssertEqual(avatar[K.SHORT_NAME].string, "ゲルト")
            XCTAssertEqual(avatar[K.FACE_ICON_URI].string, "plugin_wolf/img/face01.jpg")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertTalk() {
        do {
            let (parser, element) = try setupTargetElement(
                "<talk xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\"\n" +
                "  type=\"public\" avatarId=\"gerd\"\n" +
                "  xname=\"mes1246576501\" time=\"08:15:00+09:00\"\n" +
                ">\n" +
                "<li>ふぁーあ……ねむいな……寝てていい？</li>\n" +
                "<li/>\n" +
                "</talk>\n"
            )
            let talk = JSON(try ArchiveToJSON.TalkElementConverter(parser: parser).convert(element))
            XCTAssertEqual(talk[K.TYPE].string, K.VAL_TALK)
            XCTAssertEqual(talk[K.TALK_TYPE].string, "public")
            XCTAssertEqual(talk[K.AVATAR_ID].string, "gerd")
            XCTAssertEqual(talk[K.XNAME].string, "mes1246576501")
            XCTAssertEqual(talk[K.TIME].string, "08:15:00+09:00")
            let line = talk[K.LINES][0].string
            XCTAssertEqual(line, "ふぁーあ……ねむいな……寝てていい？")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertStartEntry() {
        do {
            let (parser, element) = try setupTargetElement(
                "<startEntry xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\">\n" +
                "<li>昼間は人間のふりをして、夜に正体を現すという人狼。</li>\n" +
                "<li>その人狼が、この村に紛れ込んでいるという噂が広がった。</li>\n" +
                "<li/>\n" +
                "<li>村人達は半信半疑ながらも、村はずれの宿に集められることになった。</li>\n" +
                "<li/>\n" +
                "</startEntry>\n"
            )
            let startEntry = JSON(try ArchiveToJSON.StartEntryElementConverter(parser: parser).convert(element))
            XCTAssertEqual(startEntry[K.TYPE].string, K.VAL_START_ENTRY)
            let line = startEntry[K.LINES][0].string
            XCTAssertEqual(line, "昼間は人間のふりをして、夜に正体を現すという人狼。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertOnStage() {
        do {
            let (parser, element) = try setupTargetElement(
                "<onStage xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\" entryNo=\"1\" avatarId=\"gerd\" >\n" +
                "<li>1人目、楽天家 ゲルト。</li>\n" +
                "</onStage>\n"
            )
            let onStage = JSON(try ArchiveToJSON.OnStageElementConverter(parser: parser).convert(element))
            XCTAssertEqual(onStage[K.TYPE].string, K.VAL_ON_STAGE)
            XCTAssertEqual(onStage[K.ENTRY_NO].int, 1)
            XCTAssertEqual(onStage[K.AVATAR_ID].string, "gerd")
            let line = onStage[K.LINES][0].string
            XCTAssertEqual(line, "1人目、楽天家 ゲルト。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertStartMirror() {
        do {
            let (parser, element) = try setupTargetElement(
                "<startMirror xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\">\n" +
                "<li>さあ、自らの姿を鏡に映してみよう。</li>\n" +
                "<li>そこに映るのはただの村人か、それとも血に飢えた人狼か。</li>\n" +
                "<li/>\n" +
                "<li>例え人狼でも、多人数で立ち向かえば怖くはない。</li>\n" +
                "<li>問題は、だれが人狼なのかという事だ。</li>\n" +
                "<li>占い師の能力を持つ人間ならば、それを見破れるだろう。</li>\n" +
                "<li/>\n" +
                "</startMirror>\n"
            )
            let startMirror = JSON(try ArchiveToJSON.StartMirrorElementConverter(parser: parser).convert(element))
            XCTAssertEqual(startMirror[K.TYPE].string, K.VAL_START_MIRROR)
            let line = startMirror[K.LINES][0].string
            XCTAssertEqual(line, "さあ、自らの姿を鏡に映してみよう。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertOpenRole() {
        do {
            let (parser, element) = try setupTargetElement(
                "<openRole xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\">\n" +
                "<li>どうやらこの中には、村人が7名、人狼が3名、占い師が1名、霊能者が1名、狂人が1名、狩人が1名、共有者が2名いるようだ。</li>\n" +
                "<roleHeads role=\"innocent\" heads=\"7\" />\n" +
                "<roleHeads role=\"wolf\" heads=\"3\" />\n" +
                "<roleHeads role=\"seer\" heads=\"1\" />\n" +
                "<roleHeads role=\"shaman\" heads=\"1\" />\n" +
                "<roleHeads role=\"madman\" heads=\"1\" />\n" +
                "<roleHeads role=\"hunter\" heads=\"1\" />\n" +
                "<roleHeads role=\"frater\" heads=\"2\" />\n" +
                "</openRole>\n"
            )
            let openRole = JSON(try ArchiveToJSON.OpenRoleElementConverter(parser: parser).convert(element))
            XCTAssertEqual(openRole[K.TYPE].string, K.VAL_OPEN_ROLE)
            XCTAssertEqual(openRole[K.ROLE_HEADS]["innocent"].int, 7)
            let line = openRole[K.LINES][0].string
            XCTAssertEqual(line, "どうやらこの中には、村人が7名、人狼が3名、占い師が1名、霊能者が1名、狂人が1名、狩人が1名、共有者が2名いるようだ。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertMurdered() {
        do {
            let (parser, element) = try setupTargetElement(
                "<murdered xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\">\n" +
                "<li>次の日の朝、楽天家 ゲルト が無残な姿で発見された。</li>\n" +
                "<li/>\n" +
                "<avatarRef avatarId=\"gerd\" />\n" +
                "</murdered>\n"
            )
            let murdered = JSON(try ArchiveToJSON.MurderedElementConverter(parser: parser).convert(element))
            XCTAssertEqual(murdered[K.TYPE].string, K.VAL_MURDERED)
            XCTAssertEqual(murdered[K.AVATAR_ID][0].string, "gerd")
            let line = murdered[K.LINES][0].string
            XCTAssertEqual(line, "次の日の朝、楽天家 ゲルト が無残な姿で発見された。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertStartAssault() {
        do {
            let (parser, element) = try setupTargetElement(
                "<startAssault xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\">\n" +
                "<li>ついに犠牲者が出た。人狼はこの村人達のなかにいる。</li>\n" +
                "<li>しかし、それを見分ける手段はない。</li>\n" +
                "<li/>\n" +
                "<li>村人達は、疑わしい者を排除するため、投票を行う事にした。</li>\n" +
                "<li>無実の犠牲者が出るのもやむをえない。村が全滅するよりは……。</li>\n" +
                "<li/>\n" +
                "<li>最後まで残るのは村人か、それとも人狼か。</li>\n" +
                "<li/>\n" +
                "</startAssault>\n"
            )
            let startAssault = JSON(try ArchiveToJSON.StartAssaultElementConverter(parser: parser).convert(element))
            XCTAssertEqual(startAssault[K.TYPE].string, K.VAL_START_ASSAULT)
            let line = startAssault[K.LINES][0].string
            XCTAssertEqual(line, "ついに犠牲者が出た。人狼はこの村人達のなかにいる。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertSurvivor() {
        do {
            let (parser, element) = try setupTargetElement(
                "<survivor xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\">\n" +
                "<li>現在の生存者は、司書 クララ、シスター フリーデル、少女 リーザ、宿屋の女主人 レジーナ、ならず者 ディーター、神父 ジムゾン、少年 ペーター、青年 ヨアヒム、旅人 ニコラス、農夫 ヤコブ、負傷兵 シモン、仕立て屋 エルナ、パン屋 オットー、老人 モーリッツ、羊飼い カタリナ の 15 名。</li>\n" +
                "<avatarRef avatarId=\"clara\" />\n" +
                "<avatarRef avatarId=\"fridel\" />\n" +
                "<avatarRef avatarId=\"liesa\" />\n" +
                "<avatarRef avatarId=\"regina\" />\n" +
                "<avatarRef avatarId=\"dieter\" />\n" +
                "<avatarRef avatarId=\"simson\" />\n" +
                "<avatarRef avatarId=\"peter\" />\n" +
                "<avatarRef avatarId=\"joachim\" />\n" +
                "<avatarRef avatarId=\"nicolas\" />\n" +
                "<avatarRef avatarId=\"jacob\" />\n" +
                "<avatarRef avatarId=\"simon\" />\n" +
                "<avatarRef avatarId=\"erna\" />\n" +
                "<avatarRef avatarId=\"otto\" />\n" +
                "<avatarRef avatarId=\"moritz\" />\n" +
                "<avatarRef avatarId=\"katharina\" />\n" +
                "</survivor>\n"
            )
            let survivor = JSON(try ArchiveToJSON.SurvivorElementConverter(parser: parser).convert(element))
            XCTAssertEqual(survivor[K.TYPE].string, K.VAL_SURVIVOR)
            XCTAssert(survivor[K.AVATAR_ID].arrayValue.contains("liesa"))
            let line = survivor[K.LINES][0].string
            XCTAssertEqual(line, "現在の生存者は、司書 クララ、シスター フリーデル、少女 リーザ、宿屋の女主人 レジーナ、ならず者 ディーター、神父 ジムゾン、少年 ペーター、青年 ヨアヒム、旅人 ニコラス、農夫 ヤコブ、負傷兵 シモン、仕立て屋 エルナ、パン屋 オットー、老人 モーリッツ、羊飼い カタリナ の 15 名。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertCounting() {
        do {
            let (parser, element) = try setupTargetElement(
                "<counting victim=\"moritz\" xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\">\n" +
                "<li>司書 クララ は 老人 モーリッツ に投票した。</li>\n" +
                "<li>シスター フリーデル は 少年 ペーター に投票した。</li>\n" +
                "<li>少女 リーザ は 少年 ペーター に投票した。</li>\n" +
                "<li>宿屋の女主人 レジーナ は 老人 モーリッツ に投票した。</li>\n" +
                "<li>ならず者 ディーター は 少年 ペーター に投票した。</li>\n" +
                "<li>神父 ジムゾン は 老人 モーリッツ に投票した。</li>\n" +
                "<li>少年 ペーター は 老人 モーリッツ に投票した。</li>\n" +
                "<li>青年 ヨアヒム は 老人 モーリッツ に投票した。</li>\n" +
                "<li>旅人 ニコラス は 少年 ペーター に投票した。</li>\n" +
                "<li>農夫 ヤコブ は 少年 ペーター に投票した。</li>\n" +
                "<li>負傷兵 シモン は 農夫 ヤコブ に投票した。</li>\n" +
                "<li>仕立て屋 エルナ は 司書 クララ に投票した。</li>\n" +
                "<li>パン屋 オットー は 老人 モーリッツ に投票した。</li>\n" +
                "<li>老人 モーリッツ は 負傷兵 シモン に投票した。</li>\n" +
                "<li>羊飼い カタリナ は 少年 ペーター に投票した。</li>\n" +
                "<li/>\n" +
                "<li>老人 モーリッツ は村人達の手により処刑された。</li>\n" +
                "<vote byWhom=\"clara\" target=\"moritz\" />\n" +
                "<vote byWhom=\"fridel\" target=\"peter\" />\n" +
                "<vote byWhom=\"liesa\" target=\"peter\" />\n" +
                "<vote byWhom=\"regina\" target=\"moritz\" />\n" +
                "<vote byWhom=\"dieter\" target=\"peter\" />\n" +
                "<vote byWhom=\"simson\" target=\"moritz\" />\n" +
                "<vote byWhom=\"peter\" target=\"moritz\" />\n" +
                "<vote byWhom=\"joachim\" target=\"moritz\" />\n" +
                "<vote byWhom=\"nicolas\" target=\"peter\" />\n" +
                "<vote byWhom=\"jacob\" target=\"peter\" />\n" +
                "<vote byWhom=\"simon\" target=\"jacob\" />\n" +
                "<vote byWhom=\"erna\" target=\"clara\" />\n" +
                "<vote byWhom=\"otto\" target=\"moritz\" />\n" +
                "<vote byWhom=\"moritz\" target=\"simon\" />\n" +
                "<vote byWhom=\"katharina\" target=\"peter\" />\n" +
                "</counting>\n"
            )
            let counting = JSON(try ArchiveToJSON.CountingElementConverter(parser: parser).convert(element))
            XCTAssertEqual(counting[K.TYPE].string, K.VAL_COUNTING)
            XCTAssertEqual(counting[K.VICTIM].string, "moritz")
            XCTAssertEqual(counting[K.VOTES]["liesa"].string, "peter")
            let line = counting[K.LINES][0].string
            XCTAssertEqual(line, "司書 クララ は 老人 モーリッツ に投票した。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertSuddenDeath() {
        do {
            let (parser, element) = try setupTargetElement(
                "<suddenDeath avatarId=\"otto\" xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\">\n" +
                "<li>パン屋 オットー は、突然死した。</li>\n" +
                "</suddenDeath>\n"
            )
            let suddenDeath = JSON(try ArchiveToJSON.SuddenDeathElementConverter(parser: parser).convert(element))
            XCTAssertEqual(suddenDeath[K.TYPE].string, K.VAL_SUDDEN_DEATH)
            XCTAssertEqual(suddenDeath[K.AVATAR_ID].string, "otto")
            let line = suddenDeath[K.LINES][0].string
            XCTAssertEqual(line, "パン屋 オットー は、突然死した。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertNoMurder() {
        do {
            let (parser, element) = try setupTargetElement(
                "<noMurder xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\">\n" +
                "<li>今日は犠牲者がいないようだ。人狼は襲撃に失敗したのだろうか。</li>\n" +
                "<li/>\n" +
                "</noMurder>\n"
            )
            let noMurder = JSON(try ArchiveToJSON.NoMurderElementConverter(parser: parser).convert(element))
            XCTAssertEqual(noMurder[K.TYPE].string, K.VAL_NO_MURDER)
            let line = noMurder[K.LINES][0].string
            XCTAssertEqual(line, "今日は犠牲者がいないようだ。人狼は襲撃に失敗したのだろうか。")            
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertWinVillage() {
        do {
            let (parser, element) = try setupTargetElement(
                "<winVillage xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\">\n" +
                "<li>全ての人狼を退治した……。人狼に怯える日々は去ったのだ！</li>\n" +
                "<li/>\n" +
                "</winVillage>\n"
            )
            let winVillage = JSON(try ArchiveToJSON.WinVillageElementConverter(parser: parser).convert(element))
            XCTAssertEqual(winVillage[K.TYPE].string, K.VAL_WIN_VILLAGE)
            let line = winVillage[K.LINES][0].string
            XCTAssertEqual(line, "全ての人狼を退治した……。人狼に怯える日々は去ったのだ！")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertWinWolf() {
        do {
            let (parser, element) = try setupTargetElement(
                "<winWolf xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\">\n" +
                "<li>もう人狼に抵抗できるほど村人は残っていない……。</li>\n" +
                "<li>人狼は残った村人を全て食らい、別の獲物を求めてこの村を去っていった。</li>\n" +
                "<li/>\n" +
                "</winWolf>\n"
            )
            let winWolf = JSON(try ArchiveToJSON.WinWolfElementConverter(parser: parser).convert(element))
            XCTAssertEqual(winWolf[K.TYPE].string, K.VAL_WIN_WOLF)
            let line = winWolf[K.LINES][0].string
            XCTAssertEqual(line, "もう人狼に抵抗できるほど村人は残っていない……。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertWinHamster() {
        do {
            let (parser, element) = try setupTargetElement(
                "<winHamster xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\">\n" +
                "<li>全ては終わったかのように見えた。</li>\n" +
                "<li>だが、奴が生き残っていた……。</li>\n" +
                "<li/>\n" +
                "</winHamster>\n"
            )
            let winHamster = JSON(try ArchiveToJSON.WinHamsterElementConverter(parser: parser).convert(element))
            XCTAssertEqual(winHamster[K.TYPE].string, K.VAL_WIN_HAMSTER)
            let line = winHamster[K.LINES][0].string
            XCTAssertEqual(line, "全ては終わったかのように見えた。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
}
