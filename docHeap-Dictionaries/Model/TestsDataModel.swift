//
//  TestsDataModel.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 20.11.23.
//

import Foundation

struct Tests {
    var identifier: String
    var name: String
    var image: String
    var testDescription: String
}

class TestDataModel {
    static var tests: [Tests] {
        return [
            Tests(identifier: "fiveWordsTest", name: "testVC_fiveWords_name".localized, image: "5wrdtst.png", testDescription: "testVC_fiveWords_description".localized),
            Tests(identifier: "threeWordsTest", name: "testVC_threeWords_name".localized, image: "3wrdtst.png", testDescription: "testVC_threeWords_description".localized),
            Tests(identifier: "findAPairTest", name: "testVC_findApair_name".localized, image: "fndApair.png", testDescription: "testVC_findApair_description".localized),
            Tests(identifier: "falseOrTrueTest", name: "testVC_falseOrTrue_name".localized, image: "toftest.png", testDescription: "testVC_falseOrTrue_description".localized),
            Tests(identifier: "findAnImageTest", name: "testVC_findAnImage_name".localized, image: "fanitest.png", testDescription: "testVC_findAnImage_description".localized)
        ]
    }
}
