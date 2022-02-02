//
//  DetectStrings.swift
//  DetectStrings
//
//  Created by Ariel Bogdziewicz on 01/02/2022.
//

import Foundation

/// Raw value means priority in case of the same content for a needle
enum NeedleType: Int {
    case hashtag
    case link
    case user // the most important
}

struct Needle {
    var text: String
    var type: NeedleType
}

enum DetectionResult: Hashable, Comparable {
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

    var trim: String {
        let whiteSpaceCharacters = CharacterSet.whitespacesAndNewlines
        return self.trimmingCharacters(in: whiteSpaceCharacters)
    }

    /// Strategy for overlapping:
    /// - take first
    /// - take longer needle if both start at the same point
    /// - ignore needles containing only white characters, trim white characters from others
    func findAll(needles: [Needle]) -> [DetectionResult] {
        var result = [DetectionResult]()

        // Basic corner case with empty self
        if self.trim.isEmpty {
            result.append(.text(self))
            return result
        }

        // According to the strategy "take longer as first" sort from the longest to the shortest
        let sortedNeedles = needles.filter {
            !$0.text.trim.isEmpty
        }.map {
            Needle(text: $0.text.trim, type: $0.type)
        }.sorted { needleA, needleB in
            if needleA.text.count != needleB.text.count {
                return needleA.text.count > needleB.text.count
            }
            return needleA.type.rawValue > needleB.type.rawValue
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
