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
import AuthenticationServices
import CryptoKit

class StartController: UIViewController{
    
//MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var keepSignedSwitch: UISwitch!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var buttonsView: UIStackView!
   // @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var keepSignedLabel: UILabel!
    @IBOutlet weak var googleSignInButton: UIButton!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    
//MARK: - Localization
    func localizeElements(){
        loginLabel.text = "startVC_login_label".localized
        emailTextField.placeholder = "startVC_email_placeholder".localized
        passwordTextField.placeholder = "startVC_password_placeholder".localized
        registerButton.setTitle("startVC_register_Button".localized, for: .normal)
        loginButton.setTitle("startVC_login_Button".localized, for: .normal)
        keepSignedLabel.text = "startVC_switch_label".localized
        orLabel.text = "startVC_or_label".localized
        googleSignInButton.setTitle("startVC_googleSignIn_label".localized, for: .normal)
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
    private let defaults = Defaults()
    private let appleButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
    private var currentNonce: String?
    private var accType = String()
    
//MARK: - Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tokenCheck()
        userSignedCheck()
        print(mainModel.getDocumentsFolderPath())
        setupView()
        localizeElements()
        loadCurrentUser()
        coreDataManager.loadCurrentUserData(userID: userID, data: context)
        elementsDesign()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        background.addGestureRecognizer(tapGesture)
    }
    
   
    
//MARK: - Controller functions
   private func setupView(){
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.cornerRadius = 5
        background.addSubview(appleButton)
        appleButton.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
        appleButton.topAnchor.constraint(equalTo: loginView.bottomAnchor, constant: 20).isActive = true
        appleButton.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 60).isActive = true
        appleButton.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -60).isActive = true
        appleButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        appleButton.centerXAnchor.constraint(equalTo: background.centerXAnchor).isActive = true
     }
    
    private func tokenCheck(){
        let isUsersExist = coreDataManager.loadAllUsers(context: context)
        if !isUsersExist {
            UserDefaults.standard.set(nil, forKey: "appleIdentityToken")
        }
    }
    
    private func userSignedCheck(){
        if mainModel.loadUserData().signed{
            performSegue(withIdentifier: "goFromStart", sender: self)
        }
    }
    
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
                    userCheckAndCreate(userName: userName, userEmail: userEmail, userPhoto: userPhoto, accType: "google", userToken: nil)
