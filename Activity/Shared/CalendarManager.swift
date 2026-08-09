//
//  CalendarManager.swift
//  Activity
//
//  Created by 柳和川的mac on 2025/10/16.
//

import EventKit

/// 管理系统日历事件（仅适用于 iOS 17+）
final class CalendarManager {
    static let shared = CalendarManager()
    
    private let eventStore = EKEventStore()
    
    private init() {}
    
    /// 请求完整的日历访问权限（读写）
    func requestAccess() async throws -> Bool {
        let granted = try await eventStore.requestFullAccessToEvents()
        if !granted {
            debugLog("❌ 用户未授权访问日历")
        }
        return granted
    }
    
    /// 获取指定时间范围内的事件
    func fetchEvents(endDate: Date) -> [EKEvent] {
        let today: Date = Calendar.current.startOfDay(for: .now)
        let predicate = eventStore.predicateForEvents(withStart: today, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)
        return events.sorted(by: { $0.startDate < $1.startDate })
    }
    
    /// 获取一年内的事件
    func fetchAYearEvents() throws -> [EKEvent] {
        let start = Calendar.current.startOfDay(for: Date())
        if let end = Calendar.current.date(byAdding: .year, value: 1, to: start) {
            return fetchEvents(endDate: end)
        }
        
        throw URLError(.unknown)
    }
}
