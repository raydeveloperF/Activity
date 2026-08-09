//
//  SettingView.swift
//  Activity
//
//  Created by 柳和川的mac on 2025/10/27.
//

import SwiftUI

struct SettingView: View {
    
    @Environment(ActivityViewModel.self) var activityViewModel
    @State private var isShowingAddNewNotificationTimeIntervalSheet: Bool = false
    @State private var newTimeInterval: Double = 15.0 * 60 {
        didSet {
            debugLog(newTimeInterval.description)
        }
    }
    
    var body: some View {
        
        @Bindable var activityViewModel = activityViewModel
        
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 40) {
                    VStack(alignment: .leading) {
                        Toggle(isOn: $activityViewModel.isShowSettingView) {
                            Text("在主页面展示设置入口")
                        }
                        .padding()
                        .background(.secondary.opacity(0.4), in: .capsule)
                        
                        Text("如果你关闭此功能，在主页将不再显示设置按钮，如果你想再次进入设置页面（也就是本页面），请长按主页的任意区域")
                            .font(.subheadline)
                            .foregroundStyle(.primary.opacity(0.6))
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Toggle(isOn: $activityViewModel.hasNotification) {
                                Text("开启通知")
                            }
                            .padding(.bottom, activityViewModel.hasNotification ? 12 : 0)
                            
                            if activityViewModel.hasNotification {
                                Group {
                                    ForEach(activityViewModel.notificationTimeIntervals, id: \.self) { timeInterval in
                                        VStack {
                                            HStack {
                                                let time = Int(timeInterval) / 60
                                                Text(time.formatted(.number))
                                                    .bold()
                                                Text("分钟")
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .contentShape(.containerRelative)
                                        .contextMenu {
                                            Button {
                                                Task {
                                                    withAnimation(.bouncy) {
                                                        delete(timeInterval: timeInterval)
                                                        activityViewModel.sortNotificationTimeIntervals()
                                                    }
                                                    await activityViewModel.refreshNotification()
                                                }
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                    
                                    AddNewNotificationTimeIntervalButton
                                }
                            }
                        }
                        .padding()
                        .background(.secondary.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 29))
                        .animation(.smooth, value: activityViewModel.hasNotification)
                        
                        Group {
                            Text("你可以添加任意多个提前提醒，这些时间代表App会在你设定的时间前多长时间给你发送通知。")
                            Text("你可以长按这些时间以删除。")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.primary.opacity(0.6))
                        .padding(.horizontal)
                        .animation(.smooth, value: activityViewModel.hasNotification)
                    }
                }
                .padding()
            }
            .navigationTitle("Setting")
            .sheet(isPresented: $isShowingAddNewNotificationTimeIntervalSheet) {
                AddNewNotificationTimeIntervalSheet
                    .presentationDetents([.medium])
            }
        }
    }
}



extension SettingView {
    
    private func delete(timeInterval: TimeInterval) {
        activityViewModel.notificationTimeIntervals.removeAll { $0 == timeInterval }
    }
    
    @ViewBuilder
    private var AddNewNotificationTimeIntervalButton: some View {
        if #available(iOS 26.0, *) {
            Button {
                isShowingAddNewNotificationTimeIntervalSheet = true
            } label: {
                Image(systemName: "plus.app")
                    .padding(5)
            }
            .buttonStyle(.glass)
        } else {
            Button {
                isShowingAddNewNotificationTimeIntervalSheet = true
            } label: {
                Image(systemName: "plus.app")
                    .padding(5)
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var AddNewNotificationTimeIntervalSheet: some View {
        VStack {
            Picker("Select", selection: $newTimeInterval) {
                ForEach(1...60, id: \.self) { index in
                    Text("\(index)")
                        .tag(Double(index * 60))
                }
            }
            .pickerStyle(.wheel)
            
            Group {
                if #available(iOS 26.0, *) {
                    Button {
                        isShowingAddNewNotificationTimeIntervalSheet = false
                        Task {
                            withAnimation(.bouncy) {
                                activityViewModel.notificationTimeIntervals.append(newTimeInterval)
                                activityViewModel.sortNotificationTimeIntervals()
                            }
                            await activityViewModel.refreshNotification()
                        }
                    } label: {
                        Text("Add")
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .padding(.vertical, 24)
                } else {
                    Button {
                        isShowingAddNewNotificationTimeIntervalSheet = false
                        Task {
                            withAnimation(.bouncy) {
                                activityViewModel.notificationTimeIntervals.append(newTimeInterval)
                                activityViewModel.sortNotificationTimeIntervals()
                            }
                            await activityViewModel.refreshNotification()
                        }
                    } label: {
                        Text("Add")
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.vertical, 24)
                }
            }
            .padding(.horizontal, 30)
        }
        .padding(.horizontal)
    }
    
}



#Preview {
    var viewModel = ActivityViewModel()
    SettingView()
        .environment(viewModel)
}
