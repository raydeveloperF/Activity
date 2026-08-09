//
//  IslandAttributes.swift
//  Activity
//
//  Created by 柳和川的mac on 2025/10/14.
//


import Foundation
import ActivityKit

public struct IslandAttributes: ActivityAttributes {
    
    public struct ContentState: Codable, Hashable {
        public var imageSystemName: String
        public var content: String
        public var time: Date?
//        public init(title: String, time: Date?) {
//            self.title = title
//            self.time = time
//        }
    }
    
    public init() {}
}


