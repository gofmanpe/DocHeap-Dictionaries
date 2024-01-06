//
//  BrowseSharedDicViewController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 24.12.23.
//

import UIKit

class BrowseSharedDicViewController: UIViewController {
    
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
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var dicID = String()
    var sharedDictionary : SharedDictionary?
    var sharedWordsArray = [SharedWord]()
    var dicOwnerData : DicOwnerData?
    var messagesCount = String()
    private let mainModel = MainModel()
    private let coreData = CoreDataManager()
    private let alamo = Alamo()
    var setDownloadedDelegate: SetDownloadedMarkToDictionary?
    private let firebase = Firebase()
    private var dicWasDownloaded = Bool()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        elementsSetup()
        sharedWordsTable.delegate = self
        sharedWordsTable.dataSource = self
        sharedWordsTable.reloadData()
        print("Messages count for dictionary is: \(messagesCount)")
    }
    
    func elementsSetup(){
        learnLangImage.image = UIImage(named: sharedDictionary?.dicLearnLang ?? "")
        transLangImage.image = UIImage(named: sharedDictionary?.dicTransLang ?? "")
        learnLangLabel.text = sharedDictionary?.dicLearnLang ?? ""
        transLangLabel.text = sharedDictionary?.dicTransLang ?? ""
        dicNameLabel.text = sharedDictionary?.dicName ?? ""
        wordsCountLabel.text = String(sharedDictionary?.dicWordsCount ?? 0)
        ownerLabel.text = dicOwnerData?.ownerName ?? "Anonimus"
        guard let downloadedTimes = sharedDictionary?.dicDownloadedUsers else {return}
        downloadedTimesLabel.text = String(downloadedTimes.count)
        guard let dicLikes = sharedDictionary?.dicLikes else {return}
        dicLikesLabel.text = String(dicLikes.count)
        downloadButton.layer.cornerRadius = 5
        messagesCountLabel.text = messagesCount
       
    }
    
    func createDictionaryCoreData(){
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
        newDictionary.dicLike = false
        newDictionary.dicOwnerID = dicOwnerData?.ownerID
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
            newWord.parentDictionary = parentDictionary.first
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
        }
        
    }
    
}

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
