//
//  ActivityViewModel.swift
//  Activity
//
//  Created by 柳和川的mac on 2025/10/27.
//

import Foundation
import SwiftUI

@Observable class ActivityViewModel {
    
    var timeFromContentView: Date = .now
    var bodyFromContentView: String = "Hi!"
    
    var isActivity: Bool = false
    
    let color1: Color = Color(red: 142 / 255, green: 218 / 255, blue: 226 / 255, opacity: 0.85)
    let color2: Color = Color(red: 218 / 255, green: 226 / 255, blue: 142 / 255, opacity: 0.85)
    let color3: Color = Color(red: 63 / 255, green: 51 / 255, blue: 81 / 255, opacity: 1)
    let color4: Color = Color(red: 140 / 255, green: 74 / 255, blue: 47 / 255, opacity: 1)
    let color5: Color = Color(red: 240 / 255, green: 209 / 255, blue: 102 / 255, opacity: 0.6)
    let color6: Color = Color(red: 209 / 255, green: 178 / 255, blue: 63 / 255, opacity: 1)
    
    init() {
        if UserDefaults.standard.object(forKey: ActivityViewModel.isShowSettingViewKey) == nil {
            UserDefaults.standard.set(true, forKey: ActivityViewModel.isShowSettingViewKey)
        }
        
        if UserDefaults.standard.object(forKey: ActivityViewModel.hasNotificationKey) == nil {
            UserDefaults.standard.set(true, forKey: ActivityViewModel.hasNotificationKey)
        }
        
        getIsShowSettingView()
        getHasNotification()
        getNotificationTimeIntervals()
    }
    
    var isShowSettingView: Bool = true {
        didSet {
            saveIsShowSettingView()
        }
    }
    
    
    
    var hasNotification: Bool = true {
        didSet {
            saveHasNotification()
            if hasNotification == false {
                NotificationManager.shared.cancelAll()
            }
        }
    }
    
    var notificationTimeIntervals: [TimeInterval] = [
        15 * 60
    ] {
        didSet {
            saveNotificationTimeIntervals()
        }
    }
}



extension ActivityViewModel {
    
    // MARK: 持久化 isShowSettingView
    static let isShowSettingViewKey: String = "is_show_setting_view_key"
    private func saveIsShowSettingView() {
        UserDefaults.standard.set(isShowSettingView, forKey: ActivityViewModel.isShowSettingViewKey)
    }
    private func getIsShowSettingView() {
        isShowSettingView = UserDefaults.standard.bool(forKey: ActivityViewModel.isShowSettingViewKey)
    }
    
    
    
    // MARK: 持久化 hasNotification
    static let hasNotificationKey: String = "has_notification_key"
    private func saveHasNotification() {
        UserDefaults.standard.set(hasNotification, forKey: ActivityViewModel.hasNotificationKey)
    }
    private func getHasNotification() {
        hasNotification = UserDefaults.standard.bool(forKey: ActivityViewModel.hasNotificationKey)
    }
    
    
    // MARK: 持久化 notificationTimeIntervals
    static let notificationTimeIntervalsKey: String = "notification_time_interval_key"
    private func saveNotificationTimeIntervals() {
        UserDefaults.standard.set(notificationTimeIntervals, forKey: ActivityViewModel.notificationTimeIntervalsKey)
        debugLog("Saved TimeInterval")
    }
    private func getNotificationTimeIntervals() {
        if let returnedValue = UserDefaults.standard.value(forKey: ActivityViewModel.notificationTimeIntervalsKey) as? [TimeInterval] {
            notificationTimeIntervals = returnedValue
        }
    }
    func sortNotificationTimeIntervals() {
        Task { [weak self] in
            guard let self else { return }
            await MainActor.run {
                self.notificationTimeIntervals.sort { $0 < $1 }
            }
        }
    }
    func refreshNotification() async {
        NotificationManager.shared.cancelAll()
        await NotificationManager.shared.scheduleNotificationWithMultiTimeIntervals(body: bodyFromContentView, time: timeFromContentView, timeIntervals: notificationTimeIntervals)
    }
    
}

