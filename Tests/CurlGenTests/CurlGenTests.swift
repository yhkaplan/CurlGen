import CurlGen // Intentionally not importing as @testable to test if everything is public
import XCTest

final class CurlGenTests: XCTestCase {

    let urlString = "https://www.github.com?key=value&other_key=other_value"
    lazy var url = URL(string: urlString)!
    lazy var baseCurlCommand = "curl -v \(urlString)"
    var sut: URLRequest!

    static var allTests = [
        ("test_justURL", test_justURL),
        ("test_withoutVerboseFlag", test_withoutVerboseFlag),
        ("test_eachHTTPMethod", test_eachHTTPMethod),
        ("test_httpHeader", test_httpHeader),
        ("test_httpHeaders", test_httpHeaders),
        ("test_httpBody", test_httpBody),
        ("test_complexRequest", test_complexRequest),
    ]

    override func setUp() {
        super.setUp()

        sut = URLRequest(url: url)
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    func test_justURL() {
        let cURLCommand = baseCurlCommand + " -X GET"
        XCTAssertEqual(sut.cURLCommand(), cURLCommand)
    }
    
    func test_withoutVerboseFlag() {
        let cURLCommand = "curl " + urlString + " -X GET"
        XCTAssertEqual(sut.cURLCommand(isVerbose: false), cURLCommand)
    }

    func test_eachHTTPMethod() {
        let httpMethods = ["GET", "POST", "PUT", "DELETE", "PATCH"]
        httpMethods.forEach { httpMethod in
            sut.httpMethod = httpMethod
            let cURLCommand = baseCurlCommand + " -X \(httpMethod)"

            XCTAssertEqual(sut.cURLCommand(), cURLCommand)
        }
    }

    func test_httpHeader() {
        let cURLCommand = "\(baseCurlCommand) -X GET \\\n--header \"Content-Type=application/json\""

        sut.addValue("application/json", forHTTPHeaderField: "Content-Type")

        XCTAssertEqual(sut.cURLCommand(), cURLCommand)
    }

    func test_httpHeaders() {
        let cURLCommand = """
        \(baseCurlCommand) -X GET \\
        --header \"Accept=image/jpeg\" \\
        --header \"Authentication=Bearer 1234\" \\
        --header \"Content-Type=application/json\"
        """

        sut.addValue("application/json", forHTTPHeaderField: "Content-Type")
        sut.addValue("Bearer 1234", forHTTPHeaderField: "Authentication")
        sut.addValue("image/jpeg", forHTTPHeaderField: "Accept")

        XCTAssertEqual(sut.cURLCommand(), cURLCommand)
    }

    func test_httpBody() {
        let dataString = "param1=zzz&param2=aaa"
        let cURLCommand = """
        \(baseCurlCommand) -X POST \\
        --data \(dataString) \\
        --header \"Content-Type=application/x-www-form-urlencoded\"
        """

        sut.httpBody = dataString.data(using: .utf8)
        sut.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        sut.httpMethod = "POST"

        XCTAssertEqual(sut.cURLCommand(), cURLCommand)
    }

    func test_complexRequest() {
        let dataString = "{\"data\": {\"key\": \"value\"}}"
        let cURLCommand = """
        \(baseCurlCommand) -X POST \\
        --data \(dataString) \\
        --header \"Accept=application/json\" \\
        --header \"Content-Type=application/json\"
        """

        sut.httpBody = dataString.data(using: .utf8)
        sut.addValue("application/json", forHTTPHeaderField: "Content-Type")
        sut.addValue("application/json", forHTTPHeaderField: "Accept")
        sut.httpMethod = "POST"

        XCTAssertEqual(sut.cURLCommand(), cURLCommand)
    }

}
