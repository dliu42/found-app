//
//  NetworkManager.swift
//  networking
//
//  Created by Justin Ngai on 3/29/22.
//
import Alamofire
import Foundation

class NetworkManager {
    
    /** Put the provided server endpoint here. If you don't know what this is, contact course staff. */
    static let host = "https://ios-course-message-board.herokuapp.com"

    static func getAllPosts(completion: @escaping ([Post]) -> Void) {
            let endpoint = "\(host)/posts/all/"
            AF.request(endpoint, method: .get).validate().responseData { response in
                switch response.result {
                case .success(let data):
                    let jsonDecoder = JSONDecoder()
                    if let userResponse = try? jsonDecoder.decode([Post].self, from: data) {
                        completion(userResponse)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }

        }
    
    static func getSpecificPost(id: String, completion: @escaping (Post) -> Void) {
        let endpoint = "\(host)/posts/\(id)/"
        AF.request(endpoint, method: .get).validate().responseData { response in
            switch response.result {
            case .success(let data):
                let jsonDecoder = JSONDecoder()
                if let userResponse = try? jsonDecoder.decode(Post.self, from: data) {
                    completion(userResponse)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    static func createPost(title: String, body: String, poster: String, completion: @escaping (Post) -> Void) {
        let endpoint = "\(host)/posts/"
        let params : [String:Any] = [
            "title": title,
            "body": body,
            "poster": poster
        ]
        AF.request(endpoint, method: .post, parameters: params).validate().responseData { response in
            switch response.result {
            case .success(let data):
                let jsonDecoder = JSONDecoder()
                if let userResponse = try? jsonDecoder.decode(Post.self, from: data) {
                    completion(userResponse)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    static func updatePost(id: String, body: String, poster: String, completion: @escaping (Post) -> Void) {
        let endpoint = "\(host)/posts/\(id)/"
        let params : [String:String] = [
//            "id": id,
            "body": body,
            "poster": poster,
        ]
        AF.request(endpoint, method: .put, parameters: params, encoder: JSONParameterEncoder.default).validate().responseData { response in
            switch response.result {
            case .success(let data):
                let jsonDecoder = JSONDecoder()
                if let userResponse = try? jsonDecoder.decode(Post.self, from: data) {
                    completion(userResponse)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    static func deletePost(id: String, poster: String, completion: @escaping (Post) -> Void) {
        let endpoint = "\(host)/posts/\(id)/"
        let params : [String: String] = [
//            "id": id,
            "poster": poster,
        ]
        AF.request(endpoint, method: .delete, parameters: params, encoder: JSONParameterEncoder.default).validate().responseData { response in
            switch response.result {
            case .success(let data):
                print(data)
                let jsonDecoder = JSONDecoder()
                if let userResponse = try? jsonDecoder.decode(Post.self, from: data) {
                    completion(userResponse)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // Extra Credit

    static func getPostersPosts(poster: String, completion: Any) {
        
    }
    
}
