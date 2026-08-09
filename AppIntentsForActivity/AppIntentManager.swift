////
////  AppIntentManager.swift
////  Activity
////
////  Created by 柳和川的mac on 2025/10/19.
////
//
//import AppIntents
//import ActivityKit
//
//
//
//struct CreateIslandActivityIntent: AppIntent {
//    static var title: LocalizedStringResource = "创建灵动岛活动"
//    static var description = IntentDescription("把文本内容显示到灵动岛上。")
//    
//    @Parameter(title: "文本内容")
//    var title: String
//    
//    @Parameter(title: "时间（可选）")
//    var time: Date?
//    
//    static var parameterSummary: some ParameterSummary {
//        Summary("在灵动岛上显示 \(\.$title)")
//    }
//    
//    @MainActor
//    func perform() async throws -> some IntentResult {
//        LiveActivityManager.shared.startActivity(imageSystemName: "hourglass", title: title, time: time)
//        
//        return .result()
//    }
//}
//
//struct CreateIslandActivityTimeMustIntent: AppIntent {
//    static var title: LocalizedStringResource = "创建灵动岛活动(必选时间）"
//    static var description = IntentDescription("把文本内容显示到灵动岛上，可以选择时间。")
//    
//    @Parameter(title: "文本内容")
//    var title: String
//    
//    @Parameter(title: "时间")
//    var time: Date
//
//    static var parameterSummary: some ParameterSummary {
//        Summary("在灵动岛上显示 \(\.$title)，时间是 \(\.$time)")
//    }
//    
//    @MainActor
//    func perform() async throws -> some IntentResult {
//        LiveActivityManager.shared.startActivity(imageSystemName: "hourglass", title: title, time: time)
//        
//        return .result()
//    }
//}
