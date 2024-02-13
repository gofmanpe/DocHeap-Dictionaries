//
//  CoreDataManager.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 13.06.23.
//

import Foundation
import CoreData
import UIKit

struct CoreDataManager{
    
    var wordsArray = [Word]()
    var wordsWithImagesArray = [Word]()
    var usersArray = [Users]()
    var parentDictionaryData = [Dictionary]()
    var dictionariesArray = [Dictionary]()
    private let alamo = Alamo()
    
    mutating func loadAllWords(data: NSManagedObjectContext, request: NSFetchRequest<Word> = Word.fetchRequest())
    {
        do {
            let array = try data.fetch(request)
            wordsArray = array.filter({$0.wrdDeleted == false})
        }
        catch { print ("Error fetching data \(error)") }
    }
    
    func getAllWords(data: NSManagedObjectContext)->[Word]{
    let request: NSFetchRequest<Word> = Word.fetchRequest()
        var result = [Word]()
        do {
            let array = try data.fetch(request)
            result = array.filter({$0.wrdDeleted == false})
        }
        catch { print ("Error fetching data \(error)") }
        return result
    }
    
    func createComment(comment:Comment, context: NSManagedObjectContext){
        let newComment = DicMessage(context:context)
        newComment.msgID = comment.msgID
        newComment.msgBody = comment.msgBody
        newComment.msgSenderID = comment.msgSenderID
        newComment.msgDateTime = comment.msgDateTime
        newComment.msgDicID = comment.msgDicID
        newComment.msgSyncronized = true
        newComment.msgOrdering = Int64(comment.msgOrdering)
        saveData(data: context)
    }
    
    func createWordsPair(wordsPair:WordsPair, context:NSManagedObjectContext){
        let newWord = Word(context: context)
        newWord.wrdID = wordsPair.wrdID
        newWord.wrdWord = wordsPair.wrdWord
        newWord.wrdTranslation = wordsPair.wrdTranslation
        if !wordsPair.wrdImageName.isEmpty{
            newWord.imageName = wordsPair.wrdImageName
            newWord.wrdImageIsSet = true
            newWord.wrdImageFirestorePath = wordsPair.wrdImageFirestorePath
            alamo.downloadAndSaveImage(
                fromURL: wordsPair.wrdImageFirestorePath,
                userID: wordsPair.wrdUserID,
                dicID: wordsPair.wrdDicID,
                imageName: wordsPair.wrdImageName) {
                }
        }
        newWord.parentDictionary = wordsPair.wrdParentDictionary
        newWord.wrdAddDate = wordsPair.wrdAddDate
        newWord.wrdBobbleColor = ".systemYellow"
        newWord.wrdDicID = wordsPair.wrdDicID
        newWord.wrdDeleted = false
        newWord.wrdReadOnly = true
        newWord.wrdUserID = wordsPair.wrdUserID
        newWord.wrdSyncronized = true
        saveData(data: context)
    }
    
    func createLocalWordsPair(wordsPair:WordsPair, context:NSManagedObjectContext, sync:Bool){
        let newWord = Word(context: context)
        newWord.wrdID = wordsPair.wrdID
        newWord.wrdWord = wordsPair.wrdWord
        newWord.wrdTranslation = wordsPair.wrdTranslation
        newWord.imageName = wordsPair.wrdImageName
        if wordsPair.wrdImageName.isEmpty{
            newWord.wrdImageIsSet = false
        } else {
            newWord.wrdImageIsSet = true
        }
        newWord.wrdImageFirestorePath = wordsPair.wrdImageFirestorePath
        newWord.parentDictionary = wordsPair.wrdParentDictionary
        newWord.wrdAddDate = wordsPair.wrdAddDate
        newWord.wrdBobbleColor = ".systemYellow"
        newWord.wrdDicID = wordsPair.wrdDicID
        newWord.wrdDeleted = false
        newWord.wrdReadOnly = false
        newWord.wrdUserID = wordsPair.wrdUserID
        newWord.wrdSyncronized = true
        saveData(data: context)
    }
    
    func createDictionary(dictionary:LocalDictionary, context:NSManagedObjectContext){
        let newDictionary = Dictionary(context: context)
        newDictionary.dicID = dictionary.dicID
        newDictionary.dicCommentsOn = dictionary.dicCommentsOn
        newDictionary.dicDeleted = dictionary.dicDeleted
        newDictionary.dicDescription = dictionary.dicDescription
        newDictionary.dicAddDate = dictionary.dicAddDate
        newDictionary.dicImagesCount = Int64(dictionary.dicImagesCount)
        newDictionary.dicLearningLanguage = dictionary.dicLearningLanguage
        newDictionary.dicTranslateLanguage = dictionary.dicTranslateLanguage
        newDictionary.dicName = dictionary.dicName
        newDictionary.dicReadOnly = dictionary.dicReadOnly
        newDictionary.dicShared = dictionary.dicShared
        newDictionary.dicUserID = dictionary.dicUserID
        newDictionary.dicWordsCount = Int64(dictionary.dicWordsCount)
        newDictionary.dicLike = dictionary.dicLike
        newDictionary.dicOwnerID = dictionary.dicOwnerID
        saveData(data: context)
    }
    
    func loadWordDataByID(wrdID: String, userID:String, data: NSManagedObjectContext)->[Word]{
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.predicate = NSPredicate(format: "wrdID MATCHES %@", wrdID)
        var oneWordArray = [Word]()
        do {
            oneWordArray = try data.fetch(request)
            oneWordArray = oneWordArray.filter({$0.wrdUserID == userID})
        }
        catch { print ("Error fetching data \(error)") }
        return oneWordArray
    }
    
    func loadWordsByDictionryID(dicID: String, data: NSManagedObjectContext)->[Word]{
         let request: NSFetchRequest<Word> = Word.fetchRequest()
             request.predicate = NSPredicate(format: "wrdDicID MATCHES %@", dicID)
        var dictionaryWordArray = [Word]()
         do {
             dictionaryWordArray = try data.fetch(request)
            
         }
         catch { print ("Error fetching data \(error)") }
        return dictionaryWordArray
     }
 
    func delWordsFromDictionaryByDicID(dicID: String, userID: String, context: NSManagedObjectContext) {
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        let predicate = NSPredicate(format: "parentDictionary.dicID MATCHES %@", dicID)
        request.predicate = predicate
        do {
            let wordsForDel = try context.fetch(request)
            let userWordsForDel = wordsForDel.filter({$0.wrdUserID == userID})
            for word in userWordsForDel {
                context.delete(word)
            }
           saveData(data: context)
        } catch {
            print("Error fetching data: \(error)")
        }
    }
    
