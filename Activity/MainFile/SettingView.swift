//
//  SettingView.swift
//  Activity
//
//  Created by 柳和川的mac on 2025/10/27.
//

import SwiftUI

struct SettingView: View {
    @Environment(ActivityViewModel.self) private var activityViewModel
    @Environment(\.openURL) private var openURL
    @State private var isShowingAddNewNotificationTimeIntervalSheet = false
    @State private var newTimeInterval: Double = 15 * 60

    var body: some View {
        @Bindable var activityViewModel = activityViewModel

        List {
            Section {
                Toggle("在主页面展示设置入口", isOn: $activityViewModel.isShowSettingView)
            } header: {
                Text("通用")
            } footer: {
                Text("如果你关闭此功能，在主页将不再显示设置按钮，如果你想再次进入设置页面（也就是本页面），请长按主页的任意区域")
            }

            Section {
                Toggle("开启通知", isOn: $activityViewModel.hasNotification.animation(.smooth))

                if activityViewModel.hasNotification {
                    ForEach(activityViewModel.notificationTimeIntervals.indices, id: \.self) { index in
                        let minutes = Int(activityViewModel.notificationTimeIntervals[index]) / 60

                        HStack {
                            Text(minutes.formatted(.number))
                                .bold()
                            Text("分钟")
                        }
                    }
                    .onDelete(perform: deleteNotificationTimeIntervals)

                    addNotificationButton
                }
            } header: {
                Text("通知")
            } footer: {
                if activityViewModel.hasNotification {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("你可以添加任意多个提前提醒，这些时间代表App会在你设定的时间前多长时间给你发送通知。")
                        Text("向左轻扫提醒时间即可删除。")
                    }
                }
            }

            Section("支持与关注") {
                Link(destination: URL(string: "https://apps.apple.com/app/id6754206929?action=write-review")!) {
                    Label("在 App Store 评分", systemImage: "star")
                }

                Button {
                    openURL(URL(string: "xhsdiscover://user/68e906680000000030032636")!) { accepted in
                        if !accepted {
                            openURL(URL(string: "https://xhslink.cn/m/3uP6VrkOZK3")!)
                        }
                    }
                } label: {
                    Label("小红书", systemImage: "heart.text.square")
                }

                Link(destination: URL(string: "https://github.com/raydeveloperF")!) {
                    Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                }

                Link(destination: URL(string: "https://leorokon.com")!) {
                    Label("个人网站", systemImage: "globe")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Setting")
        .sheet(isPresented: $isShowingAddNewNotificationTimeIntervalSheet) {
            addNotificationSheet
                .presentationDetents([.medium])
        }
    }
}

extension SettingView {
    private func deleteNotificationTimeIntervals(at offsets: IndexSet) {
        activityViewModel.notificationTimeIntervals.remove(atOffsets: offsets)
        Task {
            await activityViewModel.refreshNotification()
        }
    }

    private var addNotificationButton: some View {
        Button {
            isShowingAddNewNotificationTimeIntervalSheet = true
        } label: {
            Label("添加提醒", systemImage: "plus")
        }
    }

    private var addNotificationSheet: some View {
        VStack {
            Picker("Select", selection: $newTimeInterval) {
                ForEach(1...60, id: \.self) { index in
                    Text("\(index)")
                        .tag(Double(index * 60))
                }
            }
            .pickerStyle(.wheel)

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
            .padding(.horizontal, 30)
            .padding(.vertical, 24)
        }
        .padding(.horizontal)
    }
}

#Preview {
    var viewModel = ActivityViewModel()
    NavigationStack {
        SettingView()
            .environment(viewModel)
    }
}
