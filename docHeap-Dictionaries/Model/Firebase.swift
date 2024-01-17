//
//  fireBase.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 12.11.23.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import CoreData

struct Firebase {
    private let fireDB = Firestore.firestore()
    private let mainModel = MainModel()
    private let coreDataManager = CoreDataManager()
    private let alamo = Alamo()
    private let defaults = Defaults()
//MARK: - Create functions
    func createUser(userID:String, userEmail: String, userName: String, userInterfaceLanguage:String, userAvatarFirestorePath:URL?, accType:String) {
        let date = mainModel.convertDateToString(currentDate: Date(), time: false)
        var data: [String: Any] = [
            "userID" : userID,
            "userEmail": userEmail,
            "userName": userName,
            "userRegisterDate": date!,
            "userInterfaceLanguage": userInterfaceLanguage,
            "accountType": accType,
            "userCountry": "",
            "userBirthDate": "",
            "userNativeLanguage": "",
            "userScores": 0,
            "userShowEmail": false
        ]
        if userAvatarFirestorePath != nil {
            data["userAvatarFirestorePath"] = userAvatarFirestorePath?.absoluteString
        } else {
            data["userAvatarFirestorePath"] = defaults.emptyAvatarPath
        }
        fireDB.collection("Users").document(userID).setData(data) { (error) in
            if let err = error{
                print("FirebaseModel: Error to saving data: \(err)")
                
            }
        }
    }
    
    func createDictionary(dicName:String, dicUserID:String, dicLearningLang:String, dicTranslationLang:String, dicDescription:String, dicWordsCount:Int, dicID:String, dicImagesCount:Int, dicAddDate:String?, dicShared:Bool) {
        var date = String()
        if let dateSet = dicAddDate{
            date = dateSet
        } else {
            date = mainModel.convertDateToString(currentDate: Date(), time: false)!
        }
        fireDB.collection("Dictionaries").document(dicID).setData([
            "dicName": dicName,
            "dicUserID": dicUserID,
            "dicAddDate": date,
            "dicLearningLanguage": dicLearningLang,
            "dicTranslateLanguage": dicTranslationLang,
            "dicDescription": dicDescription,
            "dicWordsCount": dicWordsCount,
            "dicID": dicID,
            "dicImagesCount": dicImagesCount,
            "dicDeleted": false,
            "dicSyncronized": true,
            "dicShared" : dicShared,
            "dicDownloadedUsers": [],
            "dicLikes": []
        ]) { (error) in
            if let err = error{
                
                print("FirebaseModel: Error to saving data: \(err)")
            } else {
                
                print("FirebaseModel: Firebase: Dictionary succesfuly created!\n")
            }
        }
    }
    
    func createWord(wrdUserID: String, wrdDicID: String, wrdWord: String, wrdTanslation: String, wrdImageName:String, wrdID:String, wrdAddDate:String?, wrdImageFirestorePath:URL?) {
        var data : [String:Any] = [
            "wrdWord": wrdWord,
            "wrdTranslation": wrdTanslation,
            "wrdID": wrdID,
            "wrdRightAnswers": 0,
            "wrdWrongAnswers": 0,
            "wrdDicID": wrdDicID,
            "wrdUserID": wrdUserID,
            "wrdImageName": wrdImageName
        ]
       
        if wrdAddDate == nil {
            data["wrdAddDate"] = mainModel.convertDateToString(currentDate: Date(), time: false) ?? ""
        } else {
            data["wrdAddDate"] = wrdAddDate
        }
        if let wrdImageFirestorePath = wrdImageFirestorePath {
            data["wrdImageFirestorePath"] = wrdImageFirestorePath.absoluteString
        } else {
            data["wrdImageFirestorePath"] = ""
        }
        fireDB.collection("Words").document(wrdID).setData(data) { (error) in
            if let err = error{
                
                print("FirebaseModel: Error to saving data: \(err)")
            } else {
                
                print("FirebaseModel: Firebase: Word succesfuly created!\n")
            }
        }
    }
    
    func createMessage(msgSenderID:String, msgDicID: String, msgBody: String, msgID: String, replayTo:String?) {
        let date = mainModel.convertDateToString(currentDate: Date(), time: true)
        var data: [String: Any] = [
            "msgSenderID" : msgSenderID,
            "msgDicID": msgDicID,
            "msgBody": msgBody,
            "msgID": msgID,
            "msgDateTime": date!,
            "msgSyncronized": true,
            "msgOrdering": mainModel.convertCurrentDateToInt()
        ]
        if let replayTo = replayTo{
            data["msgReplayTo"] = replayTo
        }
        fireDB.collection("Messages").document(msgID).setData(data) { (error) in
            if let err = error{
                print("FirebaseModel: Error to saving data: \(err)")
            }
        }
    }
    
