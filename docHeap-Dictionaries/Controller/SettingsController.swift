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

class SettingsController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UpdateView, LogOutUser{
    
//MARK: - Protocols delegate functions
    func didUpdateView(sender: String) {
        setupUserData()
        elementsDesign()
    }
    func performToStart() {
        performSegue(withIdentifier: "logoutSegue", sender: self)
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
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var showEmailLabel: UILabel!
    @IBOutlet weak var emailSwitch: UISwitch!
    @IBOutlet weak var dateOfBirthNameLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var nativeLanguageNameLabel: UILabel!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var userInitials: UILabel!
    @IBOutlet weak var avatarBgView: UIView!
    @IBOutlet weak var aboutAppButton: UIButton!
    @IBOutlet weak var deleteAccButton: UIButton!
    
//MARK: - Localization
    func localizeElements(){
        logoutButton.setTitle("profileVC_logout_button".localized, for: .normal)
        setAvatarButton.setTitle("profileVC_setAvatar_button".localized, for: .normal)
        registredLabel.text = "profileVC_registred_label".localized
        addInfoLabel.text = "profileVC_addInfo_label".localized
        dateOfBirthNameLabel.text = "profileVC_dateOfBirth_label".localized
        countryNameLabel.text = "profileVC_country_label".localized
        nativeLanguageNameLabel.text = "profileVC_nativeLanguage_label".localized
        showEmailLabel.text = "profileVC_showEmail_label".localized
        profileLabel.text = "profileVC_profile_label".localized
        deleteAccButton.setTitle("profileVC_deleteAcc_button".localized, for: .normal)
        aboutAppButton.setTitle("profileVC_aboutApp_button".localized, for: .normal)
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
    private var userData : UserData?
    
//MARK: - Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeElements()
        setupUserData()
        elementsDesign()
        if mainModel.isInternetAvailable(){
            sync.syncUserDataWithFirebase(userID: mainModel.loadUserData().userID, context: context)
        } else {
            coreDataManager.setSyncronizedStatusForUser(userID: mainModel.loadUserData().userID, status: false, context: context)
            coreDataManager.saveData(data: context)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUserData()
    }
    
//MARK: - Controller functions
    func setupUserData(){
        guard let userData = coreDataManager.loadUserDataByID(userID: mainModel.loadUserData().userID, context: context) else {
            return
        }
        self.userData = userData
        nameLabel.text = userData.userName
        birthDateLabel.text = userData.userBirthDate
        countryLabel.text = userData.userCountry
        nativeLangLabel.text = userData.userNativeLanguage
        userInitials.text = getUserInitials(fullName: userData.userName)
        emailLabel.text = userData.userEmail
        registerDateLabel.text = userData.userRegisterDate
        if !userData.userAvatarExtention.isEmpty{
            let avaExtention = userData.userAvatarExtention
            avatarName = "userAvatar.\(avaExtention)"
            let avatarPath = "\(mainModel.loadUserData().userID)/\(avatarName)"
            userAvatar.image = UIImage(contentsOfFile:  mainModel.getDocumentsFolderPath().appendingPathComponent(avatarPath).path)
            userAvatar.isHidden = false
           // avatarBgView.isHidden = true
        } else {
            userAvatar.isHidden = true
            userInitials.text = getUserInitials(fullName: userData.userName)
           // avatarBgView.isHidden = false
        }
        if userData.userShowEmail{
            emailSwitch.isOn = true
        } else {
            emailSwitch.isOn = false
        }
    }
    
    func getUserInitials(fullName: String) -> String {
        let words = fullName.components(separatedBy: " ")
        var initials = ""
        for word in words {
            if let firstLetter = word.first {
                initials.append(firstLetter)
            }
        }
        return initials.uppercased()
    }
    
    func elementsDesign(){
        avatarBgView.layer.cornerRadius = avatarBgView.frame.size.width/2
        avatarBgView.layer.masksToBounds = false
        avatarBgView.clipsToBounds = true
        
        userAvatar.layer.cornerRadius = userAvatar.frame.size.width/2
        userAvatar.layer.masksToBounds = false
        userAvatar.clipsToBounds = true
        
        windowView.clipsToBounds = true
        windowView.layer.cornerRadius = 10
        windowView.layer.borderWidth = 0.5
        windowView.layer.borderColor = UIColor.lightGray.cgColor
        
        logoutButton.layer.cornerRadius = 5
        logoutButton.layer.shadowColor = UIColor.black.cgColor
        logoutButton.layer.shadowOpacity = 0.2
        logoutButton.layer.shadowOffset = .zero
        logoutButton.layer.shadowRadius = 2
        
        setAvatarButton.layer.cornerRadius = 5
        setAvatarButton.layer.shadowColor = UIColor.black.cgColor
        setAvatarButton.layer.shadowOpacity = 0.2
        setAvatarButton.layer.shadowOffset = .zero
        setAvatarButton.layer.shadowRadius = 2
        
        aboutAppButton.layer.cornerRadius = 5
        aboutAppButton.clipsToBounds = true
        aboutAppButton.layer.shadowColor = UIColor.black.cgColor
        aboutAppButton.layer.shadowOpacity = 0.2
        aboutAppButton.layer.shadowOffset = .zero
        aboutAppButton.layer.shadowRadius = 2
        
        deleteAccButton.layer.cornerRadius = 5
        deleteAccButton.layer.borderWidth = 1
        deleteAccButton.layer.borderColor = UIColor(named: "Wrong answer")?.cgColor
        deleteAccButton.layer.shadowColor = UIColor.black.cgColor
        deleteAccButton.layer.shadowOpacity = 0.2
        deleteAccButton.layer.shadowOffset = .zero
        deleteAccButton.layer.shadowRadius = 2
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
            coreDataManager.updateUserFieldData(userID: mainModel.loadUserData().userID, field: "userAvatarExtention", argument: imageExtention, context: context)
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
                self.coreDataManager.updateUserFieldData(
                    userID: self.mainModel.loadUserData().userID,
                    field: "userAvatarFirestorePath",
                    argument: downloadURL.absoluteString,
                    context: self.context)
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
    
    func popUpApear(sender:String){
        switch sender{
        case "edit":
            let overLayedView = EditUserInfoPopUp()
            overLayedView.updateViewDelegate = self
            overLayedView.appear(sender: self)
        case "logout":
            let overLayedView = LogOutPopUp()
            overLayedView.delegateLogOut = self
            overLayedView.appear(sender: self)
        case "deleteAcc":
            let overLayedView = DeleteAccountPopUp()
            overLayedView.delegateDeleteAccount = self
            overLayedView.appear(sender: self)
        case "aboutApp":
            let overLayedView = AboutAppPopUp()
            overLayedView.appear(sender: self)
        default: break
        }
    }
    
    func buttonScaleAnimation(targetButton:UIButton){
        UIView.animate(withDuration: 0.2) {
            targetButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        } completion: { (bool) in
            targetButton.transform = .identity
        }
    }
    
//MARK: - Actions
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        buttonScaleAnimation(targetButton: logoutButton)
        popUpApear(sender: "logout")
    }
    
    @IBAction func emailSwitchToggled(_ sender: UISwitch) {
        switch (emailSwitch.isOn, mainModel.isInternetAvailable()){
        case (true,true):
            coreDataManager.updateUserFieldData(
                userID: mainModel.loadUserData().userID,
                field: "userShowEmail",
                argument: true,
                context: context)
            firebase.updateUserEmailShowStatus(userID: userData?.userID ?? "", status: true)
        case (false,false):
            coreDataManager.updateUserFieldData(
                userID: mainModel.loadUserData().userID,
                field: "userShowEmail",
                argument: false,
                context: context)
            coreDataManager.updateUserFieldData(
                userID: mainModel.loadUserData().userID,
                field: "userSyncronized",
                argument: false,
                context: context)
        case(true,false):
            coreDataManager.updateUserFieldData(
                userID: mainModel.loadUserData().userID,
                field: "userShowEmail",
                argument: true,
                context: context)
            coreDataManager.updateUserFieldData(
                userID: mainModel.loadUserData().userID,
                field: "userSyncronized",
                argument: false,
                context: context)
        case(false,true):
            coreDataManager.updateUserFieldData(
                userID: mainModel.loadUserData().userID,
                field: "userShowEmail",
                argument: false,
                context: context)
            firebase.updateUserEmailShowStatus(userID: userData?.userID ?? "", status: false)
        }
        coreDataManager.saveData(data: context)
    }
    
    @IBAction func setAvatarPressed(_ sender: UIButton) {
        buttonScaleAnimation(targetButton: setAvatarButton)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        buttonScaleAnimation(targetButton: editButton)
        popUpApear(sender: "edit")
    }
    
    @IBAction func aboutAppButtonPressed(_ sender: UIButton) {
        buttonScaleAnimation(targetButton: aboutAppButton)
        popUpApear(sender: "aboutApp")
    }
    
    @IBAction func deleteAccButtonPressed(_ sender: UIButton) {
        buttonScaleAnimation(targetButton: deleteAccButton)
        popUpApear(sender: "deleteAcc")
    }
    
    

}
