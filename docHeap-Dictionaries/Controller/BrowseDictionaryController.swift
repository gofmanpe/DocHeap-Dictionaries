//
//  BrowseDictionaryController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 26.03.23.
//

import UIKit
import CoreData
import FirebaseStorage


class BrowseDictionaryController: UIViewController, UpdateView, UploadImageToFirestore{
 
//MARK: - Protocols delegate functions
    func didUpdateView(sender:String) {
        dictionaryData()
        issetWordsInDictionary()
        updateBubbleState()
        wordsTable.reloadData()
    }
    
    func uploadImage(imageName: String?, wrdID:String) {
        guard let imageName = imageName else {return}
        switch (mainModel.isInternetAvailable(),imageName.isEmpty){
        case (true,true),(false,true):
            return
        case (true,false):
            firebase.uploadWordImage(imageName: imageName, userID: mainModel.loadUserData().userID, dicID: dicID) { imagePath, error in
                if let error = error {
                    print("Error to upload words pair image: \(error)\n")
                } else {
                    guard let path = imagePath else {return}
                    self.coreData.updateWordsPairFirestoreImagePath(wrdID: wrdID, userID: self.mainModel.loadUserData().userID, path: path, context: self.context)
                    self.firebase.updateWordsPairImagePath(wrdID: wrdID, path: path)
                    self.firebase.updateImagesCountFirebase(dicID: self.dicID, increment: true)
                    self.coreData.setWasSynchronizedStatusForWord(data: self.context, wrdID: wrdID, sync: true)
                    self.coreData.setImagesCountForDictionary(dicID: self.dicID, increment: true, context: self.context)
                }
            }
        case (false,false):
            self.coreData.setWasSynchronizedStatusForWord(data: self.context, wrdID: wrdID, sync: false)
            self.coreData.setImagesCountForDictionary(dicID: self.dicID, increment: true, context: self.context)
        }
        
    }
 
    
//MARK: - Outlets
    @IBOutlet weak var dictionaryNameLabel: UILabel!
    @IBOutlet weak var wordsCountLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var learningLanguageLabel: UILabel!
    @IBOutlet weak var learningLanguageImage: UIImageView!
    @IBOutlet weak var translateLanguageLabel: UILabel!
    @IBOutlet weak var translateLanguageImage: UIImageView!
    @IBOutlet weak var wordsTable: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var noWordsLabel: UILabel!
    @IBOutlet weak var wordsLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var dictionaryView: UIView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var descriptionButton: UIButton!
    
//MARK: - Localize functions
    func localizeElements(){
        wordsLabel.text = "browseDictionaryVC_wordsInDictionary_label".localized
        guard let dicROStatus = selectedDictionary?.dicReadOnly else {return}
            if dicROStatus{
                createdLabel.text = "browseDictionaryVC_dicOwner_label".localized
            } else {
                createdLabel.text = "browseDictionaryVC_createDate_label".localized
            }
        
    }
    
//MARK: - Constants and variables
    var selectedDictionary : LocalDictionary?
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var coreData = CoreDataManager()
    private let mainModel = MainModel()
    private let defaults = Defaults()
    private let firebase = Firebase()
    var dicID = String()
    private var wordTranslation = String()
    private var imagePath = String()
    private var clickedWordID = String()
    private var imageStatus = Bool()
    private var wordsArray = [Word]()
    private let sync = SyncModel()
    var dicOwnerData = [DicOwnerData]()
    var ownerName = String()
    private let alamo = Alamo()

//MARK: - Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
            setupData()
            dictionaryData()
            elementsDesign()
            localizeElements()
            wordsTable.dataSource = self
            wordsTable.delegate = self
            issetWordsInDictionary()
            updateBubbleState()
        if mainModel.isInternetAvailable(){
            sync.syncDictionariesCoreDataAndFirebase(userID: mainModel.loadUserData().userID, context: context)
            sync.syncWordsCoreDataAndFirebase(userID: mainModel.loadUserData().userID, context: context)
            listenFirebase(dicID: selectedDictionary?.dicID ?? "")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupData()
        wordsTable.reloadData()
        updateBubbleState()
        if mainModel.isInternetAvailable(){
            sync.syncDictionariesCoreDataAndFirebase(userID: mainModel.loadUserData().userID, context: context)
            sync.syncWordsCoreDataAndFirebase(userID: mainModel.loadUserData().userID, context: context)
            saveNetworkUsersDataForComments(dicID: selectedDictionary?.dicID ?? "", context: context)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if mainModel.isInternetAvailable(){
            sync.syncNetworkUsersDataWithFirebase(context: context)
            createMessagesForDictionary()
        }
    }
    
//MARK: - Controller functions
    private func saveNetworkUsersDataForComments(dicID:String, context:NSManagedObjectContext){
        firebase.getNetworkUsersWhichCommentsDictionary(dicID: dicID) { usersArray, error in
            if let error = error {
                print("Error load users: \(error)")
            } else {
                let excludeCurrentUserArray = usersArray.filter({$0 != self.mainModel.loadUserData().userID})
                for user in excludeCurrentUserArray{
                    if !self.coreData.isNetworkUserExist(userID: user, data: context){
                        self.firebase.getNetworkUserDataByID(userID: user) { nuData, error in
                            if let error = error{
                                print("Error to get network user data: \(error)\n")
                            } else {
                                if let userData = nuData{
                                    self.coreData.createNetworkUser(userData: userData, context: self.context)
                                    self.alamo.downloadChatUserAvatar(url: userData.userAvatarFirestorePath, senderID: user, userID: self.mainModel.loadUserData().userID) { avatarName in
                                        self.coreData.updateNetworkUserLocalAvatarName(userID: user, avatarName: avatarName, context: self.context)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func createMessagesForDictionary(){
        firebase.loadMessagesForDictionary(dicID: dicID, context: context) { messagesArray, error in
            if let error = error{
                print("Error to get messages: \(error)")
            } else {
                if let messArray = messagesArray{
                    for message in messArray{
                        let newMessageID = message.msgID
                        let corDataMessages = self.coreData.getMessagesByDicID(dicID: self.dicID, context: self.context)
                        let filteredCDMessages = corDataMessages.filter({$0.msgID == newMessageID})
                        if filteredCDMessages.isEmpty{
                            self.coreData.createCommentForDictionary(message: message, context: self.context)
                        }
                    }
                }
            }
        }
    }
    
    func listenFirebase(dicID:String){
        firebase.listenDictionaryLikesCount(dicID: dicID) { count, error in
            if let error = error{
                print("Error get dictionary likes count: \(error)\n")
            } else {
                guard let likesCount = count else {
                    return
                }
                self.likeButton.setTitle(String(likesCount), for: .normal)
            }
        }
        firebase.listenDictionaryCommentsCount(dicID: dicID) { count, error in
            if let error = error{
                print("Error get dictionary likes count: \(error)\n")
            } else {
                guard let messagesCount = count else {
                    return
                }
                self.chatButton.setTitle(String(messagesCount), for: .normal)
            }
        }
    }
    
    func setupData(){
        guard let dicID = selectedDictionary?.dicID else {
            return}
        
    }
    
    func flipView(view:UIView) {
        let flipDirection: UIView.AnimationOptions = .transitionFlipFromTop
        UIView.transition(with: view, duration: 0.6, options: flipDirection, animations: {
        }, completion: nil)
    }
    
    func issetWordsInDictionary(){
        let wordsArray = wordsArray
        if wordsArray.isEmpty{
            wordsTable.isHidden = true
            noWordsLabel.isHidden = false
            noWordsLabel.text = defaults.noWordsLabelText
        } else {
            wordsTable.isHidden = false
            noWordsLabel.isHidden = true
        }
    }
  
    func dictionaryData(){
        wordsArray = coreData.getWordsForDictionary(dicID: dicID, userID: mainModel.loadUserData().userID, context: context)
        selectedDictionary = coreData.getLocalDictionaryByID(userID: mainModel.loadUserData().userID, dicID: dicID, data: context)
        dictionaryNameLabel.text = selectedDictionary?.dicName
        dicID = selectedDictionary?.dicID ?? ""
        wordsCountLabel.text = String(selectedDictionary!.dicWordsCount)
        if let dicROStatus = selectedDictionary?.dicReadOnly{
            if dicROStatus{
                creationDateLabel.text = ownerName
            } else {
                creationDateLabel.text = selectedDictionary?.dicAddDate
            }
        }
        learningLanguageLabel.text = selectedDictionary?.dicLearningLanguage
        translateLanguageLabel.text = selectedDictionary?.dicTranslateLanguage
        let learnImage:String = selectedDictionary!.dicLearningLanguage
        learningLanguageImage.image = UIImage(named: "\(learnImage).png")
        let translateImage:String = selectedDictionary!.dicTranslateLanguage
        translateLanguageImage.image = UIImage(named: "\(translateImage).png")
        guard let dicLike = selectedDictionary?.dicLike else {return}
            if dicLike{
                likeButton.tintColor = UIColor(named: "Wrong answer")
            } else {
                likeButton.tintColor = UIColor.systemGray
            }
        
        if selectedDictionary?.dicCommentsOn == true{
            chatButton.isHidden = false
        } else {
            chatButton.isHidden = true
        }
        guard let dicDescription = selectedDictionary?.dicDescription else {return}
        if dicDescription.isEmpty{
            descriptionButton.isEnabled = false
        } else {
            descriptionButton.isEnabled = true
        }
    }
    
    func buttonPushDownAnimate(){
        let originalFrame = addButton.frame
        let centerPosition = addButton.center
        UIView.animate(withDuration: 0.3) {
            var frame = self.addButton.frame
            frame.origin.y += 5
            self.addButton.frame = frame
        } completion: { Bool in
            self.addButton.frame = originalFrame
            self.addButton.center = centerPosition
        }
    }
    
    func buttonScaleAnimation(targetButton:UIButton){
        UIView.animate(withDuration: 0.2) {
            targetButton.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        } completion: { (bool) in
            targetButton.transform = .identity
        }
    }
    
    func popUpApear(sender:String){
        switch sender{
        case "addButton":
            let overLayedView = AddWordPopUpViewController()
            overLayedView.tableReloadDelegate = self
            overLayedView.uploadImageDelegate = self
            overLayedView.dictionaryID = dicID
            overLayedView.appear(sender: self)
        case "wordPressed":
            let overLayedView = BrowseWordViewController()
            overLayedView.wordID = clickedWordID
            overLayedView.imageName = imagePath
            overLayedView.dictionaryID = dicID
            if let dicROStatus = selectedDictionary?.dicReadOnly{
                overLayedView.dicROstatus = dicROStatus
            }
            overLayedView.tableReloadDelegate = self
            overLayedView.imageStatus = imageStatus
            overLayedView.appear(sender: self)
        case "descriptionButton":
            let overLayedView = DescriptionPopUpController()
            overLayedView.dicDescription = selectedDictionary?.dicDescription ?? ""
            overLayedView.netUserName = mainModel.loadUserData().userName
            overLayedView.appear(sender: self)
        default: break
        }
    }
    
    func elementsDesign(){
        wordsTable.layer.cornerRadius = 10
        wordsTable.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        addButton.layer.cornerRadius = 25
        dictionaryView.layer.shadowColor = UIColor.black.cgColor
        dictionaryView.layer.shadowOpacity = 0.2
        dictionaryView.layer.shadowOffset = .zero
        dictionaryView.layer.shadowRadius = 2
        if let dicROStatus = selectedDictionary?.dicReadOnly{
            if dicROStatus{
                addButton.isHidden = true
            } else if let dicShared = selectedDictionary?.dicShared{
                if dicShared{
                    addButton.isHidden = false
                    likeButton.isHidden = true
                } else {
                    likeButton.isHidden = true
                    chatButton.isHidden = true
                }
            }
        }
        let buttons = [chatButton!,addButton!,likeButton!]
        for button in buttons{
            button.layer.shadowColor = UIColor.systemGray2.cgColor
            button.layer.shadowOffset = CGSize(width: 1, height: 1)
            button.layer.shadowRadius = 2.0
            button.layer.shadowOpacity = 0.5
            button.layer.cornerRadius = 10
        }
    }
    
    func updateBubbleState(){
        for i in 0..<wordsArray.count{
            let rightAnswer = wordsArray[i].wrdRightAnswers
            let wrongAnswer = wordsArray[i].wrdWrongAnswers
            let bubbleState = rightAnswer - wrongAnswer
            if bubbleState > 0 {
                wordsArray[i].wrdBobbleColor = "green"
            } else if bubbleState < 0 {
                wordsArray[i].wrdBobbleColor = "red"
            } else if bubbleState == 0 {
                wordsArray[i].wrdBobbleColor = "yellow"
            }
            coreData.saveData(data: context)
        }
    }
    
//MARK: - Actions
    @IBAction func addButtonPressed(_ sender: UIButton) {
        buttonScaleAnimation(targetButton: addButton)
        popUpApear(sender:"addButton")
    }
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        guard let dicLike = selectedDictionary?.dicLike else {return}
            if dicLike{
                buttonScaleAnimation(targetButton: likeButton)
                if mainModel.isInternetAvailable(){
                    firebase.setLikeForDictionaryFirebase(dicID: dicID, userID: mainModel.loadUserData().userID, like: false)
                    firebase.updateNetworkUserLikeCount(userID: selectedDictionary!.dicOwnerID, increment: false)
                } else {
                    coreData.setSyncronizedStatusForDictionary(data: context, dicID: dicID, sync: false)
                }
                likeButton.tintColor = UIColor(named: "Wrong answer")
                coreData.setLikeStatusForDictionary(context: context, dicID: dicID, userID: mainModel.loadUserData().userID, sync: false)
                dictionaryData()
            } else {
                buttonScaleAnimation(targetButton: likeButton)
                if mainModel.isInternetAvailable(){
                    firebase.setLikeForDictionaryFirebase(dicID: dicID, userID: mainModel.loadUserData().userID, like: true)
                    firebase.updateNetworkUserLikeCount(userID: selectedDictionary!.dicOwnerID, increment: true)
                } else {
                    coreData.setSyncronizedStatusForDictionary(data: context, dicID: dicID, sync: false)
                }
                likeButton.tintColor = .systemGray
                coreData.setLikeStatusForDictionary(context: context, dicID: dicID, userID: mainModel.loadUserData().userID, sync: true)
                dictionaryData()
            }
    }
    
    @IBAction func descriptionButtonPressed(_ sender: UIButton) {
        popUpApear(sender: "descriptionButton")
    }
    
    
    @IBAction func chatButtonPressed(_ sender: UIButton) {
        buttonScaleAnimation(targetButton: chatButton)
        performSegue(withIdentifier: "openChat", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let destinationVC = segue.destination as! ChatViewController
                destinationVC.dicID = dicID
    }
    
}

//MARK: - Words table Delegate and DataSource
extension BrowseDictionaryController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wordCell = wordsTable.dequeueReusableCell(withIdentifier: "wordCell") as! WordCell
        wordCell.layer.cornerRadius = 5
        wordCell.learningLanguageLabel.text = wordsArray[indexPath.row].wrdWord
        wordCell.translateLanguageLabel.text = wordsArray[indexPath.row].wrdTranslation
        if wordsArray[indexPath.row].wrdImageIsSet == true {
            wordCell.isSetImageBackgroundView.backgroundColor = UIColor(named: "Right answer")
        } else {
            wordCell.isSetImageBackgroundView.backgroundColor = .systemGray2
        }
        switch wordsArray[indexPath.row].wrdBobbleColor {
        case "green":
            wordCell.statusImage.tintColor = .systemGreen
        case "red":
            wordCell.statusImage.tintColor = .systemRed
        case "yellow":
            wordCell.statusImage.tintColor = .systemYellow
        default: break
        }
        return wordCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        clickedWordID = wordsArray[indexPath.row].wrdID!
        imagePath = wordsArray[indexPath.row].imageName ?? ""
        wordTranslation = wordsArray[indexPath.row].wrdTranslation!
        imageStatus = wordsArray[indexPath.row].wrdImageIsSet
        popUpApear(sender: "wordPressed")
    }
    
}

