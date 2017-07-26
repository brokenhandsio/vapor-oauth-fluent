#if os(Linux)

import XCTest
@testable import OAuthFluentTests

XCTMain([
    testCase(OAuthFluentTests.allTests),
])

#endif
