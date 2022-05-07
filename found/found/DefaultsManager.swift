//
//  DefaultsManager.swift
//  found
//
//  Created by Ellen Li on 5/1/22.
//

import Foundation

struct DefaultsManager {
    enum Field: String {
        case username = "username"
        case password = "password"
    }
    
    static private let standard = UserDefaults.standard
    
    static private func save(value: Any?, key: Field) {
        standard.set(value, forKey: key.rawValue)
    }
    
    static private func load(key: Field) -> Any? {
        standard.value(forKey: key.rawValue)
    }
    
    static var username: String? {
        get { load(key: .username) as? String }
        set { save(value: newValue, key: .username) }
    }
    
    static var password: String? {
        get { load(key: .password) as? String }
        set { save(value: newValue, key: .password) }
    }
    
    static var needsLogin: Bool {
        guard let _ = username, let _ = password else { return true }
        return false
    }
}

