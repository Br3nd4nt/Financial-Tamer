//
//  FuzzyMatch.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 04.07.2025.
//

func levenshtein(_ a: String, _ b: String) -> Int {
    let a = Array(a)
    let b = Array(b)
    let aLength = a.count
    let bLength = b.count
    var dp = Array(repeating: Array(repeating: 0, count: bLength + 1), count: aLength + 1)

    for row in 0...aLength { dp[row][0] = row }
    for column in 0...bLength { dp[0][column] = column }

    for row in 1...aLength {
        for column in 1...bLength {
            if a[row - 1] == b[column - 1] {
                dp[row][column] = dp[row - 1][column - 1]
            } else {
                dp[row][column] = min(
                    dp[row - 1][column] + 1,    // deletion
                    dp[row][column - 1] + 1,    // insertion
                    dp[row - 1][column - 1] + 1 // substitution
                )
            }
        }
    }
    return dp[aLength][bLength]
}

func fuzzyMatch(_ pattern: Pattern, in text: String, maxDistance: Int = 3) -> (isMatch: Bool, score: Double) {
    let patternText = pattern.text
    let patternLength = patternText.count
    let textLower = text.lowercased()
    let patternLower = patternText.lowercased()
    if patternLength == 0 {
        return (false, 0)
    }
    if let range = textLower.range(of: patternLower) {
        let startIndex = textLower.distance(from: textLower.startIndex, to: range.lowerBound)
        let positionBonus = startIndex == 0 ? 1.0 : 0.8
        return (true, positionBonus)
    }
    if textLower.count < patternLength {
        let distance = levenshtein(patternLower, textLower)
        let score = 1.0 - (Double(distance) / Double(patternLength))
        return (distance <= maxDistance, score)
    }
    var minDistance = Int.max
    var minIndex = 0
    for index in 0...(textLower.count - patternLength) {
        let start = textLower.index(textLower.startIndex, offsetBy: index)
        let end = textLower.index(start, offsetBy: patternLength)
        let substring = String(textLower[start..<end])
        let distance = levenshtein(patternLower, substring)
        if distance < minDistance {
            minDistance = distance
            minIndex = index
        }
    }
    let positionPenalty = 1.0 - Double(minIndex) / Double(textLower.count)
    let score = (1.0 - (Double(minDistance) / Double(patternLength))) * positionPenalty
    return (minDistance <= maxDistance, score)
}
