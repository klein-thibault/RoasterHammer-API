@testable import App
import Vapor
import FluentPostgreSQL
import RoasterHammer_Shared

final class RuleTestsUtils {
    static func createRule(conn: DatabaseConnectable) throws -> (request: AddRuleRequest, response: Rule) {
        let request = AddRuleRequest(name: "Rule", description: "Description")
        let rule = try RuleController().createRule(request: request, conn: conn).wait()

        return (request, rule)
    }
}