//                    if coreDataManager.isUserExistInCoreData(userEmail: userEmail, context: context){ // User was found in CoreData by email
//                        userID = coreDataManager.loadUserData(userEmail: userEmail, data: context).first?.userID ?? "noUserID"
//                        self.userName = coreDataManager.loadUserData(userEmail: userEmail, data: context).first?.userName ?? "noUserName"
////TODO: - For sync from different devices, if dictionary and/or word was created/modified/deleted from different device on same accaunt
//                        userDefaults.set(userID, forKey: "userID")
//                        userDefaults.set(userEmail, forKey: "userEmail")
//                        userDefaults.set(true, forKey: "keepSigned")
//                        userDefaults.set("google", forKey: "accType")
//                        userDefaults.set(self.userName, forKey: "userName")
////TODO: - Here need to sync user with Firebase for checking changes
//                        goToApp()
//                    } else { // No user found in CoreData
//                        firebase.checkUserExistsInFirebase(userEmail: userEmail) { userExist in
//                            if userExist{ // User exist in Firebase
//                                self.firebase.getUserDataByEmail(userEmail: userEmail) { result in
//                                    guard let data = result else {return}
//                                    let userData = UserData(
//                                        userID: data.userID,
//                                        userName: data.userName,
//                                        userBirthDate: data.userBirthDate,
//                                        userCountry: data.userCountry,
//                                        userAvatarFirestorePath: data.userAvatarFirestorePath,
//                                        userAvatarExtention: data.userAvatarExtention,
//                                        userNativeLanguage: data.userNativeLanguage,
//                                        userScores: data.userScores,
//                                        userShowEmail: data.userShowEmail,
//                                        userEmail: data.userEmail,
//                                        userSyncronized: data.userSyncronized,
//                                        userType: data.userType,
//                                        userRegisterDate: data.userRegisterDate,
//                                        userInterfaceLanguage: data.userInterfaceLanguage,
//                                        userMistakes: data.userMistakes,
//                                        userRightAnswers: data.userRightAnswers,
//                                        userTestsCompleted: data.userTestsCompleted
//                                    )
//                                        self.userID = userData.userID
//                                        DispatchQueue.main.async {
//                                            self.sync.loadDictionariesFromFirebase(userID: userData.userID, context: self.context)
//                                            self.sync.loadStatisticFromFirebase(userID: userData.userID, context: self.context)
//                                        }
//                                        self.coreDataManager.createLocalUser(userData: userData, context: self.context)
//                                    if !self.mainModel.isUserFolderExist(folderName: userData.userID) { // User folder dont exist
//                                        self.mainModel.createFolderInDocuments(withName: userData.userID)
//                                        self.mainModel.createFolderInDocuments(withName: "\(userData.userID)/Temp")
//                                        }
//                                        self.userDefaults.set(userData.userID, forKey: "userID")
//                                        self.userDefaults.set(email, forKey: "userEmail")
//                                        self.userDefaults.set(true, forKey: "keepSigned")
//                                        self.userDefaults.set("google", forKey: "accType")
//                                        self.userDefaults.set(userName, forKey: "userName")
//                                    if !userData.userAvatarFirestorePath.isEmpty {
//                                        self.alamo.downloadAndSaveAvatar(from: userData.userAvatarFirestorePath, forUser: userData.userID) {
//                                            self.goToApp()
//                                        }
//                                    }
//                                }
//                            } else { // User dont exist in Firebase
//                                let userID = self.mainModel.uniqueIDgenerator(prefix: "usr")
//                                self.userID = userID
//                                self.firebase.createUser(userID: userID, userEmail: userEmail, userName: userName, userInterfaceLanguage: self.mainModel.currentSystemLanguage(), userAvatarFirestorePath: userPhoto, accType: "google")
//                                let newUserData = UserData(
//                                    userID: userID,
//                                    userName: userName,
//                                    userBirthDate: "",
//                                    userCountry: "",
//                                    userAvatarFirestorePath: userPhoto!.absoluteString,
//                                    userAvatarExtention: "jpg",
//                                    userNativeLanguage: "",
//                                    userScores: 0,
//                                    userShowEmail: false,
//                                    userEmail: userEmail,
//                                    userSyncronized: true,
//                                    userType: "",
//                                    userRegisterDate: self.mainModel.convertDateToString(currentDate: Date(), time: false)!,
//                                    userInterfaceLanguage: self.mainModel.currentSystemLanguage(),
//                                    userMistakes: 0,
//                                    userRightAnswers: 0,
//                                    userTestsCompleted: 0
//                                )
//                                self.coreDataManager.createLocalUser(userData: newUserData, context: self.context)
//                                self.mainModel.createFolderInDocuments(withName: userID)
//                                self.mainModel.createFolderInDocuments(withName: "\(userID)/Temp")
//                                if let userPhoto = userPhoto{
//                                    self.alamo.downloadAndSaveAvatar(from: userPhoto.absoluteString, forUser: userID) {
//                                        let localImagePath = self.mainModel.getDocumentsFolderPath().appendingPathComponent("\(userID)/userAvatar.jpg")
//                                        self.firebase.uploadAvatarToFirestore(userID: userID, avatarPath: localImagePath)
//                                    }
//                                }
//                                self.userDefaults.set(userID, forKey: "userID")
//                                self.userDefaults.set(email, forKey: "userEmail")
//                                self.userDefaults.set(true, forKey: "keepSigned")
//                                self.userDefaults.set("google", forKey: "accType")
//                                self.userDefaults.set(userName, forKey: "userName")
//                                self.goToApp()
//                            }
//                        }
//                    }
                }
            }
        }
    }
    
    func goToApp(){
        self.performSegue(withIdentifier: "goFromStart", sender: self)
    }
    
    func elementsDesign(){
        buttonsView.layer.cornerRadius = 5
//        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2
//        avatarImageView.layer.masksToBounds = false
//        avatarImageView.clipsToBounds = true
        googleSignInButton.layer.cornerRadius = 5
    }
    
    private func loadCurrentUser(){
        userID = mainModel.loadUserData().userID
        userEmail = mainModel.loadUserData().email
        userSigned = mainModel.loadUserData().signed
    }
    
    func showErrorPopUp(text:String){
        let overLayerView = LoginErrorPopUp()
        overLayerView.appearOverlayer(sender: self, text:text)
    }
    
    func userCheckAndCreate(userName:String, userEmail:String, userPhoto:URL?, accType:String, userToken:String?){
        var userAvatar = String()
        if userPhoto != nil {
            userAvatar = userPhoto!.absoluteString
        } else {
            userAvatar = ""
        }
        if coreDataManager.isUserExistInCoreData(userEmail: userEmail, context: context){ // User was found in CoreData by email
            guard let userID = coreDataManager.loadUserData(userEmail: userEmail, data: context).first?.userID else {
                return
            }
            //self.userName = coreDataManager.loadUserData(userEmail: userEmail, data: context).first?.userName ?? "noUserName"
            //TODO: - For sync from different devices, if dictionary and/or word was created/modified/deleted from different device on same accaunt
            userDefaults.set(userID, forKey: "userID")
            userDefaults.set(userEmail, forKey: "userEmail")
            userDefaults.set(true, forKey: "keepSigned")
            userDefaults.set(accType, forKey: "accType")
            userDefaults.set(userName, forKey: "userName")
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
                            userTestsCompleted: data.userTestsCompleted, 
                            userIdentityToken: userToken ?? ""
                        )
                        //self.userID = userData.userID
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
                        self.userDefaults.set(userEmail, forKey: "userEmail")
                        self.userDefaults.set(true, forKey: "keepSigned")
                        self.userDefaults.set(accType, forKey: "accType")
                        self.userDefaults.set(userName, forKey: "userName")
                        if !userData.userAvatarFirestorePath.isEmpty {
                            self.alamo.downloadAndSaveAvatar(from: userData.userAvatarFirestorePath, forUser: userData.userID) {
                                self.goToApp()
                            }
                        }
                    }
                } else { // User doesnt exist in Firebase
                    let userID = self.mainModel.uniqueIDgenerator(prefix: "usr")
                    //self.userID = userID
                    self.firebase.createUser(userID: userID,
                                             userEmail: userEmail,
                                             userName: userName,
                                             userInterfaceLanguage: self.mainModel.currentSystemLanguage(),
                                             userAvatarFirestorePath: URL(string:userAvatar),
                                             accType: accType)
                    let newUserData = UserData(
                        userID: userID,
                        userName: userName,
                        userBirthDate: "",
                        userCountry: "",
                        userAvatarFirestorePath: userAvatar,
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
                        userTestsCompleted: 0, 
                        userIdentityToken: userToken ?? ""
                    )
                    self.coreDataManager.createLocalUser(userData: newUserData, context: self.context)
                    self.mainModel.createFolderInDocuments(withName: userID)
                    self.mainModel.createFolderInDocuments(withName: "\(userID)/Temp")
                    self.alamo.downloadAndSaveAvatar(from: userAvatar, forUser: userID) {
                        let localImagePath = self.mainModel.getDocumentsFolderPath().appendingPathComponent("\(userID)/userAvatar.jpg")
                        self.firebase.uploadAvatarToFirestore(userID: userID, avatarPath: localImagePath)
                    }
                    self.userDefaults.set(userID, forKey: "userID")
                    self.userDefaults.set(userEmail, forKey: "userEmail")
                    self.userDefaults.set(true, forKey: "keepSigned")
                    self.userDefaults.set(accType, forKey: "accType")
                    self.userDefaults.set(userName, forKey: "userName")
                    self.goToApp()
                }
            }
        }
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
                                userTestsCompleted: data.userTestsCompleted, 
                                userIdentityToken: ""
                            )
                            self.coreDataManager.createLocalUser(userData: userData, context: self.context)
                            if !self.mainModel.isUserFolderExist(folderName: userData.userID) { // User folder dont exist
                                self.mainModel.createFolderInDocuments(withName: userData.userID)
                            }
                            DispatchQueue.main.async {
                                self.sync.loadDictionariesFromFirebase(userID: userData.userID, context: self.context)
                                self.sync.loadStatisticFromFirebase(userID: userData.userID, context: self.context)
                                self.coreDataManager.setSyncronizedStatusForUser(userID: userData.userID, status: true, context: self.context)
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

private extension StartController {
    @objc
    func handleAppleIdRequest() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName,.email]
        request.nonce = sha256(nonce)
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
    
    func randomNonceString(length: Int = 32)->String{
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainLength = length
        
        while remainLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach {random in
                if remainLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainLength -= 1
                }
            }
        }
        return result
    }
    
    @available(iOS 13, *)
    func sha256(_ input: String) -> String{
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap{
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }
}

