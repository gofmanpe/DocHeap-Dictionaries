//
//  BrowseSharedDicViewController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 24.12.23.
//

import UIKit

class BrowseSharedDicViewController: UIViewController {
 
//MARK: - Outlets
    @IBOutlet weak var learnLangImage: UIImageView!
    @IBOutlet weak var learnLangLabel: UILabel!
    @IBOutlet weak var transLangImage: UIImageView!
    @IBOutlet weak var transLangLabel: UILabel!
    @IBOutlet weak var dicNameLabel: UILabel!
    @IBOutlet weak var wordsCountNameLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var wordsCountLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var sharedWordsTable: UITableView!
    @IBOutlet weak var downloadedTimesLabel: UILabel!
    @IBOutlet weak var dicLikesLabel: UILabel!
    @IBOutlet weak var messagesCountLabel: UILabel!
    
    func localizeElemants(){
       
    }
 
//MARK: - Constants and variables
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var dicID = String()
    var sharedDictionary : SharedDictionary?
    var sharedWordsArray = [SharedWord]()
    var dicOwnerData : DicOwnerData?
    var ownerName = String()
    var ownerID = String()
    var messagesCount = String()
    private let mainModel = MainModel()
    private let coreData = CoreDataManager()
    private let alamo = Alamo()
    var setDownloadedDelegate: SetDownloadedMarkToDictionary?
    private let firebase = Firebase()
    private var dicWasDownloaded = Bool()

//MARK: - Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeElemants()
        elementsSetup()
        sharedWordsTable.delegate = self
        sharedWordsTable.dataSource = self
        sharedWordsTable.reloadData()
    }

