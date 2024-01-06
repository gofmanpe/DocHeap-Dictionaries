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
                // Получаем путь к директории Documents для конкретного пользователя
                guard let userDocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(userID) else {
                    
                    print("Error getting user documents directory")
                    return
                }
                // Проверяем существование директории и создаем ее, если не существует
                if !FileManager.default.fileExists(atPath: userDocumentsDirectory.path) {
                    do {
                        try FileManager.default.createDirectory(at: userDocumentsDirectory, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        
                        print("Error creating user documents directory: \(error)")
                        return
                    }
                }
                // Сохраняем изображение в локальной директории
                let localImageURL = userDocumentsDirectory.appendingPathComponent("userAvatar.jpg")
                do {
                    try data.write(to: localImageURL)
                    
                    //print("Image saved locally at \(localImageURL.path)")

                    // После сохранения изображения, вызываем замыкание
                    completion()
                } catch {
                   
                    print("Error saving image locally: \(error)")
                }
            case .failure(let error):
              
                print("Error downloading image: \(error)")
                // Обработка ошибок, если необходимо
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
                // Получаем путь к директории Documents для конкретного пользователя
                guard let userDocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(userID)/\(dicID)") else {
                   
                    print("Error getting user documents directory")
                    return
                }
                // Проверяем существование директории и создаем ее, если не существует
                if !FileManager.default.fileExists(atPath: userDocumentsDirectory.path) {
                    do {
                        try FileManager.default.createDirectory(at: userDocumentsDirectory, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        
                        print("Error creating user documents directory: \(error)")
                        return
                    }
                }
                // Сохраняем изображение в локальной директории
                let localImageURL = userDocumentsDirectory.appendingPathComponent(imageName)
                do {
                    try data.write(to: localImageURL)
                   
                  //  print("Image saved locally at \(localImageURL.path)")

                    // После сохранения изображения, вызываем замыкание
                    completion()
                } catch {
                   
                    print("Error saving image locally: \(error)")
                }
            case .failure(let error):
              
                print("Error downloading image: \(error)")
                // Обработка ошибок, если необходимо
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
                // Получаем путь к директории Documents для конкретного пользователя
                guard let userDocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(userID)") else {
                   
                    print("Error getting user documents directory")
                    return
                }
                // Проверяем существование директории и создаем ее, если не существует
                if !FileManager.default.fileExists(atPath: userDocumentsDirectory.path) {
                    do {
                        try FileManager.default.createDirectory(at: userDocumentsDirectory, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        
                        print("Error creating user documents directory: \(error)")
                        return
                    }
                }
                // Сохраняем изображение в локальной директории
                let localImageURL = userDocumentsDirectory.appendingPathComponent(imageName)
                do {
                    try data.write(to: localImageURL)
                   
                  //  print("Image saved locally at \(localImageURL.path)")

                    // После сохранения изображения, вызываем замыкание
                    completion()
                } catch {
                   
                    print("Error saving image locally: \(error)")
                }
            case .failure(let error):
              
                print("Error downloading image: \(error)")
                // Обработка ошибок, если необходимо
            }
        }
    }
    
//    func deleteImageFolderFromStorage1(folderURL: String, completion: @escaping (Error?) -> Void) {
//        guard let url = URL(string: folderURL) else {
//            completion(nil)
//            return
//        }
//
//        AF.request(url, method: .delete).response { response in
//            if let error = response.error {
//                print("Error deleting image folder: \(error)")
//            } else {
//                print("Image folder deleted successfully")
//            }
//            completion(response.error)
//        }
//    }
    
//    func deleteFolderFromStorage1(folderPath: String, completion: @escaping (Error?) -> Void) {
//        let storage = Storage.storage()
//        let storageRef = storage.reference(withPath: folderPath)
//
//        // Получаем список файлов в папке
//        storageRef.listAll { (result, error) in
//            if let error = error {
//                completion(error)
//                return
//            } else {
//                if let allItems = result{
//                    // Удаляем каждый файл в папке
//                    for item in allItems.items {
//                        item.delete { error in
//                            if let error = error {
//                                print("Error deleting file: \(error)")
//                            }
//                        }
//                        
//                    }
//                }
//                
//            }
//            // Удаляем саму папку
//            storageRef.delete { error in
//                completion(error)
//            }
//        }
//    }
//    
}
