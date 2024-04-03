//
//  ExitPopUp.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 17.01.24.
//

import UIKit
import FirebaseAuth
class LogOutPopUp: UIViewController {

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var dialogLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    private func localizeElements(){
        header.text = "logoutPopUp_header_label".localized
        dialogLabel.text = "logoutPopUp_dialog_label".localized
        cancelButton.setTitle("logoutPopUp_cancel_button".localized, for: .normal)
        logoutButton.setTitle("logoutPopUp_logout_button".localized, for: .normal)
    }
        
    private let userDefaults = UserDefaults.standard
    private let mainModel = MainModel()
    var delegateLogOut : LogOutUser?
    
    init() {
        super.init(nibName: "LogOutPopUp", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeElements()
        popUpBackgroundSettings()
        mainView.layer.cornerRadius = 10
    }
    
    private  func popUpBackgroundSettings(){
        self.view.backgroundColor = .clear
        background.backgroundColor = .black.withAlphaComponent(0.6)
        background.alpha = 0
        mainView.alpha = 0
    }
    
    func appear(sender: SettingsController) {
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

    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.background.alpha = 0
            self.mainView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
            self.removeFromParent()
        }
    }
    
    private func logout(){
        let accountType = mainModel.loadUserData().accType
        do{
            try Auth.auth().signOut()
        } catch {
            print("ERROR!\n")
        }
        switch accountType{
        case "google":
            userDefaults.set("", forKey: "userID")
            userDefaults.set("", forKey: "userEmail")
            userDefaults.set("", forKey: "accType")
            userDefaults.set(false, forKey: "keepSigned")
            delegateLogOut?.performToStart()
        case "auth":
            userDefaults.set("", forKey: "userID")
            userDefaults.set("", forKey: "accType")
            userDefaults.set(false, forKey: "keepSigned")
            delegateLogOut?.performToStart()
        case "apple":
            userDefaults.set("", forKey: "userID")
            userDefaults.set("", forKey: "accType")
            userDefaults.set(false, forKey: "keepSigned")
            delegateLogOut?.performToStart()
        default:
            return
        }
    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        hide()
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        logout()
        hide()
    }
    
}
