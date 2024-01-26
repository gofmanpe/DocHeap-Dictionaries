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
    @IBOutlet weak var sharedDicNameLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var sharedDicLabel: UILabel!
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var networkUser = NetworkUser()
    //private var networkUserData = NetworkUser()
    private let coreData = CoreDataManager()
    private let mainModel = MainModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpBackgroundSettings()
        elementsDesign()
        setupUserData()
        
    }
    
    func setupUserData(){
       // networkUserData = coreData.loadNetworkUserByID(userID: userID, data: context)
        userNameLabel.text = networkUser.nuName
        regDateLabel.text = networkUser.nuRegisterDate
        if !networkUser.nuShowEmail{
            userEmailLabel.isHidden = true
        } else {
            userEmailLabel.isHidden = false
            userEmailLabel.text = networkUser.nuEmail
        }
        let avatarPath = "\(mainModel.loadUserData().userID)/\(networkUser.nuLocalAvatar ?? "")"
        userAvatar.image = UIImage(contentsOfFile:  mainModel.getDocumentsFolderPath().appendingPathComponent(avatarPath).path)
        birthDateLabel.text = networkUser.nuBirthDate
        countryLabel.text = networkUser.nuCountry
        nativeLanguageLabel.text = networkUser.nuNativeLanguage
        scoresLabel.text = String(networkUser.nuScores)
        sharedDicLabel.text = String(networkUser.nuSharedDics)
        likesLabel.text = String(networkUser.nuLikes)
        
        
    }

    func elementsDesign(){
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
    
    func popUpBackgroundSettings(){
        self.view.backgroundColor = .clear
        background.backgroundColor = .black.withAlphaComponent(0.6)
        background.alpha = 0
        mainView.alpha = 0
    }
    
    func appear(sender: ChatViewController) {
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
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        hide()
    }
    
}
