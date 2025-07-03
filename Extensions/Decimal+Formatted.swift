import Foundation

extension Decimal {
    func formatted() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.decimalSeparator = "."
        formatter.usesGroupingSeparator = false
        return formatter.string(for: self) ?? ""
    }
}
