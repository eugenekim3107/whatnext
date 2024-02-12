//
//  ChatService.swift
//  whatnext
//
//  Created by Eugene Kim on 2/10/24.
//

import Foundation

struct ChatResponse: Decodable {
    var user_id: String
    var session_id: String
    var content: String
    var chat_type: String
}

class ChatService {
    static let shared = ChatService()

    private init() {}

    func postMessage(latitude: Double,
                     longitude: Double,
                     userId: String,
                     sessionId: String?,
                     message: String,
                     completion: @escaping (ChatResponse?, Error?) -> Void) {
        
        guard let url = URL(string: "https://whatnext.live/api/chatgpt_response") else { return }
        
        var requestBody: [String: Any] = [
            "user_id": userId,
            "message": message,
            "latitude": latitude,
            "longitude": longitude
        ]
        
        if let sessionId = sessionId {
            requestBody["session_id"] = sessionId
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("whatnext", forHTTPHeaderField: "whatnext_token")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data is nil"]))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse, nil)
                }
            } catch let jsonError {
                DispatchQueue.main.async {
                    completion(nil, jsonError)
                }
            }
        }.resume()
    }
}
