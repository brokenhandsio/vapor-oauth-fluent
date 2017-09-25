import XCTest
import VaporOAuthFluent
import VaporOAuth
import Vapor
import Sessions
import FluentProvider
import Cookies

class OAuthFluentTests: XCTestCase {
    // MARK: - All Tests
    
    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testThatAuthCodeFlowWorksAsExpectedWithFluentModels", testThatAuthCodeFlowWorksAsExpectedWithFluentModels),
        ("testThatPasswordCredentialsWorksAsExpectedWithFluentModel", testThatPasswordCredentialsWorksAsExpectedWithFluentModel),
        ]
    
    
    // MARK: - Properties
    
    var drop: Droplet!
    let capturingAuthHandler = CapturingAuthHandler()
    let scope = "email"
    let redirectURI = "https://api.brokenhands.io/callback"
    let clientID = "ABCDEFG"
    let passwordClientID = "1234567890"
    let clientSecret = "1234"
    let email = "han@therebelalliance.com"
    let username = "han"
    let password = "leia"
    var user: OAuthUser!
    var oauthClient: OAuthClient!
    var passwordClient: OAuthClient!
    
    // MARK: - Overrides
    
    override func setUp() {
        let provider = VaporOAuth.Provider(codeManager: FluentCodeManager(), tokenManager: FluentTokenManager(), clientRetriever: FluentClientRetriever(), authorizeHandler: capturingAuthHandler, userManager: FluentUserManager(), validScopes: [scope])
        
        var config = Config([:])
        
        try! config.set("fluent.driver", "memory")
        
        try! config.addProvider(provider)
        try! config.addProvider(FluentProvider.Provider.self)
        
        config.addConfigurable(middleware: SessionsMiddleware.init, name: "sessions")
        try! config.set("droplet.middleware", ["error", "sessions"])
        try! config.set("droplet.commands", ["prepare"])
        
        config.preparations.append(OAuthClient.self)
        config.preparations.append(OAuthUser.self)
        config.preparations.append(OAuthCode.self)
        config.preparations.append(AccessToken.self)
        config.preparations.append(RefreshToken.self)
        
        drop = try! Droplet(config)
        
        let resourceController = TestResourceController(drop: drop)
        resourceController.addRoutes()
        
        let passwordHash = try! OAuthUser.passwordHasher.make(password)
        user = OAuthUser(username: username, emailAddress: email, password: passwordHash)
        try! user.save()
        
        oauthClient = OAuthClient(clientID: clientID, redirectURIs: [redirectURI], clientSecret: clientSecret, validScopes: [scope], confidential: true, firstParty: true, allowedGrantType: .authorization)
        try! oauthClient.save()
        
        passwordClient = OAuthClient(clientID: passwordClientID, redirectURIs: [redirectURI], clientSecret: clientSecret, validScopes: [scope], confidential: true, firstParty: true, allowedGrantType: .password)
        try! passwordClient.save()
    }
    
    override func tearDown() {
        try! drop.database?.revertAll([OAuthClient.self, OAuthUser.self, OAuthCode.self, AccessToken.self, RefreshToken.self])
    }
    
    // MARK: - Tests
    
    // Courtesy of https://oleb.net/blog/2017/03/keeping-xctest-in-sync/
    func testLinuxTestSuiteIncludesAllTests() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            let thisClass = type(of: self)
            let linuxCount = thisClass.allTests.count
            let darwinCount = Int(thisClass.defaultTestSuite.testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }
    
    func testThatAuthCodeFlowWorksAsExpectedWithFluentModels() throws {        
        // Get Auth Code
        let state = "jfeiojo382497329"
        
        var queries: [String] = []
        queries.append("response_type=code")
        queries.append("client_id=\(clientID)")
        queries.append("redirect_uri=\(redirectURI)")
        queries.append("scope=\(scope)")
        queries.append("state=\(state)")
        
        let requestQuery = queries.joined(separator: "&")
        
        let authRequest = Request(method: .get, uri: "/oauth/authorize?\(requestQuery)")
        let response = try drop.respond(to: authRequest)
        
        guard let rawCookie = response.headers[.setCookie] else {
            XCTFail()
            return
        }
        
        let sessionCookie = try Cookie(bytes: rawCookie.bytes)
        
        XCTAssertEqual(capturingAuthHandler.responseType, "code")
        XCTAssertEqual(capturingAuthHandler.clientID, clientID)
        XCTAssertEqual(capturingAuthHandler.redirectURI?.description, URIParser.shared.parse(bytes: redirectURI.makeBytes()).description)
        XCTAssertEqual(capturingAuthHandler.scope?.count, 1)
        XCTAssertTrue(capturingAuthHandler.scope?.contains(scope) ?? false)
        XCTAssertEqual(capturingAuthHandler.state, state)
        XCTAssertEqual(response.status, .ok)
        
        var codeQueries: [String] = []
        
        codeQueries.append("client_id=\(clientID)")
        codeQueries.append("redirect_uri=\(redirectURI)")
        codeQueries.append("state=\(state)")
        codeQueries.append("scope=\(scope)")
        codeQueries.append("response_type=code")
        
        let codeQuery = codeQueries.joined(separator: "&")
        
        let authRequestResponse = Request(method: .post, uri: "/oauth/authorize?\(codeQuery)")
        
        var data = Node([:], in: nil)
        try data.set("applicationAuthorized", true)
        try data.set("csrfToken", capturingAuthHandler.csrfToken)
        authRequestResponse.cookies.insert(sessionCookie)
        authRequestResponse.formURLEncoded = data
        
        let authAuthenticatedKey = "auth-authenticated"
        authRequestResponse.storage[authAuthenticatedKey] = user
        
        let codeResponse = try drop.respond(to: authRequestResponse)
        
        guard let newLocation = codeResponse.headers[.location] else {
            XCTFail()
            return
        }
        
        let codeRedirectURI = URIParser.shared.parse(bytes: newLocation.makeBytes())
        
        guard let query = codeRedirectURI.query else {
            XCTFail()
            return
        }
        
        let queryParts = query.components(separatedBy: "&")
        
        var codePart: String?
        
        for queryPart in queryParts {
            if queryPart.hasPrefix("code=") {
                let codeStartIndex = queryPart.index(queryPart.startIndex, offsetBy: 5)
                codePart = String(queryPart[codeStartIndex...])
            }
        }
        
        guard let codeFound = codePart else {
            XCTFail()
            return
        }
        
        // Get Token
        
        let tokenRequest = Request(method: .post, uri: "/oauth/token/")
        
        var tokenRequestData = Node([:], in: nil)
        try tokenRequestData.set("grant_type", "authorization_code")
        try tokenRequestData.set("client_id", clientID)
        try tokenRequestData.set("client_secret", clientSecret)
        try tokenRequestData.set("redirect_uri", redirectURI)
        try tokenRequestData.set("code", codeFound)
        try tokenRequestData.set("scope", scope)

        tokenRequest.formURLEncoded = tokenRequestData
        
        let tokenResponse = try drop.respond(to: tokenRequest)
        
        print("Token response was \(tokenResponse)")
        
        guard let token = tokenResponse.json?["access_token"]?.string else {
            XCTFail()
            return
        }
        
        guard let refreshToken = tokenResponse.json?["refresh_token"]?.string else {
            XCTFail()
            return
        }
        
        // Get resource
        let protectedRequest = Request(method: .get, uri: "/protected/")
        protectedRequest.headers[.authorization] = "Bearer \(token)"
        
        let protectedResponse = try drop.respond(to: protectedRequest)
        
        XCTAssertEqual(protectedResponse.status, .ok)
        
        // Get new token
        let refreshTokenRequest = Request(method: .post, uri: "/oauth/token/")
        
        var rereshTokenRequestData = Node([:], in: nil)
        try rereshTokenRequestData.set("grant_type", "refresh_token")
        try rereshTokenRequestData.set("client_id", clientID)
        try rereshTokenRequestData.set("client_secret", clientSecret)
        try rereshTokenRequestData.set("scope", scope)
        try rereshTokenRequestData.set("refresh_token", refreshToken)
        
        refreshTokenRequest.formURLEncoded = rereshTokenRequestData
        
        let tokenRefreshResponse = try drop.respond(to: refreshTokenRequest)
        
        XCTAssertEqual(tokenRefreshResponse.status, .ok)
        
        guard let newAccessToken = tokenRefreshResponse.json?["access_token"]?.string else {
            XCTFail()
            return
        }

        // Check user returned
        let userRequest = Request(method: .get, uri: "/user")
        userRequest.headers[.authorization] = "Bearer \(newAccessToken)"
        
        let userResponse = try drop.respond(to: userRequest)
        
        XCTAssertEqual(userResponse.status, .ok)
        
        XCTAssertEqual(userResponse.json?["userID"]?.string, user.id?.string)
        XCTAssertEqual(userResponse.json?["username"]?.string, username)
        XCTAssertEqual(userResponse.json?["email"]?.string, email)
    }
    
    func testThatPasswordCredentialsWorksAsExpectedWithFluentModel() throws {
        let tokenRequest = Request(method: .post, uri: "/oauth/token/")
        
        var tokenRequestData = Node([:], in: nil)
        try tokenRequestData.set("grant_type", "password")
        try tokenRequestData.set("client_id", passwordClientID)
        try tokenRequestData.set("client_secret", clientSecret)
        try tokenRequestData.set("scope", scope)
        try tokenRequestData.set("username", username)
        try tokenRequestData.set("password", password)
        
        tokenRequest.formURLEncoded = tokenRequestData
        
        let tokenResponse = try drop.respond(to: tokenRequest)
        
        print("Token response was \(tokenResponse)")
        
        guard let token = tokenResponse.json?["access_token"]?.string else {
            XCTFail()
            return
        }
        
        // Get resource
        let protectedRequest = Request(method: .get, uri: "/protected/")
        protectedRequest.headers[.authorization] = "Bearer \(token)"
        
        let protectedResponse = try drop.respond(to: protectedRequest)
        
        XCTAssertEqual(protectedResponse.status, .ok)
        
        // Check user returned
        let userRequest = Request(method: .get, uri: "/user")
        userRequest.headers[.authorization] = "Bearer \(token)"
        
        let userResponse = try drop.respond(to: userRequest)
        
        XCTAssertEqual(userResponse.status, .ok)
        
        XCTAssertEqual(userResponse.json?["userID"]?.string, user.id?.string)
        XCTAssertEqual(userResponse.json?["username"]?.string, username)
        XCTAssertEqual(userResponse.json?["email"]?.string, email)
    }

}

