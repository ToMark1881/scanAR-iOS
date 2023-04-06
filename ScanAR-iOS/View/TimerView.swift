//
//  TimerView.swift
//  ScanAR-iOS
//
//  Created by Vladyslav Vdovychenko on 29.03.2023.
//

import Combine
import Foundation
import SwiftUI

struct TimerView: View {
    @ObservedObject var model: CameraViewModel

    private let fillColor: Color = Color.clear
    private let unprogressedColor: Color = Color(red: 0.5, green: 0.5, blue: 0.5)
    private let progressedColor: Color = .white

    private var timerDiameter: CGFloat = 50
    private var timerBarWidth: CGFloat = 5

    init(model: CameraViewModel, diameter: CGFloat = 50, barWidth: CGFloat = 5) {
        self.model = model
        self.timerDiameter = diameter
        self.timerBarWidth = barWidth
    }

    var body: some View {
        ZStack {

            Circle()
                .fill(fillColor)
                .frame(width: timerDiameter, height: timerDiameter)
                .overlay(
                    Circle().stroke(unprogressedColor, lineWidth: timerBarWidth)
                )
            Circle()
                .fill(Color.clear)
                .frame(width: timerDiameter, height: timerDiameter)
                .overlay(
                    Circle()
                        .trim(from: 0,
                              to: CGFloat(1.0 -
                                            (model.timeUntilCaptureSecs / model.autoCaptureIntervalSecs)))
                        .stroke(style: StrokeStyle(lineWidth: timerBarWidth,
                                                   lineCap: .round,
                                                   lineJoin: .round))
                        .foregroundColor(progressedColor))
        }
    }
}

