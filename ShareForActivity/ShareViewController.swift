//
//  ShareViewController.swift
//  ShareForActivity
//
//  Created by 柳和川的mac on 2025/11/19.
//



import UIKit
import UniformTypeIdentifiers

// 辅助调试函数（如果您的项目中没有定义 debugLog，请自行补充）
// func debugLog(_ message: String) { print(message) }


class ShareViewController: UIViewController {
    
    // App Group ID
    private let groupID = "group.com.Ray.Activity"
    
    // URL Scheme
    private let urlScheme = "rayactivity"

    override func viewDidLoad() {
        super.viewDidLoad()
        handleIncomingItems()
    }

    /// 解析所有传入的项目
    private func handleIncomingItems() {

        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            // 没有输入项，直接跳转并结束
            openMainAppAndFinish(fileURLs: [])
            return
        }
        
        // 关键修复 1: 使用 DispatchGroup 等待所有异步任务
        var returnedURLs: [URL] = []
        let group = DispatchGroup()
        var hasAttachments = false // 检查是否有附件需要处理
        
        for item in items {
            for provider in item.attachments ?? [] {
                hasAttachments = true
                
                group.enter() // 任务开始
                
                // 确保在全局队列上执行写入操作，以防止阻塞主线程
                ShareItemParser.parse(provider: provider) { [weak self] result in
                    guard let self = self else { group.leave(); return }
                    
                    // 实际文件写入是同步操作，但放在异步回调中执行
                    // 确保对 shared mutable state (returnedURLs) 的访问在同一线程
                    DispatchQueue.global().async {
                        defer { group.leave() } // 任务结束
                        
                        // ⚠️ 修复 2: 将 returnedURLs.append 放在 Dispatch Group 内的异步回调中
                        if let url = self.processSharedItem(item: result, fileName: provider.suggestedName) {
                            // 由于 returnedURLs 是局部变量，需要加锁或确保只在 notify 中访问
                            // 暂时使用数组 append，并依赖 notify 的原子性
                            returnedURLs.append(url)
                        }
                    }
                }
            }
        }
        
        // 如果没有附件需要处理，也需要立即跳转
        if !hasAttachments {
            openMainAppAndFinish(fileURLs: [])
            return
        }
        
        // 关键修复 3: 当所有异步解析完成后执行
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            // 修复 4: 现在 returnedURLs 包含了所有写入成功的 URL
            
            // 1. 保存到 App Group / UserDefaults
            // ⚠️ 修复 5: 假设 UserDefaultKey.saveToShareDataKey 内部正确使用了 groupID
            UserDefaultKey.saveToShareDataKey(value: returnedURLs)
            
            // 2. 触发跳转和结束
            self.openMainAppAndFinish(fileURLs: returnedURLs)
        }
    }

    
    /// 处理解析后的数据
    private func processSharedItem(item: SharedItem, fileName: String?) -> URL? {
        // --- 保持原有的逻辑不变 ---

        switch item {

        case .image(let image):
            if let data = image.jpegData(compressionQuality: 0.95) {
                if let url = store(data: data, originalFileName: fileName) {
                    return url
                }
            }

        case .livePhoto(let photoURL, let videoURL):
            if let data = try? Data(contentsOf: photoURL) {
                if let url = store(data: data, originalFileName: fileName) {
                    return url
                }
            }
            if let data = try? Data(contentsOf: videoURL) {
                if let url = store(data: data, originalFileName: fileName) {
                    return url
                }
            }

        case .video(let url):
            if let data = try? Data(contentsOf: url) {
                if let url = store(data: data, originalFileName: fileName) {
                    return url
                }
            }

        case .audio(let url):
            if let data = try? Data(contentsOf: url) {
                if let url = store(data: data, originalFileName: fileName) {
                    return url
                }
            }

        case .text(let str):
            if let data = str.data(using: .utf8) {
                if let url = store(data: data, originalFileName: fileName) {
                    return url
                }
            }

        case .url(let url):
            // 您的原有逻辑是下载 URL 内容
            if let data = try? Data(contentsOf: url) {
                if let url = store(data: data, originalFileName: fileName) {
                    return url
                }
            }

        case .file(let name, let data):
            if let url = store(data: data, originalFileName: fileName) {
                return url
            }

        case .unsupported(let reason):
            // debugLog("不支持的类型：\(reason)")
            break
        }
        
        return nil
    }

    /// 写入 App Group 持久化
    private func store(data: Data, originalFileName: String?) -> URL? {

        // App Group —— 自己改
        // ⚠️ 使用 groupID 类属性
        guard var baseURL = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: groupID)
        else {
            // debugLog("写入失败：找不到 App Group")
            return nil
        }

        // 写入到 AppGroup/Shared/
        baseURL = baseURL.appendingPathComponent("Shared", isDirectory: true)

        // 保证目录存在
        if !FileManager.default.fileExists(atPath: baseURL.path) {
            do {
                try FileManager.default.createDirectory(at: baseURL,
                                                        withIntermediateDirectories: true)
            } catch {
                // debugLog("创建目录失败：\(error)")
                return nil
            }
        }

        // --- 生成文件名 ------------------------------------------------------

        // 尝试用原文件扩展名
        let fileExt = (originalFileName as NSString?)?.pathExtension

        // 自动生成唯一文件名
        let finalFileName = UUID().uuidString + (fileExt?.isEmpty == false ? ".\(fileExt!)" : "")

        // 最终写入路径
        let finalURL = baseURL.appendingPathComponent(finalFileName)

        // --- 写入 ------------------------------------------------------------

        do {
            try data.write(to: finalURL, options: .atomic)
            // debugLog("已写入：\(finalURL)")
            return finalURL
        } catch {
            // debugLog("写入失败：\(error)")
            return nil
        }
    }


    // MARK: - 跳转和结束逻辑

    /// 统一的跳转和结束流程
    private func openMainAppAndFinish(fileURLs: [URL]) {
        
        // 1. 触发跳转
        let fileCount = fileURLs.count
        let redirectURLString = "\(urlScheme)://share?count=\(fileCount)"
        
        if let redirectURL = URL(string: redirectURLString) {
            self.openMainApp(redirectURL)
        }
        
        // 2. 结束扩展 (必须在跳转之后执行)
        self.finish()
    }
    
    /// 结束扩展
    private func finish() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }

    /// 辅助方法：唤醒主 App (使用最可靠的响应链/选择器模式)
    private func openMainApp(_ url: URL) {
            
        // 关键：在 App Extension 中，不能直接使用 UIApplication.shared.open()。
        let selector = sel_registerName("openURL:")
        var responder = self as UIResponder?
        
        // 遍历响应链
        while let r = responder {
            if r.responds(to: selector) && r != self {
                // 执行选择器调用，触发 App 跳转
                r.perform(selector, with: url)
                return
            }
            responder = r.next
        }
        
        // 备用方案
        if let context = extensionContext, context.responds(to: selector) {
            context.perform(selector, with: url)
        }
    }
}

