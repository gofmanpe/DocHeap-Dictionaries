//
//  Defaults.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 29.03.23.
//

import Foundation

struct Defaults{
    
    let monthArray = [
        MonthArray(value: "01", name: "defaults_month1".localized),
        MonthArray(value: "02", name: "defaults_month2".localized),
        MonthArray(value: "03", name: "defaults_month3".localized),
        MonthArray(value: "04", name: "defaults_month4".localized),
        MonthArray(value: "05", name: "defaults_month5".localized),
        MonthArray(value: "06", name: "defaults_month6".localized),
        MonthArray(value: "07", name: "defaults_month7".localized),
        MonthArray(value: "08", name: "defaults_month8".localized),
        MonthArray(value: "09", name: "defaults_month9".localized),
        MonthArray(value: "10", name: "defaults_month10".localized),
        MonthArray(value: "11", name: "defaults_month11".localized),
        MonthArray(value: "12", name: "defaults_month12".localized)
    ]
    
    let rightCommentsArray = ["RIGHT!", "GREAT!", "COOL!", "AWSOME!", "GOOD WORK!", "PIECE OF CAKE!"]
    let wrongCommentsArray = ["ARE YOU TIRED?", "ONE MORE TRY!", "YOU WRONG!", "NO WAY!", "NOPE!", "OK, BUT NO!"]
    
    let emptyAvatarPath = "https://firebasestorage.googleapis.com/v0/b/docheap-dictionaries-1c1be.appspot.com/o/Resources%2FnoAvatar.png?alt=media&token=8542c73b-f70e-4030-aedb-3a662e724033"
    
    let labelTestFinishedText = "TEST FINISHED!"
    let labelMistakesFixedText = "MISTAKES FIXED!"
    let labelTestProgressText = "Test progress:"
    let findApairChooseWordText = "You must choose a word"
    let findApairChooseTranslationText = "You must choose a translation"
    let labelNoCreatedDictionaries = "You have no any dictionaries yet.\nFor start testing you must create at least one dictionary, and add 5 words into it."
    
    let fiveWordsTestName = "Five words test"
    let fiveWordsTestImage = "5wrdtst.png"
    let fiveWordsTestIdentifier = "fiveWordsTest"
    let fiveWordsTestDescription = "You can test your vocabulary by choosing one correct word from five suggested answers. You can then correct the mistakes."
    
    let threeWordsTestName = "Three words test"
    let threeWordsTestImage = "3wrdtst.png"
    let threeWordsTestIdentifier = "threeWordsTest"
    let threeWordsTestDescription = "You can test your vocabulary by choosing one correct word from three suggested answers. You can then correct the mistakes."
    
    let findAPairTestName = "Find a pair test"
    let findAPairTestImage = "fndApair.png"
    let findAPairTestIdentifier = "findAPairTest"
    let findAPairTestDescription = "You will be prompted with seven pairs of words. Your task is to choose the right pair."
    
    let falseOrTrueTestName = "False or True test"
    let falseOrTrueTestImage = "toftest.png"
    let falseOrTrueTestIdentifier = "falseOrTrueTest"
    let falseOrTrueTestDescription = "You will need to determine if the proposed word is translated correctly."
    
    let findAnImageTestName = "Find an image test"
    let findAnImageTestImage = "fanitest.png"
    let findAnImageTestIdentifier = "findAnImageTest"
    let findAnImageTestDescription = "You will need to select correct image for a word meaning"
    
    //MARK: - Add word pop-up controller
    let enterBoothWords = "addWordPopUp_enterBothWords_message".localized
    let enterTranslation = "addWordPopUp_enterTranslation_message".localized
    let enterWord = "addWordPopUp_enterWord_message".localized
    let foundDoubles = "addWordPopUp_foundDoubles_message".localized
    
    //MARK: - Edit dictionary pop-up controller
    let warningMessage = "editDictionaryVC_nothingToChange_message".localized
    let noWordsInDictionary = "You can't share empty dictionary"
    let editDoneMessage = "editDictionaryVC_successSave_message".localized
    let noDicionaryNameMessage = "editDictionaryVC_dictionaryNameIsEmpty_message".localized
    
