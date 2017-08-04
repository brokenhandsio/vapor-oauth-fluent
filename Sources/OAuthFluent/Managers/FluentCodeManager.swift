import FluentProvider
import OAuth
import Crypto

public struct FluentCodeManager: CodeManager {

    public init() {}

    public func generateCode(userID: Identifier, clientID: String, redirectURI: String, scopes: [String]?) throws -> String {
        let codeString = try Random.bytes(count: 32).hexString
        let fluentCode = OAuthCode(codeID: codeString, clientID: clientID, redirectURI: redirectURI, userID: userID, expiryDate: Date().addingTimeInterval(60), scopes: scopes)
        try fluentCode.save()
        return codeString
    }

    public func getCode(_ code: String) -> OAuthCode? {
        do {
            return try OAuthCode.makeQuery().filter(OAuthCode.Properties.codeString, code).first()
        } catch {
            return nil
        }
    }

    public func codeUsed(_ code: OAuthCode) {
        try? code.delete()
    }
}
