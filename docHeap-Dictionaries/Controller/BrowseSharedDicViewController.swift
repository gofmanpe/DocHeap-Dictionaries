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
    @IBOutlet weak var wordsCountLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var sharedWordsTable: UITableView!
    @IBOutlet weak var userLikesLabel: UILabel!
    @IBOutlet weak var userSharedDicsLabel: UILabel!
    @IBOutlet weak var userScoresLabel: UILabel!
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var descriptionButton: UIButton!
    
    func localizeElemants(){
       
    }
 
//MARK: - Constants and variables
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var dicID = String()
    var sharedDictionary : SharedDictionary?
    var sharedWordsArray = [SharedWord]()
    private var wordsPairForPopUp : SharedWord?
    var networkUserData : NetworkUserData?
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
    private let dispatchGroup = DispatchGroup()

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
      //  guard let downloadedTimes = sharedDictionary?.dicDownloadedUsers else {return}
        downloadButton.layer.cornerRadius = 10
        let filePath = "\(mainModel.loadUserData().userID)/Temp/\(networkUserData?.userLocalAvatar ?? "")"
        let image = UIImage(contentsOfFile:  mainModel.getDocumentsFolderPath().appendingPathComponent(filePath).path)
        userAvatarImage.layer.cornerRadius = userAvatarImage.frame.size.width/2
        userAvatarImage.image = image
        userScoresLabel.text = String(networkUserData?.userScores ?? 0)
        userSharedDicsLabel.text = String(networkUserData?.userSharedDics ?? 0)
        userLikesLabel.text = String(networkUserData?.userLikes ?? 0)
        if sharedDictionary?.dicDescription == ""{
            descriptionButton.tintColor = .systemGray2
            descriptionButton.isEnabled = false
        } else{
            descriptionButton.tintColor = UIColor(named: "Main_header")
            descriptionButton.isEnabled = true
        }
        downloadButton.layer.shadowColor = UIColor.black.cgColor
        downloadButton.layer.shadowOpacity = 0.2
        downloadButton.layer.shadowOffset = .zero
        downloadButton.layer.shadowRadius = 2
        
    }
    
    func createRODictionaryCoreData(){
        guard let sd = sharedDictionary else {return}
        guard let dicLike = sharedDictionary?.dicLikes.filter({$0 == mainModel.loadUserData().userID}).isEmpty else {
            return
        }
        let newDictionaryData = LocalDictionary(
            dicID: dicID, 
            dicCommentsOn: sd.dicCommentsOn,
            dicDeleted: false,
            dicDescription: sd.dicDescription,
            dicAddDate: sd.dicAddDate,
            dicImagesCount: sd.dicImagesCount,
            dicLearningLanguage: sd.dicLearnLang,
            dicTranslateLanguage: sd.dicTransLang,
            dicLike: !dicLike,
            dicName: sd.dicName,
            dicOwnerID: sd.dicUserID,
            dicReadOnly: true,
            dicShared: false,
            dicSyncronized: true,
            dicUserID: mainModel.loadUserData().userID,
            dicWordsCount: sd.dicWordsCount)
        coreData.createDictionary(dictionary: newDictionaryData, context: context)
        mainModel.createFolderInDocuments(withName: "\(mainModel.loadUserData().userID)/\(dicID)")
        let parentDictionary = coreData.getParentDictionaryData(dicID: dicID, userID: mainModel.loadUserData().userID, data: context)
        for word in sharedWordsArray{
            let newWorsPair = WordsPair(
                wrdWord: word.wrdWord,
                wrdTranslation: word.wrdTranslation,
                wrdDicID: word.wrdDicID,
                wrdUserID: mainModel.loadUserData().userID,
                wrdID: word.wrdID,
                wrdImageFirestorePath: word.wrdImageFirestorePath,
                wrdImageName: word.wrdImageName,
                wrdReadOnly: true,
                wrdParentDictionary: parentDictionary, 
                wrdAddDate: mainModel.convertDateToString(currentDate: Date(), time: false)!)
            coreData.createWordsPair(wordsPair: newWorsPair, context: context)
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
            firebase.getNetworkUserDataByID(userID: ownerID) { nuData, error in
                if let error = error{
                    print("Error to get network user data: \(error)\n")
                } else {
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
    }
    
    func createDownloadedDictionaryUsers(){
        guard let usersIDsArray = sharedDictionary?.dicDownloadedUsers else {
            return }
        let excludeCurrentUserArray = usersIDsArray.filter({$0 != mainModel.loadUserData().userID})
        for userID in excludeCurrentUserArray{
            if !coreData.isNetworkUserExist(userID: userID, data: context){
                firebase.getNetworkUserDataByID(userID: userID) { nuData, error in
                    if let error = error{
                        print("Error to get network user data: \(error)\n")
                    } else {
                        if let userData = nuData{
                            self.coreData.createNetworkUser(userData: userData, context: self.context)
                            self.alamo.downloadChatUserAvatar(url: userData.userAvatarFirestorePath, senderID: userID, userID: self.mainModel.loadUserData().userID) { avatarName in
                                self.coreData.updateNetworkUserLocalAvatarName(userID: userID, avatarName: avatarName, context: self.context)
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
                            self.coreData.createChatMessage(message: message, context: self.context)
                        }
                    }
                }
            }
        }
    }
    
    func popUpApear(popUpName:String){
        switch popUpName{
        case "DescriptionPopUp":
            let overLayerView = DescriptionPopUpController()
            overLayerView.dicDescription = sharedDictionary?.dicDescription ?? ""
            overLayerView.netUserName = networkUserData?.userName ?? ""
            overLayerView.appear(sender: self)
        case "BrowseSharedWordsPairPopUp":
            let overLayerView = BrowseSharedWordViewController()
            overLayerView.wordsPair = wordsPairForPopUp
            overLayerView.dicLearnLang = sharedDictionary!.dicLearnLang
            overLayerView.dicTransLang = sharedDictionary!.dicTransLang
            overLayerView.appear(sender: self)
        default: break
        }
    
        
    }
   

//MARK: - Actions
    @IBAction func downloadButtonPressed(_ sender: UIButton) {
        //downloadButton.isEnabled = false
        switch dicWasDownloaded{
        case true:
            return
        case false:
            setDownloadedDelegate?.dictionaryWasDownloaded(dicID: dicID)
            firebase.setDictionaryDownloadedByUserUser(dicID: dicID, remove: false)
            buttonScaleAnimation(targetButton: downloadButton)
            if mainModel.isInternetAvailable(){
                createRODictionaryCoreData()
                downloadButton.tintColor = .white
                downloadButton.backgroundColor = UIColor(named: "Right answer")
            }
            dicWasDownloaded = true
            createSharedDictionaryOwnerData()
            createDownloadedDictionaryUsers()
            createMessagesForDictionary()
        }
    }
    
    @IBAction func descriptionButtonPressed(_ sender: UIButton) {
        buttonScaleAnimation(targetButton: descriptionButton)
        popUpApear(popUpName: "DescriptionPopUp")
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dispatchGroup.enter()
        var wrdImageName = String()
        if !sharedWordsArray[indexPath.row].wrdImageFirestorePath.isEmpty{
            alamo.downloadChatUserAvatar(
                url: sharedWordsArray[indexPath.row].wrdImageFirestorePath,
                senderID: sharedWordsArray[indexPath.row].wrdID,
                userID: "\(self.mainModel.loadUserData().userID)/Temp") { imageName in
                    wrdImageName = imageName
                    self.wordsPairForPopUp = SharedWord(
                        wrdWord: self.sharedWordsArray[indexPath.row].wrdWord,
                        wrdTranslation: self.sharedWordsArray[indexPath.row].wrdTranslation,
                        wrdDicID: self.sharedWordsArray[indexPath.row].wrdDicID,
                        wrdOwnerID: self.sharedWordsArray[indexPath.row].wrdOwnerID,
                        wrdID: self.sharedWordsArray[indexPath.row].wrdID,
                        wrdImageFirestorePath: self.sharedWordsArray[indexPath.row].wrdImageFirestorePath,
                        wrdImageName: wrdImageName)
                    self.popUpApear(popUpName: "BrowseSharedWordsPairPopUp")
                }
        }
        dispatchGroup.leave()
    }
}
