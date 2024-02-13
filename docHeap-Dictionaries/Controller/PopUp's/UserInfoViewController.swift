//
//  UserInfoViewController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 09.01.24.
//

import UIKit
import CoreData

class UserInfoViewController: UIViewController {
    
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
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var networkUserData : NetworkUserData?
    private let coreData = CoreDataManager()
    private let mainModel = MainModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpBackgroundSettings()
        elementsDesign()
        setupUserData()
    }
    
    private func setupUserData(){
        guard let ntUserData = networkUserData else {return}
        userNameLabel.text = ntUserData.userName
        regDateLabel.text = ntUserData.userRegisterDate
        if !ntUserData.userShowEmail{
            userEmailLabel.isHidden = true
        } else {
            userEmailLabel.isHidden = false
            userEmailLabel.text = ntUserData.userEmail
        }
        let avatarPath = "\(mainModel.loadUserData().userID)/\(ntUserData.userLocalAvatar ?? "")"
        userAvatar.image = UIImage(contentsOfFile:  mainModel.getDocumentsFolderPath().appendingPathComponent(avatarPath).path)
        birthDateLabel.text = ntUserData.userBirthDate
        countryLabel.text = ntUserData.userCountry
        nativeLanguageLabel.text = ntUserData.userNativeLanguage
        scoresLabel.text = String(ntUserData.userScores)
        testsCompletedsLabel.text = String(ntUserData.userTestsCompleted)
        mistakesLabel.text = String(ntUserData.userMistakes)
        rightAnswersLabel.text = String(ntUserData.userRightAnswers)
        likesLabel.text = String(ntUserData.userLikes)
    }

   private func elementsDesign(){
        mainView.layer.cornerRadius = 10
        userAvatar.layer.cornerRadius = userAvatar.frame.size.width/2
        userAvatar.layer.masksToBounds = false
        userAvatar.clipsToBounds = true
    }
    
    init() {
        super.init(nibName: "UserInfoViewController", bundle: nil)
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
