//
//  DeleteAccountPopUp.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 21.03.24.
//

import UIKit
import FirebaseAuth

class DeleteAccountPopUp: UIViewController {

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var warningMessage: UILabel!
    @IBOutlet weak var switchComment: UILabel!
    @IBOutlet weak var leaveDictionariesSwitch: UISwitch!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var attentionLabel: UILabel!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentImage: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    
    private func localizeElements(){
        header.text = "deleteAccountPopUp_header_label".localized
        warningMessage.text = "deleteAccountPopUp_warningMessage_label".localized
        switchComment.text = "deleteAccountPopUp_switchComment_label".localized
        attentionLabel.text = "deleteAccountPopUp_attention_label".localized
        cancelButton.setTitle( "deleteAccountPopUp_cancel_button".localized, for: .normal)
        deleteButton.setTitle("deleteAccountPopUp_delete_button".localized, for: .normal)
    }
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var delegateDeleteAccount : LogOutUser?
    private let firebase = Firebase()
    private let coreData = CoreDataManager()
    private let mainModel = MainModel()
    private var userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeElements()
        popUpBackgroundSettings()
        elementsDesign()
    }
    
    private func unauthorizeUserFirebase(){
        guard let user = Auth.auth().currentUser else {
            return
        }
        user.delete { error in
            if let error = error {
                print("Error deleting user: \(error.localizedDescription)")
            } else {
                print("User successfuly deleted")
            }
        }
    }
    
    private func cleanUserDefaults(){
        let accountType = mainModel.loadUserData().accType
        switch accountType{
        case "google":
            userDefaults.set("", forKey: "userID")
            userDefaults.set("", forKey: "userEmail")
            userDefaults.set("", forKey: "accType")
            userDefaults.set(false, forKey: "keepSigned")
        case "auth":
            userDefaults.set("", forKey: "userID")
            userDefaults.set("", forKey: "accType")
            userDefaults.set(false, forKey: "keepSigned")
        case "apple":
            userDefaults.set("", forKey: "userID")
            userDefaults.set("", forKey: "accType")
            userDefaults.set(false, forKey: "keepSigned")
            userDefaults.set(nil, forKey: "appleIdentityToken")
        default:
            return
        }
    }
    
    init() {
        super.init(nibName: "DeleteAccountPopUp", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
       
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func popUpBackgroundSettings(){
        self.view.backgroundColor = .clear
        background.backgroundColor = .black.withAlphaComponent(0.6)
        background.alpha = 0
        mainView.alpha = 0
    }
    
    func appear(sender: UIViewController) {
        sender.present(self, animated: false) {
            self.show()
        }
    }

    private func show() {
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.mainView.alpha = 1
            self.background.alpha = 1
        }
    }

    private func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.background.alpha = 0
            self.mainView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
            self.removeFromParent()
        }
    }
    
    private func elementsDesign(){
        mainView.layer.cornerRadius = 10
        mainView.clipsToBounds = true
        commentView.isHidden = true
        
    }
    
    
    
    func deleteAccountWithoutSharedDictionaries(){
        firebase.deleteAllUserStatisticFirebase(userID: mainModel.loadUserData().userID) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        coreData.deleteAllUserStatisticCoreData(userID: mainModel.loadUserData().userID, context: context)
        let dictionariesIDsArray = coreData.getAllNotSharedDictionaries(userID:mainModel.loadUserData().userID, context:context)
        for dictionary in dictionariesIDsArray{
            firebase.deleteWordsByDicIDFirebase(dicID: dictionary) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            firebase.deleteDictionaryFirebase(dicID: dictionary) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
//            coreData.deleteWordsByDicID(dicID: dictionary, context: context)
//            coreData.deleteDictionaryFromCoreData(dicID: dictionary, userID: mainModel.loadUserData().userID, context: context)
        }
        firebase.deleteUserFirebase(userID:mainModel.loadUserData().userID, completion: { error in
            if let error = error {
                print(error.localizedDescription)
            }
        })
        coreData.deleteAllUserDictionariesCoreData(userID: mainModel.loadUserData().userID, context: context)
        coreData.deleteAllUserWordsCoreData(userID: mainModel.loadUserData().userID, context: context)
        coreData.deleteUserCoreData(userID: mainModel.loadUserData().userID, context: context)
    }
    
    func completlyDeleteAccount(){
        firebase.deleteAllUserStatisticFirebase(userID: mainModel.loadUserData().userID) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        coreData.deleteAllUserStatisticCoreData(userID: mainModel.loadUserData().userID, context: context)
        firebase.deleteAllUserDictionariesFirebase(userID: mainModel.loadUserData().userID) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        firebase.deleteAllUserWordsFirebase(userID: mainModel.loadUserData().userID) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        coreData.deleteAllUserDictionariesCoreData(userID: mainModel.loadUserData().userID, context: context)
        coreData.deleteAllUserWordsCoreData(userID: mainModel.loadUserData().userID, context: context)
        firebase.deleteUserFirebase(userID: mainModel.loadUserData().userID) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        hide()
    }
    
    @IBAction func switchToggled(_ sender: UISwitch) {
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        switch leaveDictionariesSwitch.isOn{
        case true:
            deleteAccountWithoutSharedDictionaries()
        case false:
            completlyDeleteAccount()
        }
        coreData.deleteUserCoreData(userID: mainModel.loadUserData().userID, context: context)
        cleanUserDefaults()
        unauthorizeUserFirebase()
        delegateDeleteAccount?.performToStart()
        hide()
    }
    
    
}
