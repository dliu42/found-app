//
//  NetworkManager.swift
//  networking
//
//  Created by Justin Ngai on 3/29/22.
//
import Alamofire
import Foundation

class NetworkManager {
    
    /** To receive full marks on this assignment, you must do ALL of the following
     1) Setup CocoaPods to install and import Alamofire to actually do this assignment.
     2) Fill out the function stubs provided below - leave them untouched unless otherwise instructed.
     a) Note that all completions are of type `Any` - you should change these to the correct types (and any necessary keywords..)
     3) For each function stub, make sure you go to `Post.swift` to add Codable structs as necessary
     4) After filling in a function stub, go to `ViewController.swift` and add the completion in the marked area for that function and verify that your implementation works
     a) Steps are provided to help guide you in what to do inside your completion
     b) Print statements are provided to help you debug and to hint towards which variables you will need to use the implement the completion body
     5) Don't modify any other code in this project without good reason.
     a) This includes the MARK and explanatory comments, leave them to make your graders' lives easier.
     */
    
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
