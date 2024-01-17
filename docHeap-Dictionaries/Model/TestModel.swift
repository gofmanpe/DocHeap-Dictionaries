//
//  TestModel.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 17.01.24.
//

import Foundation

struct TestModel{
    
    func wordsTestingEngine(arrayOfWords:[Word], mainWordIndex:Int, numberOfWords: Int) ->(String,String,[String],[Int:String]){
        var wordsSet = Set<Word?>() // creating Set for testing words complect
        wordsSet.insert(arrayOfWords[mainWordIndex]) // inserting the main testing word into Set
        while wordsSet.count < numberOfWords { // filling Set with words up to numberOfWords
            let randomEl = arrayOfWords.randomElement()!
            wordsSet.insert(randomEl)
        }
        let convertedFromSetArray = Array(wordsSet) // convert Set into Array
        let mainWord = arrayOfWords[mainWordIndex].wrdWord! // getting mainWord
        let mainWordTranslation = arrayOfWords[mainWordIndex].wrdTranslation! // getting mainTranslation
        var threeButtonsVolumesDictionary = [Int:String]()
        var fiveButtonsVolumesDictionary = [Int:String]()
        switch numberOfWords{
        case 3:
            let threeButtonsTranstlationsArray = convertedFromSetArray.map({$0?.wrdTranslation ?? "noValue"})
            for i in 0...2 {
                threeButtonsVolumesDictionary[i] = convertedFromSetArray[i]!.wrdTranslation
            }
            return (mainWord,mainWordTranslation,threeButtonsTranstlationsArray,threeButtonsVolumesDictionary)
        case 5:
            let fiveButtonsTranstlationsArray = convertedFromSetArray.map({$0?.wrdTranslation ?? "noValue"})
            for i in 0...4 {
                fiveButtonsVolumesDictionary[i] = convertedFromSetArray[i]!.wrdTranslation
            }
            return (mainWord,mainWordTranslation,fiveButtonsTranstlationsArray,fiveButtonsVolumesDictionary)
        default: return ("error","error",["error"],[0:"error"])
        }
    }
    
    func errorsRepetitionMode(arrayOfWords:[Word], arrayOfMistakes:[Word], mainWordIndex: Int, numberOfWords: Int) -> (String,String,[String],[Int:String]){
        var errorsSet = Set<Word?>()
        errorsSet.insert(arrayOfMistakes[mainWordIndex])
        while errorsSet.count < numberOfWords {
            let randomEl = arrayOfWords.randomElement()!
            errorsSet.insert(randomEl)
        }
        let convertedFromSetArray = Array(errorsSet)
        let mainWord = arrayOfMistakes[mainWordIndex].wrdWord!
        let mainWordTranslation = arrayOfMistakes[mainWordIndex].wrdTranslation!
        var threeButtonsVolumesDictionary = [Int:String]()
        var fiveButtonsVolumesDictionary = [Int:String]()
        switch numberOfWords{
        case 3:
            let threeButtonsTranstlationsArray = convertedFromSetArray.map({$0?.wrdTranslation ?? "noValue"})
            
            for i in 0...2 {
                threeButtonsVolumesDictionary[i] = convertedFromSetArray[i]!.wrdTranslation
            }
            return (mainWord, mainWordTranslation, threeButtonsTranstlationsArray, threeButtonsVolumesDictionary)
        case 5:
            let fiveButtonsTranstlationsArray = convertedFromSetArray.map({$0?.wrdTranslation ?? "noValue"})
            
            for i in 0...4 {
                fiveButtonsVolumesDictionary[i] = convertedFromSetArray[i]!.wrdTranslation
            }
            return (mainWord, mainWordTranslation, fiveButtonsTranstlationsArray, fiveButtonsVolumesDictionary)
        default: return ("error","error",["error"],[0:"error"])
        }
    }
    
    func findAPairEngine(arrayOfWords:[Word]) ->([Word],[String],[Int:String],[Word],[String],[Int:String]){
        var wordsButtonsVolumesDictionary = [Int():String()]
        var translationsButtonsVolumesDictionary = [Int():String()]
        var wordsSet = Set<Word>() //create a Set a Word type with words
        while wordsSet.count < 7 { // in loop add randomly 7 words into Set
            let randomWordElement = arrayOfWords.randomElement()!
            wordsSet.insert(randomWordElement)
        }
        let sevenWordsArray = Array(wordsSet) // converting Set into unique Array
        let sevenButtonsWordsArray = sevenWordsArray.map({$0.wrdWord ?? "noWord"})
        var translationSet = Set<Word>() //create a Set a Word type with translations
        while translationSet.count < 7 { // in loop add randomly 7 translations into Set
            let randomTranslationElement = sevenWordsArray.randomElement()!
            translationSet.insert(randomTranslationElement)
        }
        let sevenTranslationsArray = Array(translationSet) // converting Set into unique Array
        let sevenButtonsTranslationsArray = sevenTranslationsArray.map({$0.wrdTranslation ?? "noTranslation"})
        for i in 0...6{ // in loop set the buttons titles and volumes for words and translations group
            wordsButtonsVolumesDictionary[i] = sevenWordsArray[i].wrdWord
            translationsButtonsVolumesDictionary[i] = sevenTranslationsArray[i].wrdTranslation
        }
        return (sevenWordsArray,sevenButtonsWordsArray,wordsButtonsVolumesDictionary,sevenTranslationsArray,sevenButtonsTranslationsArray,translationsButtonsVolumesDictionary)
    }
    
    func findAnImageTestEngine(arrayOfWords:[Word], mainWordIndex:Int) -> (String, String, [String?], [String]){
        var wordsWithImagesSet = Set<Word?>() // creating Set for testing words complect
        wordsWithImagesSet.insert(arrayOfWords[mainWordIndex]) // inserting the main testing word into Set
        while wordsWithImagesSet.count < 4 { // filling Set with words up to 5 pcs
            let randomEl = arrayOfWords.randomElement()!
            wordsWithImagesSet.insert(randomEl)
        }
        let convertedFromSetArray = Array(wordsWithImagesSet) // convert Set into Array
        print("Converted array is: \(convertedFromSetArray)\n")
        let mainWord = arrayOfWords[mainWordIndex].wrdWord!
        let mainWordImage = arrayOfWords[mainWordIndex].imageName!
        var fourImagesWordsArray = [String]()
        var fourImagesPathArray = [String]()
        for i in 0...3 {
            fourImagesWordsArray.append(convertedFromSetArray[i]!.wrdWord!)
            fourImagesPathArray.append(convertedFromSetArray[i]!.imageName!)
        }
        return (mainWord, mainWordImage, fourImagesWordsArray, fourImagesPathArray)
    }
}