    func createStatisticRecord(statData:StatisticData) {
        let data: [String: Any] = [
            "statID" : statData.statID,
            "statDate": statData.statDate,
            "statMistakes": statData.statMistekes,
            "statDicID": statData.statDicID,
            "statScores": statData.statScores,
            "statUserID": statData.statUserID,
            "statTestIdentifier": statData.statTestIdentifier,
            "statRightAnswers": statData.statRightAnswers
        ]
        fireDB.collection("Statistic").document(statData.statID).setData(data) { (error) in
            if let err = error{
                print("FirebaseModel: Error to saving data: \(err)")
            }
        }
    }
    
    func createUnsynchronedMessage(msgSenderID:String, msgDicID: String, msgBody: String, msgID: String, msgDateTime:String, msgOrdering:Int, msgSyncronized:Bool) {
        let data: [String: Any] = [
            "msgSenderID" : msgSenderID,
            "msgDicID": msgDicID,
            "msgBody": msgBody,
            "msgID": msgID,
            "msgDateTime": msgDateTime,
            "msgOrdering": msgOrdering,
            "msgSyncronized": msgSyncronized
        ]
        fireDB.collection("Messages").document(msgID).setData(data) { (error) in
            if let err = error{
                print("FirebaseModel: Error to saving data: \(err)")
            }
        }
    }
 
    
//MARK: - Read functions
    func getUserDataByEmail(userEmail: String, completion: @escaping ([String: Any]?) -> Void) {
        fireDB.collection("Users").whereField("userEmail", isEqualTo: userEmail).getDocuments { (querySnapshot, error) in
            if error != nil {
                completion(nil)
            } else {
                guard let document = querySnapshot?.documents.first else {
                    completion(nil)
                    return
                }
                let userData = document.data()
                completion(userData)
            }
        }
    }
    
   
    
