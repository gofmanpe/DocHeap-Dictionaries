//
//  Alamo.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 22.11.23.
//
import Alamofire
import Foundation
import FirebaseStorage

struct Alamo {
    
    func downloadAndSaveAvatar(from url: String, forUser userID: String, completion: @escaping () -> Void) {
        guard let imageURL = URL(string: url) else {
            
            print("Invalid URL")
            return
        }
        AF.download(imageURL).responseData { response in
            switch response.result {
            case .success(let data):
                guard let userDocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(userID) else {
                    print("Error getting user documents directory")
                    return
                }
                if !FileManager.default.fileExists(atPath: userDocumentsDirectory.path) {
                    do {
                        try FileManager.default.createDirectory(at: userDocumentsDirectory, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print("Error creating user documents directory: \(error)")
                        return
                    }
                }
                let localImageURL = userDocumentsDirectory.appendingPathComponent("userAvatar.jpg")
                do {
                    try data.write(to: localImageURL)
                    completion()
                } catch {
                    print("Error saving image locally: \(error)")
                }
            case .failure(let error):
                print("Error downloading image: \(error)")
            }
        }
    }
    
    func downloadAndSaveImage(fromURL: String, userID: String, dicID: String, imageName:String, completion: @escaping () -> Void) {
        guard let imageURL = URL(string: fromURL) else {
            print("Invalid URL")
            return
        }
        AF.download(imageURL).responseData { response in
            switch response.result {
            case .success(let data):
                guard let userDocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(userID)/\(dicID)") else {
                    print("Error getting user documents directory")
                    return
                }
                if !FileManager.default.fileExists(atPath: userDocumentsDirectory.path) {
                    do {
                        try FileManager.default.createDirectory(at: userDocumentsDirectory, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print("Error creating user documents directory: \(error)")
                        return
                    }
                }
                let localImageURL = userDocumentsDirectory.appendingPathComponent(imageName)
                do {
                    try data.write(to: localImageURL)
                    completion()
                } catch {
                    print("Error saving image locally: \(error)")
                }
            case .failure(let error):
                print("Error downloading image: \(error)")
            }
        }
    }
    
    func downloadOtherUserAvatar(fromURL: String, userID: String, imageName:String, completion: @escaping () -> Void) {
        guard let imageURL = URL(string: fromURL) else {
            print("Invalid URL")
            return
        }
        AF.download(imageURL).responseData { response in
            switch response.result {
            case .success(let data):
                guard let userDocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(userID)") else {
                    print("Error getting user documents directory")
                    return
                }
                if !FileManager.default.fileExists(atPath: userDocumentsDirectory.path) {
                    do {
                        try FileManager.default.createDirectory(at: userDocumentsDirectory, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print("Error creating user documents directory: \(error)")
                        return
                    }
                }
                let localImageURL = userDocumentsDirectory.appendingPathComponent(imageName)
                do {
                    try data.write(to: localImageURL)
                    completion()
                } catch {
                    print("Error saving image locally: \(error)")
                }
            case .failure(let error):
                print("Error downloading image: \(error)")
            }
        }
    }
    
    func downloadChatUserAvatar(url:String, senderID:String, userID:String, completion: @escaping (String) -> Void){
        var avatarExt = String()
        if let imageUrl = URL(string: url){
            let destination: DownloadRequest.Destination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                avatarExt = imageUrl.pathExtension
                let fileURL = documentsURL.appendingPathComponent("\(userID)/\(senderID).\(avatarExt)")
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            AF.download(imageUrl, to: destination).response { response in
//                guard let imagePath = response.fileURL?.path else {
//                    return
//                }
                completion("\(senderID).\(avatarExt)")
            }
        }
    }
    
}
