//
//  LiveActivityManager.swift
//  Activity
//
//  Created by 柳和川的mac on 2025/10/14.
//


import Foundation
import ActivityKit

// MARK: - Attributes 定义
//struct IslandAttributes: ActivityAttributes {
//    public struct ContentState: Codable, Hashable {
//        var displayText: String
//    }
//    // 外层属性：这里可以添加固定信息（如 id），本例空即可
//    init() {}
//}

// MARK: - Manager
@MainActor
@Observable
final class LiveActivityManager {
    static let shared = LiveActivityManager()
    private init() {
        
    }

    var currentActivity: Activity<IslandAttributes>?
    

    func startActivity(imageSystemName: String, content: String, time: Date?) {
        
        var returnedTime: Date? = nil
        if let time {
            if time > .now {
                returnedTime = time
            }
        }
        
        let attributes = IslandAttributes()
        let state = IslandAttributes.ContentState(imageSystemName: imageSystemName, content: content, time: returnedTime)
        let content = ActivityContent(state: state, staleDate: nil)

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            currentActivity = activity
            debugLog("✅ Live Activity 创建成功：\(activity.id)")
        } catch {
            debugLog("❌ 创建失败：\(error)")
        }
    }


    func endActivity() {
        guard let activity = currentActivity else { return }
        let finalState = IslandAttributes.ContentState(imageSystemName: "hourglass", content: "End", time: nil)
        let content = ActivityContent(state: finalState, staleDate: nil)
        Task {
            await activity.end(content, dismissalPolicy: .immediate)
            currentActivity = nil
            debugLog("🟢 Live Activity 已结束")
        }
    }
}