    func createNetworkUsersInCoreData(userID: String, context: NSManagedObjectContext) {
        fireDB.collection("Users").whereField("userID", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error to get user data: \(error)\n")
            } else {
                for document in querySnapshot!.documents {
                    let userData = document.data()
                    let userID = userData["userID"] as! String
                    let userName = userData["userName"] as? String ?? ""
                    let userBirthDate = userData["userBirthDate"] as? String ?? ""
                    let userCountry = userData["userCountry"] as? String ?? ""
                    let userNativeLanguage = userData["userNativeLanguage"] as? String ?? ""
                    let userEmail = userData["userEmail"] as? String ?? ""
                    let userScores = userData["userScores"] as? Int ?? 0
                    let userRegisterDate = userData["userRegisterDate"] as! String
                    let userAvatarFirestorePath = userData["userAvatarFirestorePath"] as! String
                    let userShowEmail = userData["userShowEmail"] as! Bool
                    let result = NetworkUserData(
                        userID: userID,
                        userName: userName,
                        userCountry: userCountry,
                        userNativeLanguage: userNativeLanguage,
                        userBirthDate: userBirthDate,
                        userRegisterDate: userRegisterDate,
                        userAvatarFirestorePath: userAvatarFirestorePath,
                        userShowEmail: userShowEmail,
                        userEmail: userEmail,
                        userScores: userScores)
                    coreDataManager.createNetworkUser(userData: result, context: context)
                    alamo.downloadChatUserAvatar(url: userAvatarFirestorePath, senderID: userID, userID: self.mainModel.loadUserData().userID) { avatarName in
                        self.coreDataManager.updateNetworkUserLocalAvatarName(userID: userID, avatarName: avatarName, context: context)
                    }
                }
            }
        }
    }
    
    func checkUserExistsInFirebase(userEmail: String, completion: @escaping (Bool) -> Void) {
        fireDB.collection("Users").whereField("userEmail", isEqualTo: userEmail).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching user documents: \(error.localizedDescription)")
                completion(false)
                return
            }
            if let documents = snapshot?.documents, !documents.isEmpty {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func getDictionaryShortData(completion: @escaping ([SharedDictionaryShortData]?) -> Void) {
        fireDB.collection("Dictionaries").whereField("dicShared", isEqualTo: true).getDocuments { (querySnapshot, error) in
            if error != nil {
                completion(nil)
            } else {
                guard let document = querySnapshot?.documents.first else {
                    completion(nil)
                    return
                }
                let dictionaryData = document.data()
                 let dictionaryName = dictionaryData["dicName"] as! String
                 let dicID = dictionaryData["dicID"] as! String
                 let dicLikes = dictionaryData["dicLikes"] as? [String] ?? [String]()
                 let dicArray = [SharedDictionaryShortData(dicID: dicID, dicName: dictionaryName, dicLikes: dicLikes)]
                completion(dicArray)
            }
        }
    }
    
    func getWordDataFromFirebase(wordID:String, completion: @escaping ([String: Any]?) -> Void) {
        fireDB.collection("Words").whereField("wrdID", isEqualTo: wordID).getDocuments { (querySnapshot, error) in
            if error != nil {
                completion(nil)
            } else {
                guard let document = querySnapshot?.documents.first else {
                    completion(nil)
                    return
                }
                let wordData = document.data()
                let convertedData = [
                    "wrdDicID": wordData["wrdDicID"] as! String,
                    "wrdID" : wordData["wrdID"] as! String,
                    "wrdImageName" : wordData["wrdImageName"] as! String,
                    "wrdAddDate": wordData["wrdAddDate"] as! String,
                    "wrdWord" : wordData["wrdWord"] as! String,
                    "wrdTranslation" : wordData["wrdTranslation"] as! String,
                    "wrdUserID" : wordData["wrdUserID"] as! String
                ]
                completion(convertedData)
            }
        }
    }
    
    func getAllDictionaries(forUser userID: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        fireDB.collection("Dictionaries").whereField("dicUserID", isEqualTo: userID).whereField("dicDeleted", isEqualTo: false).getDocuments { (querySnapshot, error) in
            if let error = error {
                      completion(nil, error)
                  } else {
                      var allDictionaries: [String: Any] = [:]

                      for document in querySnapshot!.documents {
                          let dictionaryData = document.data()
                          let dictionaryID = document.documentID
                          allDictionaries[dictionaryID] = dictionaryData
                      }

                      completion(allDictionaries, nil)
                  }
        }
    }
    
    func getAllSharedDictionaries( completion: @escaping ([String: Any]?, Error?) -> Void) {
        fireDB.collection("Dictionaries").whereField("dicShared", isEqualTo: true).getDocuments { (querySnapshot, error) in
            if let error = error {
                      completion(nil, error)
                  } else {
                      var allDictionaries: [String: Any] = [:]

                      for document in querySnapshot!.documents {
                          let dictionaryData = document.data()
                          let dictionaryID = document.documentID
                          allDictionaries[dictionaryID] = dictionaryData
                      }

                      completion(allDictionaries, nil)
                  }
        }
    }
    
    func getSharedDictionaryData( dicID:String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        fireDB.collection("Dictionaries").whereField("dicID", isEqualTo: dicID).getDocuments { (querySnapshot, error) in
            if let error = error {
                      completion(nil, error)
                  } else {
                      var allDictionaries: [String: Any] = [:]

                      for document in querySnapshot!.documents {
                          let dictionaryData = document.data()
                          let dictionaryID = document.documentID
                          allDictionaries[dictionaryID] = dictionaryData
                      }

                      completion(allDictionaries, nil)
                  }
        }
    }
    
    func getNewMessagesForDictionary1(dicID:String, context:NSManagedObjectContext, completion: @escaping ([ChatMessage]?, [ChatMessage]?, Error?) -> Void) {
        fireDB.collection("Messages").whereField("msgDicID", isEqualTo: dicID).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error getting messages: \(error)\n")
                completion(nil, [ChatMessage](), error)
            } else {
                var newMessages = [ChatMessage]()
                var coreDataMessages = [ChatMessage]()
                for document in querySnapshot!.documents {
                    let messageData = document.data()
                    let msgID = messageData["msgID"] as? String ?? ""
                    coreDataMessages = coreDataManager.getMessagesByDicID(dicID: dicID, context: context)
                    let messageForCheck = coreDataMessages.filter({$0.msgID == msgID})
                    switch messageForCheck.isEmpty{
                        case true:
                            if let msgBody = messageData["msgBody"] as? String,
                               let msgDateTime = messageData["msgDateTime"] as? String,
                               let msgDicID = messageData["msgDicID"] as? String,
                               let msgSenderID = messageData["msgSenderID"] as? String,
                               let msgSyncronized = messageData["msgSyncronized"] as? Bool,
                               let msgOrdering = messageData["msgOrdering"] as? Int{
                                let newMessage = ChatMessage(
                                        msgID: msgID,
                                        msgBody: msgBody,
                                        msgDateTime: msgDateTime,
                                        msgDicID: msgDicID,
                                        msgSenderID: msgSenderID,
                                        msgOrdering: msgOrdering,
                                        msgSyncronized: msgSyncronized)
                                newMessages.append(newMessage)
                                }
                        case false:
                              continue
                    }
                }
                print("Firebase: newMessages count is: \(newMessages.count)\n")
                completion(newMessages, coreDataMessages, nil)
            }
        }
    }
    
    func loadMessagesForDictionary(dicID:String, context:NSManagedObjectContext, completion: @escaping ([ChatMessage]?, Error?) -> Void){
        fireDB.collection("Messages").whereField("msgDicID", isEqualTo: dicID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting messages: \(error)\n")
                completion(nil, error)
            } else {
                var messagesArray = [ChatMessage]()
                for document in querySnapshot!.documents {
                    let messageData = document.data()
                    if let msgBody = messageData["msgBody"] as? String,
                       let msgID = messageData["msgID"] as? String,
                       let msgDateTime = messageData["msgDateTime"] as? String,
                       let msgDicID = messageData["msgDicID"] as? String,
                       let msgSenderID = messageData["msgSenderID"] as? String,
                       let msgSyncronized = messageData["msgSyncronized"] as? Bool,
                       let msgOrdering = messageData["msgOrdering"] as? Int{
                        let message = ChatMessage(
                                msgID: msgID,
                                msgBody: msgBody,
                                msgDateTime: msgDateTime,
                                msgDicID: msgDicID,
                                msgSenderID: msgSenderID,
                                msgOrdering: msgOrdering,
                                msgSyncronized: msgSyncronized)
                        messagesArray.append(message)
                        }
                }
                completion(messagesArray, nil)
            }
        }
    }
    
    func getUserNameByID(userID: String, completion: @escaping (String, Error?) -> Void) {
        fireDB.collection("Users").whereField("userID", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting messages: \(error)\n")
                completion(String(), error)
            } else {
                guard let document = querySnapshot?.documents.first else {
                    completion(String(), error)
                    return
                }
                let userData = document.data()
                let userName = userData["userName"] as? String ?? "Anonimus"
                completion(userName, nil)
            }
        }
    }
    
    func getStatisticByUserID(userID: String, completion: @escaping ([StatisticData]?, Error?) -> Void){
        fireDB.collection("Statistic").whereField("statUserID", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting messages: \(error)\n")
                completion(nil, error)
            } else {
                var statisticData = [StatisticData]()
                for document in querySnapshot!.documents{
                    let statData = document.data()
                    let statID = statData["statID"] as? String ?? ""
                    let statDate = statData["statDate"] as? String ?? ""
                    let statMistakes = statData["statMistakes"] as? Int ?? 0
                    let statDicID = statData["statDicID"] as? String ?? ""
                    let statScores = statData["statScores"] as? Int ?? 0
                    let statRightAnswers = statData["statRightAnswers"] as? Int ?? 0
                    let statUserID = statData["statUserID"] as? String ?? ""
                    let statTestIdentifier = statData["statTestIdentifier"] as? String ?? ""
                    let statElement = StatisticData(
                        statID: statID,
                        statDate: statDate,
                        statMistekes: statMistakes,
                        statDicID: statDicID,
                        statScores: statScores,
                        statUserID: statUserID,
                        statTestIdentifier: statTestIdentifier,
                        statRightAnswers: statRightAnswers,
                        statSyncronized: true)
                    statisticData.append(statElement)
                }
                completion(statisticData,nil)
            }
        }
    }
    
    func getDictionariesOwnersArray(sharedDictionariesArray: [SharedDictionary], completion: @escaping ([DicOwnerData]?) -> Void) {
        var dicOwnersData = [DicOwnerData]()
        for user in sharedDictionariesArray {
            let userID = user.dicUserID
            fireDB.collection("Users").whereField("userID", isEqualTo: userID).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }
                guard let document = querySnapshot?.documents.first else {
                    return
                }
                let userData = document.data()
                let ownerName = userData["userName"] as? String ?? ""
                let data = DicOwnerData(ownerName: ownerName, ownerID: userID)
                dicOwnersData.append(data)
            }
        }
        completion(dicOwnersData)
    }
    
    func createNetworkUsersData(dicID:String, context:NSManagedObjectContext){
        fireDB.collection("Messages")
            .whereField("msgDicID", isEqualTo: dicID)
            .whereField("msgSenderID", isNotEqualTo: mainModel.loadUserData().userID)
            .getDocuments { (querySnapshot, error) in
            if let error = error {
                     print("Error getting messages: \(error)")
                  } else {
                      var messagesUsersSet = Set<String>()
                      for document in querySnapshot!.documents {
                          let messageData = document.data()
                          let msgSenderID = messageData["msgSenderID"] as! String
                          messagesUsersSet.insert(msgSenderID)
                      }
                      let usersArray = Array(messagesUsersSet)
                      for user in usersArray{
                          fireDB.collection("Users").whereField("userID", isEqualTo: user).getDocuments{ (querySnapshot, error) in
                              if let error = error {
                                       print("Error getting users: \(error)")
                              } else {
                                  for document in querySnapshot!.documents {
                                      let userData = document.data()
                                      let userID = userData["userID"] as? String ?? "NO_ID"
                                      if coreDataManager.isNetworkUserExist(userID: userID, data: context){
                                          continue
                                      } else {
                                          if let userName = userData["userName"] as? String,
                                             let userAvatarFirestorePath = userData["userAvatarFirestorePath"] as? String,
                                             let userBirthDate = userData["userBirthDate"] as? String,
                                             let userNativeLanguage = userData["userNativeLanguage"] as? String,
                                             let userCountry = userData["userCountry"] as? String,
                                             let userRegisterDate = userData["userRegisterDate"] as? String,
                                             let userShowEmail = userData["userShowEmail"] as? Bool,
                                             let userEmail = userData["userEmail"] as? String
                                          {
                                              let newNetworkUser = NetworkUser(context:context)
                                              newNetworkUser.nuID = userID
                                              newNetworkUser.nuName = userName
                                              newNetworkUser.nuFirebaseAvatarPath = userAvatarFirestorePath
                                              newNetworkUser.nuBirthDate = userBirthDate
                                              newNetworkUser.nuNativeLanguage = userNativeLanguage
                                              newNetworkUser.nuCountry = userCountry
                                              newNetworkUser.nuRegisterDate = userRegisterDate
                                              newNetworkUser.nuShowEmail = userShowEmail
                                              if userShowEmail{
                                                  newNetworkUser.nuEmail = userEmail
                                              }
                                              self.coreDataManager.saveData(data: context)
                                              alamo.downloadChatUserAvatar(url: userAvatarFirestorePath, senderID: userID, userID: mainModel.loadUserData().userID) { avatarName in
                                                  newNetworkUser.nuLocalAvatar = avatarName
                                                  self.coreDataManager.saveData(data: context)
                                              }
                                              print("User \(userName) succesfully created!\n")
                                          }
                                      }
                                  }
                              }
                          }
                      }
                  }
        }
    }
    
    func updateNetworkUsersDataInCoreData(context:NSManagedObjectContext){
        let networkUsers = coreDataManager.loadAllNetworkUsers(data:context)
        let filteredUsers = networkUsers.filter({$0.nuID != mainModel.loadUserData().userID})
        for user in filteredUsers {
            let userID = user.nuID ?? "EMPTY_ID"
            fireDB.collection("Users").whereField("userID", isEqualTo: userID).getDocuments {(querySnapshot, error) in
                if let error = error {
                    print("Error getting user data: \(error)")
                } else {
                    guard let document = querySnapshot?.documents.first else {return}
                    let userData = document.data()
                    let userName = userData["userName"] as? String
                    if user.nuName != userName{
                        user.nuName = userName
                    }
                    let userShowEmail = userData["userShowEmail"] as? Bool ?? false
                    if user.nuShowEmail != userShowEmail{
                        user.nuShowEmail = userShowEmail
                        if userShowEmail{
                            let userEmail = userData["userEmail"] as? String
                            user.nuEmail = userEmail
                        }
                    }
                    let userCountry = userData["userCountry"] as? String
                    if user.nuCountry != userCountry{
                        user.nuCountry = userCountry
                    }
                    let userNativeLanguage = userData["userNativeLanguage"] as? String
                    if user.nuNativeLanguage != userNativeLanguage{
                        user.nuNativeLanguage = userNativeLanguage
                    }
                    let userScores = userData["userScores"] as? Int ?? 0
                    if user.nuScores != userScores{
                        user.nuScores = Int64(userScores)
                    }
                    let userBirthDate = userData["userBirthDate"] as? String
                    if user.nuBirthDate != userBirthDate{
                        user.nuBirthDate = userBirthDate
                    }
                    let userAvatarFirestorePath = userData["userAvatarFirestorePath"] as? String ?? "EMPTY_AVATAR"
                    if user.nuLocalAvatar != userAvatarFirestorePath{
                        user.nuFirebaseAvatarPath = userAvatarFirestorePath
                        self.alamo.downloadChatUserAvatar(url: userAvatarFirestorePath, senderID: userID, userID: mainModel.loadUserData().userID) { avatarName in
                            user.nuLocalAvatar = avatarName
                            self.coreDataManager.saveData(data: context)
                        }
                    }
                    self.coreDataManager.saveData(data: context)
                }
            }
        }
    }
    
    func getNetworkUserDataByID(userID:String, completion: @escaping (NetworkUserData?) -> Void){
        fireDB.collection("Users")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { (querySnapshot, error) in
                if error != nil {
                    print("Error getting user data: \(error!)")
                    completion(nil)
                } else {
                    var resultData : NetworkUserData?
                    guard let document = querySnapshot?.documents.first else {
                        completion(nil)
                        return
                    }
                        let userData = document.data()
                        if let userID = userData["userID"] as? String,
                           let userName = userData["userName"] as? String,
                           let userCountry = userData["userCountry"] as? String,
                           let userNativeLanguage = userData["userNativeLanguage"] as? String,
                           let userBirthDate = userData["userBirthDate"] as? String,
                           let userRegisterDate = userData["userRegisterDate"] as? String,
                           let userAvatarFirestorePath = userData["userAvatarFirestorePath"] as? String,
                           let userEmail = userData["userEmail"] as? String,
                           let userScores = userData["userScores"] as? Int,
                           let userShowEmail = userData["userShowEmail"] as? Bool
                        {
                            var userSharedEmail = String()
                            if userShowEmail{
                                userSharedEmail = userEmail
                            } else {
                                userSharedEmail = String()
                            }
                           resultData = NetworkUserData(userID: userID, userName: userName, userCountry: userCountry, userNativeLanguage: userNativeLanguage, userBirthDate: userBirthDate, userRegisterDate: userRegisterDate, userAvatarFirestorePath: userAvatarFirestorePath, userShowEmail: userShowEmail, userEmail: userSharedEmail, userScores: userScores)
                        }
                    
                    completion(resultData)
                }
            }
    }
    
    func getNetworkUserNameByID(userID:String, completion: @escaping (String?, String?) -> Void){
        fireDB.collection("Users").whereField("userID", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error getting user data: \(error!)")
                completion(nil,nil)
            } else {
                guard let document = querySnapshot?.documents.first else {
                    completion(nil,nil)
                    return
                }
                let userData = document.data()
                let userName = userData["userName"] as? String
                let userID = userData["userID"] as? String
                completion(userID,userName)
            }
        }
    }
    
    func getMessagesCountForDictionary(dicID:String, completion: @escaping (String?) -> Void){
        fireDB.collection("Messages").whereField("msgDicID", isEqualTo: dicID).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error getting messages: \(error!)")
                completion(nil)
            } else {
                let messagesCount = String(querySnapshot?.documents.count ?? 0)
                completion(messagesCount)
                  }
        }
    }
    
    func getDictionaryShortData1(completion: @escaping ([SharedDictionaryShortData]?) -> Void) {
        fireDB.collection("Dictionaries").whereField("dicShared", isEqualTo: true).getDocuments { (querySnapshot, error) in
            if error != nil {
                completion(nil)
            } else {
                guard let document = querySnapshot?.documents.first else {
                    completion(nil)
                    return
                }
                let dictionaryData = document.data()
                 let dictionaryName = dictionaryData["dicName"] as! String
                 let dicID = dictionaryData["dicID"] as! String
                 let dicLikes = dictionaryData["dicLikes"] as? [String] ?? [String]()
                 let dicArray = [SharedDictionaryShortData(dicID: dicID, dicName: dictionaryName, dicLikes: dicLikes)]
                completion(dicArray)
            }
        }
    }
    
    
    func getAllWordForSharedDictionary(dicID:String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        fireDB.collection("Words").whereField("wrdDicID", isEqualTo: dicID).getDocuments { (querySnapshot, error) in
            if let error = error {
                      completion(nil, error)
                  } else {
                      var allWords: [String: Any] = [:]

                      for document in querySnapshot!.documents {
                          let wordData = document.data()
                          let wordID = document.documentID
                          allWords[wordID] = wordData
                      }
                      completion(allWords, nil)
                  }
        }
    }

    
    func checkIsWordExistsInDictionary(wrdID:String, completion: @escaping (Bool, Error?) -> Void) {
        
        let wordReference = fireDB.collection("Words").document(wrdID)
        
        wordReference.getDocument { (document, error) in
            if let error = error {
               
                completion(false, error)
            } else if let document = document, document.exists {
                completion(true, nil)
            } else {
               
                completion(false, nil)
            }
        }
    }
    
    func checkIsExistsDictionary(dicID:String, completion: @escaping (Bool, Error?) -> Void) {
        
        let wordReference = fireDB.collection("Dictionaries").document(dicID)
        
        wordReference.getDocument { (document, error) in
            if let error = error {
               
                completion(false, error)
            } else if let document = document, document.exists {
                completion(true, nil)
            } else {
               
                completion(false, nil)
            }
        }
    }
    
