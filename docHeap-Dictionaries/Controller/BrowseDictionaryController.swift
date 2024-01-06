//
//  BrowseDictionaryController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 26.03.23.
//

import UIKit
import CoreData
import FirebaseStorage


class BrowseDictionaryController: UIViewController, UpdateView, SaveWordsPairToDictionary{
    
    func didUpdateView(sender:String) {
        coreDataManager.loadWordsForSelectedDictionary(dicID: dicID, userID: mainModel.loadUserData().userID, data: context)
        setupData()
        wordsTable.reloadData()
        issetWordsInDictionary()
        dictionaryData()
        updateBubbleState()
    }
    
    func saveWordsPair(word: String, translation: String, imageName: String?, wrdID:String) {
 // Creating record in CoreData Words entity
        let newWord = Word(context: context)
        var isSetImage = false
        newWord.wrdWord = word
        newWord.wrdTranslation = translation
        if !imageName!.isEmpty{
            let imageForWord = imageName!
           
            newWord.imageName = imageForWord
            newWord.wrdImageIsSet = true
            isSetImage = true
        }
        newWord.parentDictionary = selectedDictionary
        newWord.wrdAddDate = mainModel.convertDateToString(currentDate: Date(), time: false)
        newWord.wrdBobbleColor = ".systemYellow"
        newWord.wrdID = wrdID
        newWord.wrdDicID = selectedDictionary?.dicID ?? ""
        newWord.wrdDeleted = false
        newWord.wrdReadOnly = false
        //newWord.owner = mainModel.loadUserData().email
        newWord.wrdUserID = mainModel.loadUserData().userID
        if mainModel.isInternetAvailable(){
            fireDB.createWord(
                wrdUserID: mainModel.loadUserData().userID,
                wrdDicID: selectedDictionary?.dicID ?? "",
                wrdWord: word,
                wrdTanslation: translation,
                wrdImageName: imageName ?? "",
                wrdID: wrdID,
                wrdAddDate: mainModel.convertDateToString(currentDate: Date(), time: false),
                wrdImageFirestorePath: nil)
            fireDB.updateWordsCountFirebase(dicID: selectedDictionary?.dicID ?? "", increment: true)
            fireDB.checkIsWordExistsInDictionary(wrdID: wrdID)  { exists, error in
                if let error = error {
                    newWord.wrdSyncronized = false
                        print("Error checking word existence: \(error)")
                    } else {
                        if exists {
                            newWord.wrdSyncronized = true
                        }
                    }
            }
        } else {
            newWord.wrdSyncronized = false
            coreDataManager.setSyncronizedStatusForDictionary(data: context, dicID: selectedDictionary?.dicID ?? "", sync: false)
            coreDataManager.setCountsInParentDictionary(increment: true, isSetImage: isSetImage, dicID: dicID, context: context)
        }
        coreDataManager.saveData(data: context)
        coreDataManager.loadWordsForSelectedDictionary(dicID: dicID, userID: mainModel.loadUserData().userID, data: context)
        coreDataManager.setCountsInParentDictionary(increment: true, isSetImage: isSetImage, dicID: dicID, context: context)
        wordsTable.reloadData()
        dictionaryData()
// Uplod image, updating imageURL in Firestore, updating imageFirestorePath in CoreData
        if mainModel.isInternetAvailable(){
            if isSetImage{
                let storage = Storage.storage()
                let imageRef = storage.reference().child(mainModel.loadUserData().userID).child(dicID).child(imageName ?? "")
                let localImagePath = mainModel.getDocumentsFolderPath().appendingPathComponent("\(mainModel.loadUserData().userID)/\(dicID)/\(imageName ?? "")")
                imageRef.putFile(from: localImagePath, metadata: nil) { metadata, error in
                    guard metadata != nil else {
                        return
                    }
                    imageRef.downloadURL { url, error in
                        guard let downloadURL = url else {
                            // Errors processing
                            return
                        }
                        let currentWord = self.coreDataManager.wordsArray.filter({$0.wrdWord == word})
                        currentWord.first?.wrdImageFirestorePath = downloadURL.absoluteString
                        currentWord.first?.wrdImageIsSet = true
                        currentWord.first?.imageUploaded = true
                        
                        self.coreDataManager.saveData(data: self.context)
                        let wrdID = currentWord.first?.wrdID ?? ""
                        self.fireDB.updateImageURLaddressFirebase(wrdID: wrdID, word: word, fsURL: downloadURL.absoluteString, imageName: imageName ?? "")
                        
                        self.fireDB.updateImagesCountFirebase(dicID: self.dicID, increment: true)
                        self.coreDataManager.setWasSynchronizedStatusForWord(data: self.context, wrdID: self.selectedDictionary?.dicID ?? "", sync: true)
                    }
                }
            }
        } else {
            newWord.imageUploaded = false
            coreDataManager.setWasSynchronizedStatusForWord(data: context, wrdID: selectedDictionary?.dicID ?? "", sync: false)
            coreDataManager.saveData(data: context)
        }
        issetWordsInDictionary()
    }
    
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
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var wordsLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var dictionaryView: UIView!
    @IBOutlet weak var likeAndChatStack: UIStackView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    
    func localizeElements(){
        wordsLabel.text = "browseDictionaryVC_wordsInDictionary_label".localized
        if let dicROStatus = selectedDictionary?.dicReadOnly{
            if dicROStatus{
                createdLabel.text = "browseDictionaryVC_dicOwner_label".localized
            } else {
                createdLabel.text = "browseDictionaryVC_createDate_label".localized
            }
        }
        
    }
    
    
    var selectedDictionary: Dictionary? {
        didSet{
            coreDataManager.loadAllWords(data: context)
        }
    }
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var coreDataManager = CoreDataManager()
    private let mainModel = MainModel()
    private let defaults = Defaults()
    private let fireDB = Firebase()
    private var dicID = String()
    private var wordTranslation = String()
    private var imagePath = String()
    private var clickedWordID = String()
    private var imageStatus = Bool()
    private var wordsArray = [Word]()
    private let sync = SyncModel()
    var dicOwnerData = [DicOwnerData]()
  