    func loadDictionaryDataByID(dicID: String, data: NSManagedObjectContext)->[Dictionary]{
         let request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()
             request.predicate = NSPredicate(format: "dicdID MATCHES %@", dicID)
        var oneDictionaryArray = [Dictionary]()
         do {
             oneDictionaryArray = try data.fetch(request)
            
         }
         catch { print ("Error fetching data \(error)") }
        return oneDictionaryArray
     }
    
//    func loadUnsyncronedDeletedDictionariesByUserID(userID:String, context:NSManagedObjectContext)->[LocalDictionary]{
//        let request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()
//            request.predicate = NSPredicate(format: "dicUserID MATCHES %@", userID)
//       var result = [LocalDictionary]()
//        do {
//           let allDictionariesArray = try context.fetch(request)
//            let unsync = allDictionariesArray.filter({$0.dicSyncronized == false}).filter({$0.dicDeleted == true}).filter({$0.dicLike == true})
//            for d in unsync{
//                let convertedData = LocalDictionary(
//                    dicID: d.dicID!,
//                    dicCommentsOn: d.dicCommentsOn,
//                    dicDeleted: d.dicDeleted,
//                    dicDescription: d.dicDescription ?? "",
//                    dicAddDate: d.dicAddDate!,
//                    dicImagesCount: Int(d.dicImagesCount),
//                    dicLearningLanguage: d.dicLearningLanguage!,
//                    dicTranslateLanguage: d.dicTranslateLanguage!,
//                    dicLike: d.dicLike,
//                    dicName: d.dicName ?? "",
//                    dicOwnerID: d.dicOwnerID!,
//                    dicReadOnly: d.dicReadOnly,
//                    dicShared: d.dicShared,
//                    dicSyncronized: d.dicSyncronized,
//                    dicUserID: d.dicUserID!,
//                    dicWordsCount: Int(d.dicWordsCount))
//                result.append(convertedData)
//            }
//        }
//        catch { print ("Error fetching data \(error)") }
//       return result
//    }
    
    func deleteDictionaryFromCoreData(dicID: String, userID: String, context: NSManagedObjectContext){
        let request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()
            request.predicate = NSPredicate(format: "dicUserID MATCHES %@", userID)
        do {
           let oneDictionaryArray = try context.fetch(request)
            let filteredArray = oneDictionaryArray.filter({$0.dicID == dicID})
            for dictionary in filteredArray {
                context.delete(dictionary)
            }
           saveData(data: context)
        }
        catch { print ("Error fetching data \(error)") }
    }
    
    func deleteRODictionaryFromCoreData(dicID: String, userID:String, context: NSManagedObjectContext){
        let request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()
            request.predicate = NSPredicate(format: "dicID MATCHES %@", dicID)
        do {
           let oneDictionaryArray = try context.fetch(request)
            let filteredArray = oneDictionaryArray.filter({$0.dicUserID == userID})
            for dictionary in filteredArray {
                context.delete(dictionary)
            }
           saveData(data: context)
        }
        catch { print ("Error fetching data \(error)") }
    }
   
    func loadAllRODictionaries(userID:String, context:NSManagedObjectContext)->[Dictionary]{
        let request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()
            request.predicate = NSPredicate(format: "dicUserID MATCHES %@", userID)
        var result = [Dictionary]()
        do {
            let dictionaries = try context.fetch(request)
            let filtered = dictionaries.filter({$0.dicReadOnly == true})
            for dic in filtered{
                result.append(dic)
            }
        }
        catch { print ("Error fetching data \(error)")
        }
        return result
    }
    
    func deleteWordFromCoreData(wrdID: String, context: NSManagedObjectContext){
        let request: NSFetchRequest<Word> = Word.fetchRequest()
            request.predicate = NSPredicate(format: "wrdID MATCHES %@", wrdID)
        var oneWordArray = [Word]()
        do {
            oneWordArray = try context.fetch(request)
            oneWordArray.remove(at: 0)
            saveData(data: context)
        }
        catch { print ("Error fetching data \(error)") }
    }
    
    func deleteDownloadedWordFromCoreData(wrdID: String, context: NSManagedObjectContext){
        let request: NSFetchRequest<Word> = Word.fetchRequest()
            request.predicate = NSPredicate(format: "wrdID MATCHES %@", wrdID)
        do {
           let wordsArray = try context.fetch(request)
            for word in wordsArray{
                context.delete(word)
            }
            saveData(data: context)
        }
        catch { print ("Error fetching data \(error)") }
    }
    
    func deleteMessagesFromCoreData(dicID: String, context: NSManagedObjectContext){
        let request: NSFetchRequest<DicMessage> = DicMessage.fetchRequest()
            request.predicate = NSPredicate(format: "msgDicID MATCHES %@", dicID)
        do {
            let userMessagesForDic = try context.fetch(request)
            for message in userMessagesForDic {
                context.delete(message)
            }
            saveData(data: context)
        }
        catch { print ("Error fetching data \(error)") }
    }
    
    func loadAllWordsWithImages(data: NSManagedObjectContext, request: NSFetchRequest<Word> = Word.fetchRequest())->[Word]
     {
         var resultArray = [Word]()
         do {
            let allWordsArray = try data.fetch(request)
             resultArray = allWordsArray.filter({$0.imageName != ""}).filter({$0.wrdDeleted == false})
             
         }
         catch { print ("Error fetching data \(error)") }
         return resultArray
     }
    
    mutating func loadWordsWithImagesForSelectedDictionary(context: NSManagedObjectContext, dicID: String){
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.predicate = NSPredicate(format: "parentDictionary.dicID MATCHES %@", dicID)
        request.sortDescriptors = [NSSortDescriptor(key: "wrdWord", ascending: true)]
        do {
            wordsArray = try context.fetch(request)
        }
        catch {
            print ("Error fetching data \(error)")
        }
        wordsWithImagesArray = wordsArray.filter({$0.wrdImageIsSet == true})
    }
    