//MARK: - Update functions
    func updateUserDataFirebase(userData: UserData){
        let userID = userData.userID
        fireDB.collection("Users").document(userID).updateData(
            ["userName": userData.userName,
             "userCountry": userData.userCountry,
             "userNativeLanguage": userData.userNativeLanguage,
             "userBirthDate": userData.userBirthDate,
             "userScores": userData.userScores
            ]
        ){ error in
                if let error = error {
                    print("FirebaseModel: Error updating user data in Firestore: \(error)\n")
                }
         }
    }
    
    func updateUserEmailShowStatus(userID: String, status:Bool){
        fireDB.collection("Users").document(userID).updateData(
            [
                "userShowEmail": status
            ]
        ){ error in
                if let error = error {
                    print("FirebaseModel: Error updating user data in Firestore: \(error)\n")
                }
         }
    }
    
    func setDictionaryDownloadedByUserUser(dicID: String, remove:Bool){
        switch remove{
        case false:
            fireDB.collection("Dictionaries").document(dicID).updateData(
                [
                    "dicDownloadedUsers": FieldValue.arrayUnion([mainModel.loadUserData().userID])
                ]
            ){ error in
                    if let error = error {
                        print("FirebaseModel: Error updating user data in Firestore: \(error)\n")
                    }
             }
        case true:
            fireDB.collection("Dictionaries").document(dicID).updateData(
                [
                    "dicDownloadedUsers": FieldValue.arrayRemove([mainModel.loadUserData().userID])
                ]
            ){ error in
                    if let error = error {
                        print("FirebaseModel: Error updating user data in Firestore: \(error)\n")
                    }
             }
        }
       
    }
  
    
    func setLikeForDictionaryFirebase(dicID: String, userID:String, like:Bool){
        switch like{
        case true:
            fireDB.collection("Dictionaries").document(dicID).updateData(
                [
                    "dicLikes": FieldValue.arrayUnion([mainModel.loadUserData().userID])
                ]
            ){ error in
                if let error = error {
                    print("FirebaseModel: Error updating user data in Firestore: \(error)\n")
                }
            }
        case false:
            fireDB.collection("Dictionaries").document(dicID).updateData(
                [
                    "dicLikes": FieldValue.arrayRemove([mainModel.loadUserData().userID])
                ]
            ){ error in
                if let error = error {
                    print("FirebaseModel: Error updating user data in Firestore: \(error)\n")
                }
            }
        }
    }
    
    func updateWordsCountFirebase(dicID: String, increment:Bool) {
        switch increment{
        case true:
            fireDB.collection("Dictionaries").document(dicID).updateData(
                ["dicWordsCount": FieldValue.increment(Int64(1))]
            ){ error in
                if let error = error {
                    print("FirebaseModel: Error updating avatar URL in Firestore: \(error)")
                }
            }
        case false:
            fireDB.collection("Dictionaries").document(dicID).updateData(
                ["dicWordsCount": FieldValue.increment(Int64(-1))]) { error in
                    if let error = error {
                        print("FirebaseModel: Error updating avatar URL in Firestore: \(error)")
                    }
                }
        }
    }
    
    func setDeletedStatusForDictionary(dicID: String) {
            fireDB.collection("Dictionaries").document(dicID).updateData(
                ["dicDeleted": true]
            ){ error in
                    if let error = error {
                        print("FirebaseModel: Error updating avatar URL in Firestore: \(error)")
                    }
             }
    }
    
    func updateImagesCountFirebase(dicID: String, increment:Bool) {
        switch increment{
            case true:
            fireDB.collection("Dictionaries").document(dicID).updateData(
                ["dicImagesCount": FieldValue.increment(Int64(1))]) { error in
                    if let error = error {
                        print("FirebaseModel: Error updating avatar URL in Firestore: \(error)")
                    }
            }
            case false:
            fireDB.collection("Dictionaries").document(dicID).updateData(
                ["dicImagesCount": FieldValue.increment(Int64(-1))]) { error in
                    if let error = error {
                        print("FirebaseModel: Error updating avatar URL in Firestore: \(error)")
                    }
            }
        }
    }
    
    func updateDictionaryInFirebase(dicID: String, dicName:String, dicDescription:String, dicShared:Bool) {
        
        fireDB.collection("Dictionaries").document(dicID).updateData(
            ["dicName": dicName, "dicDescription": dicDescription, "dicShared":dicShared]
        ) { error in
            if let error = error {
                print("FirebaseModel: Error updating dictionary in Firestore: \(error)")
            }
        }
    }
    
    func updateDictionaryFieldInFirebase<typ>(dicID: String, field:String, newData:typ) {
        if let stringValue = newData as? String {
            fireDB.collection("Dictionaries").document(dicID).updateData(
                ["\(field)": stringValue]
            ) { error in
                if let error = error {
                    print("FirebaseModel: Error updating dictionary in Firestore: \(error)")
                }
            }
        } else if let boolValue = newData as? Bool {
            fireDB.collection("Dictionaries").document(dicID).updateData(
                ["\(field)": boolValue]
            ) { error in
                if let error = error {
                    print("FirebaseModel: Error updating dictionary in Firestore: \(error)")
                }
            }
        } else if let intValue = newData as? Int{
            fireDB.collection("Dictionaries").document(dicID).updateData(
                ["\(field)": intValue]
            ) { error in
                if let error = error {
                    print("FirebaseModel: Error updating dictionary in Firestore: \(error)")
                }
            }
        }
    }
    
  
    func updateWordInFirebase(wrdID: String, newWord: String, newTranslation: String) {
        fireDB.collection("Words").document(wrdID).updateData(
            ["wrdWord": newWord, "wrdTranslation": newTranslation]
        ) { error in
            if let error = error {
                print("FirebaseModel: Error updating avatar URL in Firestore: \(error)")
            }
        }
    }
    
    func clearWordImageURLInFirebase(wrdID: String) {
        fireDB.collection("Words").document(wrdID).updateData([
            "wrdImageFirestorePath": "",
            "wrdImageName":""
        ]) { error in
            if let error = error {
                print("Error updating word: \(error)")
            }
        }
    }
    
    
    func updateImageURLaddressFirebase(wrdID: String, word:String, fsURL:String, imageName:String) {
        fireDB.collection("Words").document(wrdID).updateData(
            ["wrdImageFirestorePath": fsURL, "wrdImageName": imageName]
        ) { error in
            if let error = error {
                
                print("FirebaseModel: Error updating avatar URL in Firestore: \(error)")
            }
        }
    }
    
