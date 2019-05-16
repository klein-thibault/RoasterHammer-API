@testable import App
import XCTest
import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

class KeywordControllerTests: BaseTests {

    func testGetKeywordWithName() throws {
        let keyword = "KHORNE"
        let keywordController = KeywordController()
        var allKeywords = try keywordController.getAllKeywords(conn: conn).wait()

        XCTAssertTrue(allKeywords.count == 0)

        _ = try keywordController.getKeywordWithName(keyword, conn: conn).wait()
        allKeywords = try keywordController.getAllKeywords(conn: conn).wait()

        XCTAssertTrue(allKeywords.count == 1)
    }

}