    mutating func loadWordsForSelectedDictionary(dicID: String, userID:String, context: NSManagedObjectContext){
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.predicate = NSPredicate(format: "parentDictionary.dicID MATCHES %@", dicID)
        request.sortDescriptors = [NSSortDescriptor(key: "wrdWord", ascending: true)]
        do {
            let array = try context.fetch(request)
            let undeletedWords = array.filter({$0.wrdDeleted == false})
            wordsArray = undeletedWords.filter({$0.wrdUserID == userID})
        }
        catch {
            print ("Error fetching data \(error)")
        }
    }
    
    func getWordsForDictionary(dicID: String, userID:String, context: NSManagedObjectContext)->[Word]{
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.predicate = NSPredicate(format: "wrdDicID MATCHES %@", dicID)
        var requestedWords = [Word]()
        do {
            let array = try context.fetch(request)
            let filterDeleted = array.filter({$0.wrdDeleted == false})
            requestedWords = filterDeleted.filter({$0.wrdUserID == userID})
        }
        catch {
            print ("Error fetching data \(error)")
        }
        return requestedWords
    }
    
    func getWordsForSharedDictionary(dicID: String, context: NSManagedObjectContext)->[Word]{
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.predicate = NSPredicate(format: "parentDictionary.dicID MATCHES %@", dicID)
        request.sortDescriptors = [NSSortDescriptor(key: "wrdWord", ascending: true)]
        var sharedArray = [Word]()
        do {
            let array = try context.fetch(request)
            
            sharedArray = array.filter({$0.wrdReadOnly == true})
        }
        catch {
            print ("Error fetching data \(error)")
        }
        return sharedArray
    }
    
    func loadWordsCountForSelectedDictionary(dicID: String, data: NSManagedObjectContext, with request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest())->Int{
        
        request.predicate = NSPredicate(format: "dicID MATCHES %@", dicID)
        request.sortDescriptors = [NSSortDescriptor(key: "wrdWord", ascending: true)]
        do {
            let array = try data.fetch(request)
            return Int(array.first?.dicWordsCount ?? 0)
        }
        catch {
            print ("Error fetching data \(error)")
            return 0
        }
    }
    
    
    
    func loadWordsForDictionary(dicID: String, data: NSManagedObjectContext, with request: NSFetchRequest<Word> = Word.fetchRequest())->[Word]{
        
        request.predicate = NSPredicate(format: "wrdDicID MATCHES %@", dicID)
        do {
            let array = try data.fetch(request)
            let wordsArray = array.filter({$0.wrdDeleted == false})
            return wordsArray
        }
        catch {
            print ("Error fetching data \(error)")
            return [Word]()
        }
    }
    
    mutating func loadParentDictionaryData (dicID: String, userID:String, data: NSManagedObjectContext, with request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()){
        request.predicate = NSPredicate(format: "dicID MATCHES %@", dicID)
        do {
            let dictionaryData = try data.fetch(request)
            parentDictionaryData = dictionaryData.filter({$0.dicUserID == userID})
           // print(parentDictionaryData)
        }
        catch {
            print("Error fetching data \(error)")
            
        }
    }
    
    func getParentDictionaryData(dicID: String, userID:String, context: NSManagedObjectContext)->Dictionary{
        let request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()
        request.predicate = NSPredicate(format: "dicID MATCHES %@", dicID)
        var parentDic = Dictionary()
        do {
            let dictionary = try context.fetch(request)
            parentDic = dictionary.filter({$0.dicUserID == userID}).first ?? Dictionary()
        }
        catch {
            print("Error fetching data \(error)")
        }
        return parentDic
    }
    
    func loadParentDictionaryForWord (dicID: String, data: NSManagedObjectContext, with request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest())->[Dictionary]{
        request.predicate = NSPredicate(format: "dicID MATCHES %@", dicID)
        var parentDictionary = [Dictionary]()
        do {
           parentDictionary = try data.fetch(request)
            
        }
        catch {
            print("Error fetching data \(error)")
            
        }
        return parentDictionary
    }
    
    func loadParentReadOnlyDictionaryForWord(dicID: String, userID:String, data: NSManagedObjectContext, with request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest())->[Dictionary]{
        request.predicate = NSPredicate(format: "dicID MATCHES %@", dicID)
        var parentDictionary = [Dictionary]()
        do {
           let dictionary = try data.fetch(request)
            parentDictionary = dictionary.filter({$0.dicUserID == userID})
        }
        catch {
            print("Error fetching data \(error)")
            
        }
        return parentDictionary
    }
    
    mutating func loadDictionariesData(data: NSManagedObjectContext){
        let request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dicAddDate", ascending: false)]
        do {
            let array = try data.fetch(request)
            dictionariesArray = array.filter({$0.dicDeleted == false})
        }
        catch { print ("Error fetching data \(error)") }
    }
    
    mutating func loadDictionariesForCurrentUser(userID: String, data: NSManagedObjectContext){
        let request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()
        request.predicate = NSPredicate(format: "dicUserID MATCHES %@", userID)
        request.sortDescriptors = [NSSortDescriptor(key: "dicAddDate", ascending: false)]
        do {
            let array = try data.fetch(request)
            dictionariesArray = array.filter({$0.dicDeleted == false})
        }
        catch { print ("Error fetching data \(error)") }
    }
    
    func loadUserDictionaries(userID: String, context: NSManagedObjectContext)->[LocalDictionary]{
        let request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()
        request.predicate = NSPredicate(format: "dicUserID MATCHES %@", userID)
        request.sortDescriptors = [NSSortDescriptor(key: "dicAddDate", ascending: false)]
        var filteredArray = [LocalDictionary]()
        do {
            let array = try context.fetch(request)
            for dic in array{
                let userDic = LocalDictionary(
                    dicID: dic.dicID!,
                    dicCommentsOn: dic.dicCommentsOn,
                    dicDeleted: dic.dicDeleted,
                    dicDescription: dic.dicDescription ?? "",
                    dicAddDate: dic.dicAddDate!,
                    dicImagesCount: Int(dic.dicImagesCount),
                    dicLearningLanguage: dic.dicLearningLanguage!,
                    dicTranslateLanguage: dic.dicTranslateLanguage!,
                    dicLike: dic.dicLike,
                    dicName: dic.dicName ?? "",
                    dicOwnerID: dic.dicOwnerID ?? "",
                    dicReadOnly: dic.dicReadOnly,
                    dicShared: dic.dicShared,
                    dicSyncronized: dic.dicSyncronized,
                    dicUserID: dic.dicUserID!,
                    dicWordsCount: Int(dic.dicWordsCount))
                if dic.dicDeleted && dic.dicReadOnly{
                    filteredArray.append(userDic)
                }
                if !dic.dicReadOnly && !dic.dicDeleted{
                    filteredArray.append(userDic)
                }
                if dic.dicReadOnly{
                    filteredArray.append(userDic)
                }
            }
        }
        catch { print ("Error fetching data \(error)")
        }
        return filteredArray
    }
    
