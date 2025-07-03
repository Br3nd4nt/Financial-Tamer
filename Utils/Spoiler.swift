import SwiftUI
import UIKit

final class EmitterView: UIView {
    override static var layerClass: AnyClass {
        CAEmitterLayer.self
    }
    
    override var layer: CAEmitterLayer {
        switch self.layer {
        case let emitterLayer as CAEmitterLayer:
            return emitterLayer
        default:
            fatalError("Expected CAEmitterLayer, got: \(type(of: layer))")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.emitterPosition = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        layer.emitterSize = bounds.size
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
        emitterView.layer.emitterShape = .rectangle
        emitterView.layer.emitterCells = [emitterCell]
        return emitterView
    }

    func updateUIView(_ uiView: EmitterView, context: Context) {
        if isOn {
            uiView.layer.beginTime = CACurrentMediaTime()
        }
        uiView.layer.birthRate = isOn ? 1 : 0
    }

    static func dotImage() -> UIImage? {
        let size = CGSize(width: 4, height: 4)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fillEllipse(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
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
