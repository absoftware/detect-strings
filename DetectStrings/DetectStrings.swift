//
//  DetectStrings.swift
//  DetectStrings
//
//  Created by Ariel Bogdziewicz on 01/02/2022.
//

import Foundation

enum NeedleType {
    case user
    case link
    case hashtag
}

struct Needle {
    var text: String
    var type: NeedleType
}

enum DetectionResult: Hashable {
    case user(_ text: String)
    case link(_ text: String)
    case hashtag(_ text: String)
    case text(_ text: String)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .user(let text):
            hasher.combine(0)
            hasher.combine(text)
        case .link(let text):
            hasher.combine(1)
            hasher.combine(text)
        case .hashtag(let text):
            hasher.combine(2)
            hasher.combine(text)
        case .text(let text):
            hasher.combine(3)
            hasher.combine(text)
        }
    }
}

extension String {

    /// Strategy for overlapping:
    /// - take first
    /// - take longer if both starts in the same point
    func findAll(needles: [Needle]) -> [DetectionResult] {
        var result = [DetectionResult]()

        // According to the strategy "take longer as first" sort from the longest to the shortest
        let sortedNeedles = needles.sorted { needleA, needleB in
            needleA.text.count > needleB.text.count
        }

        var currentElementCharStartIndex: Int = 0
        var currentCharIndex: Int = 0
        let charCount = self.count

        // Iterate over characters
        while currentCharIndex < charCount {

            // Check if a needle has been found
            let currentStringIndex = self.index(self.startIndex, offsetBy: currentCharIndex)
            let foundNeedle: Needle? = sortedNeedles.first { self[currentStringIndex...].hasPrefix($0.text) }

            // If no needle then go to the next character
            guard let foundNeedle = foundNeedle else {
                currentCharIndex += 1
                continue
            }

            // Create text element if there are some characters
            if currentElementCharStartIndex < currentCharIndex {
                let textStart = self.index(self.startIndex, offsetBy: currentElementCharStartIndex)
                let textEnd = self.index(self.startIndex, offsetBy: currentCharIndex)
                result.append(.text(String(self[textStart..<textEnd])))
            }

            // If needle has been found
            switch foundNeedle.type {
            case .user:
                result.append(.user(foundNeedle.text))
            case .hashtag:
                result.append(.hashtag(foundNeedle.text))
            case .link:
                result.append(.link(foundNeedle.text))
            }

            currentCharIndex += foundNeedle.text.count
            currentElementCharStartIndex = currentCharIndex
        }

        // If we reach end of the string then we create text element taking last characters
        if currentElementCharStartIndex < charCount {
            let index = self.index(self.startIndex, offsetBy: currentElementCharStartIndex)
            result.append(.text(String(self[index...])))
        }

        return result
    }
}
