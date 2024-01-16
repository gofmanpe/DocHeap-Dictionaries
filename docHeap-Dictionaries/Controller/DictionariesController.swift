//
//  DictionariesController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 26.03.23.
//

import UIKit
import CoreData
import Firebase

class DictionariesController: UIViewController, UpdateView, CellButtonPressed{
    
//MARK: - Protocol delegate functions
    func cellButtonPressed(dicID: String, button:String) {
        switch button{
        case "Edit":
            popUpApear(dictionaryIDFromCell: dicID, senderAction: button)
        case "Delete":
            popUpApear(dictionaryIDFromCell: dicID, senderAction: button)
        default: break
        }
    }
    
    func didUpdateView(sender:String) {
        if mainModel.isInternetAvailable(){
            sync.syncDictionariesCoreDataAndFirebase(userID: mainModel.loadUserData().userID, context: context)
            sync.syncUserDataWithFirebase(userID: mainModel.loadUserData().userID, context: context)
        }
        setupData()
        dictionaryCheck()
        
    }
    
//MARK: - Outlets
    @IBOutlet weak var dictionariesTable: UITableView!
    @IBOutlet weak var newDictionaryButton: UIButton!
    @IBOutlet weak var noDicltionariesLabel: UILabel!
    @IBOutlet weak var myDictionariesLabel: UILabel!
    @IBOutlet weak var profileButtonView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
//MARK: - Constants and variables
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var coreDataManager = CoreDataManager()
    private var currentUser = String()
    private var currentUserEmail = String()
    private var currentUserNickname = String()
    private var firebase = Firebase()
    private var avatarName = String()
    private let mainModel = MainModel()
    private let sync = SyncModel()
    private var dicID = String()
    var userID = String()
    private var dictionariesArray = [Dictionary]()
    private var usersArray : UserData?
    private var dicOwnerData = [DicOwnerData]()
    private var sharedDictionaries: [SharedDictionaryShortData]?
    
//MARK: - Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        avatarSet()
        dictionaryCheck()
        elementsDesign()
        if mainModel.isInternetAvailable(){
            sync.syncDictionariesCoreDataAndFirebase(userID: mainModel.loadUserData().userID, context: context)
            sync.syncWordsCoreDataAndFirebase(userID: mainModel.loadUserData().userID, context: context)
        }
        localizeElements()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if mainModel.isInternetAvailable(){
            sync.syncDictionariesCoreDataAndFirebase(userID: mainModel.loadUserData().userID, context: context)
            sync.syncNetworkUsersDataWithFirebase(context: context)
        }
        avatarSet()
        setupData()
        dictionaryCheck()
    }
    
//MARK: - Controller functions
    func setupData(){
        dictionariesArray = coreDataManager.loadUserDictionaries(userID: mainModel.loadUserData().userID, data: context)
        usersArray = coreDataManager.loadUserDataByID(userID: mainModel.loadUserData().userID, context: context).first
        dictionariesTable.delegate = self
        dictionariesTable.dataSource = self
        dictionariesTable.reloadData()
        if dictionariesArray.isEmpty{
            noDicltionariesLabel.isHidden = false}
        else {
            dictionariesTable.reloadData()
                noDicltionariesLabel.isHidden = true
            }
        if let userNickname = usersArray?.userName, userNickname.isEmpty {
            userNameLabel.text = usersArray?.userEmail
        } else {
            userNameLabel.text = usersArray?.userName
        }
    }
    
    func localizeElements(){
        myDictionariesLabel.text = "dictionariesVC_myDictionaries_label".localized
    }
    
    func elementsDesign(){
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2
        avatarImageView.layer.masksToBounds = false
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.borderWidth = 0.5
        avatarImageView.layer.borderColor = UIColor.lightGray.cgColor
        profileButtonView.layer.cornerRadius = 45
        profileButtonView.layer.shadowColor = UIColor.black.cgColor
        profileButtonView.layer.shadowOpacity = 0.2
        profileButtonView.layer.shadowOffset = .zero
        profileButtonView.layer.shadowRadius = 2
        newDictionaryButton.layer.shadowColor = UIColor.black.cgColor
        newDictionaryButton.layer.shadowOpacity = 0.2
        newDictionaryButton.layer.shadowOffset = .zero
        newDictionaryButton.layer.shadowRadius = 2
        newDictionaryButton.layer.cornerRadius = 10
    }
    
    func avatarSet(){
        if usersArray?.userAvatarExtention != nil{
            if let ava = usersArray?.userAvatarExtention{
                avatarName = "userAvatar.\(ava)"
            }
            let avatarPath = "\(mainModel.loadUserData().userID)/\(avatarName)"
            avatarImageView.image = UIImage(contentsOfFile:  mainModel.getDocumentsFolderPath().appendingPathComponent(avatarPath).path)
        }
    }
    
    func popUpApear(dictionaryIDFromCell:String, senderAction:String){
            switch senderAction {
            case "Create":
                let overLayerView = CreatePopUpViewController()
                overLayerView.tableReloadDelegate = self
                overLayerView.appear(sender: self)
            case "Edit":
                let overLayerView = EditDictionaryViewController()
                overLayerView.dicID = dictionaryIDFromCell
                overLayerView.tableReloadDelegate = self
                overLayerView.appear(sender: self)
            case "Delete":
                let overLayerView = DeleteDictionaryViewController()
                overLayerView.tableReloadDelegate = self
                overLayerView.dicID = dictionaryIDFromCell
                overLayerView.appear(sender: self)
            default: break
            }
    }
    
    func buttonScaleAnimation(targetButton:UIButton){
        UIView.animate(withDuration: 0.2) {
            targetButton.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        } completion: { (bool) in
            targetButton.transform = .identity
        }
    }
    
    func dictionaryCheck(){
        dictionariesTable.reloadData()
        if dictionariesArray.isEmpty {
           dictionariesTable.isHidden = true
            noDicltionariesLabel.text = "dictionariesVC_attention_label".localized
            noDicltionariesLabel.isHidden = false
        } else {
            dictionariesTable.isHidden = false
            noDicltionariesLabel.isHidden = true
        }
    }
    
