//
//  StartController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 03.11.23.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import Alamofire
import GoogleSignIn
import GoogleSignInSwift

class StartController: UIViewController{
    
//MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var keepSignedSwitch: UISwitch!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var buttonsView: UIStackView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var keepSignedLabel: UILabel!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var background: UIView!
    
//MARK: - Localization
    func localizeElements(){
        emailTextField.placeholder = "startVC_email_placeholder".localized
        passwordTextField.placeholder = "startVC_password_placeholder".localized
        registerButton.setTitle("startVC_register_Button".localized, for: .normal)
        signInButton.setTitle("startVC_signIn_Button".localized, for: .normal)
        keepSignedLabel.text = "startVC_switch_label".localized
    }
    
//MARK: - Constants and variables
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let userDefaults = UserDefaults.standard
    private var switchStatus = Bool()
    private var userSigned = Bool()
    private var coreDataManager = CoreDataManager()
    private var userEmail = String()
    private var avatarName = String()
    private var firstLogin = Bool()
    private var userID = String()
    private var userName = String()
    private let mainModel = MainModel()
    private let fireDB = Firestore.firestore()
    private let firebase = Firebase()
    private let alamo = Alamo()
    private let tableReloadDelegate : UpdateView? = nil
    private let sync = SyncModel()
    
//MARK: - Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        if mainModel.loadUserData().signed{
            performSegue(withIdentifier: "goFromStart", sender: self)
        } else if !userEmail.isEmpty{
            emailTextField.text = userEmail
            if coreDataManager.usersArray.first?.userAvatarExtention != nil{
                if let ava = coreDataManager.usersArray.first?.userAvatarExtention{
                    avatarName = "userAvatar.\(ava)"
                }
                let avatarPath = "\(userID)/\(avatarName)"
                avatarImageView.image = UIImage(contentsOfFile:  mainModel.getDocumentsFolderPath().appendingPathComponent(avatarPath).path)
            }
        }
        print(mainModel.getDocumentsFolderPath())
        localizeElements()
        loadCurrentUser()
        coreDataManager.loadCurrentUserData(userID: userID, data: context)
        elementsDesign()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        background.addGestureRecognizer(tapGesture)
    }
    
   
    
