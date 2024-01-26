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
            sync.syncUserLikesForSharedDictionaries(userID: mainModel.loadUserData().userID, context: context)
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
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var scoresNameLabel: UILabel!
    @IBOutlet weak var scoresLabel: UILabel!
    @IBOutlet weak var testsRunsLabel: UILabel!
    @IBOutlet weak var testsRunsNameLabel: UILabel!
    @IBOutlet weak var likesNameLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    
    
    
//MARK: - Constants and variables
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var coreData = CoreDataManager()
    private let sync = SyncModel()
    private let mainModel = MainModel()
    private var firebase = Firebase()
    private var currentUser = String()
    private var currentUserEmail = String()
    private var currentUserNickname = String()
    private var avatarName = String()
    private var dicID = String()
    var userID = String()
    private var dictionariesArray = [Dictionary]()
    private var userDataArray = [UserData]()
    
    private var likesCount = Int()
//    private var messagesCount = Int()
//    private let dispatchGroup = DispatchGroup()
    
//MARK: - Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        dictionaryCheck()
        elementsDesign()
        localizeElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if mainModel.isInternetAvailable(){
            sync.syncDictionariesCoreDataAndFirebase(userID: mainModel.loadUserData().userID, context: context)
            sync.syncNetworkUsersDataWithFirebase(context: context)
            sync.syncUserDataWithFirebase(userID: mainModel.loadUserData().userID, context: context)
            sync.syncUserLikesForSharedDictionaries(userID: mainModel.loadUserData().userID, context: context)
            DispatchQueue.global().async {
                self.sync.syncDownloadedDictionariesData(userID: self.mainModel.loadUserData().userID, context: self.context)
                Thread.sleep(forTimeInterval: 1)
                DispatchQueue.main.async {
                    self.dictionariesTable.reloadData()
                    self.setupData()
                }
            }
        }
        setupData()
        dictionaryCheck()
    }

    
    
//MARK: - Controller functions
    func setupData(){
        dictionariesArray = coreData.loadUserDictionaries(userID: mainModel.loadUserData().userID, data: context)
        userDataArray = coreData.loadUserDataByID(userID: mainModel.loadUserData().userID, context: context) 
        let userTotalStat = coreData.getTotalStatisticForUser(userID: mainModel.loadUserData().userID, context: context).first
        scoresLabel.text = String(userTotalStat?.scores ?? 0)
        testsRunsLabel.text = String(userTotalStat?.testRuns ?? 0)
        let userName = userDataArray.first?.userName
        let userEmail = userDataArray.first?.userEmail
        dictionariesTable.delegate = self
        dictionariesTable.dataSource = self
        dictionariesTable.reloadData()
        if dictionariesArray.isEmpty{
            noDicltionariesLabel.isHidden = false}
        else {
            dictionariesTable.reloadData()
            noDicltionariesLabel.isHidden = true
        }
        if userName != nil {
            userNameLabel.text = userName
        } else {
            userNameLabel.text = userEmail
        }
        let avatarExtention = userDataArray.first?.userAvatarExtention
        if avatarExtention != nil{
            avatarName = "userAvatar.\(avatarExtention ?? "")"
            let avatarPath = "\(mainModel.loadUserData().userID)/\(avatarName)"
            avatarImageView.image = UIImage(contentsOfFile:  mainModel.getDocumentsFolderPath().appendingPathComponent(avatarPath).path)
        }
        firebase.listenUserLikesCount(userID: mainModel.loadUserData().userID) { count, error in
            if let error = error {
                print ("Error to get user likes: \(error)\n")
            } else {
                guard let likes = count else {return}
                if likes != self.likesCount {
                    self.imageScaleAnimation(target: self.likeImage)
                }
                self.likesLabel.text = String(likes)
                self.likesCount = likes
            }
        }
    }