    override func viewDidLoad() {
        super.viewDidLoad()
            localizeElements()
            setupData()
            dictionaryData()
            coreDataManager.loadWordsForSelectedDictionary(dicID: dicID, userID: mainModel.loadUserData().userID, data: context)
            elementsDesign()
            wordsTable.dataSource = self
            wordsTable.delegate = self
            issetWordsInDictionary()
            updateBubbleState()
        if mainModel.isInternetAvailable(){
            sync.syncDictionariesCoreDataAndFirebase(userID: mainModel.loadUserData().userID, context: context)
            sync.syncWordsCoreDataAndFirebase(userID: mainModel.loadUserData().userID, context: context)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupData()
        wordsTable.dataSource = self
        wordsTable.delegate = self
        wordsTable.reloadData()
        updateBubbleState()
        if mainModel.isInternetAvailable(){
            sync.syncDictionariesCoreDataAndFirebase(userID: mainModel.loadUserData().userID, context: context)
            sync.syncWordsCoreDataAndFirebase(userID: mainModel.loadUserData().userID, context: context)
        }
    }
    
    func setupData(){
        guard let dicID = selectedDictionary?.dicID else {
            return}
        wordsArray = coreDataManager.getWordsForDictionary(dicID: dicID, userID: mainModel.loadUserData().userID, data: context)
    }
    
    func flipView(view:UIView) {
        let flipDirection: UIView.AnimationOptions = .transitionFlipFromTop
        UIView.transition(with: view, duration: 0.6, options: flipDirection, animations: {
        }, completion: nil)
    }
    
    func issetWordsInDictionary(){
        let wordsArray = /*coreDataManager.*/wordsArray
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
        dictionaryNameLabel.text = selectedDictionary?.dicName
        if let description = selectedDictionary?.dicDescription{
            descriptionLabel.text = description
        }
        dicID = selectedDictionary?.dicID ?? ""
        wordsCountLabel.text = String(selectedDictionary!.dicWordsCount)
        if let dicROStatus = selectedDictionary?.dicReadOnly{
            if dicROStatus{
                creationDateLabel.text = dicOwnerData.first?.ownerName ?? "Anonimus"
            } else {
                creationDateLabel.text = selectedDictionary?.dicAddDate
            }
        }
        learningLanguageLabel.text = selectedDictionary?.dicLearningLanguage
        translateLanguageLabel.text = selectedDictionary?.dicTranslateLanguage
        let learnImage:String = selectedDictionary!.dicLearningLanguage!
        learningLanguageImage.image = UIImage(named: "\(learnImage).png")
        let translateImage:String = selectedDictionary!.dicTranslateLanguage!
        translateLanguageImage.image = UIImage(named: "\(translateImage).png")
        if let dicLike = selectedDictionary?.dicLike{
            if dicLike{
                likeButton.tintColor = UIColor(named: "Main_header")
                likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            } else {
                likeButton.tintColor = UIColor.systemGray
                likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            }
        }
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        buttonScaleAnimation(targetButton: addButton)
        popUpApear(sender:"addButton")
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
            overLayedView.saveWordformPopupDelegate = self
            overLayedView.dictionaryID = dicID
            overLayedView.appear(sender: self)
        case "wordPressed":
            let overLayedView = BrowseWordViewController()
            overLayedView.wordID = clickedWordID
            overLayedView.imageName = imagePath
            overLayedView.dictionaryID = dicID
            if let dicROStatus = selectedDictionary?.dicReadOnly{
                if dicROStatus{
                    overLayedView.dicROstatus = true
                } else {
                    overLayedView.dicROstatus = false
                }
            }
            overLayedView.tableReloadDelegate = self
            overLayedView.imageStatus = imageStatus
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
        likeAndChatStack.isHidden = true
        if let dicROStatus = selectedDictionary?.dicReadOnly{
            if dicROStatus{
                addButton.isHidden = true
                likeAndChatStack.isHidden = false
            } else if let dicShared = selectedDictionary?.dicShared{
                if dicShared{
                    addButton.isHidden = false
                    likeAndChatStack.isHidden = false
                    likeButton.isHidden = true
                } else {
                    likeAndChatStack.isHidden = false
                    likeButton.isHidden = true
                    chatButton.isHidden = true
                }
            }
        }
        chatButton.layer.cornerRadius = 5
        addButton.layer.cornerRadius = 5
        likeButton.layer.cornerRadius = 5
    }
   
    func updateBubbleState(){
        for i in 0..<wordsArray.count{
            let rightAnswer = /*coreDataManager.*/wordsArray[i].wrdRightAnswers
            let wrongAnswer = /*coreDataManager.*/wordsArray[i].wrdWrongAnswers
            let bubbleState = rightAnswer - wrongAnswer
            if bubbleState > 0 {
                /*coreDataManager.*/wordsArray[i].wrdBobbleColor = "green"
            } else if bubbleState < 0 {
                /*coreDataManager.*/wordsArray[i].wrdBobbleColor = "red"
            } else if bubbleState == 0 {
                /*coreDataManager.*/wordsArray[i].wrdBobbleColor = "yellow"
            }
            coreDataManager.saveData(data: context)
        }
    }
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        if let dicLike = selectedDictionary?.dicLike{
            if dicLike{
                fireDB.setLikeForDictionaryFirebase(dicID: dicID, userID: mainModel.loadUserData().userID, like: false)
                buttonScaleAnimation(targetButton: likeButton)
                let handFillImage = UIImage(systemName: "hand.thumbsup.fill")
                likeButton.setImage(handFillImage, for: .normal)
                likeButton.tintColor = UIColor(named: "Main_header")
                selectedDictionary?.dicLike = false
                dictionaryData()
            } else {
                fireDB.setLikeForDictionaryFirebase(dicID: dicID, userID: mainModel.loadUserData().userID, like: true)
                buttonScaleAnimation(targetButton: likeButton)
                let handBorderedImage = UIImage(systemName: "hand.thumbsup")
                likeButton.setImage(handBorderedImage, for: .normal)
                likeButton.tintColor = .systemGray
                selectedDictionary?.dicLike = true
                dictionaryData()
            }
            coreDataManager.saveData(data: context)
        }
        
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
        if coreDataManager.wordsArray[indexPath.row].wrdImageIsSet == true {
            
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
        clickedWordID = /*coreDataManager.*/wordsArray[indexPath.row].wrdID!
        imagePath = /*coreDataManager.*/wordsArray[indexPath.row].imageName ?? ""
        wordTranslation = /*coreDataManager.*/wordsArray[indexPath.row].wrdTranslation!
        imageStatus = /*coreDataManager.*/wordsArray[indexPath.row].wrdImageIsSet
        popUpApear(sender: "wordPressed")
    }
    

}

