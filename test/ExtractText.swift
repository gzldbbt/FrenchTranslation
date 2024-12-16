//
//  ExtractText.swift
//  test
//
//  Created by liming on 26/11/2024.
//
import Foundation
import UIKit

class ExtractText {
    
    // 定义一个闭包类型，用于回调结果
    typealias CompletionHandler = (Result<String, Error>) -> Void
    
    // 调用 OCR API 方法
    func callOCRSpace(imageData: Data, completion: @escaping CompletionHandler) {
        // URL 和请求设置
        guard let url = URL(string: "https://api.ocr.space/Parse/Image") else {
            completion(.failure(NSError(domain: "InvalidURL", code: 400, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = "randomString"
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // API 参数
        let parameters = [
            "apikey": "yK84591752588957",
            "isOverlayRequired": "True",
            "language": "fre"
        ]
        
        // 构建请求体
        let body = createBody(withBoundary: boundary, parameters: parameters, imageData: imageData, filename: "uploadedImage.jpeg")
        request.httpBody = body
        
        // 执行请求
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 404, userInfo: nil)))
                return
            }
            
            do {
                if let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let parsedResults = result["ParsedResults"] as? [[String: Any]],
                   let firstResult = parsedResults.first,
                   let extractedText = firstResult["ParsedText"] as? String {
                    completion(.success(extractedText))
                } else {
                    completion(.failure(NSError(domain: "ParsingError", code: 500, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // 构建 multipart/form-data 请求体的方法
    private func createBody(withBoundary boundary: String, parameters: [String: String], imageData: Data, filename: String) -> Data {
        var body = Data()
        
        // 添加图片数据
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // 添加文本参数
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // 添加结束边界
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}