    func loadAllUserDictionaries(userID: String, data: NSManagedObjectContext)->[Dictionary]{
        let request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()
        request.predicate = NSPredicate(format: "dicUserID MATCHES %@", userID)
        do {
            let array = try data.fetch(request)
            return array
        }
        catch { print ("Error fetching data \(error)")
            return [Dictionary]()
        }
    }
    
    func getAllUserDictionaries(userID: String, data: NSManagedObjectContext)->[LocalDictionary]{
        let request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()
        request.predicate = NSPredicate(format: "dicUserID MATCHES %@", userID)
        var result = [LocalDictionary]()
        do {
            let dictionariesArray = try data.fetch(request)
            for dic in dictionariesArray{
                let localDic = LocalDictionary(
                    dicID: dic.dicID!,
                    dicCommentsOn: dic.dicCommentsOn,
                    dicDeleted: dic.dicDeleted,
                    dicDescription: dic.dicDescription ?? "",
                    dicAddDate: dic.dicAddDate!,
                    dicImagesCount: Int(dic.dicImagesCount),
                    dicLearningLanguage: dic.dicLearningLanguage!,
                    dicTranslateLanguage: dic.dicTranslateLanguage!,
                    dicLike: dic.dicLike,
                    dicName: dic.dicName!,
                    dicOwnerID: dic.dicOwnerID ?? "",
                    dicReadOnly: dic.dicReadOnly,
                    dicShared: dic.dicShared,
                    dicSyncronized: dic.dicSyncronized,
                    dicUserID: dic.dicUserID!,
                    dicWordsCount: Int(dic.dicWordsCount)
                )
                result.append(localDic)
            }
        }
        catch {
            print ("Error fetching data \(error)")
        }
        return result
    }
    
    func getLocalDictionaryByID(userID: String, dicID:String, data: NSManagedObjectContext)->LocalDictionary?{
        let request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()
        request.predicate = NSPredicate(format: "dicID MATCHES %@", dicID)
        var result : LocalDictionary?
        do {
            let dictionariesArray = try data.fetch(request)
            let filtered = dictionariesArray.filter({$0.dicUserID == userID})
            for dic in filtered{
                let localDic = LocalDictionary(
                    dicID: dic.dicID!,
                    dicCommentsOn: dic.dicCommentsOn,
                    dicDeleted: dic.dicDeleted,
                    dicDescription: dic.dicDescription ?? "",
                    dicAddDate: dic.dicAddDate!,
                    dicImagesCount: Int(dic.dicImagesCount),
                    dicLearningLanguage: dic.dicLearningLanguage!,
                    dicTranslateLanguage: dic.dicTranslateLanguage!,
                    dicLike: dic.dicLike,
                    dicName: dic.dicName!,
                    dicOwnerID: dic.dicOwnerID ?? "",
                    dicReadOnly: dic.dicReadOnly,
                    dicShared: dic.dicShared,
                    dicSyncronized: dic.dicSyncronized,
                    dicUserID: dic.dicUserID ?? "",
                    dicWordsCount: Int(dic.dicWordsCount)
                )
                result = localDic
            }
        }
        catch {
            print ("Error fetching data \(error)")
        }
        return result
    }
    
    func getMessagesByDicID(dicID:String, context:NSManagedObjectContext)->[Comment]{
        let request: NSFetchRequest<DicMessage> = DicMessage.fetchRequest()
        request.predicate = NSPredicate(format: "msgDicID MATCHES %@", dicID)
        var messagesArray = [Comment]()
        do {
            let array = try context.fetch(request)
            for message in array{
                let chatMessage = Comment(
                    msgID: message.msgID ?? "",
                    msgBody: message.msgBody ?? "",
                    msgDateTime: message.msgDateTime ?? "",
                    msgDicID: message.msgDicID ?? "",
                    msgSenderID: message.msgSenderID ?? "",
                    msgOrdering: Int(message.msgOrdering),
                    msgSyncronized: message.msgSyncronized
                )
                messagesArray.append(chatMessage)
            }
        }
        catch {
            print ("Error fetching data \(error)")
        }
        return messagesArray
    }
    
    func createCommentForDictionary(message:Comment, context:NSManagedObjectContext){
        let newMessage = DicMessage(context: context)
        newMessage.msgID = message.msgID
        newMessage.msgBody = message.msgBody
        newMessage.msgDateTime = message.msgDateTime
        newMessage.msgDicID = message.msgDicID
        newMessage.msgSenderID = message.msgSenderID
        newMessage.msgOrdering = Int64(message.msgOrdering)
        newMessage.msgSyncronized = true
        saveData(data: context)
    }
    
    func createNetworkUser(userData:NetworkUserData, context:NSManagedObjectContext){
        let newNetworkUser = NetworkUser(context: context)
        newNetworkUser.nuBirthDate = userData.userBirthDate
        newNetworkUser.nuCountry = userData.userCountry
        newNetworkUser.nuEmail = userData.userEmail
        newNetworkUser.nuFirebaseAvatarPath = userData.userAvatarFirestorePath
        newNetworkUser.nuID = userData.userID
        newNetworkUser.nuLocalAvatar = ""
        newNetworkUser.nuName = userData.userName
        newNetworkUser.nuNativeLanguage = userData.userNativeLanguage
        newNetworkUser.nuRegisterDate = userData.userRegisterDate
        newNetworkUser.nuScores = Int64(userData.userScores)
        newNetworkUser.nuShowEmail = false
        newNetworkUser.nuLikes = Int64(userData.userLikes)
        newNetworkUser.nuTestsCompleted = Int64(userData.userTestsCompleted)
        newNetworkUser.nuRightAnswers = Int64(userData.userRightAnswers)
        newNetworkUser.nuMistakes = Int64(userData.userMistakes)
        saveData(data: context)
    }
    
