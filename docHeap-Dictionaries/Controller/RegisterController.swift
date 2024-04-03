//
//  RegisterController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 03.11.23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CoreData
import FirebaseStorage

class RegisterController: UIViewController {

    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPesswordTextField: UITextField!
    @IBOutlet weak var buttonsView: UIStackView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var addAvatarButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var background: UIView!
    
    func localizeElements(){
        nickNameTextField.placeholder = "registerVC_name_placeholder".localized
        emailTextField.placeholder = "registerVC_email_placeholder".localized
        passwordTextField.placeholder = "registerVC_password_placeholder".localized
        confirmPesswordTextField.placeholder = "registerVC_password_confirm_placeholder".localized
        addAvatarButton.setTitle("registerVC_avatar_button".localized, for: .normal)
        backButton.setTitle("registerVC_back_button".localized, for: .normal)
        registerButton.setTitle("registerVC_register_button".localized, for: .normal)
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var coreDataManager = CoreDataManager()
    private let mainModel = MainModel()
    private var defaults = UserDefaults()
    private let fireDB = Firebase()
    private var avatarSelected = false
    private var selectedImage = UIImage()
    private var imageExtention = String()
    private var tempAvatarName = String()
    private var avatarName = String()
    private var currentUserEmail = String()
    private var userName = String()
    private var nameEntered = false
    private var tempAvatarURL: URL?
    private var avatarURL: URL?
    private let userDefaults = UserDefaults.standard
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeElements()
        elementsDesign()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        background.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func elementsDesign(){
        buttonsView.layer.cornerRadius = 5
        avatarImage.layer.cornerRadius = avatarImage.frame.size.width/2
        avatarImage.layer.masksToBounds = false
        avatarImage.clipsToBounds = true
        addAvatarButton.layer.cornerRadius = 5
        
    }
    
    private func checkName()->Bool{
        var userName = String()
        if let un = nickNameTextField.text{
            userName = un
        } else {
            userName = ""
        }
        if userName.isEmpty{
            return false
        } else {
            return true
        }
    }
    
    private func passwordsEquals()->Bool{
        if passwordTextField.text == confirmPesswordTextField.text {
            return true
        } else {
            return false
        }
    }
    
    private func entryesCheck()->Bool{
        switch (checkName(),passwordsEquals()){
        case (true,true):
            return true
        case (true,false):
            showErrorPopUp(text: "registerVC_passwordsNoMatch_message".localized)
            return false
        case (false,true):
            showErrorPopUp(text: "registerVC_missName_message".localized)
            return false
        case (false,false):
            showErrorPopUp(text: "registerVC_missNameAndPassNoMatch_message".localized)
            return false
        }
    }
    
    func saveImageToAppDirectory(image: UIImage, isImageSelected: Bool) {
        if isImageSelected{
            tempAvatarName = "tmpAvatar.\(imageExtention)"
            mainModel.createFolderInDocuments(withName: "Temp")
            tempAvatarURL = mainModel.getDocumentsFolderPath().appendingPathComponent("Temp/\(tempAvatarName)")
            avatarSelected = true
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                do {
                    if let imageWithUrl = tempAvatarURL{
                        try imageData.write(to: imageWithUrl)
                    } else {
                    }
                } catch {
                    print("Error saving image: \(error)")
                }
            }
        }
    }
    
