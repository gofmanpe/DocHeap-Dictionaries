//
//  TestsDataModel.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 20.11.23.
//

import Foundation

class TestDataModel {
    static var tests: [Tests] {
        return [
            Tests(
                identifier: "fiveWordsTest",
                name: "testVC_fiveWords_name".localized,
                image: "testVC_5wordstest_ico".localized,
                testDescription: "testVC_fiveWords_description".localized),
            Tests(
                identifier: "threeWordsTest",
                name: "testVC_threeWords_name".localized,
                image: "testVC_3wordstest_ico".localized,
                testDescription: "testVC_threeWords_description".localized),
            Tests(
                identifier: "findAPairTest",
                name: "testVC_findApair_name".localized,
                image: "testVC_findApairtest_ico".localized,
                testDescription: "testVC_findApair_description".localized),
            Tests(
                identifier: "falseOrTrueTest",
                name: "testVC_falseOrTrue_name".localized,
                image: "testVC_trueOrFalsetest_ico".localized,
                testDescription: "testVC_falseOrTrue_description".localized),
            Tests(
                identifier: "findAnImageTest",
                name: "testVC_findAnImage_name".localized,
                image: "testVC_findAnImagetest_ico".localized,
                testDescription: "testVC_findAnImage_description".localized)
        ]
    }
}