    func createLocalUser(userData:UserData, context:NSManagedObjectContext){
        let localUser = Users(context: context)
        localUser.userBirthDate = userData.userBirthDate
        localUser.userCountry = userData.userCountry
        localUser.userEmail = userData.userEmail
        localUser.userAvatarFirestorePath = userData.userAvatarFirestorePath
        localUser.userID = userData.userID
        localUser.userAvatarExtention = "jpg"
        localUser.userName = userData.userName
        localUser.userNativeLanguage = userData.userNativeLanguage
        localUser.userRegisterDate = userData.userRegisterDate
        localUser.userScores = Int64(userData.userScores)
        localUser.userShowEmail = false
        localUser.userMistakes = Int64(userData.userMistakes)
        localUser.userRightAnswers = Int64(userData.userRightAnswers)
        localUser.userTestsCompleted = Int64(userData.userTestsCompleted)
        saveData(data: context)
    }
    
    func getNetworkUserNameByID(userID:String, context:NSManagedObjectContext)->String{
        let request: NSFetchRequest<NetworkUser> = NetworkUser.fetchRequest()
        request.predicate = NSPredicate(format: "nuID MATCHES %@", userID)
        var userName = String()
        do {
            let userData = try context.fetch(request)
            userName = userData.first?.nuName ?? "Anonimus"
        }
        catch {
            print ("Error fetching data \(error)")
        }
        return userName
    }
    
    func updateNetworkUserLocalAvatarName(userID:String, avatarName:String, context:NSManagedObjectContext){
        let request: NSFetchRequest<NetworkUser> = NetworkUser.fetchRequest()
        request.predicate = NSPredicate(format: "nuID MATCHES %@", userID)
       
        do {
            let userData = try context.fetch(request)
            userData.first?.nuLocalAvatar = avatarName
        }
        catch {
            print ("Error fetching data \(error)")
        }
       saveData(data: context)
    }
    
    func updateWordsPairFirestoreImagePath(wrdID:String, userID:String, path:String, context:NSManagedObjectContext){
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.predicate = NSPredicate(format: "wrdID MATCHES %@", wrdID)
        do {
            let userData = try context.fetch(request)
            let filteredData = userData.filter({$0.wrdUserID == userID}).first
            filteredData?.wrdImageFirestorePath = path
        }
        catch {
            print ("Error fetching data \(error)")
        }
       saveData(data: context)
    }
    
//    func checkIsExistNetworkUser(userID:String, context:NSManagedObjectContext)->Bool{
//        let request: NSFetchRequest<NetworkUser> = NetworkUser.fetchRequest()
//        request.predicate = NSPredicate(format: "nuID MATCHES %@", userID)
//        var result = Bool()
//        do {
//            let user = try context.fetch(request)
//            if user.isEmpty{
//                result = false
//            } else {
//                result = true
//            }
//        }
//        catch {
//            print ("Error fetching data \(error)")
//        }
//        return result
//    }
    
    func updateUserProfileData(userData:UserData, context:NSManagedObjectContext){
        let userID = userData.userID
        let request: NSFetchRequest<Users> = Users.fetchRequest()
        request.predicate = NSPredicate(format: "userID MATCHES %@", userID)
        do {
            let uData = try context.fetch(request)
            uData.first?.userName = userData.userName
            uData.first?.userNativeLanguage = userData.userNativeLanguage
            uData.first?.userBirthDate = userData.userBirthDate
            uData.first?.userCountry = userData.userCountry
        }
        catch {
            print ("Error fetching data \(error)")
        }
        saveData(data: context)
    }
    
    func updateUserDataAfterTest(userData:UserData, context:NSManagedObjectContext){
        let userID = userData.userID
        let request: NSFetchRequest<Users> = Users.fetchRequest()
        request.predicate = NSPredicate(format: "userID MATCHES %@", userID)
        do {
            let storedData = try context.fetch(request).first
            storedData?.userMistakes += Int64(userData.userMistakes)
            storedData?.userScores += Int64(userData.userScores)
            storedData?.userRightAnswers += Int64(userData.userRightAnswers)
            storedData?.userTestsCompleted += Int64(userData.userTestsCompleted)
        }
        catch {
            print ("Error fetching data \(error)")
        }
        saveData(data: context)
    }
    
    func loadAllWordsByUserID(userID: String, data: NSManagedObjectContext)->[Word]{
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.predicate = NSPredicate(format: "wrdUserID MATCHES %@", userID)
        do {
            let array = try data.fetch(request)
            
            return array
        }
        catch { print ("Error fetching data \(error)")
            return [Word]()
        }
    }
    
    func getAllWordsForDownloadedDictionary(userID: String, dicID:String, context: NSManagedObjectContext)->[WordsPair]{
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.predicate = NSPredicate(format: "wrdUserID MATCHES %@", userID)
        var wordsArray = [WordsPair]()
        do {
            let allUserWords = try context.fetch(request)
            let wordsForDic = allUserWords.filter({$0.wrdDicID == dicID})
            for word in wordsForDic{
                let wordsPair = WordsPair(
                    wrdWord: word.wrdWord!,
                    wrdTranslation: word.wrdTranslation!,
                    wrdDicID: word.wrdDicID!,
                    wrdUserID: word.wrdUserID!,
                    wrdID: word.wrdID!,
                    wrdImageFirestorePath: word.wrdImageFirestorePath ?? "",
                    wrdImageName: word.imageName ?? "",
                    wrdReadOnly: word.wrdReadOnly,
                    wrdParentDictionary: word.parentDictionary!,
                    wrdAddDate: word.wrdAddDate!)
                wordsArray.append(wordsPair)
            }
        }
        catch { print ("Error fetching data \(error)")
        }
        return wordsArray
    }
    
    func loadWordByDictionary(user: String, word:String, dicID:String, data: NSManagedObjectContext)->[Word]{
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.predicate = NSPredicate(format: "wrdDicID MATCHES %@", dicID)
        do {
            let allUserWords = try data.fetch(request)
            let wordsByDictionary = allUserWords.filter({$0.wrdDicID == dicID})
            let wordArray = wordsByDictionary.filter({$0.wrdWord == word})
            return wordArray
        }
        catch { print ("Error fetching data \(error)")
            return [Word]()
        }
    }

    mutating func loadCurrentUserData(userID: String, data: NSManagedObjectContext ){
        let request: NSFetchRequest<Users> = Users.fetchRequest()
        request.predicate = NSPredicate(format: "userID MATCHES %@", userID)
        do {
            usersArray = try data.fetch(request)
        }
        catch { print ("Error fetching data \(error)") }
    }
    
