//
//  DebugLog.swift
//  Activity
//
//  Created by 柳和川的mac on 2025/10/14.
//

func debugLog(_ message: @autoclosure () -> Any) {
#if DEBUG
    print(message())
#endif
}


