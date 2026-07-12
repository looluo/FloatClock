import SwiftUI

struct FloatClockMark: View {
    var body: some View {
        GeometryReader { proxy in
            let size = min(proxy.size.width, proxy.size.height)
            let lineWidth = max(size * 0.075, 1.25)
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let markRect = CGRect(
                x: center.x - size / 2,
                y: center.y - size / 2,
                width: size,
                height: size
            )
            let faceRect = CGRect(
                x: center.x - size * 0.29,
                y: center.y - size * 0.29,
                width: size * 0.58,
                height: size * 0.58
            )
            let centerDotSize = max(size * 0.09, 2)

            ZStack {
                Path(roundedRect: markRect, cornerRadius: size * 0.23)
                    .fill(Color.floatClockAccent)

                Path(ellipseIn: faceRect)
                    .stroke(.white, lineWidth: lineWidth)

                Path { path in
                    path.move(to: center)
                    path.addLine(to: handEnd(from: center, angle: .degrees(-48), length: size * 0.2))
                    path.move(to: center)
                    path.addLine(to: handEnd(from: center, angle: .degrees(148), length: size * 0.16))
                }
                .stroke(.white, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

                Path(ellipseIn: CGRect(
                    x: center.x - centerDotSize / 2,
                    y: center.y - centerDotSize / 2,
                    width: centerDotSize,
                    height: centerDotSize
                ))
                .fill(.white)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel("FloatClock")
        .accessibilityAddTraits(.isImage)
    }

    private func handEnd(from center: CGPoint, angle: Angle, length: CGFloat) -> CGPoint {
        CGPoint(
            x: center.x + cos(angle.radians) * length,
            y: center.y + sin(angle.radians) * length
        )
    }
}

#Preview {
    HStack(spacing: 16) {
        FloatClockMark()
            .frame(width: 18, height: 18)
        FloatClockMark()
            .frame(width: 24, height: 24)
        FloatClockMark()
            .frame(width: 44, height: 44)
        FloatClockMark()
            .frame(width: 102, height: 102)
    }
    .padding()
    .background(.black)
}
