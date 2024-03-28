//
//  SyncModel.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 05.12.23.
//

import Foundation
import CoreData
import Firebase

struct SyncModel {
    private var coreData = CoreDataManager()
    private let firebase = Firebase()
    private let mainModel = MainModel()
    private let alamo = Alamo()
    private let fireDB = Firestore.firestore()
    
    
    func syncUserDataWithFirebase(userID:String, context:NSManagedObjectContext){
        guard let userData = coreData.loadUserDataByID(userID: userID, context: context) else {
            return
        }
            if !userData.userSyncronized{
                firebase.updateUserDataFirebase(userData: userData)
            } else {
                return
            }
        
    }
   
    func syncUserLikesForSharedDictionaries(userID:String, context:NSManagedObjectContext){
        let allRODictionaries = coreData.loadAllRODictionaries(userID: userID, context: context)
        let unsyncRODics = allRODictionaries.filter({$0.dicSyncronized == false})
        if !unsyncRODics.isEmpty{
            for dic in unsyncRODics{
                let dicID = dic.dicID ?? ""
                firebase.getLikesFromDictionary(dicID: dicID) { idsArray, error in
                    if let error = error{
                        print("Error to get likes data: \(error)")
                    } else {
                        if let result = idsArray{
                            if result.contains(self.mainModel.loadUserData().userID){
                                if !dic.dicLike{  //remove userID from dictionary Firebase
                                    firebase.setLikeForDictionaryFirebase(dicID: dicID, userID: mainModel.loadUserData().userID, like: false)
                                }
                            } else {
                                if dic.dicLike{ // add userID in dictionary Firebase
                                    firebase.setLikeForDictionaryFirebase(dicID: dicID, userID: mainModel.loadUserData().userID, like: true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func syncStatistic(userID:String, context:NSManagedObjectContext){
        let allUserStat = coreData.loadAllStatisticForUser(userID: mainModel.loadUserData().userID, context: context)
        let unSyncStat = allUserStat.filter({$0.statSyncronized == false})
        if !unSyncStat.isEmpty{
            for element in unSyncStat{
                firebase.createStatisticRecord(statData: element)
            }
        }
    }
    
    func syncMessages(coreDataMessages:[Comment]){
        let unsyncMessages = coreDataMessages.filter({$0.msgSyncronized == false})
        if !unsyncMessages.isEmpty{
            for message in unsyncMessages{
                firebase.createUnsynchronedMessage(
                    msgSenderID: message.msgSenderID,
                    msgDicID: message.msgDicID,
                    msgBody: message.msgBody,
                    msgID: message.msgID,
                    msgDateTime: message.msgDateTime,
                    msgOrdering: Int(message.msgOrdering),
                    msgSyncronized: true
                )
            }
        }
    }
    
    func syncNetworkUsersDataWithFirebase(context:NSManagedObjectContext){
        firebase.updateNetworkUsersDataInCoreData(context: context)
    }
    
    func syncWordsCoreDataAndFirebase(userID: String, context:NSManagedObjectContext){
       let allWords = coreData.loadAllWordsByUserID(userID: userID, data: context)
        let unsyncWords = allWords.filter({$0.wrdSyncronized == false})
        if !unsyncWords.isEmpty{
            for unsyWord in unsyncWords {
                let wrdID = unsyWord.wrdID ?? "NO_WRD_ID"
                switch unsyWord.wrdReadOnly{
                case false:
                    firebase.checkIsWordExistsInDictionary(wrdID: wrdID){ wordExist, error in
                        if let error = error {
                            print("Error reading wordds in Firebase: \(error)\n")
                        }
                        if wordExist{
                            if unsyWord.wrdDeleted{ // word was deleted in CoreData
                                firebase.deleteWordFromFirebase(wrdID: wrdID) // delete word from Firestore
                                coreData.deleteWordFromCoreData(wrdID: wrdID, context: context) // delete word from CoreData
                                context.delete(unsyWord)
                            } else { // word was changed in CoreData
                                // here update word filds in Firestore and set Sync = true for word in CoreData
                                let wrdWord = unsyWord.wrdWord ?? "NO_WORD"
                                let wrdTranslation = unsyWord.wrdTranslation ?? "NO_TRANSLATION"
                                let wrdImageName = unsyWord.imageName ?? ""
                                let wrdFirestoreImagePath = unsyWord.wrdImageFirestorePath ?? ""
                                fireDB.collection("Words").document(wrdID).updateData(
                                    ["wrdWord": wrdWord,
                                     "wrdTranslation": wrdTranslation,
                                     "wrdImageName": wrdImageName,
                                     "wrdImageFirestorePath" : wrdFirestoreImagePath
                                    ]
                                ) { error in
                                    if let error = error {
                                        print("FirebaseModel: Error updating word firlds in Firestore: \(error)\n")
                                    }
                                }
                                 self.coreData.setWasSynchronizedStatusForWord(data: context, wrdID: wrdID, sync: true)
                            }
                        } else { // word was not finded in Firebase
                            // here create word in Firebase, and set Sync = true for word in CoreData
                            let wrdWord = unsyWord.wrdWord ?? "NO_WORD"
                            let wrdTranslation = unsyWord.wrdTranslation ?? "NO_TRANSLATION"
                            let wrdImageName = unsyWord.imageName ?? ""
                            let wrdFirestoreImagePath = URL(string:unsyWord.wrdImageFirestorePath ?? "")
                            let wrdDicID = unsyWord.wrdDicID!
                            let wrdAddDate = unsyWord.wrdAddDate!
                            let wrdUserID = unsyWord.wrdUserID!
                            firebase.createWord(wrdUserID: wrdUserID, wrdDicID: wrdDicID, wrdWord: wrdWord, wrdTanslation: wrdTranslation, wrdImageName: wrdImageName, wrdID: wrdID, wrdAddDate: wrdAddDate, wrdImageFirestorePath: wrdFirestoreImagePath)
                            coreData.setWasSynchronizedStatusForWord(data: context, wrdID: wrdID, sync: true)
                        }
                    }
                case true:
                    if unsyWord.wrdDeleted{ // word was deleted in CoreData
                        coreData.deleteWordFromCoreData(wrdID: wrdID, context: context) // delete word from CoreData
                        context.delete(unsyWord)
                    }
                }
                
            }
        }
    }
    
    func loadDictionariesFromFirebase(userID:String, context:NSManagedObjectContext){
         firebase.getAllDictionaries(forUser: userID) { allDictionaries, error in
             if let allDictionaries = allDictionaries{
                 for dictionary in allDictionaries {
                     if let dictionaryData = dictionary.value as? [String: Any] {
                         let dicID = dictionaryData["dicID"] as! String
                         let dicForSave = LocalDictionary(
                            dicID: dicID,
                            dicCommentsOn: dictionaryData["dicCommentsOn"] as! Bool,
                            dicDeleted: false,
                            dicDescription: dictionaryData["dicDescription"] as? String ?? "",
                            dicAddDate: dictionaryData["dicAddDate"] as! String,
                            dicImagesCount: dictionaryData["dicImagesCount"] as? Int ?? 0,
                            dicLearningLanguage: dictionaryData["dicLearningLanguage"] as! String,
                            dicTranslateLanguage: dictionaryData["dicTranslateLanguage"] as! String,
                            dicLike: false,
                            dicName: dictionaryData["dicName"] as? String ?? "",
                            dicOwnerID: "",
                            dicReadOnly: false,
                            dicShared: dictionaryData["dicShared"] as! Bool,
                            dicSyncronized: true,
                            dicUserID: dictionaryData["dicUserID"] as! String,
                            dicWordsCount: dictionaryData["dicWordsCount"] as? Int ?? 0)
                         coreData.createDictionary(dictionary: dicForSave, context: context)
                         self.mainModel.createFolderInDocuments(withName: "\(dicForSave.dicUserID)/\(dicID)")
                         self.loadWordsFromFirebase(dicID: dicID, context: context)
                    }
                     
                 }
             }
         }
     }
    
    func loadWordsFromFirebase(dicID: String, context:NSManagedObjectContext) {
        fireDB.collection("Words").whereField("wrdDicID", isEqualTo: dicID).getDocuments { (querySnapshot, error) in
             if let error = error {
                 
                 print("Error getting words: \(error.localizedDescription)")
                 return
             }
             guard let documents = querySnapshot?.documents else {
                 print("No words found")
                 return
             }
             for document in documents {
                 let wordData = document.data()
                 let wrdWord = wordData["wrdWord"] as? String
                 let wrdTranslation = wordData["wrdTranslation"] as? String
                 let wrdAddDate = wordData["wrdAddDate"] as? String
                 let wrdDicID = wordData["wrdDicID"] as? String  ?? "NO_DIC"
                 let wrdImageName = wordData["wrdImageName"] as? String ?? "NO_IMAGE"
                 let wrdUserID = wordData["wrdUserID"] as? String ?? "NO_USER_ID"
                 let wrdID = wordData["wrdID"] as! String
                 let wrdImageFirestorePath = wordData["wrdImageFirestorePath"] as? String ?? ""
                 let parentDictionary = self.coreData.loadParentDictionaryForWord(dicID: wrdDicID,  data: context).first
                 let loadedWord = Word(context: context)
                 loadedWord.wrdWord = wrdWord
                 loadedWord.wrdTranslation = wrdTranslation
                 loadedWord.wrdAddDate = wrdAddDate
                 loadedWord.imageName = wrdImageName
                 loadedWord.wrdBobbleColor = ".yellow"
                 loadedWord.wrdStatus = 0
                 loadedWord.wrdWrongAnswers = 0
                 loadedWord.wrdRightAnswers = 0
                 loadedWord.wrdID = wrdID
                 loadedWord.wrdDicID = wrdDicID
                 loadedWord.wrdUserID = wrdUserID
                 loadedWord.parentDictionary = parentDictionary
                 if wrdImageFirestorePath != "" {
                     self.alamo.downloadAndSaveImage(fromURL: wrdImageFirestorePath, userID: wrdUserID, dicID: wrdDicID, imageName: wrdImageName) {}
                     loadedWord.wrdImageFirestorePath = wrdImageFirestorePath
                     loadedWord.wrdImageIsSet = true
                 } else {
                     loadedWord.wrdImageFirestorePath = ""
                     loadedWord.wrdImageIsSet = false
                 }
                 self.coreData.saveData(data: context)
                 }
         }
     }
    
    func loadStatisticFromFirebase(userID:String, context:NSManagedObjectContext){
        firebase.getStatisticByUserID(userID: userID) { loadedUserStatistic, error in
            if let error = error{
                print("Error to load user statistic: \(error)")
            } else {
                if let stat = loadedUserStatistic{
                    for element in stat{
                        coreData.createStatisticRecord(statisticData: element, context: context)
                    }
                }
            }
        }
    }
    
    func syncDownloadedDictionariesData(userID:String, context:NSManagedObjectContext){
        let allDictionaries = coreData.getAllUserDictionaries(userID: userID, data: context)
        let allDownloadedDictionaries = allDictionaries.filter({$0.dicReadOnly == true}).filter({$0.dicDeleted == false})
        if !allDownloadedDictionaries.isEmpty{
            for dictionary in allDownloadedDictionaries{
                firebase.checkIsDictionaryExistAndShared(dicID: dictionary.dicID) { dicExist, dicShared, error  in
                    if let error = error{
                        print("Error to get dictionary from Firebase: \(error)\n")
                    } else {
                        switch (dicExist,dicShared){
                        case (true,true):
                            firebase.getSharedDictionaryData(dicID: dictionary.dicID) { sharedDictionary, error in
                                if let error = error{
                                    print("Error to get dhared dcitionary from Firebase: \(error)\n")
                                } else {
                                    if dictionary.dicName != sharedDictionary?.dicName{
                                        coreData.updateDownloadedDictionaryData(dicID: dictionary.dicID, userID: mainModel.loadUserData().userID, field: "dicName", argument: sharedDictionary!.dicName as String, context: context)
                                    }
                                    if dictionary.dicDescription != sharedDictionary?.dicDescription{
                                        coreData.updateDownloadedDictionaryData(dicID: dictionary.dicID, userID: mainModel.loadUserData().userID, field: "dicDescription", argument: sharedDictionary!.dicDescription as String, context: context)
                                    }
                                    if dictionary.dicCommentsOn != sharedDictionary?.dicCommentsOn{
                                        coreData.updateDownloadedDictionaryData(dicID: dictionary.dicID, userID: mainModel.loadUserData().userID, field: "dicCommentsOn", argument: sharedDictionary!.dicCommentsOn as Bool, context: context)
                                    }
                                    if dictionary.dicWordsCount != sharedDictionary?.dicWordsCount{
                                        coreData.updateDownloadedDictionaryData(dicID: dictionary.dicID, userID: mainModel.loadUserData().userID, field: "dicWordsCount", argument: sharedDictionary!.dicWordsCount as Int, context: context)
                                        syncWordsForDownloadedDictionary(dicID: dictionary.dicID, context: context)
                                    } else {
                                        if dictionary.dicImagesCount != sharedDictionary?.dicImagesCount{
                                            coreData.updateDownloadedDictionaryData(dicID: dictionary.dicID, userID: mainModel.loadUserData().userID, field: "dicImagesCount", argument: sharedDictionary!.dicImagesCount as Int, context: context)
                                            syncWordsForDownloadedDictionary(dicID: dictionary.dicID, context: context)
                                        } else {
                                            syncWordsForDownloadedDictionary(dicID: dictionary.dicID, context: context)
                                        }
                                    }
                                }
                            }
                        case (true,false):
                            mainModel.deleteFolderInDocuments(folderName: "\(mainModel.loadUserData().userID)/\(dictionary.dicID)")
                            coreData.delWordsFromDictionaryByDicID(dicID: dictionary.dicID, userID: mainModel.loadUserData().userID, context: context)
                            coreData.deleteRODictionaryFromCoreData(dicID: dictionary.dicID, userID: mainModel.loadUserData().userID, context: context)
                            coreData.deleteMessagesFromCoreData(dicID: dictionary.dicID, context: context)
                        case (false,true),(false,false):
                            coreData.updateDownloadedDictionaryData(dicID: dictionary.dicID, userID: mainModel.loadUserData().userID, field: "dicDeleted", argument: true, context: context)
                        }
                    }
                }
            }
        }
    }
    
    func syncWordsForDownloadedDictionary(dicID:String, context:NSManagedObjectContext){
        let allDictionaryWordsFromCoreData = coreData.getAllWordsForDownloadedDictionary(userID: mainModel.loadUserData().userID, dicID: dicID, context: context)
        firebase.getDownloadedWordsData(dicID: dicID) { sharedWordsArray, error in
            if let error = error{
                print("Error to get shared words for dictionary: \(error)\n")
            } else {
                guard let sharedWords = sharedWordsArray else {
                    return
                }
                for word in sharedWords{
                    let checkIsWordExistInCoreData = allDictionaryWordsFromCoreData.filter({$0.wrdID == word.wrdID})
                    if checkIsWordExistInCoreData.isEmpty{
                        let newWorsPair = WordsPair(
                            wrdWord: word.wrdWord,
                            wrdTranslation: word.wrdTranslation,
                            wrdDicID: word.wrdDicID,
                            wrdUserID: mainModel.loadUserData().userID,
                            wrdID: word.wrdID,
                            wrdImageFirestorePath: word.wrdImageFirestorePath,
                            wrdImageName: word.wrdImageName,
                            wrdReadOnly: true,
                            wrdParentDictionary: coreData.getParentDictionaryData(dicID: word.wrdDicID, userID: mainModel.loadUserData().userID, context: context),
                            wrdAddDate: mainModel.convertDateToString(currentDate: Date(), time: false)!)
                        coreData.createWordsPair(wordsPair: newWorsPair, context: context)
                    } else {
                        let coreDataWordsPair = checkIsWordExistInCoreData.first
                        if coreDataWordsPair?.wrdWord != word.wrdWord{
                            coreData.updateDownloadedWordData(wrdID: coreDataWordsPair!.wrdID, userID: mainModel.loadUserData().userID, field: "wrdWord", argument: word.wrdWord, context: context)
                        }
                        if coreDataWordsPair?.wrdTranslation != word.wrdTranslation{
                            coreData.updateDownloadedWordData(wrdID: coreDataWordsPair!.wrdID, userID: mainModel.loadUserData().userID, field: "wrdTranslation", argument: word.wrdTranslation, context: context)
                        }
                        if coreDataWordsPair?.wrdImageFirestorePath != word.wrdImageFirestorePath{
                            if !word.wrdImageFirestorePath.isEmpty{
                                coreData.updateDownloadedWordData(wrdID: coreDataWordsPair!.wrdID, userID: mainModel.loadUserData().userID, field: "wrdImageFirestorePath", argument: word.wrdImageFirestorePath, context: context)
                                coreData.updateDownloadedWordData(wrdID: coreDataWordsPair!.wrdID, userID: mainModel.loadUserData().userID, field: "imageName", argument: word.wrdImageName, context: context)
                                coreData.updateDownloadedWordData(wrdID: coreDataWordsPair!.wrdID, userID: mainModel.loadUserData().userID, field: "wrdImageIsSet", argument: true, context: context)
                                alamo.downloadAndSaveImage(
                                    fromURL: word.wrdImageFirestorePath,
                                    userID: coreDataWordsPair!.wrdUserID,
                                    dicID: word.wrdDicID,
                                    imageName: word.wrdImageName) {}
                            } else {
                                coreData.updateDownloadedWordData(wrdID: coreDataWordsPair!.wrdID, userID: mainModel.loadUserData().userID, field: "wrdImageFirestorePath", argument: "" as String, context: context)
                                coreData.updateDownloadedWordData(wrdID: coreDataWordsPair!.wrdID, userID: mainModel.loadUserData().userID, field: "imageName", argument: "" as String, context: context)
                                coreData.updateDownloadedWordData(wrdID: coreDataWordsPair!.wrdID, userID: mainModel.loadUserData().userID, field: "wrdImageIsSet", argument: false, context: context)
                            }
                        }
                    }
                }
                for word in allDictionaryWordsFromCoreData{
                    let wordExistInFirebase = sharedWords.filter({$0.wrdID == word.wrdID})
                    if wordExistInFirebase.isEmpty{
                        coreData.deleteDownloadedWordFromCoreData(wrdID: word.wrdID, context: context)
                    }
                }
            }
        }
    }
    
    func syncDictionariesCoreDataAndFirebase(userID: String, context:NSManagedObjectContext){
//TODO: - check, if local RO dictionary is apsent in Firebase, delete it in CoreData
       let allDictionaries = coreData.loadAllUserDictionaries(userID: userID, data: context)
        let allUserDictionaries = allDictionaries.filter({$0.dicReadOnly == false})
        let unsyncDictionaries = allUserDictionaries.filter({$0.dicSyncronized == false})
        if !unsyncDictionaries.isEmpty{
            for unsyncDictionary in unsyncDictionaries {
                let dicID = unsyncDictionary.dicID!
                switch unsyncDictionary.dicReadOnly{
                case false:
                    firebase.checkIsExistsDictionary(dicID: dicID){ dictionaryExist, error in
                        if let error = error {
                            print("Error reading wordds in Firebase: \(error)\n")
                        }
                        if dictionaryExist{
                            if unsyncDictionary.dicDeleted{ // dictionary was deleted in CoreData
                                firebase.deleteDictionaryFirebase(dicID: dicID) { error in
                                    if let error = error {
                                        print("Error deleting dictionary from Firebase: \(error)\n")
                                    }
                                }
                                coreData.deleteDictionaryFromCoreData(dicID: dicID, userID: mainModel.loadUserData().userID, context: context)
                                context.delete(unsyncDictionary)
    //TODO: - Delete all images in dictionary Firestore folder
                            } else { // dictionary was changed in CoreData
                                // here update dictionary filds in Firestore and set Sync = true for dictionary in CoreData
                                let dicName = unsyncDictionary.dicName ?? "NO_DIC_NAME"
                                let dicDescription = unsyncDictionary.dicDescription ?? "NO_DIC_DESCRIPTION"
                                let dicWordsCount = unsyncDictionary.dicWordsCount
                                let dicImagesCount = unsyncDictionary.dicImagesCount
                                fireDB.collection("Dictionaries").document(dicID).updateData(
                                    ["dicName": dicName,
                                     "dicDescription": dicDescription,
                                     "dicWordsCount": dicWordsCount,
                                     "dicImagesCount" : dicImagesCount
                                    ]
                                ) { error in
                                    if let error = error {
                                        print("FirebaseModel: Error updating word firlds in Firestore: \(error)\n")
                                    }
                                }
                                 self.coreData.setSyncronizedStatusForDictionary(data: context, dicID: dicID, sync: true)
                            }
                        } else { // dictionary was not finded in Firebase
                            // here create dictionary in Firebase, and set Sync = true for word in CoreData
                            let dicID = unsyncDictionary.dicID!
                            let dicName = unsyncDictionary.dicName!
                            let dicUserID = unsyncDictionary.dicUserID!
                            let dicLearnigLang = unsyncDictionary.dicLearningLanguage!
                            let dicTranslateLang = unsyncDictionary.dicTranslateLanguage!
                            let dicDescription = unsyncDictionary.dicDescription ?? ""
                            let dicWordsCount = unsyncDictionary.dicWordsCount
                            let dicImagesCount = unsyncDictionary.dicImagesCount
                            let dicAddDate = unsyncDictionary.dicAddDate
                            let dicShared = unsyncDictionary.dicShared
                            firebase.createDictionary(dicName: dicName, dicUserID: dicUserID, dicLearningLang: dicLearnigLang, dicTranslationLang: dicTranslateLang, dicDescription: dicDescription, dicWordsCount: Int(dicWordsCount), dicID: dicID, dicImagesCount: Int(dicImagesCount), dicAddDate: dicAddDate, dicShared: dicShared)
                            coreData.setSyncronizedStatusForDictionary(data: context, dicID: dicID, sync: true)
                        }
                    }
                case true:
                    firebase.setDictionaryDownloadedByUserUser(dicID: dicID, remove: true)
                    coreData.delWordsFromDictionaryByDicID(dicID: dicID, userID: mainModel.loadUserData().userID, context: context)
                    coreData.deleteRODictionaryFromCoreData(dicID: dicID, userID: mainModel.loadUserData().userID, context: context)
                    coreData.saveData(data: context)
                } // end switch
            }
        }
    }
    
   
}
