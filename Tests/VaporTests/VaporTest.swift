import DeclarativeRequests
import Foundation
import Testing
import Vapor

struct VaporTests {
    let server = MockServer()

    @Test("Multipart upload correctly constructs request")
    func testMultipartUpload() async throws {
        let url = server.app.baseUrl

        let request = try url.buildRequest {
            Method.POST
            Endpoint("/upload")

            RequestBlock {
                Header.setCustom("Content-Type", "multipart/form-data; boundary=test")

                "--test\r\nContent-Disposition: form-data; name=\"test\"\r\n\r\ntest content\r\n--test--"
                    .data(using: .utf8)
            }

            RequestBlock {
                Cookie("Key", "Value")
                Cookie("Key2", "Value2")
            }
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        let (vaporRequest, _) = await server.interceptor.get(response)

        #expect((response as! HTTPURLResponse).statusCode == 200)
        #expect(String(decoding: data, as: UTF8.self) == "Success")

        #expect(vaporRequest.url.path == "/upload")
        #expect(vaporRequest.method == .POST)
        #expect(vaporRequest.headers.contentType?.type == "multipart")
        #expect(vaporRequest.headers.contentType?.subType == "form-data")
        #expect(vaporRequest.headers.contentType?.parameters["boundary"] == "test")
        #expect(vaporRequest.headers.cookie!["Key"]?.string == "Value")
        #expect(vaporRequest.headers.cookie!["Key2"]?.string == "Value2")

        struct TestForm: Content {
            let test: String
        }

        let form = try vaporRequest.content.decode(TestForm.self)
        #expect(form.test == "test content")
    }
}
