@testable import App
import XCTest
import Vapor
import FluentPostgreSQL

class BaseTests: XCTestCase {

    var app: Application!
    var conn: PostgreSQLConnection!

    override func setUp() {
        super.setUp()

        try! Application.reset()
        app = try! Application.start()
        conn = try! app.newConnection(to: .psql).wait()
    }

    override func tearDown() {
        conn.close()
        // Prevent an exception of too many clients with PostgreSQL
        try! app.syncShutdownGracefully()

        super.tearDown()
    }

}
