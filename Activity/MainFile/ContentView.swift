//
//  ContentView.swift
//  Activity
//
//  Created by 柳和川的mac on 2025/10/14.
//


import SwiftUI
import SwiftData
import EventKit
import ActivityKit
import StoreKit

final class DynamicIslandImageOnly {
    
    static let shared = DynamicIslandImageOnly()
    private init() { }
    
    @AppStorage("image_system_name_key")
    var imageSystemName: String = "hourglass"
    
}

struct BezierCurve {
    static let customDuration: Double = 0.5
    static let customEase: Animation = Animation.timingCurve(1, 0.5, 0.3, 1, duration: customDuration)
    static let customCurve: (p1x: Double, p1y: Double, p2x: Double, p2y: Double) = (1, 0.5, 0.3, 1)
}

struct ContentView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.requestReview) private var requestReview
    @Environment(ActivityViewModel.self) var activityViewModel
    
    @State private var rotateAngle: Double = 0.0
    
    @State private var title = ""
    @AppStorage("storaged_title") var storagedTitle: String = "Hi"
    @State private var time: Date = .now - 1
    @AppStorage("storaged_time") var storagedTime: Date = .now - 1
    @AppStorage("successful_live_activity_count") private var successfulLiveActivityCount = 0
    
    @FocusState private var isFocused: Bool
    
    @AppStorage("image_system_name_key") private var imageSystemName: String = "hourglass"
    @State private var isShowingImageDetailSection: Bool = false
    @Namespace private var namespace
    
    @State private var isShowingNavigationDestination: Bool = false
    
    let customEase: Animation = BezierCurve.customEase
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                AngularGradientSection
                
                TextFieldSection
                
                VStack {
                    Spacer()
                    
                    DatePickerSection
                        .opacity(isFocused ? 0 : 1)
                        .allowsHitTesting(!isFocused)
                        .accessibilityHidden(isFocused)
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    if !activityViewModel.isActivity {
                        SelectImageSection
                    }
                    
                    Spacer()
                    
                    DynamicCapsuleSection
                    
                    Spacer()
                    Spacer()
                }
                .animation(customEase, value: isFocused)
                
            }
            .contentShape(Rectangle())
            .onLongPressGesture {
                if !activityViewModel.isShowSettingView {
                    isShowingNavigationDestination = true
                }
            }
            .toolbar {
                if activityViewModel.isShowSettingView {
                    ToolbarItem(placement: .automatic) {
                        NavigationLink {
                            SettingView()
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $isShowingNavigationDestination) {
                SettingView()
            }
        }
        .task {
            await NotificationManager.shared.requestAuthorization()
        }
        .onChange(of: scenePhase) { _, newValue in
            guard newValue == .active else { return }
            
            if let activity = Activity<IslandAttributes>.activities.first {
                if !activityViewModel.isActivity {
                    HapticManager.shared.customHaptic(intensityStartValue: 0.25, intensityEndValue: 1, sharpStartValue: 0.21, sharpEndValue: 0.85, duration: BezierCurve.customDuration)
                }
                LiveActivityManager.shared.currentActivity = activity
                withAnimation(customEase) {
                    activityViewModel.isActivity = true
                }
            }
        }
        .onAppear {
            activityViewModel.timeFromContentView = storagedTime
            activityViewModel.bodyFromContentView = storagedTitle
        }
        .onChange(of: time) { _, newValue in
            storagedTime = newValue
            activityViewModel.timeFromContentView = storagedTime
        }
        .onChange(of: title) { _, newValue in
            storagedTitle = newValue
            activityViewModel.bodyFromContentView = storagedTitle
        }
        .onChange(of: imageSystemName, initial: true) { _, newValue in
            DynamicIslandImageOnly.shared.imageSystemName = newValue
        }
    }
}

#Preview {
    var viewModel = ActivityViewModel()
    ContentView()
        .environment(viewModel)
}




