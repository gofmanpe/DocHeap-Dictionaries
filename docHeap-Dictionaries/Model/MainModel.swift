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
        let newFolderURL = getDocumentsFolderPath().appendingPathComponent("\(loadUserData().email)/\(newName)")
        do {
            try FileManager.default.moveItem(at: oldFolderURL, to: newFolderURL)
        } catch {
            print("Renaming error: \(error.localizedDescription)")
        }
    }
    
    func uniqueIDgenerator(prefix:String)->String{
        let uniqueID = prefix + UUID().uuidString.components(separatedBy: "-").joined()
        return uniqueID
    }

    func isInternetAvailable() -> Bool {
        let reachabilityManager = NetworkReachabilityManager()
        return reachabilityManager?.isReachable ?? false
    }
    
   
}







