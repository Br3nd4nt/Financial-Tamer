import CoreGraphics
import UIKit

public class PieChartView: UIView {
    // MARK: - Properties

    public var entities: [Entity] = [] {
        didSet {
            print("PieChartView: entities changed, count: \(entities.count)")
            if oldValue != entities {
                if !oldValue.isEmpty {
                    animateTransition(from: oldValue, to: entities)
                } else {
                    setNeedsDisplay()
                    layoutIfNeeded()
                }
            } else {
                setNeedsDisplay()
                layoutIfNeeded()
            }
        }
    }

    // MARK: - Animation Properties

    private var animationLayer: CALayer?
    private var isAnimating = false
    private var oldEntities: [Entity] = []
    private var newEntities: [Entity] = []
    private var animationProgress = 0.0
    private var displayLink: CADisplayLink?

        private let segmentColors: [UIColor] = [
            UIColor(red: 203.0 / 255.0, green: 187.0 / 255.0, blue: 108.0 / 255.0, alpha: 1.0),
            UIColor(red: 194.0 / 255.0, green: 138.0 / 255.0, blue: 77.0 / 255.0, alpha: 1.0),
            UIColor(red: 213.0 / 255.0, green: 171.0 / 255.0, blue: 185.0 / 255.0, alpha: 1.0),
            UIColor(red: 129.0 / 255.0, green: 134.0 / 255.0, blue: 94.0 / 255.0, alpha: 1.0),
            UIColor(red: 180.0 / 255.0, green: 179.0 / 255.0, blue: 130.0 / 255.0, alpha: 1.0),
            UIColor(red: 208.0 / 255.0, green: 203.0 / 255.0, blue: 175.0 / 255.0, alpha: 1.0)
        ]

    // MARK: - Initialization

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

            private func setupView() {
            backgroundColor = UIColor.clear
            isOpaque = false
            print("PieChartView: setupView called, backgroundColor: \(backgroundColor?.description ?? "nil"), isOpaque: \(isOpaque)")
        }

    // MARK: - Drawing

    override public func draw(_ rect: CGRect) {
        print("PieChartView: draw called with rect: \(rect)")
        guard let context = UIGraphicsGetCurrentContext() else {
            print("PieChartView: No graphics context available")
            return
        }

        if isAnimating {
            drawAnimatedChart(context: context, rect: rect)
        } else {
            let chartSegments = prepareChartSegments()
            print("PieChartView: prepared \(chartSegments.count) segments")
            if chartSegments.isEmpty {
                print("PieChartView: No segments to draw")
                return
            }

            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2 - 20
            print("PieChartView: drawing with center: \(center), radius: \(radius)")

            drawPieChart(context: context, center: center, radius: radius, segments: chartSegments)
            drawLegend(context: context, center: center, radius: radius, segments: chartSegments)
        }
    }

    // MARK: - Private Methods

    private func prepareChartSegments() -> [ChartSegment] {
        print("PieChartView: prepareChartSegments called with \(entities.count) entities")
        guard !entities.isEmpty else {
            print("PieChartView: entities is empty")
            return []
        }

        let totalValue = entities.reduce(Decimal.zero) { $0 + $1.value }
        print("PieChartView: total value: \(totalValue)")
        guard totalValue > 0 else {
            print("PieChartView: total value is 0")
            return []
        }

        var segments: [ChartSegment] = []

        let mainEntities = Array(entities.prefix(5))
        for (index, entity) in mainEntities.enumerated() {
            let percentage = Double(truncating: (entity.value / totalValue) as NSDecimalNumber)
            if entity.value > 0 {
                segments.append(ChartSegment(
                    label: entity.label,
                    percentage: percentage,
                    color: segmentColors[index]
                ))
            }
        }

        if entities.count > 5 {
            let remainingEntities = Array(entities.dropFirst(5))
            let remainingValue = remainingEntities.reduce(Decimal.zero) { $0 + $1.value }
            if remainingValue > 0 {
                let remainingPercentage = Double(truncating: (remainingValue / totalValue) as NSDecimalNumber)
                segments.append(ChartSegment(
                    label: "Остальные",
                    percentage: remainingPercentage,
                    color: segmentColors[5]
                ))
            }
        }

        return segments
    }

    private func drawPieChart(context: CGContext, center: CGPoint, radius: Double, segments: [ChartSegment]) {
        print("PieChartView: drawPieChart called with \(segments.count) segments, center: \(center), radius: \(radius)")
        var startAngle: Double = -Double.pi / 2

        let innerRadius = radius * 0.8

        for (index, segment) in segments.enumerated() {
            let endAngle = startAngle + (segment.percentage * 2 * Double.pi)
            print("PieChartView: drawing segment \(index): \(segment.label), percentage: \(segment.percentage), startAngle: \(startAngle), endAngle: \(endAngle)")

            let path = UIBezierPath()

            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

            path.addArc(withCenter: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: false)

            path.close()

            segment.color.setFill()
            path.fill()
            print("PieChartView: filled segment with color: \(segment.color)")

            UIColor.white.setStroke()
            path.lineWidth = 2
            path.stroke()
            print("PieChartView: stroked segment with white border")

            startAngle = endAngle
        }
    }

