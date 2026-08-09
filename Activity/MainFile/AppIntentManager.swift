//
//  NewFile.swift
//  Activity
//
//  Created by 柳和川的mac on 2025/11/4.
//


import AppIntents
import ActivityKit



struct CreateIslandActivityIntent: AppIntent, LiveActivityIntent {
    static var title: LocalizedStringResource = "创建灵动岛活动"
    static var description = IntentDescription("把文本内容显示到灵动岛上，不能选择时间。")
    
    let imageSystemName = DynamicIslandImageOnly.shared.imageSystemName
    
    @Parameter(title: "文本内容")
    var content: String
    
    @Parameter(title: "时间（可选）")
    var time: Date?
    
    static var parameterSummary: some ParameterSummary {
        Summary("在灵动岛上显示 \(\.$content)")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        LiveActivityManager.shared.startActivity(imageSystemName: imageSystemName, content: content, time: time)
        
        return .result()
    }
}


struct CreateIslandActivityTimeMustIntent: AppIntent, LiveActivityIntent {
    static var title: LocalizedStringResource = "创建实时活动(必选时间）"
    static var description = IntentDescription("把文本内容显示到灵动岛上，可以选择时间。")
    
    let imageSystemName = DynamicIslandImageOnly.shared.imageSystemName
    
    @Parameter(title: "Content", description: "你将在实时活动中显示的文字", requestValueDialog: "内容是什么")
    var content: String
    
    @Parameter(title: "Time", description: "时间", requestValueDialog: "啥时候")
    var time: Date
    
    static var parameterSummary: some ParameterSummary {
        Summary("在灵动岛上显示 \(\.$content)，时间是\(\.$time)")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        LiveActivityManager.shared.startActivity(imageSystemName: imageSystemName, content: content, time: time)
        
        guard let timeIntervals = UserDefaults.standard.object(forKey: ActivityViewModel.notificationTimeIntervalsKey) as? [TimeInterval]
        else { return .result() }
        
        await NotificationManager.shared.scheduleNotificationWithMultiTimeIntervals(body: content, time: time, timeIntervals: timeIntervals)
        
        return .result()
    }
}


struct AppShortcuts: AppShortcutsProvider {
    
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: CreateIslandActivityTimeMustIntent(),
                phrases: [
                    "创建\(.applicationName)"
                ],
                shortTitle: "创建实时活动(必选时间）",
                systemImageName: "hourglass",
            ),
            
            AppShortcut(
                intent: CreateIslandActivityIntent(),
                phrases: [
                    "创建\(.applicationName)，no time"
                ],
                shortTitle: "创建实时活动（无时间）",
                systemImageName: "bell.badge.waveform.slash.fill"
            )
        ]
    }
}


//struct CreateIslandActivityEntity: IndexedEntity {
//    var id: UUID
//    static var defaultQuery: CreateIslandActivityQuery = CreateIslandActivityQuery()
//    
//    @Property(
//        indexingKey: \.displayName
//    )
//    var content: String
//    
//    @Property(
//        indexingKey: \.displayName
//    )
//    var time: Date
//    
//    static let typeDisplayRepresentation: TypeDisplayRepresentation = TypeDisplayRepresentation(name: "上岛！")
//    
//    var displayRepresentation: DisplayRepresentation {
//        DisplayRepresentation(
//            title: "Display",
//            subtitle: "Subtitle--",
//            image: DisplayRepresentation.Image(systemName: "gear")
//        )
//    }
//}

//struct CreateIslandActivityQuery: EntityQuery {
//    
//    typealias Entity = CreateIslandActivityEntity
//    
//    func entities(for identifiers: [UUID]) async throws -> [CreateIslandActivityEntity] {
//        var returnedValue: [CreateIslandActivityEntity] = []
//        for _ in identifiers {
//            let value = CreateIslandActivityEntity(id: UUID())
//            returnedValue.append(value)
//        }
//        return returnedValue
//    }
//}

