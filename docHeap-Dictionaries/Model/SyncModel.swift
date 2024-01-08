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
        let userData = coreData.loadUserDataByID(userID: userID, data: context) //get CoreData user data
        if !userData.userSyncronized{
            firebase.updateUserDataFirebase(userData: userData)
        } else {
            return
        }
    }
    
    func syncNetworkUsersDataWithFirebase(context:NSManagedObjectContext){
        // 1. get nuID from CoreData
        // 2. in loop, for each nuID get data from Firebase and update it in CoreData (exclude avatar path)
        // 3. check, if avatar path is not equals, download new avatar, and upddate it locally
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
                         let dicName = dictionaryData["dicName"] as? String
                         let dicID = dictionaryData["dicID"] as? String ?? "NO_DICID"
                         let dicLearningLang = dictionaryData["dicLearningLanguage"] as? String
                         let dicTranslateLang = dictionaryData["dicTranslateLanguage"] as? String
                         let dicAddDate = dictionaryData["dicAddDate"] as? String
                         let dicWordsCount = dictionaryData["dicWordsCount"] as? Int64
                         let dicImagesCount = dictionaryData["dicImagesCount"] as? Int64
                         let dicDescription = dictionaryData["dicDescription"] as? String
                         let dicShared = dictionaryData["dicShared"] as? Bool
                         self.mainModel.createFolderInDocuments(withName: "\(userID)/\(dicID)")
                             let dictionary = Dictionary(context: context)
                             dictionary.dicName = dicName
                             dictionary.dicLearningLanguage = dicLearningLang
                             dictionary.dicTranslateLanguage = dicTranslateLang
                             dictionary.dicAddDate = dicAddDate
                             dictionary.dicImagesCount = dicImagesCount ?? 0
                             dictionary.dicUserID = userID
                             dictionary.dicDescription = dicDescription
                             dictionary.dicID = dicID
                             dictionary.dicWordsCount = Int64(dicWordsCount!)
                             dictionary.dicDeleted = false
                             dictionary.dicSyncronized = true
                            dictionary.dicShared = dicShared ?? false
                            dictionary.dicReadOnly = false
                             coreData.saveData(data: context)
                         self.loadWordsFromFirestore(dicID: dicID, context: context)
                    }
                     
                 }
             }
         }
     }
    
    func loadWordsFromFirestore(dicID: String, context:NSManagedObjectContext) {
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
    
    func syncDictionariesCoreDataAndFirebase(userID: String, context:NSManagedObjectContext){
       let allDictionaries = coreData.loadAllUserDictionaries(userID: userID, data: context)
        let allUserDictionaries = allDictionaries.filter({$0.dicReadOnly == false})
        let unsyncDictionaries = allUserDictionaries.filter({$0.dicSyncronized == false})
        if !unsyncDictionaries.isEmpty{
            for unsyncDictionary in unsyncDictionaries {
                let dicID = unsyncDictionary.dicID!
                switch unsyncDictionary.dicReadOnly{ // start switch
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
