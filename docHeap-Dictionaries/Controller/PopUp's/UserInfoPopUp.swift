//
//  UserInfoViewController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 09.01.24.
//

import UIKit
import CoreData

class UserInfoPopUp: UIViewController {
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var registredNameLabel: UILabel!
    @IBOutlet weak var regDateLabel: UILabel!
    @IBOutlet weak var birthDateNameLAbel: UILabel!
    @IBOutlet weak var counrtyNameLabel: UILabel!
    @IBOutlet weak var nativeLanguageNameLabel: UILabel!
    @IBOutlet weak var scoresNameLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var nativeLanguageLabel: UILabel!
    @IBOutlet weak var scoresLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var addInfoNameLabel: UILabel!
    @IBOutlet weak var likesNameLabel: UILabel!
    @IBOutlet weak var testsCompletedNameLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var testsCompletedsLabel: UILabel!
    @IBOutlet weak var rightAnswersLabel: UILabel!
    @IBOutlet weak var mistakesLabel: UILabel!
    @IBOutlet weak var rightAnswersNameLabel: UILabel!
    @IBOutlet weak var mistakesNameLabel: UILabel!
    @IBOutlet weak var avatarBgView: UIView!
    @IBOutlet weak var userInitials: UILabel!
    @IBOutlet weak var deletedAccMessage: UILabel!
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var userInfoStack: UIStackView!
    @IBOutlet weak var registredView: UIView!
    @IBOutlet weak var deletedMessageStack: UIStackView!
    
    private func localizeElements(){
        headerLabel.text = "userInfoPopUp_header_label".localized
        registredNameLabel.text = "userInfoPopUp_registred_label".localized
        addInfoNameLabel.text = "userInfoPopUp_additionalInfo_label".localized
        birthDateNameLAbel.text = "userInfoPopUp_dateOfBirth_label".localized
        counrtyNameLabel.text =  "userInfoPopUp_country_label".localized
        nativeLanguageNameLabel.text = "userInfoPopUp_nativeLanguage_label".localized
        likesNameLabel.text = "userInfoPopUp_likes_label".localized
        testsCompletedNameLabel.text = "userInfoPopUp_testCompleted_label".localized
        rightAnswersNameLabel.text = "userInfoPopUp_rightAnswers_label".localized
        mistakesNameLabel.text = "userInfoPopUp_mistakes_label".localized
        scoresNameLabel.text = "userInfoPopUp_scores_label".localized
    }
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var networkUserData : NetworkUserData?
    private let coreData = CoreDataManager()
    private let mainModel = MainModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeElements()
        popUpBackgroundSettings()
        setupUserData()
        elementsDesign()
    }
    
    private func setupUserData(){
        if networkUserData == nil {
            userInfoStack.isHidden = true
            userInitials.text = "userInfoPopUp_deletedAccName_label".localized
            userNameLabel.text = "dictionariesVC_deletedOwner_label".localized
            regDateLabel.isHidden = true
            userEmailLabel.isHidden = true
            registredView.isHidden = true
            deletedAccMessage.text = "userInfoPopUp_deletedAccountMessage".localized
        } else {
            deletedMessageStack.isHidden = true
            guard let ntUserData = networkUserData else {
                return
            }
            userInitials.text = getUserInitials(fullName: ntUserData.userName)
            userNameLabel.text = ntUserData.userName
            regDateLabel.text = ntUserData.userRegisterDate
            if !ntUserData.userShowEmail{
                userEmailLabel.isHidden = true
            } else {
                userEmailLabel.isHidden = false
                userEmailLabel.text = ntUserData.userEmail
            }
            if ntUserData.userLocalAvatar != nil {
                let avatarPath = "\(mainModel.loadUserData().userID)/\(ntUserData.userLocalAvatar ?? "")"
                userAvatar.image = UIImage(contentsOfFile:  mainModel.getDocumentsFolderPath().appendingPathComponent(avatarPath).path)
                userAvatar.isHidden = false
            } else {
                userAvatar.isHidden = true
            }
            birthDateLabel.text = ntUserData.userBirthDate
            countryLabel.text = ntUserData.userCountry
            nativeLanguageLabel.text = ntUserData.userNativeLanguage
            scoresLabel.text = String(ntUserData.userScores)
            testsCompletedsLabel.text = String(ntUserData.userTestsCompleted)
            mistakesLabel.text = String(ntUserData.userMistakes)
            rightAnswersLabel.text = String(ntUserData.userRightAnswers)
            likesLabel.text = String(ntUserData.userLikes)
        }
    }

    private func getUserInitials(fullName: String) -> String {
        let words = fullName.components(separatedBy: " ")
        var initials = ""
        for word in words {
            if let firstLetter = word.first {
                initials.append(firstLetter)
            }
        }
        return initials.uppercased()
    }
    
    private func elementsDesign(){
        avatarBgView.layer.cornerRadius = avatarBgView.frame.size.width/2
        avatarBgView.layer.masksToBounds = false
        avatarBgView.clipsToBounds = true
        
        mainView.layer.cornerRadius = 10
        userAvatar.layer.cornerRadius = userAvatar.frame.size.width/2
        userAvatar.layer.masksToBounds = false
        userAvatar.clipsToBounds = true
        
    }
    
    init() {
        super.init(nibName: "UserInfoPopUp", bundle: nil)
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
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        hide()
    }
    
}