//MARK: - Actions
    @IBAction func newDictionaryButtonPressed(_ sender: UIButton) {
            buttonScaleAnimation(targetButton: newDictionaryButton)
            popUpApear(dictionaryIDFromCell: "", senderAction: "Create")
    }
}

//MARK: - Table Delegate and dataSource functions
extension DictionariesController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  dictionariesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dictionaryCell = dictionariesTable.dequeueReusableCell(withIdentifier: "dictionaryCell") as! DictionaryCell
        
        dictionaryCell.cellView.layer.cornerRadius = 5
        dictionaryCell.sharedDictionaryImage.image = UIImage(systemName: "person.icloud")
        dictionaryCell.sharedDictionaryImage.isHidden = true
        dictionaryCell.cellView.clipsToBounds = true
        dictionaryCell.dictionaryNameLabel.text = dictionariesArray[indexPath.row].dicName
        dictionaryCell.learningLanguageLabel.text = dictionariesArray[indexPath.row].dicLearningLanguage
        dictionaryCell.translateLanguageLabel.text = dictionariesArray[indexPath.row].dicTranslateLanguage
        dictionaryCell.dicName = dictionariesArray[indexPath.row].dicName ?? "no_dicName"
        dictionaryCell.dicID = dictionariesArray[indexPath.row].dicID ?? "no_dicID"
        if let learnImage:String = dictionariesArray[indexPath.row].dicLearningLanguage{
            dictionaryCell.learningLanguageImage.image = UIImage(named: "\(learnImage).png")
        } else {print("No learning language image")}
        if let translateImage:String = dictionariesArray[indexPath.row].dicTranslateLanguage{
            dictionaryCell.translateLanguageImage.image = UIImage(named: "\(translateImage).png")
        } else {print("No translate language image")}
        dictionaryCell.wordsInDictionaryLabel.text = String(dictionariesArray[indexPath.row].dicWordsCount)
        dictionaryCell.cellButtonActionDelegate = self
        if dictionariesArray[indexPath.row].dicReadOnly{
            dictionaryCell.sharedDictionaryImage.image = UIImage(systemName: "icloud.and.arrow.down")
            dictionaryCell.sharedDictionaryImage.isHidden = false
            dictionaryCell.editButton.isHidden = true
            dictionaryCell.createDateLabel.text = "dictionariesVC_ownerName_label".localized
            let ownerName = coreDataManager.getNetworkUserNameByID(userID: dictionariesArray[indexPath.row].dicOwnerID ?? "NONAME", context: context)
            dictionaryCell.creatinDateLabel.text = ownerName
        } else {
            dictionaryCell.creatinDateLabel.text = dictionariesArray[indexPath.row].dicAddDate
            dictionaryCell.createDateLabel.text = "dictionariesVC_createDate_label".localized
            dictionaryCell.editButton.isHidden = false
           
        }
        if dictionariesArray[indexPath.row].dicShared{
            dictionaryCell.sharedDictionaryImage.isHidden = false
        }
        dictionaryCell.selectionStyle = .none
        return dictionaryCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "openDictionary", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let destinationVC = segue.destination as! BrowseDictionaryController
            if let indexPath = dictionariesTable.indexPathForSelectedRow{
                destinationVC.dicOwnerData = dicOwnerData
                let ownerName = coreDataManager.getNetworkUserNameByID(userID: dictionariesArray[indexPath.row].dicOwnerID ?? "NONAME", context: context)
                destinationVC.ownerName = ownerName
                destinationVC.selectedDictionary = dictionariesArray[indexPath.row]
                destinationVC.selectedDictionary = dictionariesArray[indexPath.row]
            }
    }
    
}
    
    