//MARK: - Controller functions
    func elementsSetup(){
        learnLangImage.image = UIImage(named: sharedDictionary?.dicLearnLang ?? "")
        transLangImage.image = UIImage(named: sharedDictionary?.dicTransLang ?? "")
        learnLangLabel.text = sharedDictionary?.dicLearnLang ?? ""
        transLangLabel.text = sharedDictionary?.dicTransLang ?? ""
        dicNameLabel.text = sharedDictionary?.dicName ?? ""
        wordsCountLabel.text = String(sharedDictionary?.dicWordsCount ?? 0)
        ownerLabel.text = ownerName
        guard let downloadedTimes = sharedDictionary?.dicDownloadedUsers else {return}
        downloadedTimesLabel.text = String(downloadedTimes.count)
        guard let dicLikes = sharedDictionary?.dicLikes else {return}
        dicLikesLabel.text = String(dicLikes.count)
        downloadButton.layer.cornerRadius = 10
        messagesCountLabel.text = messagesCount
    }
    
    func createDictionaryCoreData(){
        let likesArray = sharedDictionary?.dicLikes ?? [String]()
        let isUserLikedDictionaryBefore = likesArray.filter({$0 == mainModel.loadUserData().userID})
        let newDictionary = Dictionary(context: context)
        newDictionary.dicName = sharedDictionary?.dicName
        newDictionary.dicDescription = sharedDictionary?.dicDescription
        newDictionary.dicLearningLanguage = sharedDictionary?.dicLearnLang
        newDictionary.dicTranslateLanguage = sharedDictionary?.dicTransLang
        newDictionary.dicID = dicID
        newDictionary.dicUserID = mainModel.loadUserData().userID
        newDictionary.dicAddDate = mainModel.convertDateToString(currentDate: Date(), time: false)
        mainModel.createFolderInDocuments(withName: "\(mainModel.loadUserData().userID)/\(dicID)")
        newDictionary.dicDeleted = false
        newDictionary.dicShared = false
        newDictionary.dicReadOnly = true
        if isUserLikedDictionaryBefore.isEmpty{
            newDictionary.dicLike = false
        } else {
            newDictionary.dicLike = true
        }
        newDictionary.dicOwnerID = sharedDictionary?.dicUserID
        newDictionary.dicWordsCount = Int64(sharedDictionary?.dicWordsCount ?? 0)
        newDictionary.dicImagesCount = Int64(sharedDictionary?.dicImagesCount ?? 0)
        coreData.saveData(data: context)
        let parentDictionary = coreData.getParentDictionaryData(dicID: dicID, userID: mainModel.loadUserData().userID, data: context)
        for word in sharedWordsArray{
            let newWord = Word(context: context)
            newWord.wrdID = word.wrdID
            newWord.wrdWord = word.wrdWord
            newWord.wrdTranslation = word.wrdTranslation
            if !word.wrdImageName.isEmpty{
                newWord.imageName = word.wrdImageName
                newWord.wrdImageIsSet = true
                newWord.wrdImageFirestorePath = word.wrdImageFirestorePath
                alamo.downloadAndSaveImage(
                    fromURL: word.wrdImageFirestorePath,
                    userID: mainModel.loadUserData().userID,
                    dicID: dicID,
                    imageName: word.wrdImageName) {
                    }
            }
            newWord.parentDictionary = parentDictionary
            newWord.wrdAddDate = mainModel.convertDateToString(currentDate: Date(), time: false)
            newWord.wrdBobbleColor = ".systemYellow"
            newWord.wrdDicID = dicID
            newWord.wrdDeleted = false
            newWord.wrdReadOnly = true
            newWord.wrdUserID = mainModel.loadUserData().userID
            newWord.wrdSyncronized = true
            coreData.saveData(data: context)
        }
    }
    
    func buttonScaleAnimation(targetButton:UIButton){
        UIView.animate(withDuration: 0.2) {
            targetButton.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        } completion: { (bool) in
            targetButton.transform = .identity
        }
    }
    
    func createSharedDictionaryOwnerData(){
        if coreData.isNetworkUserExist(userID: ownerID, data: context){
            return
        } else {
            firebase.getNetworkUserDataByID(userID: ownerID) { nuData in
                guard let networkUserData = nuData else {
                    return
                }
                self.coreData.createNetworkUser(userData: networkUserData, context: self.context)
                let userAvatarFirestorePath = networkUserData.userAvatarFirestorePath
                let userID = networkUserData.userID
                self.alamo.downloadChatUserAvatar(url: userAvatarFirestorePath, senderID: userID, userID: self.mainModel.loadUserData().userID) { avatarName in
                    self.coreData.updateNetworkUserLocalAvatarName(userID: networkUserData.userID, avatarName: avatarName, context: self.context)
                }
            }
        }
    }
    
    func createDownloadedDictionaryUsers(){
        guard let usersIDsArray = sharedDictionary?.dicDownloadedUsers else {
            return }
        let excludeCurrentUserArray = usersIDsArray.filter({$0 != mainModel.loadUserData().userID})
        for userID in excludeCurrentUserArray{
            if coreData.isNetworkUserExist(userID: userID, data: context){
                return
            } else {
                firebase.createNetworkUsersInCoreData(userID: userID, context: context)
            }
        }
    }
    
    func createMessagesForDictionary(){
        firebase.loadMessagesForDictionary(dicID: dicID, context: context) { messagesArray, error in
            if let error = error{
                print("Error to get messages: \(error)")
            } else {
                if let messArray = messagesArray{
                    // check is message already exist in CoreData
                    for message in messArray{
                        let newMessageID = message.msgID
                        let corDataMessages = self.coreData.getMessagesByDicID(dicID: self.dicID, context: self.context)
                        let filteredCDMessages = corDataMessages.filter({$0.msgID == newMessageID})
                        if filteredCDMessages.isEmpty{
                            self.coreData.createChatMessage(message: message, context: self.context)
                        }
                    }
                    
                }
            }
        }
    }

//MARK: - Actions
    @IBAction func downloadButtonPressed(_ sender: UIButton) {
        switch dicWasDownloaded{
        case true:
            return
        case false:
            setDownloadedDelegate?.dictionaryWasDownloaded(dicID: dicID)
            firebase.setDictionaryDownloadedByUserUser(dicID: dicID, remove: false)
            buttonScaleAnimation(targetButton: downloadButton)
            if mainModel.isInternetAvailable(){
                createDictionaryCoreData()
                downloadButton.tintColor = .white
                downloadButton.backgroundColor = UIColor(named: "Right answer")
            }
            dicWasDownloaded = true
            createSharedDictionaryOwnerData()
            createDownloadedDictionaryUsers()
            createMessagesForDictionary()
        }
    }
    
}

//MARK: - Words table Delegate and DataSource
extension BrowseSharedDicViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharedWordsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let wordCell = sharedWordsTable.dequeueReusableCell(withIdentifier: "sharedWordCell") as! SharedWordCell
        if sharedWordsArray[indexPath.row].wrdImageFirestorePath.isEmpty{
            wordCell.imgBgView.backgroundColor = .systemGray2
        } else {
            wordCell.imgBgView.backgroundColor = UIColor(named: "Right answer")
        }
        wordCell.wordLabel.text = sharedWordsArray[indexPath.row].wrdWord
        wordCell.translationLabel.text = sharedWordsArray[indexPath.row].wrdTranslation
        return wordCell
    }
}
