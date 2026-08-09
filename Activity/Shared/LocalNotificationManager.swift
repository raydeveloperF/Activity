//
//  LocalNotificationManager.swift
//  Activity
//
//  Created by 柳和川的mac on 2025/10/23.
//



import SwiftUI
import UserNotifications



@MainActor
struct NotificationManager {
    
    static let shared = NotificationManager()
    private init() { }
    
    /// 初始化时机建议在 App 启动时调用，例如在 App 的 `.onAppear` 或 `@main` 入口调用
    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                debugLog("✅ 通知权限已授权")
            } else {
                debugLog("⚠️ 用户拒绝了通知权限")
            }
        } catch {
            debugLog("❌ 通知权限请求失败: \(error.localizedDescription)")
        }
    }
    
    /// 一键触发所有的通知，在App里直接用这个
    func scheduleNotificationWithMultiTimeIntervals(body: String, time: Date, timeIntervals: [TimeInterval]) async {
        await scheduleNotification(systemName: "hourglass", body: body, time: time)
        for timeInterval in timeIntervals {
            let finalTime = time.addingTimeInterval(-timeInterval)
            await scheduleNotification(systemName: "hourglass", body: body, time: finalTime)
        }
    }
    
    private func scheduleNotification(systemName: String, body: String, time: Date) async {
        guard time > Date.now else { return }
        let center = UNUserNotificationCenter.current()
        
        let triggerDate = Calendar.current.dateComponents([.hour, .minute],
                                                          from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = body
        content.sound = .defaultCritical
        content.interruptionLevel = .timeSensitive
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        do {
            try await center.add(request)
            debugLog("📅 通知已安排: \(time.formatted(date: .omitted, time: .standard))")
        } catch {
            debugLog("❌ 添加通知失败: \(error.localizedDescription)")
        }
    }
    
    /// 取消所有已安排的通知
    func cancelAll() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        debugLog("🗑️ 已取消所有待触发的通知")
    }
    
    /// 打印所有待触发通知（调试用）
    func debugPrintAllPending() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            debugLog("📋 当前待触发通知数量: \(requests.count)")
            for r in requests {
                debugLog("🔸 \(r.identifier): \(r.content.title)")
            }
        }
    }
    
}
