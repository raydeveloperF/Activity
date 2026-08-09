//
//  HapticManager.swift
//  Activity
//
//  Created by 柳和川的mac on 2025/11/6.
//

import SwiftUI
import CoreHaptics

class HapticManager {
    
    static let shared = HapticManager()
    private init() {
        prepareHaptics()
        observeAppLifecycle()
    }
    
    private var engine: CHHapticEngine?
    
    
    
    func customHaptic(intensityStartValue: Float, intensityEndValue: Float, sharpStartValue: Float, sharpEndValue: Float, duration: TimeInterval) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        let event = CHHapticEvent(
            eventType: .hapticContinuous, // 短促脉冲（也可用 .hapticContinuous）
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensityStartValue),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpStartValue),
            ],
            relativeTime: 0,
            duration: duration
        )
        
        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints:
                makeHapticControlPoints(BezierCurve.customCurve.p1x, BezierCurve.customCurve.p1y, BezierCurve.customCurve.p2x, BezierCurve.customCurve.p2y, startValue: Double(intensityStartValue), endValue: Double(intensityEndValue), samples: 10)
            ,
            relativeTime: 0
        )
        
        let sharpCurve = CHHapticParameterCurve(
            parameterID: .hapticSharpnessControl,
            controlPoints:
                makeHapticControlPoints(BezierCurve.customCurve.p1x, BezierCurve.customCurve.p1y, BezierCurve.customCurve.p2x, BezierCurve.customCurve.p2y, startValue: Double(sharpStartValue), endValue: Double(sharpEndValue), samples: 10)
            ,
            relativeTime: 0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameterCurves: [intensityCurve, sharpCurve])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            debugLog("⚠️ Error playing haptic: \(error.localizedDescription)")
        }
    }
    
    
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            engine?.resetHandler = { [weak self] in
                debugLog("🔁 Haptic engine reset by system, restarting...")
                do {
                    try self?.engine?.start()
                    debugLog("✅ Haptic engine restarted successfully")
                } catch {
                    debugLog("❌ Failed to restart haptic engine: \(error)")
                }
            }
        } catch {
            debugLog("⚠️ Haptic engine failed: \(error.localizedDescription)")
        }
    }
    
    private func observeAppLifecycle() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            debugLog("📱 App returned to foreground, restarting haptic engine")
            do {
                try self?.engine?.start()
            } catch {
                debugLog("❌ Failed to restart haptics: \(error)")
            }
        }
    }
    
    private func makeHapticControlPoints(
        _ p1x: Double, _ p1y: Double,
        _ p2x: Double, _ p2y: Double,
        startValue: Double,
        endValue: Double,
        samples: Int
    ) -> [CHHapticParameterCurve.ControlPoint] {
        
        var points: [CHHapticParameterCurve.ControlPoint] = []
        for i in 0...samples {
            let t = Double(i) / Double(samples)
            // 计算贝塞尔曲线的 y 值
            let y = cubicBezier(t, 0.0, p1y, p2y, 1.0)
            // 插值强度
            let intensity = startValue + (endValue - startValue) * y
            points.append(.init(relativeTime: t, value: Float(intensity)))
        }
        return points
    }
    
    private func cubicBezier(_ t: Double, _ p0: Double, _ p1: Double, _ p2: Double, _ p3: Double) -> Double {
        let u = 1 - t
        return pow(u, 3) * p0 +
               3 * pow(u, 2) * t * p1 +
               3 * u * pow(t, 2) * p2 +
               pow(t, 3) * p3
    }
    
}