class CapturingAuthHandler: AuthorizeHandler {

    func handleAuthorizationError(_ errorType: AuthorizationError) throws -> ResponseRepresentable {
        return "ERROR"
    }
    
    private(set) var request: Request?
    private(set) var responseType: String?
    private(set) var clientID: String?
    private(set) var redirectURI: URI?
    private(set) var scope: [String]?
    private(set) var state: String?
    private(set) var csrfToken: String?
    func handleAuthorizationRequest(_ request: Request, authorizationRequestObject: AuthorizationRequestObject) throws -> ResponseRepresentable {
        self.request = request
        self.responseType = authorizationRequestObject.responseType
        self.clientID = authorizationRequestObject.clientID
        self.redirectURI = authorizationRequestObject.redirectURI
        self.scope = authorizationRequestObject.scope
        self.state = authorizationRequestObject.state
        self.csrfToken = authorizationRequestObject.csrfToken
        return "ALLOW"
    }
}

struct TestResourceController {
    let drop: Droplet
    
    func addRoutes() {
        
        let oauthMiddleware = OAuth2ScopeMiddleware(requiredScopes: ["email"])
        let protected = drop.grouped(oauthMiddleware)
        
        protected.get("protected", handler: protectedHandler)
        protected.get("user", handler: getOAuthUser)
    }
    
    func protectedHandler(request: Request) throws -> ResponseRepresentable {
        return "PROTECTED"
    }
    
    func getOAuthUser(request: Request) throws -> ResponseRepresentable {
        let user: OAuthUser = try request.oauth.user()
        var json = JSON()
        try json.set("userID", user.id?.string)
        try json.set("email", user.emailAddress)
        try json.set("username", user.username)
        
        return json
    }
}
