//
//  AddWordPopUpViewController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 31.03.23.
//

import UIKit
import CoreData
import Alamofire

class AddWordsPairPopUp: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var translationTextField: UITextField!
    @IBOutlet weak var wordTextField: UITextField!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var secretButton: UIButton!
    // @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var setImageButton: UIButton!
    @IBOutlet weak var learningLngImage: UIImageView!
    @IBOutlet weak var translationLngImage: UIImageView!
    @IBOutlet weak var selectedImageStatus: UILabel!
   // @IBOutlet weak var parseWordButton: UIButton!
   // @IBOutlet weak var parseTranslationButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var imageSelectedLabel: UILabel!
    
    func localizeElements(){
        headerLabel.text = "addWordPopUp_header_label".localized
        wordLabel.text = "addWordPopUp_word_label".localized
        wordTextField.placeholder = "addWordPopUp_wordTextField_placeholder".localized
        translationLabel.text = "addWordPopUp_translation_label".localized
        translationTextField.placeholder = "addWordPopUp_translationTextField_placeholder".localized
        setImageButton.setTitle("addWordPopUp_setImage_button".localized, for: .normal)
        imageSelectedLabel.text = "addWordPopUp_imageIsSelected_label".localized
        cancelButton.setTitle("addWordPopUp_cancel_button".localized, for: .normal)
        saveButton.setTitle("addWordPopUp_save_button".localized, for: .normal)
        selectedImageStatus.text = "addWordPopUp_selectedNo_label".localized
    }
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var enteredWord = String()
    var enteredTranslation = String()
    var tableReloadDelegate: UpdateView?
    var uploadImageDelegate: UploadImageToFirestore?
    var selectedImage = UIImage()
    var imageUrl: URL?
    var imageName = String()
    var imageIsSet = false
    var dictionaryID = String()
    var parsedRequest = String()
    var imageExtention = String()
    var coreData = CoreDataManager()
    private let defaults = Defaults()
    private let mainModel = MainModel()
    var learningLaguage = String()
    var translationLanguage = String()
    private let userDefaults = UserDefaults.standard
    private var currentUser = String()
    private let firebase = Firebase()
    private var currentFramePosY = CGFloat()
    private var bottomYPosition = CGFloat()
    
    init() {
        super.init(nibName: "AddWordsPairPopUp", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        localizeElements()
        loadUserDefaults()
        coreData.loadParentDictionaryData(dicID: dictionaryID, userID: mainModel.loadUserData().userID, data: context)
        coreData.loadWordsForSelectedDictionary(dicID: coreData.parentDictionaryData.first?.dicID ?? "", userID: mainModel.loadUserData().userID, context: context)
        standartState()
        elementsDesign()
        popUpBackgroundSettings()
        keyboardBehavorSettings()
    }
    
    private func keyboardBehavorSettings(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        currentFramePosY = mainView.frame.origin.y
        bottomYPosition = UIScreen.main.bounds.height - mainView.frame.origin.y - mainView.frame.size.height
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            mainView.frame.origin.y = currentFramePosY + (bottomYPosition - keyboardHeight) - 5.0
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        mainView.frame.origin.y = currentFramePosY
    }
    
    func loadUserDefaults(){
        if let user = userDefaults.object(forKey: "userEmail") as? String{
            currentUser = user
        }
    }
    
    func standartState(){
        warningView.isHidden = true
        learningLaguage = coreData.parentDictionaryData.first!.dicLearningLanguage!
        translationLanguage = coreData.parentDictionaryData.first!.dicTranslateLanguage!
        let learnImage = learningLaguage
        learningLngImage.image = UIImage(named: "\(learnImage).png")
        let translateImage:String = translationLanguage
        translationLngImage.image = UIImage(named: "\(translateImage).png")
        translationTextField.delegate = self
        wordTextField.delegate = self
    }
    
    func elementsDesign(){
        mainView.clipsToBounds = true
        mainView.layer.cornerRadius = 10
        headerLabel.clipsToBounds = true
        headerLabel.layer.cornerRadius = 10
        headerLabel.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        warningView.layer.cornerRadius = 10
        warningView.clipsToBounds = true
        warningView.backgroundColor = .systemGray6
        warningView.layer.borderWidth = 3
        warningView.layer.borderColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.00).cgColor
        cancelButton.layer.cornerRadius = 10
        cancelButton.layer.maskedCorners = [.layerMinXMaxYCorner]
        saveButton.layer.cornerRadius = 10
        saveButton.layer.maskedCorners = [.layerMaxXMaxYCorner]
        learningLngImage.layer.cornerRadius = 5
        translationLngImage.layer.cornerRadius = 5
        setImageButton.layer.cornerRadius = 10
    }
    
    func popUpBackgroundSettings(){
        self.view.backgroundColor = .clear
        backgroundView.backgroundColor = .black.withAlphaComponent(0.6)
        backgroundView.alpha = 0
        mainView.alpha = 0
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        hideKeyboard()
        enteredWord = wordTextField.text!
        if enteredChecking() && checkForDoubles(){
            saveImageToAppDirectory(image: selectedImage, isImageSelected: imageIsSet)
            let wrdID = mainModel.uniqueIDgenerator(prefix: "wrd")
            let wordsPair = WordsPair(
                wrdWord: enteredWord,
                wrdTranslation: enteredTranslation,
                wrdDicID: dictionaryID,
                wrdUserID: self.mainModel.loadUserData().userID,
                wrdID: wrdID,
                wrdImageFirestorePath: "",
                wrdImageName: imageName,
                wrdReadOnly: false,
                wrdParentDictionary: coreData.getParentDictionaryData(dicID: dictionaryID, userID: mainModel.loadUserData().userID, context: context),
                wrdAddDate: self.mainModel.convertDateToString(currentDate: Date(), time: false)!)
            coreData.createLocalWordsPair(wordsPair: wordsPair, context: self.context, sync: true)
            coreData.setWordsCountForDictionary(dicID: dictionaryID, increment: true, context: context)
            if mainModel.isInternetAvailable(){
                firebase.createWordsPair(wordsPair: wordsPair)
                firebase.updateWordsCountFirebase(dicID: dictionaryID, increment: true)
            } else {
                self.coreData.setWasSynchronizedStatusForWord(data: self.context, wrdID: wrdID, sync: false)
            }
            uploadImageDelegate?.uploadImage(imageName: imageName, wrdID: wrdID)
            tableReloadDelegate?.didUpdateView(sender:"")
            hide()
        }
    }
    
    @IBAction func setPicturePressed(_ sender: Any) {
        if enteredChecking(){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           let maxLength = 25
           let currentLength = textField.text?.count ?? 0
           let newLength = currentLength + string.count - range.length
           return newLength <= maxLength
       }
   
    func saveImageToAppDirectory(image: UIImage, isImageSelected: Bool) {
        if isImageSelected{
            imageName = "\(mainModel.uniqueIDgenerator(prefix: "img")).\(imageExtention)"
            imageUrl = mainModel.getDocumentsFolderPath().appendingPathComponent("\(mainModel.loadUserData().userID)/\(dictionaryID)/\(imageName)")
            if selectedImageStatus.text == "addWordPopUp_selectedYes_label".localized{
                imageIsSet = true }
            if let imageData = image.jpegData(compressionQuality: 0.6) {
                do {
                    if let imageWithUrl = imageUrl{
                        try imageData.write(to: imageWithUrl)
                    } else {
                    }
                } catch {
                    print("Error saving image: \(error)")
                }
            }
        }
    }
    
    func enteredChecking()->Bool{
        enteredWord = wordTextField.text!
        enteredTranslation = translationTextField.text!
        if enteredTranslation.isEmpty && enteredWord.isEmpty{
            showWarning(text: defaults.enterBoothWords)
            return false
        } else if enteredTranslation.isEmpty{
            showWarning(text: defaults.enterTranslation)
            return false
        } else if enteredWord.isEmpty{
            showWarning(text: defaults.enterWord)
            return false
        } else {
            return true
        }
    }
    
    func checkForDoubles()->Bool{
        var foundDoubles = 0
        var isCheked = false
        let wordsArray = coreData.wordsArray
        let onlyWordsArray = wordsArray.map({$0.wrdWord})
        for i in 0..<onlyWordsArray.count{
            if onlyWordsArray[i] == enteredWord {
                showWarning(text: defaults.foundDoubles)
                foundDoubles += 1
            }
       }
        if foundDoubles > 0 {
            isCheked = false
        } else {
            isCheked = true}
        return isCheked
    }
    
    func showWarning(text:String){
        warningLabel.text = text
        warningViewAppearAnimate()
    }
    
    func warningViewAppearAnimate(){
        warningView.isHidden = false
        warningView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.warningView.alpha = 1
        } completion: { Bool in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.warningView.isHidden = true
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        if imageIsSet{
            mainModel.deleteFileInFolder(folderName: "\(dictionaryID)/Images/", fileName: imageName)}
        hideKeyboard()
        hide()
    }
    
    func appear(sender: BrowseDictionaryController) {
        sender.present(self, animated: false) {
            self.show()
        }
    }

    private func show() {
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.mainView.alpha = 1
            self.backgroundView.alpha = 1
        }
    }

    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.backgroundView.alpha = 0
            self.mainView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
            self.removeFromParent()
        }
    }
    
    @IBAction func secretButtonPresed(_ sender: UIButton) {
        struct SecretWordsPair {
            let word: String
            let translation: String
        }

        let englishWords: [String] = [
            "However",
            "Therefore",
            "Furthermore",
            "Nevertheless",
            "Moreover",
            "Consequently",
            "Significant",
            "Considerable",
            "Particularly",
            "Substantial",
            "According",
            "Regarding",
            "Occasionally",
            "Frequently",
            "Generally",
            "Usually",
            "Typically",
            "Possibly",
            "Obviously",
            "Apparently",
            "Undoubtedly",
            "Likewise",
            "Alternatively",
            "Approximately",
            "Previously",
            "Eventually",
            "Specifically",
            "Considerably",
            "Practically",
            "Currently",
            "Impressively",
            "Subsequently",
            "Initially",
            "Comparatively",
            "Remarkably",
            "Accordingly",
            "Importantly"
        ]

        let germanTranslations: [String] = [
            "Jedoch",
            "Daher",
            "Darüber hinaus",
            "Dennoch",
            "Außerdem",
            "Folglich",
            "Bedeutend",
            "Beträchtlich",
            "Insbesondere",
            "Substanziell",
            "Gemäß",
            "Hinsichtlich",
            "Gelegentlich",
            "Häufig",
            "Im Allgemeinen",
            "Gewöhnlich",
            "Typischerweise",
            "Möglicherweise",
            "Offensichtlich",
            "Anscheinend",
            "Zweifellos",
            "Ebenso",
            "Alternativ",
            "Ungefähr",
            "Vorher",
            "Schließlich",
            "Speziell",
            "Erheblich",
            "Praktisch",
            "Derzeit",
            "Beeindruckend",
            "In der Folge",
            "Anfänglich",
            "Vergleichsweise",
            "Bemerkenswert",
            "Dementsprechend",
            "Wichtig"
        ]

        var wordPairs = [SecretWordsPair]()
        for (index, englishWord) in englishWords.enumerated() {
            let translation = germanTranslations[index]
            let pair = SecretWordsPair(word: englishWord, translation: translation)
            wordPairs.append(pair)
        }

     
        
        for pair in wordPairs{
            let wrdID = mainModel.uniqueIDgenerator(prefix: "wrd")
            let wordsPair = WordsPair(
                wrdWord: pair.word,
                wrdTranslation: pair.translation,
                wrdDicID: dictionaryID,
                wrdUserID: mainModel.loadUserData().userID,
                wrdID: wrdID,
                wrdImageFirestorePath: "",
                wrdImageName: imageName,
                wrdReadOnly: false,
                wrdParentDictionary: coreData.getParentDictionaryData(dicID: dictionaryID, userID: mainModel.loadUserData().userID, context: context),
                wrdAddDate: mainModel.convertDateToString(currentDate: Date(), time: false)!)
            firebase.createWordsPair(wordsPair: wordsPair)
            firebase.updateWordsCountFirebase(dicID: dictionaryID, increment: true)
            
        }
        print("Secret words array count is: \(wordPairs.count)\n")
        // Печать пар слов
//        for pair in wordPairs {
//            print("\(pair.word) - \(pair.translation)")
//        }

        
        
    }
    
    
}

extension AddWordsPairPopUp: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageFromGallery = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            selectedImage = imageFromGallery
            imageIsSet = true
            selectedImageStatus.textColor = UIColor(named: "Right answer")
            selectedImageStatus.text = "addWordPopUp_selectedYes_label".localized
            if let imageUrl = info[.imageURL] as? URL {
                imageExtention = imageUrl.pathExtension
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