        private func drawLegend(context: CGContext, center: CGPoint, radius: Double, segments: [ChartSegment]) {
        let fontSize: Double = 10
        let dotSize: Double = 6
        let lineSpacing: Double = 16
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: UIColor.black
        ]

        var currentY = center.y - (Double(segments.count) * lineSpacing / 2) + lineSpacing * 0.25

        for segment in segments {
            let percentageText = String(format: "%.0f%%", segment.percentage * 100)
            let fullText = "\(percentageText) \(segment.label)"

            let dotRect = CGRect(
                x: center.x - 50,
                y: currentY - dotSize / 2,
                width: dotSize,
                height: dotSize
            )
            let dotPath = UIBezierPath(ovalIn: dotRect)
            segment.color.setFill()
            dotPath.fill()

            let textRect = CGRect(
                x: center.x - 40,
                y: currentY - fontSize / 2,
                width: 100,
                height: fontSize
            )

            let attributedString = NSAttributedString(string: fullText, attributes: textAttributes)
            attributedString.draw(in: textRect)

            currentY += lineSpacing
        }
    }

    // MARK: - Animation Methods

    private func animateTransition(from oldData: [Entity], to newData: [Entity]) {
        guard !isAnimating else {
            return
        }

        isAnimating = true
        oldEntities = oldData
        newEntities = newData
        animationProgress = 0.0

        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateAnimation() {
        animationProgress += 0.02

        if animationProgress >= 1.0 {
            finishAnimation()
        } else {
            setNeedsDisplay()
        }
    }

    private func finishAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        isAnimating = false
        oldEntities = []
        newEntities = []
        animationProgress = 0.0
        setNeedsDisplay()
    }

    private func drawAnimatedChart(context: CGContext, rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - 20

        let rotationAngle = animationProgress * 2 * Double.pi

        let fadeOutAlpha: Double
        let fadeInAlpha: Double

        if animationProgress <= 0.5 {
            fadeOutAlpha = 1.0 - (animationProgress * 2.0)
            fadeInAlpha = 0.0
        } else {
            fadeOutAlpha = 0.0
            fadeInAlpha = (animationProgress - 0.5) * 2.0
        }

        if !oldEntities.isEmpty && fadeOutAlpha > 0 {
            context.saveGState()
            context.setAlpha(fadeOutAlpha)
            context.translateBy(x: center.x, y: center.y)
            context.rotate(by: rotationAngle)
            context.translateBy(x: -center.x, y: -center.y)

            let oldSegments = prepareChartSegments(from: oldEntities)
            drawPieChart(context: context, center: center, radius: radius, segments: oldSegments)
            drawLegend(context: context, center: center, radius: radius, segments: oldSegments)
            context.restoreGState()
        }

        if !newEntities.isEmpty && fadeInAlpha > 0 {
            context.saveGState()
            context.setAlpha(fadeInAlpha)
            context.translateBy(x: center.x, y: center.y)
            context.rotate(by: rotationAngle)
            context.translateBy(x: -center.x, y: -center.y)

            let newSegments = prepareChartSegments(from: newEntities)
            drawPieChart(context: context, center: center, radius: radius, segments: newSegments)
            drawLegend(context: context, center: center, radius: radius, segments: newSegments)
            context.restoreGState()
        }
    }

    private func prepareChartSegments(from entities: [Entity]) -> [ChartSegment] {
        guard !entities.isEmpty else {
            return []
        }

        let totalValue = entities.reduce(Decimal.zero) { $0 + $1.value }
        guard totalValue > 0 else {
            return []
        }

        var segments: [ChartSegment] = []

        let mainEntities = Array(entities.prefix(5))
        for (index, entity) in mainEntities.enumerated() {
            let percentage = Double(truncating: (entity.value / totalValue) as NSDecimalNumber)
            if entity.value > 0 {
                segments.append(ChartSegment(
                    label: entity.label,
                    percentage: percentage,
                    color: segmentColors[index]
                ))
            }
        }

        if entities.count > 5 {
            let remainingEntities = Array(entities.dropFirst(5))
            let remainingValue = remainingEntities.reduce(Decimal.zero) { $0 + $1.value }
            if remainingValue > 0 {
                let remainingPercentage = Double(truncating: (remainingValue / totalValue) as NSDecimalNumber)
                segments.append(ChartSegment(
                    label: "Остальные",
                    percentage: remainingPercentage,
                    color: segmentColors[5]
                ))
            }
        }

        return segments
    }
}

// MARK: - Helper Struct

private struct ChartSegment {
    let label: String
    let percentage: Double
    let color: UIColor
}
