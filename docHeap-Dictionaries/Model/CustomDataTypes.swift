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
struct LanguagesArray{
    let lang: String
    let langValue: String
}
struct UserDataFirebase{
    let userID: String
    let userName:String
    let userEmail:String
    let userCountry:Int
    let userNativeLanguage:String
    let userBirthDate:String
    let userRegisterDate:String
    let userScores:Int
}
struct MonthArray{
    let value: String
    let name: String
}

struct DictionaryLike{
    let userID: String
    let likeStatus: Bool
}

struct ChatMessage{
    let msgID: String
    let msgBody: String
    let msgSenderID: String
    let msgDicID: String
    let msgDateTime: String
    let msgSenderName: String
    let msgSenderAvatarPath: String
    let msgOrdering: Int
}
