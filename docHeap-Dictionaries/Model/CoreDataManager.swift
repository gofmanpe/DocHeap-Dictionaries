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
    
//    func createMessage(messagesArray:[ChatMessage], context: NSManagedObjectContext){
//        for message in messagesArray{
//            let newMessage = DicMessage(context:context)
//            newMessage.msgID = message.msgID
//            newMessage.msgBody = message.msgBody
//            newMessage.msgSenderID = message.msgSenderID
//            newMessage.msgDateTime = message.msgDateTime
//            newMessage.msgDicID = message.msgDicID
//            newMessage.msgSyncronized = true
//            newMessage.msgOrdering = Int64(message.msgOrdering)
//        }
//        saveData(data: context)
//    }
    
    func loadWordDataByID(wrdID: String, data: NSManagedObjectContext)->[Word]{
         let request: NSFetchRequest<Word> = Word.fetchRequest()
             request.predicate = NSPredicate(format: "wrdID MATCHES %@", wrdID)
        var oneWordArray = [Word]()
         do {
            oneWordArray = try data.fetch(request)
            
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
    
    func loadAllDictionariesByUserID(userID:String, context:NSManagedObjectContext)->[Dictionary]{
        let request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()
            request.predicate = NSPredicate(format: "dicUserID MATCHES %@", userID)
       var allDictionaryArray = [Dictionary]()
        do {
            allDictionaryArray = try context.fetch(request)
           
        }
        catch { print ("Error fetching data \(error)") }
       return allDictionaryArray
    }
    
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
            print("Array before filtering count: \(oneDictionaryArray.count)\n")
            let filteredArray = oneDictionaryArray.filter({$0.dicUserID == userID})
            print("Array for del count: \(filteredArray.count)\n")
            for dictionary in filteredArray {
                context.delete(dictionary)
            }
           saveData(data: context)
        }
        catch { print ("Error fetching data \(error)") }
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
    
    mutating func loadWordsWithImagesForSelectedDictionary(data: NSManagedObjectContext, dicID: String, with request: NSFetchRequest<Word> = Word.fetchRequest()){
        
        request.predicate = NSPredicate(format: "parentDictionary.dicID MATCHES %@", dicID)
        request.sortDescriptors = [NSSortDescriptor(key: "wrdWord", ascending: true)]
        do {
            wordsArray = try data.fetch(request)
          //  print("All words count: \(wordsArray.count)")
        }
        catch {
            print ("Error fetching data \(error)")
        }
        wordsWithImagesArray = wordsArray.filter({$0.wrdImageIsSet == true})
        //print("Array with images count: \(wordsWithImagesArray.count)")
        
    }
    
    mutating func loadWordsForSelectedDictionary(dicID: String, userID:String, data: NSManagedObjectContext, with request: NSFetchRequest<Word> = Word.fetchRequest()){
        
        request.predicate = NSPredicate(format: "parentDictionary.dicID MATCHES %@", dicID)
        request.sortDescriptors = [NSSortDescriptor(key: "wrdWord", ascending: true)]
        do {
            let array = try data.fetch(request)
            let undeletedWords = array.filter({$0.wrdDeleted == false})
            wordsArray = undeletedWords.filter({$0.wrdUserID == userID})
        }
        catch {
            print ("Error fetching data \(error)")
        }
    }
    
    func getWordsForDictionary(dicID: String, userID:String, data: NSManagedObjectContext)->[Word]{
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.predicate = NSPredicate(format: "wrdDicID MATCHES %@", dicID)
        var requestedWords = [Word]()
        do {
            let array = try data.fetch(request)
            let filterDeleted = array.filter({$0.wrdDeleted == false})
            requestedWords = filterDeleted.filter({$0.wrdUserID == userID})
        }
        catch {
            print ("Error fetching data \(error)")
        }
        return requestedWords
    }
    
    func getWordsForSharedDictionary(dicID: String, data: NSManagedObjectContext, with request: NSFetchRequest<Word> = Word.fetchRequest())->[Word]{
        
        request.predicate = NSPredicate(format: "parentDictionary.dicID MATCHES %@", dicID)
        request.sortDescriptors = [NSSortDescriptor(key: "wrdWord", ascending: true)]
        var sharedArray = [Word]()
        do {
            let array = try data.fetch(request)
            
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
    
    func getParentDictionaryData(dicID: String, userID:String, data: NSManagedObjectContext, with request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest())->Dictionary{
        request.predicate = NSPredicate(format: "dicID MATCHES %@", dicID)
        var parentDic = Dictionary()
        do {
            let dictionary = try data.fetch(request)
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
    
    func loadUserDictionaries(userID: String, data: NSManagedObjectContext)->[Dictionary]{
        let request: NSFetchRequest<Dictionary> = Dictionary.fetchRequest()
        request.predicate = NSPredicate(format: "dicUserID MATCHES %@", userID)
        request.sortDescriptors = [NSSortDescriptor(key: "dicAddDate", ascending: false)]
        var filteredArray = [Dictionary]()
        do {
            let array = try data.fetch(request)
            filteredArray = array.filter({$0.dicDeleted == false})
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
    
    func getMessagesByDicID(dicID:String, context:NSManagedObjectContext)->[ChatMessage]{
        let request: NSFetchRequest<DicMessage> = DicMessage.fetchRequest()
        request.predicate = NSPredicate(format: "msgDicID MATCHES %@", dicID)
        var messagesArray = [ChatMessage]()
        do {
            let array = try context.fetch(request)
            for message in array{
                let chatMessage = ChatMessage(
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
    
    func createChatMessage(message:ChatMessage, context:NSManagedObjectContext){
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
    
    func updateUserData(userData:UserData, context:NSManagedObjectContext){
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
    
    func loadNetworkUserByID(userID:String, data:NSManagedObjectContext)->NetworkUser{
        let request: NSFetchRequest<NetworkUser> = NetworkUser.fetchRequest()
        var userData = NetworkUser()
        do {
            let user = try data.fetch(request)
            userData = user.first ?? NetworkUser()
        }
        catch { print ("Error fetching data \(error)") }
        return userData
    }
    
    func loadUserDataByID(userID: String, context: NSManagedObjectContext)->[UserData]{
        let request: NSFetchRequest<Users> = Users.fetchRequest()
        request.predicate = NSPredicate(format: "userID MATCHES %@", userID)
        var queryResult = [UserData]()
        do {
            let userArray = try context.fetch(request)
            let data = userArray.first
            queryResult = [UserData(
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
                userInterfaceLanguage: data?.userInterfaceLanguage ?? "")]
            return queryResult
        }
        catch { print ("Error fetching data \(error)") }
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
                    statRightAnswers: Int(data.statRightAnswers))
                statisticData.append(statDataElement)
            }
        } catch {
            print ("Error fetching data \(error)")
        }
        return statisticData
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
    
    func updateUserData(userID:String, field:String, argument:Any, context:NSManagedObjectContext){
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
    
    
}
