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
    typealias K = ArchiveConstants
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
    
    func testConvertPlayerList() {
        do {
            let (parser, element) = try setupTargetElement(
                "<playerList xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\">\n" +
                "<li>楽天家 ゲルト （master）、死亡。村人だった。</li>\n" +
                "<li>司書 クララ （player1）、生存。霊能者だった。</li>\n" +
                "<li>シスター フリーデル （player2）、生存。共有者だった。</li>\n" +
                "<li>少女 リーザ （player3）、死亡。村人だった。</li>\n" +
                "<li>宿屋の女主人 レジーナ （player4）、生存。共有者だった。</li>\n" +
                "<li>ならず者 ディーター （player5）、死亡。人狼だった。</li>\n" +
                "<li>農夫 ヤコブ （player10）、生存。占い師だった。</li>\n" +
                "<li>仕立て屋 エルナ （player12）、生存。狩人だった。</li>\n" +
                "<li>羊飼い カタリナ （player15）、死亡。狂人だった。</li>\n" +
                "<playerInfo playerId=\"master\" avatarId=\"gerd\" survive=\"false\" role=\"innocent\" />\n" +
                "<playerInfo playerId=\"player1\" avatarId=\"clara\" survive=\"true\" role=\"shaman\" />\n" +
                "<playerInfo playerId=\"player2\" avatarId=\"fridel\" survive=\"true\" role=\"frater\" uri=\"http://192.168.150.129/wolfbbs/player2.html\" />\n" +
                "<playerInfo playerId=\"player3\" avatarId=\"liesa\" survive=\"false\" role=\"innocent\" uri=\"http://192.168.150.129/wolfbbs/player3.html\" />\n" +
                "<playerInfo playerId=\"player4\" avatarId=\"regina\" survive=\"true\" role=\"frater\" />\n" +
                "<playerInfo playerId=\"player5\" avatarId=\"dieter\" survive=\"false\" role=\"wolf\" uri=\"http://192.168.150.129/wolfbbs/player5.html\" />\n" +
                "<playerInfo playerId=\"player10\" avatarId=\"jacob\" survive=\"true\" role=\"seer\" uri=\"http://192.168.150.129/wolfbbs/player10.html\" />\n" +
                "<playerInfo playerId=\"player12\" avatarId=\"erna\" survive=\"true\" role=\"hunter\" uri=\"http://192.168.150.129/wolfbbs/player12.html\" />\n" +
                "<playerInfo playerId=\"player15\" avatarId=\"katharina\" survive=\"false\" role=\"madman\" uri=\"http://192.168.150.129/wolfbbs/player15.html\" />\n" +
                "</playerList>\n"
            )
            let playerList = JSON(try ArchiveToJSON.PlayerListElementConverter(parser: parser).convert(element))
            XCTAssertEqual(playerList[K.TYPE].string, K.VAL_PLAYER_LIST)
            XCTAssertEqual(playerList[K.PLAYER_INFOS].array?.count, 9)
            XCTAssertEqual(playerList[K.PLAYER_INFOS][0][K.PLAYER_ID].string, "master")
            XCTAssertEqual(playerList[K.PLAYER_INFOS][0][K.SURVIVE].bool, false)
            XCTAssertEqual(playerList[K.PLAYER_INFOS][1][K.AVATAR_ID].string, "clara")
            XCTAssertEqual(playerList[K.PLAYER_INFOS][1][K.SURVIVE].bool, true)
            XCTAssertNil(playerList[K.PLAYER_INFOS][1][K.URI].string)
            XCTAssertEqual(playerList[K.PLAYER_INFOS][2][K.URI].string, "http://192.168.150.129/wolfbbs/player2.html")
            let line = playerList[K.LINES][0].string
            XCTAssertEqual(line, "楽天家 ゲルト （master）、死亡。村人だった。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertPanic() {
        do {
            let (parser, element) = try setupTargetElement(
                "<panic xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\">\n" +
                "<li>……。</li>\n" +
                "</panic>\n"
            )
            let panic = JSON(try ArchiveToJSON.PanicElementConverter(parser: parser).convert(element))
            XCTAssertEqual(panic[K.TYPE].string, K.VAL_PANIC)
            let line = panic[K.LINES][0].string
            XCTAssertEqual(line, "……。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertExecution() {
        do {
            let (parser, element) = try setupTargetElement(
                "<execution xmlns=\"http://jindolf.sourceforge.jp/xml/ns/501\" victim=\"dieter\" >\n" +
                "<li>負傷兵 シモン、1票。</li>\n" +
                "<li>青年 ヨアヒム、1票。</li>\n" +
                "<li>ならず者 ディーター、8票。</li>\n" +
                "<li/>\n" +
                "<li>ならず者 ディーター は村人達の手により処刑された。</li>\n" +
                "<nominated avatarId=\"simon\" count=\"1\" />\n" +
                "<nominated avatarId=\"joachim\" count=\"1\" />\n" +
                "<nominated avatarId=\"dieter\" count=\"8\" />\n" +
                "</execution>\n"
            )
            let execution = JSON(try ArchiveToJSON.ExecutionElementConverter(parser: parser).convert(element))
            XCTAssertEqual(execution[K.TYPE].string, K.VAL_EXECUTION)
            XCTAssertEqual(execution[K.VICTIM].string, "dieter")
            XCTAssertEqual(execution[K.NOMINATEDS]["simon"].int, 1)
            let line = execution[K.LINES][0].string
            XCTAssertEqual(line, "負傷兵 シモン、1票。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertVanish() {
        do {
            let (parser, element) = try setupTargetElement(
                "<vanish xmlns=\"http://jindolf.sourceforge.jp/xml/ns/501\" avatarId=\"erna\" >\n" +
                "<li>仕立て屋 エルナ は、失踪した。</li>\n" +
                "</vanish>\n"
            )
            let vanish = JSON(try ArchiveToJSON.VanishElementConverter(parser: parser).convert(element))
            XCTAssertEqual(vanish[K.TYPE].string, K.VAL_VANISH)
            XCTAssertEqual(vanish[K.AVATAR_ID].string, "erna")
            let line = vanish[K.LINES][0].string
            XCTAssertEqual(line, "仕立て屋 エルナ は、失踪した。")            
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertCheckout() {
        do {
            let (parser, element) = try setupTargetElement(
                "<checkout xmlns=\"http://jindolf.sourceforge.jp/xml/ns/501\" avatarId=\"joachim\" >\n" +
                "<li>青年 ヨアヒム は、宿を去った。</li>\n" +
                "</checkout>\n"
            )
            let checkout = JSON(try ArchiveToJSON.CheckoutElementConverter(parser: parser).convert(element))
            XCTAssertEqual(checkout[K.TYPE].string, K.VAL_CHECKOUT)
            XCTAssertEqual(checkout[K.AVATAR_ID].string, "joachim")
            let line = checkout[K.LINES][0].string
            XCTAssertEqual(line, "青年 ヨアヒム は、宿を去った。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertShortMember() {
        do {
            let (parser, element) = try setupTargetElement(
                "<shortMember xmlns=\"http://jindolf.sourceforge.jp/xml/ns/501\">\n" +
                "<li>まだ村人達は揃っていないようだ。</li>\n" +
                "<li/>\n" +
                "</shortMember>\n"
            )
            let shortMember = JSON(try ArchiveToJSON.ShortMemberElementConverter(parser: parser).convert(element))
            XCTAssertEqual(shortMember[K.TYPE].string, K.VAL_SHORT_MEMBER)
            let line = shortMember[K.LINES][0].string
            XCTAssertEqual(line, "まだ村人達は揃っていないようだ。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertAskEntry() {
        do {
            let (parser, element) = try setupTargetElement(
                "<askEntry xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\" commitTime=\"10:00:00+09:00\" minMembers=\"11\" maxMembers=\"16\">\n" +
                "<li>演じたいキャラクターを選び、発言してください。</li>\n" +
                "<li>午前 10時 0分 に11名以上がエントリーしていれば進行します。</li>\n" +
                "<li>最大16名まで参加可能です。</li>\n" +
                "<li />\n" +
                "<li>※エントリーは取り消せません。ルールをよく理解した上でご参加下さい。</li>\n" +
                "<li>※始めての方は、村人希望での参加となります。</li>\n" +
                "<li>※希望能力についての発言は控えてください。</li>\n" +
                "<li/>\n" +
                "</askEntry>\n"
            )
            let askEntry = JSON(try ArchiveToJSON.AskEntryElementConverter(parser: parser).convert(element))
            XCTAssertEqual(askEntry[K.TYPE].string, K.VAL_ASK_ENTRY)
            XCTAssertEqual(askEntry[K.COMMIT_TIME].string, "10:00:00+09:00")
            XCTAssertEqual(askEntry[K.MIN_MEMBERS].int, 11)
            XCTAssertEqual(askEntry[K.MAX_MEMBERS].int, 16)
            let line = askEntry[K.LINES][0].string
            XCTAssertEqual(line, "演じたいキャラクターを選び、発言してください。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertAskCommit() {
        do {
            let (parser, element) = try setupTargetElement(
                "<askCommit xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\" limitVote=\"23:00:00+09:00\" limitSpecial=\"23:00:00+09:00\">\n" +
                "<li>午後 11時 0分 までに、誰を処刑するべきかの投票先を決定して下さい。</li>\n" +
                "<li>一番票を集めた人物が処刑されます。同数だった場合はランダムで決定されます。</li>\n" +
                "<li/>\n" +
                "<li>特殊な能力を持つ人は、午後 11時 0分 までに行動を確定して下さい。</li>\n" +
                "<li/>\n" +
                "</askCommit>\n"
            )
            let askCommit = JSON(try ArchiveToJSON.AskCommitElementConverter(parser: parser).convert(element))
            XCTAssertEqual(askCommit[K.TYPE].string, K.VAL_ASK_COMMIT)
            XCTAssertEqual(askCommit[K.LIMIT_VOTE].string, "23:00:00+09:00")
            XCTAssertEqual(askCommit[K.LIMIT_SPECIAL].string, "23:00:00+09:00")
            let line = askCommit[K.LINES][0].string
            XCTAssertEqual(line, "午後 11時 0分 までに、誰を処刑するべきかの投票先を決定して下さい。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertNoComment() {
        do {
            let (parser, element) = try setupTargetElement(
                "<noComment xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\">\n" +
                "<li>本日まだ発言していない者は、羊飼い カタリナ、以上 1 名。</li>\n" +
                "<avatarRef avatarId=\"katharina\" />\n" +
                "</noComment>\n"
            )
            let noComment = JSON(try ArchiveToJSON.NoCommentElementConverter(parser: parser).convert(element))
            XCTAssertEqual(noComment[K.TYPE].string, K.VAL_NO_COMMENT)
            XCTAssertEqual(noComment[K.AVATAR_ID][0].string, "katharina")
            let line = noComment[K.LINES][0].string
            XCTAssertEqual(line, "本日まだ発言していない者は、羊飼い カタリナ、以上 1 名。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertStayEpilogue() {
        do {
            let (parser, element) = try setupTargetElement(
                "<stayEpilogue xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\" winner=\"village\" limitTime=\"02:00:00+09:00\">\n" +
                "<li>村人側の勝利です！</li>\n" +
                "<li>全てのログとユーザー名を公開します。午前 2時 0分 まで自由に書き込めますので、今回の感想などをどうぞ。</li>\n" +
                "<li/>\n" +
                "</stayEpilogue>\n"
            )
            let stayEpilogue = JSON(try ArchiveToJSON.StayEpilogueElementConverter(parser: parser).convert(element))
            XCTAssertEqual(stayEpilogue[K.TYPE].string, K.VAL_STAY_EPILOGUE)
            XCTAssertEqual(stayEpilogue[K.WINNER].string, "village")
            XCTAssertEqual(stayEpilogue[K.LIMIT_TIME].string, "02:00:00+09:00")
            let line = stayEpilogue[K.LINES][0].string
            XCTAssertEqual(line, "村人側の勝利です！")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertGameOver() {
        do {
            let (parser, element) = try setupTargetElement(
                "<gameOver xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\">\n" +
                "<li>終了しました</li>\n" +
                "<li/>\n" +
                "</gameOver>\n"
            )
            let gameOver = JSON(try ArchiveToJSON.GameOverElementConverter(parser: parser).convert(element))
            XCTAssertEqual(gameOver[K.TYPE].string, K.VAL_GAME_OVER)
            let line = gameOver[K.LINES][0].string
            XCTAssertEqual(line, "終了しました")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertJudge() {
        do {
            let (parser, element) = try setupTargetElement(
                "<judge xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\" byWhom=\"albin\" target=\"liesa\" >\n" +
                "<li>行商人 アルビン は、少女 リーザ を占った。</li>\n" +
                "</judge>\n"
            )
            let judge = JSON(try ArchiveToJSON.JudgeElementConverter(parser: parser).convert(element))
            XCTAssertEqual(judge[K.TYPE].string, K.VAL_JUDGE)
            XCTAssertEqual(judge[K.BY_WHOM].string, "albin")
            XCTAssertEqual(judge[K.TARGET].string, "liesa")
            let line = judge[K.LINES][0].string
            XCTAssertEqual(line, "行商人 アルビン は、少女 リーザ を占った。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertGuard() {
        do {
            let (parser, element) = try setupTargetElement(
                "<guard xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\" byWhom=\"jacob\" target=\"peter\" >\n" +
                "<li>農夫 ヤコブ は、少年 ペーター を守っている。</li>\n" +
                "</guard>\n"
            )
            let guardObject = JSON(try ArchiveToJSON.GuardElementConverter(parser: parser).convert(element))
            XCTAssertEqual(guardObject[K.TYPE].string, K.VAL_GUARD)
            XCTAssertEqual(guardObject[K.BY_WHOM].string, "jacob")
            XCTAssertEqual(guardObject[K.TARGET].string, "peter")
            let line = guardObject[K.LINES][0].string
            XCTAssertEqual(line, "農夫 ヤコブ は、少年 ペーター を守っている。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testConvertCounting2() {
        do {
            let (parser, element) = try setupTargetElement(
                "<counting2 xmlns=\"http://jindolf.sourceforge.jp/xml/ns/501\">\n" +
                "<li>負傷兵 シモン は 青年 ヨアヒム に投票した。</li>\n" +
                "<li>村娘 パメラ は 青年 ヨアヒム に投票した。</li>\n" +
                "<li>少女 リーザ は 青年 ヨアヒム に投票した。</li>\n" +
                "<li>少年 ペーター は 青年 ヨアヒム に投票した。</li>\n" +
                "<li>ならず者 ディーター は 青年 ヨアヒム に投票した。</li>\n" +
                "<li>青年 ヨアヒム は 青年 ヨアヒム に投票した。</li>\n" +
                "<li>パン屋 オットー は 青年 ヨアヒム に投票した。</li>\n" +
                "<li>旅人 ニコラス は 青年 ヨアヒム に投票した。</li>\n" +
                "<li>神父 ジムゾン は 青年 ヨアヒム に投票した。</li>\n" +
                "<li>村長 ヴァルター は 青年 ヨアヒム に投票した。</li>\n" +
                "<li>行商人 アルビン は 青年 ヨアヒム に投票した。</li>\n" +
                "<li>農夫 ヤコブ は 青年 ヨアヒム に投票した。</li>\n" +
                "<vote byWhom=\"simon\" target=\"joachim\" />\n" +
                "<vote byWhom=\"pamela\" target=\"joachim\" />\n" +
                "<vote byWhom=\"liesa\" target=\"joachim\" />\n" +
                "<vote byWhom=\"peter\" target=\"joachim\" />\n" +
                "<vote byWhom=\"dieter\" target=\"joachim\" />\n" +
                "<vote byWhom=\"joachim\" target=\"joachim\" />\n" +
                "<vote byWhom=\"otto\" target=\"joachim\" />\n" +
                "<vote byWhom=\"nicolas\" target=\"joachim\" />\n" +
                "<vote byWhom=\"simson\" target=\"joachim\" />\n" +
                "<vote byWhom=\"walter\" target=\"joachim\" />\n" +
                "<vote byWhom=\"albin\" target=\"joachim\" />\n" +
                "<vote byWhom=\"jacob\" target=\"joachim\" />\n" +
                "</counting2>\n"
            )
            let counting2 = JSON(try ArchiveToJSON.Counting2ElementConverter(parser: parser).convert(element))
            XCTAssertEqual(counting2[K.TYPE].string, K.VAL_COUNTING2)
            XCTAssertEqual(counting2[K.VOTES]["simon"].string, "joachim")
            let line = counting2[K.LINES][0].string
            XCTAssertEqual(line, "負傷兵 シモン は 青年 ヨアヒム に投票した。")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }

    func testConvertAssault() {
        do {
            let (parser, element) = try setupTargetElement(
                "<assault xmlns=\"http://jindolf.sourceforge.jp/xml/ns/401\"\n" +
                "  byWhom=\"walter\" target=\"simon\"\n" +
                "  xname=\"mes1268151301\" time=\"01:15:00+09:00\"\n" +
                " >\n" +
                "<li>負傷兵 シモン ！ 今日がお前の命日だ！</li>\n" +
                "</assault>\n"
            )
            let assault = JSON(try ArchiveToJSON.AssaultElementConverter(parser: parser).convert(element))
            XCTAssertEqual(assault[K.TYPE].string, K.VAL_ASSAULT)
            XCTAssertEqual(assault[K.BY_WHOM].string, "walter")
            XCTAssertEqual(assault[K.TARGET].string, "simon")
            XCTAssertEqual(assault[K.XNAME].string, "mes1268151301")
            XCTAssertEqual(assault[K.TIME].string, "01:15:00+09:00")
            let line = assault[K.LINES][0].string
            XCTAssertEqual(line, "負傷兵 シモン ！ 今日がお前の命日だ！")
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
}
