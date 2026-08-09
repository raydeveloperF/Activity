//
//  WidgetForActivityLiveActivity.swift
//  WidgetForActivity
//
//  Created by 柳和川的mac on 2025/10/14.
//

import ActivityKit
import WidgetKit
import SwiftUI

//struct WidgetForActivityAttributes: ActivityAttributes {
//    public struct ContentState: Codable, Hashable {
//        // Dynamic stateful properties about your activity go here!
//        var emoji: String
//    }
//
//    // Fixed non-changing properties about your activity go here!
//    var name: String
//}

struct WidgetForActivityLiveActivity: Widget {
    
    
    let emojis: [String] = [
        "😀", "😃", "😅", "😘", "🥰", "🤯", "😎", "🤣",
        "🥺", "🤪", "🥵", "😏", "🫨", "😨", "🥳", "😭",
    ]
    
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: IslandAttributes.self) { context in
            VStack(alignment: .leading) {
                HStack {
                    HourglassSection(context: context)
                    Spacer()
                    Text(context.state.content)
                        .font(.largeTitle)
                        .bold()
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .opacity(0.9)
                    Spacer()
                    clockView(for: context.state.time)
                }
            }
            .padding(.leading, 10)
            .padding(.trailing, 2)
            .padding()
            .activityBackgroundTint(.clear)
            .activitySystemActionForegroundColor(Color.orange)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HourglassSection(context: context)
                        .frame(maxHeight: .infinity, alignment: .center)
                        .padding(.leading, 18)
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.content)
                        .font(.title)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .bold()
                        .foregroundStyle(.primary)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    clockView(for: context.state.time)
                        .frame(maxHeight: .infinity, alignment: .center)
                        .padding(.trailing, 8)
                }
            } compactLeading: {
                HourglassSection(context: context)
            } compactTrailing: {
                if let time = context.state.time {
                    Text(time.formatted(.dateTime.hour().minute()))
                }
            } minimal: {
                HourglassSection(context: context)
            }
//            .widgetURL(URL(string: "http://www.apple.com"))
//            .keylineTint(.red)
        }

    }
    
    @ViewBuilder
    private func TimeSection(context: ActivityViewContext<IslandAttributes>) -> some View {
        if let time = context.state.time {
            Text(time.formatted(.dateTime.hour().minute()))
                .bold()
        } else {
            Text("无时间")
        }
    }
    
    private func HourglassSection(context: ActivityViewContext<IslandAttributes>) -> some View {
        Image(systemName: context.state.imageSystemName)
            .resizable()
            .scaledToFit()
            .frame(width: 24)
            .foregroundStyle(.orange)
    }
    
    @ViewBuilder
    private func clockView(for date: Date?) -> some View {
        if let date {
            let components = Calendar.current.dateComponents([.hour, .minute], from: date)
            let hour = Double(components.hour ?? 0)
            let minute = Double(components.minute ?? 0)
            
            let hourAngle = Angle.degrees((hour.truncatingRemainder(dividingBy: 12)) / 12 * 360 + (minute / 60) * 30)
//            let minuteAngle = Angle.degrees(minute / 60 * 360)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 2, height: 14)
                    .opacity(0.9)
                    .offset(y: -7)
                    .rotationEffect(hourAngle)
                
//                Rectangle()
//                    .fill(Color.primary)
//                    .frame(width: 1.5, height: 12)
//                    .offset(y: -6)
//                    .rotationEffect(minuteAngle)
                
                Circle()
                    .fill(Color.primary)
                    .frame(width: 2)
                    .opacity(0.9)
            }
            .frame(width: 42, height: 42)
        } else {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                .frame(width: 42, height: 42)
        }
    }
    
    
    
}

extension IslandAttributes {
    fileprivate static var preview: IslandAttributes {
        IslandAttributes()
    }
}

extension IslandAttributes.ContentState {
    fileprivate static var smiley: IslandAttributes.ContentState {
        IslandAttributes.ContentState(imageSystemName: "hourglass", content: "😀", time: .now)
     }
     
     fileprivate static var starEyes: IslandAttributes.ContentState {
         IslandAttributes.ContentState(imageSystemName: "hourglass", content: "🤩", time: .now)
     }
}


#Preview("Expanded", as: .content, using: IslandAttributes.preview) {
    WidgetForActivityLiveActivity()
} contentStates: {
    IslandAttributes.ContentState(imageSystemName: "hourglass", content: "dancing in the shadow", time: .now)
}

//#Preview("Compact", as: .dynamicIsland(.compact), using: IslandAttributes.preview) {
//    WidgetForActivityLiveActivity()
//} contentStates: {
//    IslandAttributes.ContentState(title: "测试", time: .now)
//}
//
//#Preview("Expanded", as: .dynamicIsland(.expanded), using: IslandAttributes.preview) {
//    WidgetForActivityLiveActivity()
//} contentStates: {
//    IslandAttributes.ContentState(title: "测试", time: .now)
//}




