import OAuth
import FluentProvider

extension OAuthCode: Model {
    
    struct Properties {
        static let codeString = "code_string"
        static let clientID = "client_id"
        static let redirectURI = "redirect_uri"
        static let userID = "user_id"
        static let expiryDate = "expiry_date"
        static let scopes = "scopes"
    }
    
    public var storage: Storage {
        get {
            if let storage = extend["fluent-storage"] as? Storage {
                return storage
            }
            else {
                let storage = Storage()
                extend["fluent-storage"] = storage
                return storage
            }
        }
    }
    
    public convenience init(row: Row) throws {
        let codeString: String = try row.get(Properties.codeString)
        let clientID: String = try row.get(Properties.clientID)
        let redirectURI: String = try row.get(Properties.redirectURI)
        let userID: Identifier = try row.get(Properties.userID)
        let expiryDate: Date = try row.get(Properties.expiryDate)
        let scopesString: String? = try? row.get(Properties.scopes)
        let scopes = scopesString?.components(separatedBy: " ")
        
        self.init(codeID: codeString, clientID: clientID, redirectURI: redirectURI, userID: userID, expiryDate: expiryDate, scopes: scopes)
    }
    
    public func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.codeString, codeID)
        try row.set(Properties.clientID, clientID)
        try row.set(Properties.redirectURI, redirectURI)
        try row.set(Properties.userID, userID)
        try row.set(Properties.expiryDate, expiryDate)
        try row.set(Properties.scopes, scopes?.joined(separator: " "))
        return row
    }
}

extension OAuthCode: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Properties.codeString)
            builder.string(Properties.clientID)
            builder.string(Properties.redirectURI)
            builder.string(Properties.userID)
            builder.date(Properties.expiryDate)
            builder.string(Properties.scopes, optional: true)
        }
        
        try database.index(Properties.codeString, for: OAuthCode.self)
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
