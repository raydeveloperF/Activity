//
//  ShareItemParser.swift
//  Activity
//
//  Created by 柳和川的mac on 2025/11/19.
//

import Foundation
import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

// MARK: - 统一分类后的数据结构
enum SharedItem {
    case image(UIImage)
    case livePhoto(photoURL: URL, videoURL: URL)
    case video(URL)
    case audio(URL)
    case text(String)
    case url(URL)
    case file(name: String, data: Data)
    case unsupported(String)
}


// MARK: - 核心解析器
class ShareItemParser {

    /// 对 NSItemProvider 进行分类解析
    static func parse(
        provider: NSItemProvider,
        completion: @escaping (SharedItem) -> Void
    ) {

        // 图片
        if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { item, _ in
                loadImage(item: item, completion: completion)
            }
            return
        }

        // Live Photo
        if provider.hasItemConformingToTypeIdentifier(UTType.livePhoto.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.livePhoto.identifier, options: nil) { item, _ in
                loadLivePhoto(item: item, completion: completion)
            }
            return
        }

        // 视频
        if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.movie.identifier, options: nil) { item, _ in
                loadURL(item: item) { url in
                    if let url { completion(.video(url)) }
                }
            }
            return
        }

        // 音频
        if provider.hasItemConformingToTypeIdentifier(UTType.audio.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.audio.identifier, options: nil) { item, _ in
                loadURL(item: item) { url in
                    if let url { completion(.audio(url)) }
                }
            }
            return
        }

        // 文本
        if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { item, _ in
                if let text = item as? String {
                    completion(.text(text))
                } else {
                    completion(.unsupported("plainText parsing failed"))
                }
            }
            return
        }

        // URL（网页、文件地址等）
        if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { item, _ in
                if let url = item as? URL {
                    completion(.url(url))
                } else {
                    completion(.unsupported("URL parsing failed"))
                }
            }
            return
        }

        // 通用二进制文件
        if provider.hasItemConformingToTypeIdentifier(UTType.data.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.data.identifier, options: nil) { item, _ in
                loadRawData(item: item, completion: completion)
            }
            return
        }

        // 兜底
        completion(.unsupported(provider.registeredTypeIdentifiers.joined(separator: ",")))
    }
}


// MARK: - 解析函数实现

/// 图片解析
private func loadImage(
    item: NSSecureCoding?,
    completion: @escaping (SharedItem) -> Void
) {
    if let url = item as? URL,
       let data = try? Data(contentsOf: url),
       let img = UIImage(data: data) {
        completion(.image(img))
        return
    }

    if let img = item as? UIImage {
        completion(.image(img))
        return
    }

    completion(.unsupported("image parsing failed"))
}


/// Live Photo 解析
private func loadLivePhoto(
    item: NSSecureCoding?,
    completion: @escaping (SharedItem) -> Void
) {
    guard
        let dict = item as? NSDictionary,
        let photoURL = dict["photoURL"] as? URL,
        let videoURL = dict["videoURL"] as? URL
    else {
        completion(.unsupported("live photo parse failed"))
        return
    }

    completion(.livePhoto(photoURL: photoURL, videoURL: videoURL))
}


/// URL 解析（用于视频、音频、网页等）
private func loadURL(
    item: NSSecureCoding?,
    completion: @escaping (URL?) -> Void
) {
    if let url = item as? URL {
        completion(url)
        return
    }
    completion(nil)
}


/// 通用二进制文件解析
private func loadRawData(
    item: NSSecureCoding?,
    completion: @escaping (SharedItem) -> Void
) {
    if let url = item as? URL,
       let data = try? Data(contentsOf: url) {

        completion(.file(name: url.lastPathComponent, data: data))
        return
    }

    completion(.unsupported("raw data parsing failed"))
}
