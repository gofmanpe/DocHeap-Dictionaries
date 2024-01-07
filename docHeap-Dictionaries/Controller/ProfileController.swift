//
//  SettingsController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 26.03.23.
//

import UIKit
import Alamofire
import CoreData
import FirebaseFirestore
import FirebaseStorage

class ProfileController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UpdateView {
    
//MARK: - Protocols delegate functions
    func didUpdateView(sender: String) {
        setupUserData()
    }
    
//MARK: - Outlets
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var setAvatarButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var windowView: UIView!
    @IBOutlet weak var addInfoLabel: UILabel!
    @IBOutlet weak var registredLabel: UILabel!
    @IBOutlet weak var registerDateLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var nativeLangLabel: UILabel!
    @IBOutlet weak var scoresLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
//MARK: - Localization
    func localizeElements(){
        logoutButton.setTitle("profileVC_logout_button".localized, for: .normal)
        setAvatarButton.setTitle("profileVC_setAvatar_button".localized, for: .normal)
        registredLabel.text = "profileVC_registred_label".localized
        addInfoLabel.text = "profileVC_addInfo_label".localized
    }
    
//MARK: - Constants and variables
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let userDefaults = UserDefaults.standard
    private var selectedImage = UIImage()
    private var imageIsSet = false
    private var imageExtention = String()
    private var avatarName = String()
    private let mainModel = MainModel()
    private var coreDataManager = CoreDataManager()
    private var avatarURL: URL?
    private var firebase = Firebase()
    private var fireDB = Firestore.firestore()
    var currentUserData = [String:Any]()
    private var defaults = Defaults()
    private let sync = SyncModel()
    private var avatarFirestorePath = String()
    private var userData : Users?
//MARK: - Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeElements()
        setupUserData()
        elementsDesign()
        if mainModel.isInternetAvailable(){
            sync.syncUserDataWithFirebase(userID: mainModel.loadUserData().userID, context: context)
        } else {
            userData?.userSyncronized = false
            coreDataManager.saveData(data: context)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUserData()
    }
    
//MARK: - Controller functions
    func setupUserData(){
        userData = coreDataManager.loadUserDataByID(userID: mainModel.loadUserData().userID, data: context)
        nameLabel.text = userData?.userName
        birthDateLabel.text = userData?.userBirthDate
        countryLabel.text = userData?.userCountry
        nativeLangLabel.text = userData?.userNativeLanguage
        scoresLabel.text = String(userData?.userScores ?? 0)
    }

    func elementsDesign(){
        if userData?.userAvatarExtention != nil{
            let avaExtention = userData?.userAvatarExtention ?? ""
            avatarName = "userAvatar.\(avaExtention)"
            let avatarPath = "\(mainModel.loadUserData().userID)/\(avatarName)"
            userAvatar.image = UIImage(contentsOfFile:  mainModel.getDocumentsFolderPath().appendingPathComponent(avatarPath).path)
            userAvatar.layer.cornerRadius = userAvatar.frame.size.width/2
            userAvatar.layer.masksToBounds = false
            userAvatar.clipsToBounds = true
        } else {
            print("NO USER AVATAR\n")
        }
        emailLabel.text = userData?.userEmail
        registerDateLabel.text = userData?.userRegisterDate
        setAvatarButton.layer.cornerRadius = 5
        logoutButton.layer.cornerRadius = 5
        windowView.clipsToBounds = true
        windowView.layer.cornerRadius = 10
        windowView.layer.borderWidth = 0.5
        windowView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let imageFromGallery = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
                selectedImage = imageFromGallery
                imageIsSet = true
                if let imageUrl = info[.imageURL] as? URL {
                        imageExtention = imageUrl.pathExtension
                        }
                saveImageToAppDirectory(image: selectedImage, isImageSelected: true)
                uploadAvatarToStorage()
                let avatarFile = mainModel.getDocumentsFolderPath().appendingPathComponent("\(mainModel.loadUserData().userID)/\(avatarName)").path
                userAvatar.image = UIImage(contentsOfFile: avatarFile)
            } else {
                print("No IMAGE!")
            }
              picker.dismiss(animated: true, completion: nil)
        }
    
    func saveImageToAppDirectory(image: UIImage, isImageSelected: Bool) {
        if isImageSelected{
            avatarName = "userAvatar.\(imageExtention)"
            avatarURL = mainModel.getDocumentsFolderPath().appendingPathComponent("\(mainModel.loadUserData().userID)/\(avatarName)")
            userData?.userAvatarExtention = imageExtention
            coreDataManager.saveData(data: context)
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                do {
                    if let imageWithUrl = avatarURL{
                        try imageData.write(to: imageWithUrl)
                    } else {
                    }
                } catch {
                    print("Error saving image: \(error)")
                }
            }
        }
    }
    
    func uploadAvatarToStorage() {
        let storage = Storage.storage()
        let imageRef = storage.reference().child(mainModel.loadUserData().userID).child("userAvatar.\(imageExtention)")
        let localImageURL = avatarURL!
        imageRef.putFile(from: localImageURL, metadata: nil) { metadata, error in
            guard metadata != nil else { return }
            imageRef.downloadURL { url, error in
                guard let downloadURL = url else { return }
                self.userData?.userAvatarFirestorePath = downloadURL.absoluteString
                self.coreDataManager.saveData(data: self.context)
                self.updateAvatarURLInFirestore(userID: self.mainModel.loadUserData().userID, avatarURL: downloadURL.absoluteString)
            }
        }
    }

    func updateAvatarURLInFirestore(userID: String, avatarURL: String) {
        self.fireDB.collection("Users").document(userID).updateData(["userAvatarFirestorePath": avatarURL]) { error in
            if let error = error {
                print("Error updating avatar URL in Firestore: \(error)")
            }
        }
    }
    
    func popUpApear(){
            let overLayedView = EditProfileViewController()
            overLayedView.updateViewDelegate = self
            overLayedView.appear(sender: self)
    }
    
//MARK: - Actions
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        let accountType = mainModel.loadUserData().accType
        switch accountType{
        case "google":
            userDefaults.set("", forKey: "userID")
            userDefaults.set("", forKey: "userEmail")
            userDefaults.set("", forKey: "accType")
            userDefaults.set(false, forKey: "keepSigned")
            performSegue(withIdentifier: "logoutSegue", sender: self)
        case "auth":
            userDefaults.set("", forKey: "userID")
            userDefaults.set("", forKey: "accType")
            userDefaults.set(false, forKey: "keepSigned")
            performSegue(withIdentifier: "logoutSegue", sender: self)
        default:
            return
        }
        
    }
    
    @IBAction func setAvatarPressed(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        popUpApear()
    }

}
