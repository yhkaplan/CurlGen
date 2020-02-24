import Foundation

public extension URLRequest {

    private var base: String { "curl -v " }

    var cURL: String { // TODO: turn into func accepting isVerbose bool
        guard let urlString = url?.absoluteString else { return "" }
        let base = "curl -v " + urlString

        let sortedHeaders = allHTTPHeaderFields?
            .map { (key: $0.key, value: $0.value) }
            .sorted(by: { $0.key < $1.key })
            ?? []
        let headerParameters = sortedHeaders
            .map { (flag: "--header", value: Optional("\"\($0.key)=\($0.value)\"")) }

        var rawParameters: [(flag: String, value: String?)] = [
            (flag: "-X", value: httpMethod),
        ]
        rawParameters.append(contentsOf: headerParameters)

        let formattedParameters = rawParameters
            .compactMap { parameter in
                guard let value = parameter.value else { return nil }
                return parameter.flag + " " + value
            }
            .joined(separator: " \\\n")

        var body = ""
        if let data = httpBody {
            let contentType = value(forHTTPHeaderField: "Content-Type")
            switch contentType {
            case "application/x-www-form-urlencoded", "application/json":
                guard let bodyString = String(data: data, encoding: .utf8) else { return "" } // TODO: throw error?
                body = " \\\n--data " + bodyString
                
            case "multipart/form-data":
                body = " \\\n--data <multipart-body>"
                
            default:
                body = " \\\n--data <unknown body>"
            }
        }
        
        return formattedParameters.isEmpty
            ? base
            : base + " " + formattedParameters + body
    }

}
