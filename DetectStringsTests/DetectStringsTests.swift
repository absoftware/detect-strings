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
        TestCase(
            text: "",
            needles: [],
            expected: []),
        TestCase(
            text: "ABCDEF",
            needles: [Needle(text: "ABC", type: .link), Needle(text: "ABCDE", type: .hashtag)],
            expected: [.hashtag("ABCDE"), .text("F")]),
        TestCase(
            text: "Test ABC ABC ABC",
            needles: [Needle(text: "ABC", type: .link)],
            expected: [.text("Test "), .link("ABC"), .text(" "), .link("ABC"), .text(" "), .link("ABC")]),
        TestCase(
            text: "Test ABC ABC ABC ",
            needles: [Needle(text: "ABC", type: .link)],
            expected: [.text("Test "), .link("ABC"), .text(" "), .link("ABC"), .text(" "), .link("ABC"), .text(" ")]),
        TestCase(
            text: "Test ABC ABC ABC abc",
            needles: [Needle(text: "ABC", type: .link)],
            expected: [.text("Test "), .link("ABC"), .text(" "), .link("ABC"), .text(" "), .link("ABC"), .text(" abc")]),
        TestCase(
            text: "ABC",
            needles: [Needle(text: "ABC", type: .link)],
            expected: [.link("ABC")]),
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
