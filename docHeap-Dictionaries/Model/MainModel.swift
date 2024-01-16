//
//  FiveWordsTestModel.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 30.05.23.
//

import Foundation
import CoreData
import Alamofire

struct MainModel{
    
    private var coreDataManager = CoreDataManager()
    
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
    
    func wordsStatusClearing(array:[Word], statusToClear:Int, data: NSManagedObjectContext){
        switch statusToClear{
        case 0:
            for i in 0..<array.count{
                array[i].wrdStatus = 0
            }
        case 1:
            for i in 0..<array.count{
                if  array[i].wrdStatus == 1 {
                    array[i].wrdStatus = 0
                }
            }
        case 2:
            for i in 0..<array.count{
                if  array[i].wrdStatus == 2 {
                    array[i].wrdStatus = 0
                }
            }
        default: break
        }
        coreDataManager.saveData(data: data)
    }
    
    func convertDateToString(currentDate:Date, time:Bool) ->String?{
        switch time{
        case true:
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
            let currentDateAndTime = formatter.string(from: currentDate)
            return currentDateAndTime
        case false:
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let currentDate = formatter.string(from: currentDate)
            return currentDate
        }
    }
    
    func convertCurrentDateToInt() ->Int{
       var currentDate = Date()
        let intDate = Int(currentDate.timeIntervalSince1970)
        return intDate
    }
    
    func commentWithState(minWordsCount: Int, isSetImage:Int)->String{
        switch isSetImage{
        case 0:
            var textComment: String {
                get{
                    return "In this dictionary less then \(minWordsCount) words! Please add words into it or select other dictionary"
                }
            }
            return textComment
        case 1:
            var textComment: String {
                get{
                    return "In this dictionary less then \(minWordsCount) words with saved images! Please add images for words or select other dictionary"
                }
            }
            return textComment
        default: break
        }
        return "no data"
    }
    
    
    func deleteFileInFolder(folderName: String, fileName: String) {
        let fileManager = FileManager.default
        if !fileName.isEmpty{
            do {
                let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let folderURL = documentsDirectory.appendingPathComponent(folderName)
                let fileURL = folderURL.appendingPathComponent(fileName)
                try fileManager.removeItem(at: fileURL)
            } catch {
                print("Error deleting file: \(error)")
            }
        } else {
            print("Empty file name!\n")
        }
    }
    
    func deleteFolderInDocuments(folderName: String) {
        let fileManager = FileManager.default
        do {
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let folderURL = documentsDirectory.appendingPathComponent(folderName)
            try fileManager.removeItem(at: folderURL)
        } catch {
            print("Error deleting folder: \(error)")
        }
    }
    
    func getDocumentsFolderPath()->URL{
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectoryURL
    }
    
    func relativeImagePath(dicID: String, imageName: String)->String{
        let imagePath = "\(loadUserData().userID)/\(dicID)/\(imageName)"
        let relativeImagePath = getDocumentsFolderPath().appendingPathComponent(imagePath).path
        return relativeImagePath
    }
    
    func spacesToUnderscores(value:String) ->String{
        return value.replacingOccurrences(of: " ", with: "_")
    }
    
    func createFolderInDocuments(withName folderName: String) {
        let fileManager = FileManager.default
        
        do {
            let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let folderURL = documentsDirectory.appendingPathComponent(folderName)
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating folder: \(error)")
        }
    }
    
    func loadUserData()->(email:String, signed:Bool, userID:String, accType:String, userName:String){
        let defaults = UserDefaults.standard
        var mail = String()
        var signed = Bool()
        var iD = String()
        var accType = String()
        var userName = String()
        if let userEmail = defaults.object(forKey: "userEmail") as? String{
            mail = userEmail
        }
        if let userID = defaults.object(forKey: "userID") as? String{
            iD = userID
        }
        if let keepSigned = defaults.object(forKey: "keepSigned") as? Bool{
            signed = keepSigned
        }
        if let atype = defaults.object(forKey: "accType") as? String{
            accType = atype
        }
        if let uName = defaults.object(forKey: "userName") as? String{
            userName = uName
        }
        return (email:mail, signed:signed, userID:iD, accType:accType,userName:userName)
    }
    
    func isUserFolderExist(folderName: String) -> Bool {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let subfolderURL = documentsDirectoryURL.appendingPathComponent(folderName)
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: subfolderURL.path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    func currentSystemLanguage()->String{
        var lang = String()
        if let languageCode = Locale.preferredLanguages.first {
            let components = Locale.components(fromIdentifier: languageCode)
            let languageOnly = components[NSLocale.Key.languageCode.rawValue]
            lang = languageOnly ?? "Language is not detected"
        }
        return lang
    }
    
    
    
    func renameDictionaryFolder(oldName: String, newName: String) {
        let oldFolderURL = getDocumentsFolderPath().appendingPathComponent("\(loadUserData().email)/\(oldName)")
        print("OLD PATH: \(oldFolderURL)\n")
        let newFolderURL = getDocumentsFolderPath().appendingPathComponent("\(loadUserData().email)/\(newName)")
        print("NEW PATH: \(newFolderURL)\n")
        do {
            try FileManager.default.moveItem(at: oldFolderURL, to: newFolderURL)
            print("Folder renamed\n")
        } catch {
            print("Renaming error: \(error.localizedDescription)")
        }
    }
    
    func uniqueIDgenerator(prefix:String)->String{
        let uniqueID = prefix + UUID().uuidString.components(separatedBy: "-").joined()
        return uniqueID
    }

//    func extractDictionaryStorageFolderURL(from imageURL: String) -> String? {
//        // Разделяем ссылку на составляющие
//        let components = imageURL.components(separatedBy: "%2F")
//
//        // Проверяем, достаточно ли компонентов
//        guard components.count >= 3 else {
//            return nil
//        }
//        print(components)
//        // Извлекаем базовый URL из переданной ссылки
//       // let baseURL = components.dropLast(2).joined(separator: "%2F")
//        let baseURL = components.first
//        let dictionaryFolderName = components[1]
//        // Собираем полный URL папки
//        let folderURL = "\(baseURL ?? "NO_BASE_URL")%2F\(dictionaryFolderName)"
//
//        return folderURL
//    }

//    func loggingNetworkProcesses(function:String, complete:Bool, context:NSManagedObjectContext){
//        let newLog = NetworkLog(context: context)
//        newLog.function = function
//        newLog.dateAndTime = convertDateToString(currentDate: Date(), time: true)
//        newLog.complete = complete
//        coreDataManager.saveData(data: context)
//    }
    func isInternetAvailable() -> Bool {
        let reachabilityManager = NetworkReachabilityManager()
        return reachabilityManager?.isReachable ?? false
    }
    
   
}







