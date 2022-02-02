//
//  DetectStringsTests.swift
//  DetectStringsTests
//
//  Created by Ariel Bogdziewicz on 01/02/2022.
//

import XCTest
@testable import DetectStrings

class DetectStringsTests: XCTestCase {

    struct TestCase {
        var text: String
        var needles: [Needle]
        var expected: [DetectionResult]
    }

    let testCases: [TestCase] = [
        TestCase( // everything is empty
            text: "",
            needles: [],
            expected: [.text("")]),
        TestCase( // needle not found
            text: "ABCDEF",
            needles: [Needle(text: "DEFG", type: .link)],
            expected: [.text("ABCDEF")]),
        TestCase( // empty string, empty needle
            text: "",
            needles: [Needle(text: "", type: .link)],
            expected: [.text("")]),
        TestCase( // empty string with needle
            text: "",
            needles: [Needle(text: "ABC", type: .link)],
            expected: [.text("")]),
        TestCase( // higher priority for longer needle
            text: "ABCDEF",
            needles: [Needle(text: "ABC", type: .link), Needle(text: "ABCDE", type: .hashtag)],
            expected: [.hashtag("ABCDE"), .text("F")]),
        TestCase( // no text at the end, last element is link
            text: "Test ABC ABC ABC",
            needles: [Needle(text: "ABC", type: .link)],
            expected: [.text("Test "), .link("ABC"), .text(" "), .link("ABC"), .text(" "), .link("ABC")]),
        TestCase( // whitespace at the end
            text: "Test ABC ABC ABC ",
            needles: [Needle(text: "ABC", type: .link)],
            expected: [.text("Test "), .link("ABC"), .text(" "), .link("ABC"), .text(" "), .link("ABC"), .text(" ")]),
        TestCase( // text at the end with white space
            text: "Test ABC ABC ABC abc",
            needles: [Needle(text: "ABC", type: .link)],
            expected: [.text("Test "), .link("ABC"), .text(" "), .link("ABC"), .text(" "), .link("ABC"), .text(" abc")]),
        TestCase( // when entire string is a link
            text: "ABC",
            needles: [Needle(text: "ABC", type: .link)],
            expected: [.link("ABC")]),
        TestCase( // just searching emojis
            text: "👨‍👩‍👦‍👦👨‍👩‍👦‍👦👨‍👩‍👦‍👦",
            needles: [Needle(text: "👨‍👩‍👦‍👦", type: .link)],
            expected: [.link("👨‍👩‍👦‍👦"), .link("👨‍👩‍👦‍👦"), .link("👨‍👩‍👦‍👦")]),
        TestCase( // test for needle being a unicode scalar included into another character, it shouldn't be found
            text: "👨‍👩‍👧‍👦👨‍👩‍👧‍👦👨‍👩‍👧‍👦",
            needles: [Needle(text: "👩", type: .link)],
            expected: [.text("👨‍👩‍👧‍👦👨‍👩‍👧‍👦👨‍👩‍👧‍👦")]),
        TestCase( // higher priority sequentially for user, link, hashtag
            text: "ABCDEF",
            needles: [Needle(text: "ABC", type: .hashtag), Needle(text: "ABC", type: .link), Needle(text: "DEF", type: .link), Needle(text: "DEF", type: .user)],
            expected: [.link("ABC"), .user("DEF")])
    ]

    func testAllCases() throws {
        for (index, testCase) in self.testCases.enumerated() {
            XCTContext.runActivity(named: "\(index):\(testCase.text)") { activity in
                let result = testCase.text.findAll(needles: testCase.needles)
                debug(index: index, result: result)
                XCTAssertEqual(result.count, testCase.expected.count)
                if result.count == testCase.expected.count {
                    for itemIndex in 0..<result.count {
                        XCTAssertEqual(result[itemIndex], testCase.expected[itemIndex])
                    }
                }
            }
        }
    }

    private func debug(index: Int, result: [DetectionResult]) {
        print("INDEX[\(index)]:")
        for item in result {
            print(" - \(item)")
        }
    }
}
