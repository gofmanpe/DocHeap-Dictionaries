//
//  customData.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 20.12.23.
//

import Foundation

struct DicOwnerData {
    let ownerName:String
    let ownerID:String
}


struct SharedDictionary{
    let dicID: String
    let dicDescription:String
    let dicName:String
    let dicWordsCount:Int
    let dicLearnLang:String
    let dicTransLang:String
    let dicAddDate:String
    let dicUserID:String
    let dicImagesCount:Int
    var dicDownloaded:Bool
    let dicDownloadedUsers:[String]
    let dicLikes:[String]
}

struct SharedDictionaryShortData{
    let dicID: String
    let dicName:String
    let dicLikes:[String]
}

struct SharedWord{
    let wrdWord:String
    let wrdTranslation:String
    let wrdDicID:String
    let wrdOwnerID:String
    let wrdID:String
    let wrdImageFirestorePath:String
    let wrdImageName:String
}

struct WordsPair{
    let wrdWord:String
    let wrdTranslation:String
    let wrdDicID:String
    let wrdUserID:String
    let wrdID:String
    let wrdImageFirestorePath:String
    let wrdImageName:String
    let wrdReadOnly:String
    
}

struct LanguagesArray{
    let lang: String
    let langValue: String
}

struct MonthArray{
    let value: String
    let name: String
}

struct DictionaryLike{
    let userID: String
    let likeStatus: Bool
}

struct DictionaryCounts{
    let dicID:String
    let likesCount:String
    let downloadsCount:String
    let messagesCount:String
}

struct UserData{
    let userID: String
    let userName: String
    let userBirthDate: String
    let userCountry: String
    let userAvatarFirestorePath: String
    let userAvatarExtention: String
    let userNativeLanguage: String
    let userScores: Int
    let userShowEmail: Bool
    let userEmail: String
    let userSyncronized: Bool
    let userType: String
    let userRegisterDate: String
    let userInterfaceLanguage: String
}

struct NetworkUserData{
    let userID: String
    let userName:String
    let userCountry:String
    let userNativeLanguage:String
    let userBirthDate:String
    let userRegisterDate:String
    let userAvatarFirestorePath:String
    let userShowEmail:Bool
    let userEmail:String
    let userScores:Int
}

struct ChatMessage{
    let msgID: String
    let msgBody: String
    let msgDateTime: String
    let msgDicID: String
    let msgSenderID: String
    let msgOrdering: Int
    let msgSyncronized: Bool
}

struct Tests {
    var identifier: String
    var name: String
    var image: String
    var testDescription: String
}

struct StatisticData{
    let statID: String
    let statDate: String
    let statMistekes: Int
    let statDicID: String
    let statScores: Int
    let statUserID: String
    let statTestIdentifier: String
    let statRightAnswers: Int
    let statSyncronized: Bool
}

struct StatisticForTest{
    let statTestImage: String
    let statRightAnswers: Int
    let statMistakes: Int
    let statLaunches: Int
    let statScores: Int
}