//MARK: - Controller functions
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    private func setupGoogleSignIn(){
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
          guard error == nil else {
              if let error = error {
                  print("There some error: \(error)")
              }
              return
          }
          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
          else {
              if let error = error {
                  print("There some error: \(error)")
              }
                return
          }
          let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { [self] result, error in
                let user = Auth.auth().currentUser
                if let user = user {
                  let email = user.email
                  let photoURL = user.photoURL
                  var multiFactorString = "MultiFactor: "
                  let userName = user.displayName ?? "no user name"
                  for info in user.multiFactor.enrolledFactors {
                    multiFactorString += info.displayName ?? "[DispayName]"
                    multiFactorString += " "
                  } // User was logined
                    let userEmail = email ?? "No_user_email"
                    let userPhoto = photoURL
                    if coreDataManager.isUserExistInCoreData(userEmail: userEmail, context: context){ // User was found in CoreData by email
                        userID = coreDataManager.loadUserData(userEmail: userEmail, data: context).first?.userID ?? "noUserID"
                        self.userName = coreDataManager.loadUserData(userEmail: userEmail, data: context).first?.userName ?? "noUserName"
//TODO: - For sync from different devices, if dictionary and/or word was created/modified/deleted from different device on same accaunt
                        userDefaults.set(userID, forKey: "userID")
                        userDefaults.set(userEmail, forKey: "userEmail")
                        userDefaults.set(true, forKey: "keepSigned")
                        userDefaults.set("google", forKey: "accType")
                        userDefaults.set(self.userName, forKey: "userName")
//TODO: - Here need to sync user with Firebase for checking changes
                        goToApp()
                    } else { // No user found in CoreData
                        firebase.checkUserExistsInFirebase(userEmail: userEmail) { userExist in
                            if userExist{ // User exist in Firebase
                                self.firebase.getUserDataByEmail(userEmail: userEmail) { result in
                                    guard let data = result else {return}
                                    let userData = UserData(
                                        userID: data.userID,
                                        userName: data.userName,
                                        userBirthDate: data.userBirthDate,
                                        userCountry: data.userCountry,
                                        userAvatarFirestorePath: data.userAvatarFirestorePath,
                                        userAvatarExtention: data.userAvatarExtention,
                                        userNativeLanguage: data.userNativeLanguage,
                                        userScores: data.userScores,
                                        userShowEmail: data.userShowEmail,
                                        userEmail: data.userEmail,
                                        userSyncronized: data.userSyncronized,
                                        userType: data.userType,
                                        userRegisterDate: data.userRegisterDate,
                                        userInterfaceLanguage: data.userInterfaceLanguage,
                                        userMistakes: data.userMistakes,
                                        userRightAnswers: data.userRightAnswers,
                                        userTestsCompleted: data.userTestsCompleted
                                    )
                                        self.userID = userData.userID
                                        DispatchQueue.main.async {
                                            self.sync.loadDictionariesFromFirebase(userID: userData.userID, context: self.context)
                                            self.sync.loadStatisticFromFirebase(userID: userData.userID, context: self.context)
                                        }
                                        self.coreDataManager.createLocalUser(userData: userData, context: self.context)
                                    if !self.mainModel.isUserFolderExist(folderName: userData.userID) { // User folder dont exist
                                        self.mainModel.createFolderInDocuments(withName: userData.userID)
                                        self.mainModel.createFolderInDocuments(withName: "\(userData.userID)/Temp")
                                        }
                                        self.userDefaults.set(userData.userID, forKey: "userID")
                                        self.userDefaults.set(email, forKey: "userEmail")
                                        self.userDefaults.set(true, forKey: "keepSigned")
                                        self.userDefaults.set("google", forKey: "accType")
                                        self.userDefaults.set(userName, forKey: "userName")
                                    if !userData.userAvatarFirestorePath.isEmpty {
                                        self.alamo.downloadAndSaveAvatar(from: userData.userAvatarFirestorePath, forUser: userData.userID) {
                                            self.goToApp()
                                        }
                                    }
                                }
                            } else { // User dont exist in Firebase
                                let userID = self.mainModel.uniqueIDgenerator(prefix: "usr")
                                self.userID = userID
                                self.firebase.createUser(userID: userID, userEmail: userEmail, userName: userName, userInterfaceLanguage: self.mainModel.currentSystemLanguage(), userAvatarFirestorePath: userPhoto, accType: "google")
                                let newUserData = UserData(
                                    userID: userID,
                                    userName: userName,
                                    userBirthDate: "",
                                    userCountry: "",
                                    userAvatarFirestorePath: userPhoto!.absoluteString,
                                    userAvatarExtention: "jpg",
                                    userNativeLanguage: "",
                                    userScores: 0,
                                    userShowEmail: false,
                                    userEmail: userEmail,
                                    userSyncronized: true,
                                    userType: "",
                                    userRegisterDate: self.mainModel.convertDateToString(currentDate: Date(), time: false)!,
                                    userInterfaceLanguage: self.mainModel.currentSystemLanguage(),
                                    userMistakes: 0,
                                    userRightAnswers: 0,
                                    userTestsCompleted: 0
                                )
                                self.coreDataManager.createLocalUser(userData: newUserData, context: self.context)
                                self.mainModel.createFolderInDocuments(withName: userID)
                                self.mainModel.createFolderInDocuments(withName: "\(userID)/Temp")
                                if let userPhoto = userPhoto{
                                    self.alamo.downloadAndSaveAvatar(from: userPhoto.absoluteString, forUser: userID) {
                                        let localImagePath = self.mainModel.getDocumentsFolderPath().appendingPathComponent("\(userID)/userAvatar.jpg")
                                        self.firebase.uploadAvatarToFirestore(userID: userID, avatarPath: localImagePath)
                                    }
                                }
                                self.userDefaults.set(userID, forKey: "userID")
                                self.userDefaults.set(email, forKey: "userEmail")
                                self.userDefaults.set(true, forKey: "keepSigned")
                                self.userDefaults.set("google", forKey: "accType")
                                self.userDefaults.set(userName, forKey: "userName")
                                self.goToApp()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func goToApp(){
        self.performSegue(withIdentifier: "goFromStart", sender: self)
    }
    
    func elementsDesign(){
        buttonsView.layer.cornerRadius = 5
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2
        avatarImageView.layer.masksToBounds = false
        avatarImageView.clipsToBounds = true
    }
    
    private func loadCurrentUser(){
        userID = mainModel.loadUserData().userID
        userEmail = mainModel.loadUserData().email
        userSigned = mainModel.loadUserData().signed
    }
    
    func showErrorPopUp(text:String){
                let overLayerView = LoginErrorViewController()
                overLayerView.appearOverlayer(sender: self, text:text)
            }
   
//MARK: - Actions
    @IBAction func switchToggled(_ sender: UISwitch) {
        if keepSignedSwitch.isOn{
            switchStatus = true
        } else {
            switchStatus = false
        }
    }
    
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let err = error as? NSError{
                    if let errorRequest = err.userInfo["FIRAuthErrorUserInfoNameKey"] as? String{
                        switch errorRequest{
                        case "ERROR_WRONG_PASSWORD":
                            self.showErrorPopUp(text:"Wrong password or email")
                        case "ERROR_NETWORK_REQUEST_FAILED":
                            self.showErrorPopUp(text:"No internet connection")
                        default:
                            break
                        }
                    }
                } else {
                    if self.coreDataManager.isUserExistInCoreData(userEmail: email, context: self.context){
                        self.userID = self.coreDataManager.loadUserData(userEmail: email, data: self.context).first?.userID ?? "noUserID"
                        self.userName = self.coreDataManager.loadUserData(userEmail: email, data: self.context).first?.userName ?? "noUserName"
                        self.userDefaults.set(self.userID, forKey: "userID")
                        self.userDefaults.set(email, forKey: "userEmail")
                        self.userDefaults.set(self.switchStatus, forKey: "keepSigned")
                        self.userDefaults.set("auth", forKey: "accType")
                        self.userDefaults.set(self.userName, forKey: "userName")
                        self.goToApp()
                    } else {
                        self.firebase.getUserDataByEmail(userEmail: email) { result in
                            guard let data = result else {return}
                            let userData = UserData(
                                userID: data.userID,
                                userName: data.userName,
                                userBirthDate: data.userBirthDate,
                                userCountry: data.userCountry,
                                userAvatarFirestorePath: data.userAvatarFirestorePath,
                                userAvatarExtention: data.userAvatarExtention,
                                userNativeLanguage: data.userNativeLanguage,
                                userScores: data.userScores,
                                userShowEmail: data.userShowEmail,
                                userEmail: data.userEmail,
                                userSyncronized: data.userSyncronized,
                                userType: "",
                                userRegisterDate: data.userRegisterDate,
                                userInterfaceLanguage: data.userInterfaceLanguage,
                                userMistakes: data.userMistakes,
                                userRightAnswers: data.userRightAnswers,
                                userTestsCompleted: data.userTestsCompleted
                            )
                            DispatchQueue.main.async {
                                self.sync.loadDictionariesFromFirebase(userID: userData.userID, context: self.context)
                            }
                            self.coreDataManager.createLocalUser(userData: userData, context: self.context)
                            if !self.mainModel.isUserFolderExist(folderName: userData.userID) { // User folder dont exist
                                self.mainModel.createFolderInDocuments(withName: userData.userID)
                            }
                            self.userDefaults.set(userData.userID, forKey: "userID")
                            self.userDefaults.set(email, forKey: "userEmail")
                            self.userDefaults.set(self.switchStatus, forKey: "keepSigned")
                            self.userDefaults.set("auth", forKey: "accType")
                            self.userDefaults.set(userData.userName, forKey: "userName")
                            if !userData.userAvatarFirestorePath.isEmpty {
                                self.alamo.downloadAndSaveAvatar(from: userData.userAvatarFirestorePath, forUser: userData.userID) {
                                    self.goToApp()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
  
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToRegister", sender: self)
        
    }
    
    @IBAction func googleSignInPressed(_ sender: UIButton) {
        setupGoogleSignIn()
    }
}
