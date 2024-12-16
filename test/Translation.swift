//
//  Translation.swift
//  test
//
//  Created by liming on 27/11/2024.
//

import Foundation
class Translation{
    func translateText(text: String, sourceLang: String, targetLang: String, completion: @escaping (String?) -> Void) {
        let baseURL = "https://655.mtis.workers.dev/translate"
        guard var urlComponents = URLComponents(string: baseURL) else {
            completion(nil)
            return
        }
        
        // 设置查询参数
        urlComponents.queryItems = [
            URLQueryItem(name: "text", value: text),
            URLQueryItem(name: "source_lang", value: sourceLang),
            URLQueryItem(name: "target_lang", value: targetLang)
        ]
        
        guard let url = urlComponents.url else {
            completion(nil)
            return
        }
        
        // 创建 GET 请求
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Request error: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                // 解析 JSON
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let response = json["response"] as? [String: Any],
                   let translatedText = response["translated_text"] as? String {
                    completion(translatedText)
                } else {
                    completion(nil)
                }
            } catch {
                print("JSON parsing error: \(error)")
                completion(nil)
            }
        }
        
        task.resume()
    }

}
