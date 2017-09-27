import VaporOAuth
import FluentProvider

extension OAuthResourceServer: Model {

    struct Properties {
        static let username =  "username"
        static let password = "password"
    }

    public var storage: Storage {
        if let storage = extend["fluent-storage"] as? Storage {
            return storage
        } else {
            let storage = Storage()
            extend["fluent-storage"] = storage
            return storage
        }
    }

    public convenience init(row: Row) throws {
        let username: String = try row.get(Properties.username)
        let passwordAsString: String = try row.get(Properties.password)
        self.init(username: username, password: passwordAsString.makeBytes())
    }

    public func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.username, username)
        try row.set(Properties.password, password.makeString())
        return row
    }
}

extension OAuthResourceServer: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Properties.username)
            builder.string(Properties.password)
        }

        try database.index(Properties.username, for: OAuthResourceServer.self)
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