//MARK: - Delete functions
    func deleteDictionaryFirebase(dicID: String, completion: @escaping (Error?) -> Void) {
        fireDB.collection("Dictionaries").document(dicID).delete { error in
            if let error = error {
                
                print("FirebaseModel: Error deleting dictionary: \(error)")
            }
            completion(error)
        }
    }
    
  
 func deleteWordsByDicIDFirebase(dicID: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let wordsCollection = db.collection("Words")
        wordsCollection.whereField("dicID", isEqualTo: dicID).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(error)
            } else {
                let documents = querySnapshot?.documents ?? []
                for document in documents {
                    let documentID = document.documentID
                    wordsCollection.document(documentID).delete { deleteError in
                        if let deleteError = deleteError {
                            completion(deleteError)
                            return
                        }
                    }
                }
                completion(nil)
            }
        }
    }
    
  
    
    func deleteWordFromFirebase(wrdID: String) {
        fireDB.collection("Words").document(wrdID).delete { error in
            if let error = error {
                print("Error deleting word: \(error)")
            }
        }
    }
    
//MARK: - Firestore functions
    
    func uploadImageToFirestore(userID:String, dicID:String, imageName:String, word:String, context: NSManagedObjectContext){
        let storage = Storage.storage()
        let imageRef = storage.reference().child(userID).child(dicID).child(imageName)
        let localImagePath = mainModel.getDocumentsFolderPath().appendingPathComponent("\(userID)/\(dicID)/\(imageName)")
        imageRef.putFile(from: localImagePath, metadata: nil) { metadata, error in
            guard metadata != nil else {
                return
            }
            imageRef.downloadURL {url, error in
                guard let downloadURL = url else {
                    return
                }
                let wordForImage = coreDataManager.loadWordByDictionary(user: userID, word: word, dicID: dicID, data: context)
                wordForImage.first?.wrdImageFirestorePath = downloadURL.absoluteString
                let wrdID = wordForImage.first?.wrdID ?? ""
                updateImageURLaddressFirebase(wrdID: wrdID, word: word, fsURL: downloadURL.absoluteString, imageName: imageName)
            }
            updateImagesCountFirebase(dicID: dicID, increment: true)
        }
        
    }
    
    func uploadAvatarToFirestore(userID:String, avatarPath:URL){
        let storage = Storage.storage()
        let imageRef = storage.reference().child(userID).child("userAvatar.jpg")
       
        imageRef.putFile(from: avatarPath, metadata: nil) { metadata, error in
            guard metadata != nil else {
                return
            }
           
        }
        
    }
    
    func deleteImageFromStorage(imageName: String, userID:String, dicID:String){
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let desertRef = storageRef.child(userID).child(dicID).child(imageName)
        desertRef.delete { error in
            if let error = error {
                print("FirebaseModel: Error deleting image from Storage: \(error)\n")
            }
        }
    }
    
    func deleteAllImagesFromDictionaryStorage(userID:String, dicID:String, arrayOfWords:[Word]){
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let filteredArray = arrayOfWords.filter({$0.imageName == nil})
        for word in filteredArray {
            let desertRef = storageRef.child(userID).child(dicID).child(word.imageName ?? "")
            desertRef.delete { error in
                if let error = error {
                    print("FirebaseModel: Error deleting image from Storage: \(error)\n")
                }
            }
        }
    }
    
    
}
