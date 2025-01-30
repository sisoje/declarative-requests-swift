import Foundation

func createMultipartBody(parameters: [String: String], fileData: Data, boundary: String, fileName: String, mimeType: String) -> Data {
    var body = Data()
    
    // Add text parameters
    for (key, value) in parameters {
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(value)\r\n".data(using: .utf8)!)
    }
    
    // Add file data
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
    body.append(fileData)
    body.append("\r\n".data(using: .utf8)!)
    
    // Closing boundary
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)
    
    return body
}
