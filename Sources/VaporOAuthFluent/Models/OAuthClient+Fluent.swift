import VaporOAuth
import FluentProvider

extension OAuthClient: Model {

    struct Properties {
        static let clientID = "client_id"
        static let clientSecret = "client_secret"
        static let redirectURIs = "redirect_uris"
        static let scopes = "scopes"
        static let confidentialClient = "confidential_client"
        static let firstParty = "first_party"
        static let allowedGrantType = "allowed_grant_type"
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
        let clientID: String = try row.get(Properties.clientID)
        let clientSecret: String? = try? row.get(Properties.clientSecret)
        let redirectURIsString: String? = try? row.get(Properties.redirectURIs)
        let scopeString: String? = try row.get(Properties.scopes)
        let confidentalClient: Bool? = try? row.get(Properties.confidentialClient)
        let firstParty: Bool = try row.get(Properties.firstParty)
        let allowedGrantTypeString: String = try row.get(Properties.allowedGrantType)
        let retrievedAllowedGrantType = OAuthFlowType(rawValue: allowedGrantTypeString)
        
        guard let allowedGrantType = retrievedAllowedGrantType else {
            throw Abort.serverError
        }

        let scopes: [String]?
        let redirectURIs: [String]?

        if let scopeStringSet = scopeString {
            scopes = scopeStringSet.components(separatedBy: " ")
        } else {
            scopes = nil
        }

        if let redirectURIsSet = redirectURIsString {
            redirectURIs = redirectURIsSet.components(separatedBy: " ")
        } else {
            redirectURIs = nil
        }

        self.init(clientID: clientID, redirectURIs: redirectURIs, clientSecret: clientSecret, validScopes: scopes,
                  confidential: confidentalClient, firstParty: firstParty, allowedGrantType: allowedGrantType)
    }

    public func makeRow() throws -> Row {
        var row = Row()

        try row.set(Properties.clientID, clientID)
        try row.set(Properties.clientSecret, clientSecret)
        try row.set(Properties.redirectURIs, redirectURIs?.joined(separator: " "))
        try row.set(Properties.scopes, validScopes?.joined(separator: " "))
        try row.set(Properties.confidentialClient, confidentialClient)
        try row.set(Properties.firstParty, firstParty)
        try row.set(Properties.allowedGrantType, allowedGrantType.rawValue)
        
        return row
    }
}

extension OAuthClient: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Properties.clientID)
            builder.string(Properties.redirectURIs, optional: true)
            builder.string(Properties.clientSecret, optional: true)
            builder.string(Properties.scopes, optional: true)
            builder.bool(Properties.confidentialClient, optional: true)
            builder.bool(Properties.firstParty)
            builder.string(Properties.allowedGrantType)
        }

        try database.index(Properties.clientID, for: OAuthClient.self)
    }

    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
