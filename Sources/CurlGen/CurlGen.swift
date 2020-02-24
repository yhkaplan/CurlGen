import Foundation

extension URLRequest {

    private typealias Parameter = (flag: String, value: String?)

    /// Generates a cURL command based on the URLRequest instance that can be copy and pasted
    /// right into the command line and executed as is.
    /// - Warning: This is meant for debugging purposes and not to be used in production in any way
    /// - Parameter isVerbose: Whether to use the `-v` flag
    /// - Returns: A cURL command generated from the URLRequest
    public func cURLCommand(isVerbose: Bool = true) -> String {
        guard let urlString = url?.absoluteString else { return "" }

        let verbosityFlag = isVerbose ? " -v" : ""
        let base = "curl" + verbosityFlag + " " + urlString
        let headerParameters = makeHeaderParameters()
        let bodyParameter = makeBodyParameter()
        let methodParameter = (flag: "-X", value: httpMethod)

        var rawParameters = [methodParameter, bodyParameter]
        rawParameters.append(contentsOf: headerParameters)

        let joinedParameters = joinParameters(rawParameters)

        return joinedParameters.isEmpty
            ? base
            : base + " " + joinedParameters
    }
}

// MARK: - Helper Methods

extension URLRequest {

    private func makeHeaderParameters() -> [Parameter] {
        let sortedHeaders = allHTTPHeaderFields? // Sorting headers for consistency with tests
            .sorted(by: { $0.key < $1.key })
            ?? []
        return sortedHeaders.map { (flag: "--header", value: Optional("\"\($0.key)=\($0.value)\"")) }
    }

    private func makeBodyParameter() -> Parameter {
        guard let data = httpBody else { return ("", nil) }

        let contentType = value(forHTTPHeaderField: "Content-Type")

        var body: String?
        switch contentType {
        case "application/x-www-form-urlencoded", "application/json":
            body = String(data: data, encoding: .utf8)

        case "multipart/form-data":
            body = "<multipart-body>"

        default:
            body = "<unknown body>"
        }

        return ("--data", body)
    }

    private func joinParameters(_ parameters: [Parameter]) -> String {
        return parameters
            .compactMap { parameter in
                guard let value = parameter.value else { return nil }
                return parameter.flag + " " + value
            }
            .joined(separator: " \\\n")
    }
}
