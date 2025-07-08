//
//  Pattern.swift
//  Financial Tamer
//
//  Created by br3nd4nt on 04.07.2025.
//

struct Pattern {
    let text: String
    let mask: [Character: UInt]
    let alphabet: [Character]
    let length: Int

    init(_ pattern: String) {
        self.text = pattern.lowercased()
        self.length = text.count

        var maskDict: [Character: UInt] = [:]
        var charSet: Set<Character> = []

        for (index, char) in text.enumerated() {
            let bit = UInt(1) << index
            maskDict[char] = (maskDict[char] ?? 0) | bit
            charSet.insert(char)
        }

        self.mask = maskDict
        self.alphabet = Array(charSet)
    }
}
