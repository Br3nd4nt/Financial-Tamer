import SwiftUI
import UIKit

final class EmitterView: UIView {
    override static var layerClass: AnyClass {
        CAEmitterLayer.self
    }

    internal var emitterLayer: CAEmitterLayer {
        guard let layer = super.layer as? CAEmitterLayer else {
            fatalError("Expected CAEmitterLayer, got: \(type(of: super.layer))")
        }
        return layer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        emitterLayer.emitterPosition = CGPoint(
            x: bounds.midX,
            y: bounds.midY
        )
        emitterLayer.emitterSize = bounds.size
    }
}

struct SpoilerView: UIViewRepresentable {
    var isOn: Bool

    func makeUIView(context: Context) -> EmitterView {
        let emitterView = EmitterView()
        let emitterCell = CAEmitterCell()

        emitterCell.contents = Self.dotImage()?.cgImage
        emitterCell.color = UIColor.black.cgColor
        emitterCell.contentsScale = 1.8
        emitterCell.emissionRange = .pi * 2
        emitterCell.lifetime = 1
        emitterCell.scale = 0.7
        emitterCell.velocityRange = 20
        emitterCell.alphaRange = 1
        emitterCell.birthRate = 500

        emitterView.emitterLayer.emitterShape = .rectangle
        emitterView.emitterLayer.emitterCells = [emitterCell]

        return emitterView
    }

    func updateUIView(_ uiView: EmitterView, context: Context) {
        if isOn {
            uiView.emitterLayer.beginTime = CACurrentMediaTime()
        }
        uiView.emitterLayer.birthRate = isOn ? 1 : 0
    }

    static func dotImage() -> UIImage? {
        let size = CGSize(width: 4, height: 4)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(origin: .zero, size: size))

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

struct SpoilerModifier: ViewModifier {
    let isOn: Bool
    func body(content: Content) -> some View {
        content.overlay {
            SpoilerView(isOn: isOn)
        }
    }
}

extension View {
    func spoiler(isOn: Binding<Bool>) -> some View {
        self
            .opacity(isOn.wrappedValue ? 0 : 1)
            .modifier(SpoilerModifier(isOn: isOn.wrappedValue))
            .animation(.default, value: isOn.wrappedValue)
            .onTapGesture {
                isOn.wrappedValue.toggle()
            }
    }
}
