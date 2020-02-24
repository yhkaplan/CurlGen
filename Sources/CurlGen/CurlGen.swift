import Foundation

extension URLRequest {

    private var base: String { "curl -v " }
    
    private typealias Parameter = (flag: String, value: String?)
    
    /// TODO: document
    public var cURL: String { // TODO: turn into func accepting isVerbose bool
        guard let urlString = url?.absoluteString else { return "" }
        
        let base = "curl -v " + urlString
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
