//
//  UserDefaultKey.swift
//  Activity
//
//  Created by 柳和川的mac on 2025/11/19.
//

import Foundation

actor UserDefaultKey {
    static let groupID = "group.com.Ray.Activity"

    static let ShareDataKey: String = "share_data_key"
    
    static func saveToShareDataKey(value: Any) {
        UserDefaults.standard.set(value, forKey: UserDefaultKey.ShareDataKey)
    }
    static func getFromShareDataKey() -> Any? {
        UserDefaults.standard.object(forKey: UserDefaultKey.ShareDataKey)
    }
    
}