    func showErrorPopUp(text:String){
        let overLayerView = LoginErrorPopUp()
        overLayerView.appearOverlayer(sender: self, text: text)
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        if entryesCheck(){
            if let enteredEmail = emailTextField.text, let enteredPassword = passwordTextField.text {
                Auth.auth().createUser(withEmail: enteredEmail, password: enteredPassword) { authResult, error in
                    if let err = error {
                        let errDescription = err.localizedDescription
                        switch errDescription{
                        case "An email address must be provided.":
                            self.showErrorPopUp(text: "registerVC_missEmail_message".localized)
                        case "The password must be 6 characters long or more.":
                            self.showErrorPopUp(text: "registerVC_shortPassword_message".localized)
                        case "The email address is badly formatted.":
                            self.showErrorPopUp(text: "registerVC_badEmail_message".localized)
                        default:
                            break
                        }
                    } else {
                        let newUser = Users(context: self.context)
                        newUser.userEmail = enteredEmail
                        let name = self.nickNameTextField.text
                        newUser.userName = name!
                        self.userName = name!
                        newUser.userRegisterDate = self.mainModel.convertDateToString(currentDate: Date(), time: false)
                        let userID = self.mainModel.uniqueIDgenerator(prefix: "usr")
                        newUser.userID = userID
                        newUser.userCountry = ""
                        newUser.userBirthDate = ""
                        newUser.userNativeLanguage = ""
                        newUser.userScores = 0
                        newUser.userShowEmail = false
                        self.mainModel.createFolderInDocuments(withName: userID)
                        self.defaults.set(enteredEmail, forKey: "userEmail")
                        self.defaults.set(false, forKey: "keepSigned")
                        self.defaults.set(userID, forKey: "userID")
                        self.defaults.set("auth", forKey: "accType")
                        self.defaults.set(name, forKey: "userName")
                        if self.avatarSelected{
                            self.avatarName = "userAvatar.\(self.imageExtention)"
                            newUser.userAvatarExtention = self.imageExtention
                            self.tempAvatarURL = self.mainModel.getDocumentsFolderPath().appendingPathComponent("Temp/\(self.tempAvatarName)")
                            self.avatarURL = self.mainModel.getDocumentsFolderPath().appendingPathComponent("\(userID)/\(self.avatarName)")
                            self.copyAvatarFromTemp(from: self.tempAvatarURL!, to: self.avatarURL!)
                            self.mainModel.deleteFolderInDocuments(folderName: "Temp")
                            self.coreDataManager.saveData(data: self.context)
                            let storage = Storage.storage() // Upload avatar to Firestore start
                            let imageRef = storage.reference().child(userID).child("userAvatar.\(self.imageExtention)")
                            let localImageURL = self.avatarURL!
                            imageRef.putFile(from: localImageURL, metadata: nil) { metadata, error in
                                guard metadata != nil else {
                                    return
                                }
                                if let error = error{
                                    print("Error is: \(error)\n")
                                }
                                imageRef.downloadURL { url, error in
                                    guard let downloadURL = url else {
                                        return
                                    }
                                    if let error {
                                        print("There is an error to download avatar: \(error)\n")
                                    }
                                    self.coreDataManager.loadCurrentUserData(userID: userID, data: self.context)
                                    self.coreDataManager.usersArray.first?.userAvatarFirestorePath = downloadURL.absoluteString
                                    self.coreDataManager.saveData(data: self.context)
                                    self.fireDB.createUser(
                                        userID: userID,
                                        userEmail: enteredEmail,
                                        userName: self.userName,
                                        userInterfaceLanguage: self.mainModel.currentSystemLanguage(),
                                        userAvatarFirestorePath: downloadURL,
                                        accType: "auth"
                                    )
                                }
                            }
                        } else {
                            self.coreDataManager.saveData(data: self.context)
                            self.fireDB.createUser(
                                userID: userID,
                                userEmail: enteredEmail,
                                userName: self.userName,
                                userInterfaceLanguage: self.mainModel.currentSystemLanguage(),
                                userAvatarFirestorePath: nil,
                                accType: "auth"
                            )
                        }
                        self.performSegue(withIdentifier: "goToApp", sender: self)
                    }
                }
            }
        }
    }
    
  
    func copyAvatarFromTemp(from sourceURL: URL, to destinationURL: URL) {
        let fileManager = FileManager.default

        do {
            if fileManager.fileExists(atPath: sourceURL.path) {
                try fileManager.copyItem(at: sourceURL, to: destinationURL)
            } else {
                print("File didn't found.")
            }
        } catch let error {
            print("Error copying file: \(error.localizedDescription)")
        }
    }
 
    @IBAction func backButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func addAvatarButtonPressed(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
}

extension RegisterController: UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageFromGallery = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            selectedImage = imageFromGallery
            avatarSelected = true
            if let imageUrl = info[.imageURL] as? URL {
                imageExtention = imageUrl.pathExtension
            }
            saveImageToAppDirectory(image: selectedImage, isImageSelected: true)
            let tempAvatarPath = "Temp/\(tempAvatarName)"
            avatarImage.image = UIImage(contentsOfFile:  mainModel.getDocumentsFolderPath().appendingPathComponent(tempAvatarPath).path)
        } else {
            print("No IMAGE!")
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