extension ContentView {
    
    
    private var AngularGradientSection: some View {
        AngularGradient(
            colors: [
                activityViewModel.isActivity ? activityViewModel.color3 : activityViewModel.color1,
                activityViewModel.isActivity ? activityViewModel.color4 : activityViewModel.color2,
            ],
            center: .center,
            startAngle: .degrees(rotateAngle),
            endAngle: .degrees(180 + rotateAngle)
        )
        .opacity(0.8)
        .ignoresSafeArea()
        .onChange(of: activityViewModel.isActivity) { oldValue, newValue in
            withAnimation(customEase) {
                rotateAngle += 180.0
            }
        }
    }
    
    
    @ViewBuilder
    private var TextFieldSection: some View {
        if !activityViewModel.isActivity {
            if #available(iOS 26.0, *) {
                TextField("Hello!", text: $title)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        isFocused = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .glassEffect(.regular, in: .capsule)
                    .padding()
                    .offset(y: activityViewModel.isShowSettingView ? -16 : 8)
            } else {
                TextField("Hello!", text: $title)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        isFocused = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial, in: .capsule)
                    .padding()
                    .offset(y: activityViewModel.isShowSettingView ? -16 : 8)
            }
        }
    }
    
    
    @ViewBuilder
    private var DatePickerSection: some View {
        if !activityViewModel.isActivity {
            DatePicker(selection: $time, displayedComponents: [.hourAndMinute]) {
                
            }
            .datePickerStyle(.wheel)
            .frame(width: 300)
        }
    }
    
    
    @ViewBuilder
    private var DynamicCapsuleSection: some View {
        if #available(iOS 26.0, *) {
            Capsule()
                .frame(width: activityViewModel.isActivity ? 200 : 70, height: 70)
                .glassEffect(.clear.interactive().tint(activityViewModel.isActivity ? activityViewModel.color6 : activityViewModel.color5))
                .offset(x: 0, y: activityViewModel.isActivity ? -200 : 0)
                .animation(customEase, value: activityViewModel.isActivity)
                .onTapGesture {
                    if title != "" || LiveActivityManager.shared.currentActivity != nil {
                        HapticManager.shared.customHaptic(intensityStartValue: 0.25, intensityEndValue: 1, sharpStartValue: 0.21, sharpEndValue: 0.85, duration: BezierCurve.customDuration)
                    }
                    
                    isFocused = false
                    
                    withAnimation(customEase) {
                        if LiveActivityManager.shared.currentActivity != nil {
                            activityViewModel.isActivity = false
                            
                            LiveActivityManager.shared.endActivity()
                            
                            if activityViewModel.hasNotification {
                                NotificationManager.shared.cancelAll()
                            }
                        } else {
                            if title != "" {
                                activityViewModel.isActivity = true
                                if time.timeIntervalSince(.now) > 0 {
                                    startLiveActivity()
                                    
                                    if activityViewModel.hasNotification {
                                        Task {
                                            await NotificationManager.shared.scheduleNotificationWithMultiTimeIntervals(body: title, time: time, timeIntervals: activityViewModel.notificationTimeIntervals)
                                        }
                                    }
                                } else {
                                    startLiveActivity()
                                }
                            }
                        }
                    }
                }
        } else {
            Capsule()
                .frame(width: activityViewModel.isActivity ? 200 : 70, height: 70)
                .background(.ultraThinMaterial, in: .capsule)
                .offset(x: 0, y: activityViewModel.isActivity ? -200 : 0)
                .animation(customEase, value: activityViewModel.isActivity)
                .onTapGesture {
                    if title != "" || LiveActivityManager.shared.currentActivity != nil {
                        HapticManager.shared.customHaptic(intensityStartValue: 0.25, intensityEndValue: 1, sharpStartValue: 0.21, sharpEndValue: 0.85, duration: BezierCurve.customDuration)
                    }
                    
                    isFocused = false
                    
                    withAnimation(customEase) {
                        if LiveActivityManager.shared.currentActivity != nil {
                            activityViewModel.isActivity = false
                            
                            LiveActivityManager.shared.endActivity()
                            
                            if activityViewModel.hasNotification {
                                NotificationManager.shared.cancelAll()
                            }
                        } else {
                            if title != "" {
                                activityViewModel.isActivity = true
                                if time.timeIntervalSince(.now) > 0 {
                                    startLiveActivity()
                                    
                                    if activityViewModel.hasNotification {
                                        Task {
                                            await NotificationManager.shared.scheduleNotificationWithMultiTimeIntervals(body: title, time: time, timeIntervals: activityViewModel.notificationTimeIntervals)
                                        }
                                    }
                                } else {
                                    startLiveActivity()
                                }
                            }
                        }
                    }
                }
        }
    }

    private func startLiveActivity() {
        guard LiveActivityManager.shared.startActivity(
            imageSystemName: imageSystemName,
            content: title,
            time: time
        ) else { return }

        successfulLiveActivityCount += 1
        guard [10, 30, 50, 100].contains(successfulLiveActivityCount) else { return }

        Task {
            try? await Task.sleep(for: .seconds(2))
            requestReview()
        }
    }
    
    
    
    @ViewBuilder
    private var SelectImageSection: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer {
                Image(systemName: imageSystemName)
                    .resizable()
                    .scaledToFit()
                    .symbolEffect(.bounce, value: imageSystemName)
                    .frame(width: 30, height: 30)
                    .padding()
                    .onTapGesture {
                        withAnimation(.smooth) {
                            isShowingImageDetailSection.toggle()
                        }
                    }
                    .overlay(alignment: .bottom) {
                        if isShowingImageDetailSection {
                            SelectImageSystemNameSection
                                .padding(40)
                                .glassEffect()
                                .offset(y: -50)
                        }
                    }
            }
        } else {
            Image(systemName: imageSystemName)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .padding()
                .onTapGesture {
                    withAnimation(.smooth) {
                        isShowingImageDetailSection.toggle()
                    }
                }
                .overlay(alignment: .bottom) {
                    if isShowingImageDetailSection {
                        SelectImageSystemNameSection
                            .padding(40)
                            .background(.ultraThinMaterial, in: .containerRelative)
                            .offset(y: -50)
                    }
                }
        }
    }
    
    
    private var SelectImageSystemNameSection: some View {
        let imageSystemNames: [String] = [
            "hourglass", "person", "star",
            "heart", "bolt", "flame", "moon",
            "sun.max","cloud", "umbrella", "hare",
            "tortoise", "leaf", "snowflake","sparkle",
            "ring", "airplane.up.right", "checkmark"
        ]
        let gridItems: [GridItem] = [
            GridItem(.fixed(30), spacing: 30, alignment: .center),
            GridItem(.fixed(30), spacing: 30, alignment: .center),
            GridItem(.fixed(30), spacing: 30, alignment: .center),
        ]
        return LazyVGrid(columns: gridItems, spacing: 10) {
            ForEach(imageSystemNames, id: \.self) { name in
                if name == imageSystemName {
                    Image(systemName: name)
                        .resizable()
                        .foregroundStyle(.accent)
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding(10)
//                        .background(.accent.opacity(0.5), in: .circle)
                        .onTapGesture {
                            withAnimation(.smooth) {
                                imageSystemName = name
                                isShowingImageDetailSection = false
                            }
                        }
                } else {
                    Image(systemName: name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding(10)
                        .onTapGesture {
                            withAnimation(.smooth) {
                                imageSystemName = name
                                isShowingImageDetailSection = false
                            }
                        }
                }
            }
        }
    }
    
    
    
}
