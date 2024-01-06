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
    
    @IBOutlet weak var dictionariesTable: UITableView!
    @IBOutlet weak var newDictionaryButton: UIButton!
    @IBOutlet weak var noDicltionariesLabel: UILabel!
    @IBOutlet weak var myDictionariesLabel: UILabel!
    @IBOutlet weak var profileButtonView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
    private var usersArray : Users?
    private var dicOwnerData = [DicOwnerData]()
    private var sharedDictionaries: [SharedDictionaryShortData]?
    
    
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
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if mainModel.isInternetAvailable(){
            sync.syncDictionariesCoreDataAndFirebase(userID: mainModel.loadUserData().userID, context: context)
        }
        loadDataForSharedDictionary()
        avatarSet()
        setupData()
        dictionaryCheck()
    }
    
    func setupData(){
        dictionariesArray = coreDataManager.loadUserDictionaries(userID: mainModel.loadUserData().userID, data: context)
        usersArray = coreDataManager.loadUserDataByID(userID: mainModel.loadUserData().userID, data: context)
        dictionariesTable.delegate = self
        dictionariesTable.dataSource = self
        dictionariesTable.reloadData()
        if dictionariesArray.isEmpty{
            noDicltionariesLabel.isHidden = false}
        else {
            dictionariesTable.reloadData()
                noDicltionariesLabel.isHidden = true
            }
       

    }
    
    func loadDataForSharedDictionary(){
        firebase.getDictionaryShortData { dicArray in
        let sharedDictionaries = dicArray
           
        }
    }
    
    func getDicOwnerDataFromFirestore(ownerID:String){
        let db = Firestore.firestore()
        db.collection("Users").whereField("userID", isEqualTo: ownerID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let ownerData = document.data()
                    if let ownerName = ownerData["userName"] as? String,
                       let ownerID = ownerData["userID"] as? String
                    {
                        let owner = DicOwnerData(ownerName: ownerName, ownerID: ownerID)
                        self.dicOwnerData.append(owner)
                    }
                }
            }
        }
    }
    
    func elementsDesign(){
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2
        avatarImageView.layer.masksToBounds = false
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.borderWidth = 0.5
        avatarImageView.layer.borderColor = UIColor.lightGray.cgColor
        if let userNickname = usersArray?.userName, userNickname.isEmpty {
            userNameLabel.text = usersArray?.userEmail
        } else {
            userNameLabel.text = usersArray?.userName
        }
        myDictionariesLabel.text = "dictionariesVC_myDictionaries_label".localized
        profileButtonView.layer.cornerRadius = 45
        profileButtonView.layer.shadowColor = UIColor.black.cgColor
        profileButtonView.layer.shadowOpacity = 0.2
        profileButtonView.layer.shadowOffset = .zero
        profileButtonView.layer.shadowRadius = 2
        newDictionaryButton.layer.shadowColor = UIColor.black.cgColor
        newDictionaryButton.layer.shadowOpacity = 0.2
        newDictionaryButton.layer.shadowOffset = .zero
        newDictionaryButton.layer.shadowRadius = 2
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
    
    @IBAction func newDictionaryButtonPressed(_ sender: UIButton) {
            buttonScaleAnimation(targetButton: newDictionaryButton)
            popUpApear(dictionaryIDFromCell: "", senderAction: "Create")
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
    
}

extension DictionariesController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  dictionariesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dictionaryCell = dictionariesTable.dequeueReusableCell(withIdentifier: "dictionaryCell") as! DictionaryCell
        
        dictionaryCell.cellView.layer.cornerRadius = 5
        dictionaryCell.sharedDictionaryImage.image = UIImage(systemName: "person.2.fill")
       // dictionaryCell.sharedDictionaryImage.isHidden = true
        dictionaryCell.sharedDictionaryImage.isHidden = true
        dictionaryCell.cellView.clipsToBounds = true
        dictionaryCell.dictionaryNameLabel.text = dictionariesArray[indexPath.row].dicName
        dictionaryCell.learningLanguageLabel.text = dictionariesArray[indexPath.row].dicLearningLanguage
        dictionaryCell.translateLanguageLabel.text = dictionariesArray[indexPath.row].dicTranslateLanguage
        dictionaryCell.descriptionLabel.text = dictionariesArray[indexPath.row].dicDescription ?? ""
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
            dictionaryCell.sharedDictionaryImage.image = UIImage(systemName: "tray.and.arrow.down.fill")
            dictionaryCell.sharedDictionaryImage.isHidden = false
            //dictionaryCell.sharedDictionaryImage.isHidden = false
            dictionaryCell.separatorTwoButtons.isHidden = true
            dictionaryCell.editButton.isHidden = true
            dictionaryCell.createDateLabel.text = "dictionariesVC_ownerName_label".localized
            DispatchQueue.main.async {
                self.getDicOwnerDataFromFirestore(ownerID: self.dictionariesArray[indexPath.row].dicOwnerID ?? "")
            }
            dictionaryCell.creatinDateLabel.text = dicOwnerData.first?.ownerName ?? "Anonimus"
        } else {
            dictionaryCell.creatinDateLabel.text = dictionariesArray[indexPath.row].dicAddDate
            dictionaryCell.createDateLabel.text = "dictionariesVC_createDate_label".localized
            dictionaryCell.separatorOneButton.isHidden = true
            dictionaryCell.editButton.isHidden = false
            dictionaryCell.separatorTwoButtons.isHidden = false
        }
        if dictionariesArray[indexPath.row].dicShared{
            dictionaryCell.sharedDictionaryImage.isHidden = false
           // dictionaryCell.sharedDictionaryImage.isHidden = false
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
                destinationVC.selectedDictionary = dictionariesArray[indexPath.row]
            }
    }
    
}
    
    

