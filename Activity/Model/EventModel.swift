//
//  EventModel.swift
//  Activity
//
//  Created by 柳和川的mac on 2025/10/16.
//

import SwiftData
import EventKit

@Model
class EventModel {
    
    var calendar: String?
    var title: String?
    var location: String?
    
    var startDate: Date
    var endDate: Date
    
    var notes: String?
    var status: String
    
    
    init(
        calendar: String? = nil,
        title: String? = nil,
        location: String? = nil,
        startDate: Date,
        endDate: Date,
        notes: String? = nil,
        status: String
    ) {
        self.calendar = calendar
        self.title = title
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
        self.status = status
    }
}



extension EKEventStatus {
    var displayString: String {
        switch self {
        case .none:
            return "未设置状态"
        case .confirmed:
            return "已确认"
        case .tentative:
            return "暂定"
        case .canceled:
            return "已取消"
        @unknown default:
            return "未知状态"
        }
    }
}



// MARK: - 原生event -> EventModel
extension EKEvent {
    
    func ToEventModel() throws -> EventModel {
        
        guard let startDate = self.startDate,
              let endDate = self.endDate else {
            debugLog("原生event转model event 出错")
            throw URLError(.unknown)
        }
        
        let calendar = self.calendar.title
        let title = self.title
        let location = self.location
        
        let notes = self.notes
        let status = self.status.displayString
        
        let event = EventModel(
            calendar: calendar,
            title: title,
            location: location,
            startDate: startDate,
            endDate: endDate,
            notes: notes,
            status: status
        )
        
        return event
    }
}

// MARK: - [原生event] -> [EventModel]
extension Array where Element == EKEvent {
    
    func ToEventModelArray() -> [EventModel] {
        var returnedEvents: [EventModel] = []
        do {
            for originalEvent in self {
                try returnedEvents.append(originalEvent.ToEventModel())
            }
        } catch {
            debugLog("[原生event] -> [EventModel] 出错")
        }
        
        return returnedEvents
    }
    
}

