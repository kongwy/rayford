//
//  CircularProgressView.swift
//  Rayford
//
//  Created by Weiyi Kong on 15/8/2025.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double
    var text: String?

    var lineWidthRatio: CGFloat = 0.15
    var minimumLineWidth: CGFloat = 2
    var fontSizeRatio: CGFloat = 0.3
    var minimumFontSize: CGFloat = 8
    var tintColor: Color = .accentColor
    var backgroundColor: Color = .secondary.opacity(0.2)

    private var displayText: String { text ?? "\(Int(progress * 100))%" }

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let lineWidth = max(minimumLineWidth, side * lineWidthRatio)
            let fontSize = max(minimumFontSize, side * fontSizeRatio)

            ZStack {
                Circle()
                    .strokeBorder(backgroundColor, lineWidth: lineWidth)

                Circle()
                    .inset(by: lineWidth / 2)
                    .trim(from: 0, to: progress)
                    .stroke(tintColor, style: StrokeStyle(lineWidth: lineWidth,
                                                          lineCap: .round,
                                                          lineJoin: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.6), value: progress)

                Text(displayText)
                    .font(.system(size: fontSize, design: .rounded)).bold()
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    CircularProgressView(progress: 0.33)
}
