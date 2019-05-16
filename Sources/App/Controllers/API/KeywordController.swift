import Vapor
import FluentPostgreSQL

final class KeywordController {

    // MARK: - Utilities Functions

    func getKeywordForId(_ id: Int, conn: DatabaseConnectable) -> Future<Keyword> {
        return Keyword.find(id, on: conn).unwrap(or: RoasterHammerError.keywordIsMissing.error())
    }

    func getKeywordsForIds(_ ids: [Int], conn: DatabaseConnectable) -> Future<[Keyword]> {
        return ids.map { self.getKeywordForId($0, conn: conn) }.flatten(on: conn)
    }

    func getKeywordWithName(_ name: String, conn: DatabaseConnectable) -> Future<Keyword> {
        return Keyword.query(on: conn).filter(\.name == name).first()
            .flatMap(to: Keyword.self, { keyword in
                if let keyword = keyword {
                    return conn.future(keyword)
                } else {
                    return Keyword(name: name).save(on: conn)
                }
            })
    }

    func getKeywordsWithNames(_ names: [String], conn: DatabaseConnectable) -> Future<[Keyword]> {
        return names.map { self.getKeywordWithName($0, conn: conn) }.flatten(on: conn)
    }

}
