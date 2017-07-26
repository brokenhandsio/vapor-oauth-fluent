import OAuth
import FluentProvider

public final class FluentOAuthCode: OAuthCode, Model {
    
    struct Properties {
        static let codeString = "code_string"
        static let clientID = "client_id"
        static let redirectURI = "redirect_uri"
        static let userID = "user_id"
        static let expiryDate = "expiry_date"
        static let scopes = "scopes"
    }
    
    public let storage = Storage()
    
    public init(row: Row) throws {
        let codeString: String = try row.get(Properties.codeString)
        let clientID: String = try row.get(Properties.clientID)
        let redirectURI: String = try row.get(Properties.redirectURI)
        let userID: String = try row.get(Properties.userID)
        let expiryDate: Date = try row.get(Properties.expiryDate)
        let scopesString: String? = try? row.get(Properties.scopes)
        let scopes = scopesString?.components(separatedBy: " ")
        
        super.init(codeID: codeString, clientID: clientID, redirectURI: redirectURI, userID: userID, expiryDate: expiryDate, scopes: scopes)
    }
    
    override public init(codeID: String, clientID: String, redirectURI: String, userID: String, expiryDate: Date, scopes: [String]?) {
        super.init(codeID: codeID, clientID: clientID, redirectURI: redirectURI, userID: userID, expiryDate: expiryDate, scopes: scopes)
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

extension FluentOAuthCode: Preparation {
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
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