//    func listenCounts(dicID:String){
//        firebase.listenDictionaryLikesCount(dicID: dicID) { count, error in
//            if let error = error{
//                print("Error get dictionary likes count: \(error)\n")
//            } else {
//                guard let likesCount = count else {
//                    return
//                }
//                self.likesCount = likesCount
//            }
//        }
//        firebase.listenDictionaryCommentsCount(dicID: dicID) { count, error in
//            if let error = error{
//                print("Error get dictionary likes count: \(error)\n")
//            } else {
//                guard let messagesCount = count else {
//                    return
//                }
//                self.messagesCount = messagesCount
//            }
//        }
//    }
    
    func localizeElements(){
        myDictionariesLabel.text = "dictionariesVC_myDictionaries_label".localized
        likesNameLabel.text = "dictionariesVC_likes_label".localized
        scoresNameLabel.text = "dictionariesVC_scores_label".localized
        testsRunsNameLabel.text = "dictionariesVC_testRuns_label".localized
    }
    
    func elementsDesign(){
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2
        avatarImageView.layer.masksToBounds = false
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.borderWidth = 0.5
        avatarImageView.layer.borderColor = UIColor.lightGray.cgColor
//        profileButtonView.layer.cornerRadius = 45
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
    
    func imageScaleAnimation(target:UIImageView){
        UIView.animate(withDuration: 0.2) {
            target.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        } completion: { (bool) in
            target.transform = .identity
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
        dictionaryCell.dicTypeLabel.isHidden = true
        dictionaryCell.infoStack.isHidden = false
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
            dictionaryCell.infoStack.isHidden = true
            dictionaryCell.dicTypeLabel.text = "dictionariesVC_dicCell_downloaded_label".localized
            dictionaryCell.dicTypeLabel.isHidden = false
            dictionaryCell.editButton.isHidden = true
            dictionaryCell.createDateLabel.text = "dictionariesVC_ownerName_label".localized
            let ownerName = coreData.getNetworkUserNameByID(userID: dictionariesArray[indexPath.row].dicOwnerID ?? "NONAME", context: context)
            dictionaryCell.creatinDateLabel.text = ownerName
        } else {
            dictionaryCell.infoStack.isHidden = true
            dictionaryCell.creatinDateLabel.text = dictionariesArray[indexPath.row].dicAddDate
            dictionaryCell.createDateLabel.text = "dictionariesVC_createDate_label".localized
            dictionaryCell.editButton.isHidden = false
        }
        if dictionariesArray[indexPath.row].dicShared{
            dictionaryCell.infoStack.isHidden = false
            if dictionariesArray[indexPath.row].dicCommentsOn{
                dictionaryCell.messagesStackView.isHidden = false
            } else {
                dictionaryCell.messagesStackView.isHidden = true
            }
            //listenCounts(dicID: dictionariesArray[indexPath.row].dicID ?? "")
            firebase.listenDictionaryCommentsCount(dicID: dictionariesArray[indexPath.row].dicID ?? "") { count, error in
                if let error = error{
                    print("Error get dictionary likes count: \(error)\n")
                } else {
                    guard let messagesCount = count else {
                        return
                    }
                  //  self.imageScaleAnimation(target: dictionaryCell.commentImage)
                    dictionaryCell.dicCommentsLabel.text = String(messagesCount)
                }
            }
            firebase.listenDictionaryLikesCount(dicID: dictionariesArray[indexPath.row].dicID ?? "") { count, error in
                if let error = error{
                    print("Error get dictionary likes count: \(error)\n")
                } else {
                    guard let likesCount = count else {
                        return
                    }
                 //   self.imageScaleAnimation(target: dictionaryCell.likeImage)
                    dictionaryCell.dicLikesLabel.text = String(likesCount)
                }
            }
            //dictionaryCell.dicLikesLabel.text = String(likesCount)
           // dictionaryCell.dicCommentsLabel.text = String(messagesCount)
            dictionaryCell.dicTypeLabel.text = "dictionariesVC_dicCell_shared_label".localized
            dictionaryCell.dicTypeLabel.isHidden = false
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
                let ownerName = coreData.getNetworkUserNameByID(userID: dictionariesArray[indexPath.row].dicOwnerID ?? "NONAME", context: context)
                destinationVC.ownerName = ownerName
                destinationVC.selectedDictionary = dictionariesArray[indexPath.row]
            }
    }
    
}
    
    