    //MARK: - Create dictionary pop-up controller
//    let language_1 = "defaults_langArray_1".localized
//    let language_2 = "defaults_langArray_2".localized
//    let language_3 = "defaults_langArray_3".localized
//    let language_4 = "defaults_langArray_4".localized
//    let language_5 = "defaults_langArray_5".localized
//    let language_6 = "defaults_langArray_6".localized
//    let language_7 = "defaults_langArray_7".localized
//    let language_8 = "defaults_langArray_8".localized
//    let language_9 = "defaults_langArray_9".localized
//    let language_10 = "defaults_langArray_10".localized
//    let language_11 = "defaults_langArray_11".localized
//    let language_12 = "defaults_langArray_12".localized
//    let language_13 = "defaults_langArray_13".localized
    let languagesKeysArray = ["DE", "EN", "ES", "FI", "FR", "IT", "LT", "LV", "PL", "PT", "RU", "SL", "UA"]
    
    let languagesVolumesArray = [
        "defaults_langArray_1".localized,
        "defaults_langArray_2".localized,
        "defaults_langArray_3".localized,
        "defaults_langArray_4".localized,
        "defaults_langArray_5".localized,
        "defaults_langArray_6".localized,
        "defaults_langArray_7".localized,
        "defaults_langArray_8".localized,
        "defaults_langArray_9".localized,
        "defaults_langArray_10".localized,
        "defaults_langArray_11".localized,
        "defaults_langArray_12".localized,
        "defaults_langArray_13".localized,
        ]
    let langArray = [
    LanguagesArray(lang: "DE", langValue: "defaults_langArray_1".localized),
    LanguagesArray(lang: "EN", langValue: "defaults_langArray_2".localized),
    LanguagesArray(lang: "ES", langValue: "defaults_langArray_3".localized),
    LanguagesArray(lang: "FI", langValue: "defaults_langArray_4".localized),
    LanguagesArray(lang: "FR", langValue: "defaults_langArray_5".localized),
    LanguagesArray(lang: "IT", langValue: "defaults_langArray_6".localized),
    LanguagesArray(lang: "LT", langValue: "defaults_langArray_7".localized),
    LanguagesArray(lang: "LV", langValue: "defaults_langArray_8".localized),
    LanguagesArray(lang: "PL", langValue: "defaults_langArray_9".localized),
    LanguagesArray(lang: "PT", langValue: "defaults_langArray_10".localized),
    LanguagesArray(lang: "RU", langValue: "defaults_langArray_11".localized),
    LanguagesArray(lang: "SL", langValue: "defaults_langArray_12".localized),
    LanguagesArray(lang: "UA", langValue: "defaults_langArray_13".localized)
    ]
    
    let warningDictionaryName = "createDictionaryPopUpVC_dictionary_warning".localized
    let warningSelectLanguages = "createDictionaryPopUpVC_sameLanguages_warning".localized
    let warningSameLanguages = "createDictionaryPopUpVC_noLanguages_warning".localized
    
    //MARK: - Delete dictionary pop-up controller
    let succDeleteMessage = "deleteDictionaryVC_succDelete_message".localized
    
    //MARK: - Browse dictionary controller
    let noWordsLabelText = "browseDictionaryVC_emptyDictionary_message".localized
    //MARK: - Profile view controller
    let intefaceLanguage_ru = "defaults_interfaceLanguage_ru".localized
    let intefaceLanguage_uk = "defaults_interfaceLanguage_uk".localized
    let intefaceLanguage_en = "defaults_interfaceLanguage_en".localized
    //MARK: - Change language pop-up controller
    let attention_message = "changeLanguagePopUp_attention_label".localized
    let currentLanguageDictionary = ["en":"defaults_interfaceLanguage_en".localized, "uk":"defaults_interfaceLanguage_uk".localized, "ru":"defaults_interfaceLanguage_ru".localized]
}