    func loadUserData(userEmail: String, data: NSManagedObjectContext , with request: NSFetchRequest<Users> = Users.fetchRequest())->[Users]{
        request.predicate = NSPredicate(format: "userEmail MATCHES %@", userEmail)
        do {
            let userArray = try data.fetch(request)
            return userArray
        }
        catch { print ("Error fetching data \(error)") }
        return [Users]()
    }
    
    func isNetworkUserExist(userID: String, data: NSManagedObjectContext)->Bool{
        let request: NSFetchRequest<NetworkUser> = NetworkUser.fetchRequest()
        request.predicate = NSPredicate(format: "nuID MATCHES %@", userID)
        var userExist = Bool()
        do {
            let userArray = try data.fetch(request)
            if !userArray.isEmpty{
                userExist = true
            }
        }
        catch { print ("Error fetching data \(error)") }
        return userExist
    }
    
    func loadAllNetworkUsers(data:NSManagedObjectContext)->[NetworkUser]{
        let request: NSFetchRequest<NetworkUser> = NetworkUser.fetchRequest()
        var usersArray = [NetworkUser]()
        do {
            let array = try data.fetch(request)
            usersArray = array
        }
        catch { print ("Error fetching data \(error)") }
        return usersArray
    }
    
    func getAllNetworkUsers(context:NSManagedObjectContext)->[NetworkUserData]{
        let request: NSFetchRequest<NetworkUser> = NetworkUser.fetchRequest()
        var netUsersArray = [NetworkUserData]()
        do {
            let usersArray = try context.fetch(request)
            for user in usersArray{
                let networkUser = NetworkUserData(
                    userID: user.nuID!,
                    userName: user.nuName!,
                    userCountry: user.nuCountry ?? "",
                    userNativeLanguage: user.nuNativeLanguage ?? "",
                    userBirthDate: user.nuBirthDate ?? "",
                    userRegisterDate: user.nuRegisterDate!,
                    userAvatarFirestorePath: user.nuFirebaseAvatarPath ?? "",
                    userShowEmail: user.nuShowEmail,
                    userEmail: user.nuEmail ?? "",
                    userScores: Int(user.nuScores),
                    userLocalAvatar: user.nuLocalAvatar,
                    userTestsCompleted: Int(user.nuTestsCompleted),
                    userMistakes: Int(user.nuMistakes),
                    userRightAnswers: Int(user.nuRightAnswers),
                    userLikes: Int(user.nuLikes))
                netUsersArray.append(networkUser)
            }
        }
        catch { print ("Error fetching data \(error)") }
        return netUsersArray
    }
    
    func loadNetworkUserByID(userID:String, data:NSManagedObjectContext)->NetworkUser{
        let request: NSFetchRequest<NetworkUser> = NetworkUser.fetchRequest()
        request.predicate = NSPredicate(format: "nuID MATCHES %@", userID)
        var userData = NetworkUser()
        do {
            let usersArray = try data.fetch(request)
            userData = usersArray.first ?? NetworkUser()
        }
        catch { print ("Error fetching data \(error)") }
        return userData
    }
    
    func getNetworkUserByID(userID:String, data:NSManagedObjectContext)->NetworkUserData?{
        let request: NSFetchRequest<NetworkUser> = NetworkUser.fetchRequest()
        var userData = [NetworkUserData]()
        do {
            let usersArray = try data.fetch(request)
            for user in usersArray{
                let netUserData = NetworkUserData(
                    userID: user.nuID!,
                    userName: user.nuName!,
                    userCountry: user.nuCountry ?? "",
                    userNativeLanguage: user.nuNativeLanguage ?? "",
                    userBirthDate: user.nuBirthDate ?? "",
                    userRegisterDate: user.nuRegisterDate!,
                    userAvatarFirestorePath: user.nuFirebaseAvatarPath ?? "",
                    userShowEmail: user.nuShowEmail,
                    userEmail: user.nuEmail ?? "",
                    userScores: Int(user.nuScores),
                    userLocalAvatar: user.nuLocalAvatar ?? "",
                    userTestsCompleted: Int(user.nuTestsCompleted),
                    userMistakes: Int(user.nuMistakes),
                    userRightAnswers: Int(user.nuRightAnswers),
                    userLikes: Int(user.nuLikes)
                )
                userData.append(netUserData)
            }
        }
        catch { print ("Error fetching data \(error)") }
        return userData.first
    }
    
    func convertNetworkUserToNetworkUserData(userID:String, context:NSManagedObjectContext)->NetworkUserData?{
        let request: NSFetchRequest<NetworkUser> = NetworkUser.fetchRequest()
        request.predicate = NSPredicate(format: "nuID MATCHES %@", userID)
        var result : NetworkUserData?
        do {
            let networkUser = try context.fetch(request).first
                let netUserData = NetworkUserData(
                    userID: networkUser!.nuID!,
                    userName: networkUser!.nuName!,
                    userCountry: networkUser?.nuCountry ?? "",
                    userNativeLanguage: networkUser?.nuNativeLanguage ?? "",
                    userBirthDate: networkUser?.nuBirthDate ?? "",
                    userRegisterDate: networkUser!.nuRegisterDate!,
                    userAvatarFirestorePath: networkUser?.nuFirebaseAvatarPath ?? "",
                    userShowEmail: networkUser?.nuShowEmail ?? false,
                    userEmail: networkUser?.nuEmail ?? "",
                    userScores: Int(networkUser?.nuScores ?? 0),
                    userLocalAvatar: networkUser?.nuLocalAvatar ?? "",
                    userTestsCompleted: Int(networkUser?.nuTestsCompleted ?? 0),
                    userMistakes: Int(networkUser?.nuMistakes ?? 0),
                    userRightAnswers: Int(networkUser?.nuRightAnswers ?? 0),
                    userLikes: Int(networkUser?.nuLikes ?? 0)
                )
                result = netUserData
        }
        catch { print ("Error fetching data \(error)") }
        return result
    }
    