extension StartController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Some error with apple sign in\n")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
       
        guard let nonce = currentNonce else {
            return
        }
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        
        guard let token = credential.identityToken else {
            return
        }
        
        guard let tokenString = String(data:token, encoding: .utf8) else {
            return
        }
        let userToken = UserDefaults.standard.string(forKey: "appleIdentityToken")
        
        if userToken == nil{
            UserDefaults.standard.set(tokenString, forKey: "appleIdentityToken")
            let oAuthCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
            Auth.auth().signIn(with: oAuthCredential) { result, error in
                if let error = error {
                    print("Some error without token: \(error)\n")
                } else {
                    guard let firstName = credential.fullName?.givenName else {
                        return
                    }
                    guard let lastName = credential.fullName?.familyName else {
                        return
                    }
                    guard let email = credential.email else {
                        return
                    }
                    let userName = "\(firstName) \(lastName)"
                    self.userCheckAndCreate(userName: userName, userEmail: email, userPhoto: nil, accType: "apple", userToken: tokenString)
                }
            }
            
        } else {
            let oAuthCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: userToken!, rawNonce: "")
            Auth.auth().signIn(with: oAuthCredential) { result, error in
                if let error = error {
                    print("Some error with saved token: \(error)\n")
                }
                self.accType = "apple"
                guard let userData = self.coreDataManager.loadUserDataByToken(userToken: userToken!, context: self.context) else {
                    return
                }
                print(userData)
                self.userDefaults.set(userData.userID, forKey: "userID")
                self.userDefaults.set(userData.userEmail, forKey: "userEmail")
                self.userDefaults.set(true, forKey: "keepSigned")
                self.userDefaults.set(self.accType, forKey: "accType")
                self.userDefaults.set(userData.userName, forKey: "userName")
                self.goToApp()
            }
        }
       
        
        
        
      
    }
}

