//
//  ProgressBar.swift
//  ScanAR-iOS
//
//  Created by Vladyslav Vdovychenko on 31.03.2023.
//

import SwiftUI

struct ProgressBar: View {
    @Binding var progress: Float
    var color: Color = .red
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(color)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)

            Text(String(format: "%.0f %%", min(self.progress, 1.0) * 100.0))
                .font(.largeTitle)
                .bold()
        }
    }
}