    func loadUserDataByID(userID: String, context: NSManagedObjectContext)->UserData?{
        let request: NSFetchRequest<Users> = Users.fetchRequest()
        request.predicate = NSPredicate(format: "userID MATCHES %@", userID)
        var queryResult : UserData?
        do {
            let userArray = try context.fetch(request)
            let data = userArray.first
            queryResult = UserData(
                userID: data?.userID ?? "",
                userName: data?.userName ?? "",
                userBirthDate: data?.userBirthDate ?? "",
                userCountry: data?.userCountry ?? "",
                userAvatarFirestorePath: data?.userAvatarFirestorePath ?? "",
                userAvatarExtention: data?.userAvatarExtention ?? "",
                userNativeLanguage: data?.userNativeLanguage ?? "",
                userScores: Int(data?.userScores ?? 0),
                userShowEmail: data?.userShowEmail ?? false,
                userEmail: data?.userEmail ?? "",
                userSyncronized: data?.userSyncronized ?? true,
                userType: data?.userType ?? "",
                userRegisterDate: data?.userRegisterDate ?? "",
                userInterfaceLanguage: data?.userInterfaceLanguage ?? "",
                userMistakes: Int(data?.userMistakes ?? 0),
                userRightAnswers: Int(data?.userRightAnswers ?? 0),
                userTestsCompleted: Int(data?.userTestsCompleted ?? 0)
            )
           // return queryResult
        } catch {
            print ("Error fetching data \(error)")
        }
       
        return queryResult
    }
    
    
    func saveData(data: NSManagedObjectContext){
        do {
            try data.save()
        }
        catch {
            print("Error saving data \(error)")
        }
    }
    
    func createStatisticRecord(statisticData:StatisticData, context: NSManagedObjectContext){
        let newStatisticData = Statistic(context: context)
        newStatisticData.statID = statisticData.statID
        newStatisticData.statDate = statisticData.statDate
        newStatisticData.statTestIdentifier = statisticData.statTestIdentifier
        newStatisticData.statUserID = statisticData.statUserID
        newStatisticData.statDicID = statisticData.statDicID
        newStatisticData.statMistakes = Int64(statisticData.statMistekes)
        newStatisticData.statScores = Int64(statisticData.statScores)
        newStatisticData.statRightAnswers = Int64(statisticData.statRightAnswers)
        newStatisticData.statSyncronized = statisticData.statSyncronized
        saveData(data: context)
    }
    
    func loadAllStatisticForUser(userID:String, context:NSManagedObjectContext)->[StatisticData]{
        let request: NSFetchRequest<Statistic> = Statistic.fetchRequest()
        request.predicate = NSPredicate(format: "statUserID MATCHES %@", userID)
        var statisticData = [StatisticData]()
        do {
            let array = try context.fetch(request)
            for data in array{
                let statDataElement = StatisticData(
                    statID: data.statID ?? "",
                    statDate: data.statDate ?? "",
                    statMistekes: Int(data.statMistakes),
                    statDicID: data.statDicID ?? "",
                    statScores: Int(data.statScores),
                    statUserID: data.statUserID ?? "",
                    statTestIdentifier: data.statTestIdentifier ?? "", 
                    statRightAnswers: Int(data.statRightAnswers),
                    statSyncronized: data.statSyncronized)
                statisticData.append(statDataElement)
            }
        } catch {
            print ("Error fetching data \(error)")
        }
        return statisticData
    }
    
    func getTotalStatisticForUser(userID:String, context:NSManagedObjectContext)->[TotalStatistic]{
        let request: NSFetchRequest<Statistic> = Statistic.fetchRequest()
        request.predicate = NSPredicate(format: "statUserID MATCHES %@", userID)
        var totalStatistic = [TotalStatistic]()
        do {
            let statArray = try context.fetch(request)
           let  totalStat = TotalStatistic(
                scores: Int(statArray.reduce(0) { $0 + $1.statScores }),
                testRuns: statArray.count,
                mistakes: Int(statArray.reduce(0) { $0 + $1.statMistakes}),
                rightAnswers: Int(statArray.reduce(0) { $0 + $1.statRightAnswers }))
            totalStatistic.append(totalStat)
        } catch {
            print ("Error fetching data \(error)")
        }
        return totalStatistic
    }
    
    func setDeletedStatusForDictionary(data: NSManagedObjectContext, dicID: String){
            let requestDictionary: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()
            requestDictionary.predicate = NSPredicate(format: "dicID MATCHES %@", dicID)
            do {
                let array = try data.fetch(requestDictionary)
                array.first?.dicDeleted = true
                saveData(data: data)
            } catch {print ("Error fetching data \(error)")}
          
    }
    
    func setDeletedStatusForWord(data: NSManagedObjectContext, wrdID: String){
            let requestDictionary: NSFetchRequest<Word> = Word.fetchRequest()
            requestDictionary.predicate = NSPredicate(format: "wrdID MATCHES %@", wrdID)
            do {
                let array = try data.fetch(requestDictionary)
                array.first?.wrdDeleted = true
                saveData(data: data)
            } catch {print ("Error fetching data \(error)")}
           
    }
    
    func setDeletedStatusForWordsInDictionary(data: NSManagedObjectContext, dicID: String){
        
            let requestDictionary: NSFetchRequest<Word> = Word.fetchRequest()
            requestDictionary.predicate = NSPredicate(format: "wrdDicID MATCHES %@", dicID)
            do {
                let array = try data.fetch(requestDictionary)
                for word in array{
                    word.wrdDeleted = true
                }
                
            } catch {print ("Error fetching data \(error)")}
        saveData(data: data)
    }
 
    func setSyncronizedStatusForDictionary(data: NSManagedObjectContext, dicID:String, sync:Bool){
        let requestDictionary: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()
        requestDictionary.predicate = NSPredicate(format: "dicID MATCHES %@", dicID)
        switch sync{
        case true:
            do {
                let array = try data.fetch(requestDictionary)
                for element in array{
                    element.dicSyncronized = true
                }
            } catch {print ("Error fetching data \(error)")}
        case false:
            do {
                let array = try data.fetch(requestDictionary)
                for element in array{
                    element.dicSyncronized = false
                }
            } catch {print ("Error fetching data \(error)")}
        }
        saveData(data: data)
    }
    
    func setLikeStatusForDictionary(context: NSManagedObjectContext, dicID:String, userID:String, sync:Bool){
        let requestDictionary: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()
        requestDictionary.predicate = NSPredicate(format: "dicID MATCHES %@", dicID)
        switch sync{
        case true:
            do {
                let array = try context.fetch(requestDictionary)
                let filteredArray = array.filter({$0.dicUserID == userID})
                for element in filteredArray{
                    element.dicLike = true
                }
            } catch {print ("Error fetching data \(error)")}
        case false:
            do {
                let array = try context.fetch(requestDictionary)
                let filteredArray = array.filter({$0.dicUserID == userID})
                for element in filteredArray{
                    element.dicLike = false
                }
            } catch {print ("Error fetching data \(error)")}
        }
        saveData(data: context)
    }
    
