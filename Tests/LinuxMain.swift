#if os(Linux)

import XCTest
@testable import VaporOAuthFluentTests

XCTMain([
    testCase(VaporOAuthFluentTests.allTests),
])

#endif