    func setSyncronizedStatusForWordsInDictionary(data: NSManagedObjectContext, dicID:String, sync:Bool){
        let requestDictionary: NSFetchRequest<Word> = Word.fetchRequest()
        requestDictionary.predicate = NSPredicate(format: "wrdDicID MATCHES %@", dicID)
        switch sync{
        case true:
            do {
                let array = try data.fetch(requestDictionary)
                for element in array{
                    element.wrdSyncronized = true
                }
            } catch {print ("Error fetching data \(error)")}
        case false:
            do {
                let array = try data.fetch(requestDictionary)
                for element in array{
                    element.wrdSyncronized = false
                }
            } catch {print ("Error fetching data \(error)")}
        }
        saveData(data: data)
    }
    
    func setWasSynchronizedStatusForWord(data: NSManagedObjectContext, wrdID:String, sync:Bool){
        let requestWord: NSFetchRequest<Word> = Word.fetchRequest()
        requestWord.predicate = NSPredicate(format: "wrdID MATCHES %@", wrdID)
       
        switch sync{
        case true:
            do {
                let array = try data.fetch(requestWord)
                for word in array{
                    word.wrdSyncronized = true
                }
            } catch {print ("Error fetching data \(error)")}
        case false:
            do {
                let array = try data.fetch(requestWord)
                for word in array{
                    word.wrdSyncronized = false
                }
               
            } catch {print ("Error fetching data \(error)")}
        }
        saveData(data: data)
    }
    
    func setCountsInParentDictionary(increment:Bool, isSetImage:Bool, dicID:String, context:NSManagedObjectContext){
        let parentDic = loadParentDictionaryForWord(dicID: dicID, data: context)
        
        switch increment {
        case true:
            parentDic.first?.dicWordsCount += 1
            if isSetImage{
                parentDic.first?.dicImagesCount += 1
            }
            saveData(data: context)
        case false:
            parentDic.first?.dicWordsCount -= 1
            saveData(data: context)
        }
    }
    
    func setImagesCountForDictionary(dicID:String, increment:Bool, context:NSManagedObjectContext){
        let parentDic = loadParentDictionaryForWord(dicID: dicID, data: context)
        switch increment {
        case true:
            parentDic.first?.dicImagesCount += 1
        case false:
            parentDic.first?.dicImagesCount -= 1
            
        }
        saveData(data: context)
    }
    
    func setWordsCountForDictionary(dicID:String, increment:Bool, context:NSManagedObjectContext){
        let parentDic = loadParentDictionaryForWord(dicID: dicID, data: context)
        switch increment {
        case true:
            parentDic.first?.dicWordsCount += 1
        case false:
            parentDic.first?.dicWordsCount -= 1
            
        }
        saveData(data: context)
    }
    
    func isUserExistInCoreData(userEmail:String, context:NSManagedObjectContext)->Bool{
        let request: NSFetchRequest<Users> = Users.fetchRequest()
        request.predicate = NSPredicate(format: "userEmail MATCHES %@", userEmail)
        var answer = Bool()
        do {
            let usersArray = try context.fetch(request)
            if usersArray.isEmpty{
                answer = false
            } else {
                answer = true
            }
        }
        catch { print ("Error fetching data \(error)") }
        return answer
    }
    
    func setSyncronizedStatusForUser(userID:String, status:Bool, context:NSManagedObjectContext){
        let request: NSFetchRequest<Users> = Users.fetchRequest()
        request.predicate = NSPredicate(format: "userID MATCHES %@", userID)
        do {
            let usersArray = try context.fetch(request)
            usersArray.first?.userSyncronized = status
        }
        catch { print ("Error fetching data \(error)") }
       saveData(data: context)
    }
    
    func updateDownloadedDictionaryData(dicID:String, userID:String, field:String, argument:Any, context:NSManagedObjectContext){
        let request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()
        request.predicate = NSPredicate(format: "dicID MATCHES %@", dicID)
        do {
            let dictionariesArray = try context.fetch(request)
            let filteredByUserArray = dictionariesArray.filter({$0.dicUserID == userID})
            if let dictionary = filteredByUserArray.first {
                dictionary.setValue(argument, forKey: field)
            }
        }
        catch { print ("Error fetching data \(error)") }
        saveData(data: context)
    }
    
    func updateDownloadedWordData(wrdID:String, userID:String, field:String, argument:Any, context:NSManagedObjectContext){
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.predicate = NSPredicate(format: "wrdID MATCHES %@", wrdID)
        do {
            let wordsArray = try context.fetch(request)
            let filteredByUserArray = wordsArray.filter({$0.wrdUserID == userID})
            if let word = filteredByUserArray.first {
                word.setValue(argument, forKey: field)
            }
        }
        catch { print ("Error fetching data \(error)") }
        saveData(data: context)
    }
    
    func updateUserFieldData(userID:String, field:String, argument:Any, context:NSManagedObjectContext){
        let request: NSFetchRequest<Users> = Users.fetchRequest()
        request.predicate = NSPredicate(format: "userID MATCHES %@", userID)
        do {
            let usersArray = try context.fetch(request)
            if let user = usersArray.first {
                user.setValue(argument, forKey: field)
            }
        }
        catch { print ("Error fetching data \(error)") }
        saveData(data: context)
    }
    
    func updateNetworkUserFieldData(userID:String, field:String, argument:Any, context:NSManagedObjectContext){
        let request: NSFetchRequest<NetworkUser> = NetworkUser.fetchRequest()
        request.predicate = NSPredicate(format: "nuID MATCHES %@", userID)
        do {
            let usersArray = try context.fetch(request)
            if let user = usersArray.first {
                user.setValue(argument, forKey: field)
            }
        }
        catch { print ("Error fetching data \(error)") }
        saveData(data: context)
    }
    
    func updateStatisticFieldData(statID:String, field:String, argument:Any, context:NSManagedObjectContext){
        let request: NSFetchRequest<Statistic> = Statistic.fetchRequest()
        request.predicate = NSPredicate(format: "statID MATCHES %@", statID)
        do {
            let statArray = try context.fetch(request)
            if let stat = statArray.first {
                stat.setValue(argument, forKey: field)
            }
        }
        catch { print ("Error fetching data \(error)") }
        saveData(data: context)
    }
    
}
