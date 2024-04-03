//
//  BrowseWordViewController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 05.09.23.
//

import UIKit
import CoreData

class BrowseWordsPairPopUp: UIViewController {
  
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainView: UIView!
   
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var dialogLabel: UILabel!
    @IBOutlet weak var wordImage: UIImageView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var testedLabel: UILabel!
    @IBOutlet weak var rightAnswersLabel: UILabel!
    @IBOutlet weak var wrongAnswersLabel: UILabel!
    @IBOutlet weak var addDateLabel: UILabel!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var learningLanguageImageInfo: UIImageView!
    @IBOutlet weak var learningLanguageLabelInfo: UILabel!
    @IBOutlet weak var testedNameLabel: UILabel!
    @IBOutlet weak var rightAnswersNameLabel: UILabel!
    @IBOutlet weak var wrongAnswersNameLabel: UILabel!
    @IBOutlet weak var addDateNameLabel: UILabel!
    
    @IBOutlet weak var translateLanguageImageInfo: UIImageView!
    @IBOutlet weak var translateLanguageLabelInfo: UILabel!
    
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var wordDeleteViewLabel: UILabel!
    @IBOutlet weak var translationDeleteViewLabel: UILabel!
    @IBOutlet weak var learningLanguageDeleteImage: UIImageView!
    @IBOutlet weak var learningLanguageDeleteLabel: UILabel!
    @IBOutlet weak var translateLanguageDeleteImage: UIImageView!
    @IBOutlet weak var translateLanguageDeleteLabel: UILabel!
    
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var wordTextFieldEditView: UITextField!
    @IBOutlet weak var translationTextFiedEditView: UITextField!
    @IBOutlet weak var imageEditView: UIImageView!
    @IBOutlet weak var changeImageButtonEditView: UIButton!
    @IBOutlet weak var clearImageButton: UIButton!
    @IBOutlet weak var wordLabelEdit: UILabel!
    @IBOutlet weak var translationEditLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cancelButoon: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var warningView: UIView!
    
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var warningImage: UIImageView!
    
    private func localizeElements(){
        dialogLabel.text = "browseWordPopUpVC_dialog_label_info".localized
        deleteButton.setTitle("browseWordPopUpVC_delete_button".localized, for: .normal)
        cancelButoon.setTitle("browseWordPopUpVC_cancel_button".localized, for: .normal)
        editButton.setTitle("browseWordPopUpVC_edit_button".localized, for: .normal)
        confirmButton.setTitle("browseWordPopUpVC_confirm_button".localized, for: .normal)
        saveButton.setTitle("browseWordPopUpVC_save_button".localized, for: .normal)
        testedNameLabel.text = "browseWordPopUpVC_testedName_label".localized
        rightAnswersNameLabel.text = "browseWordPopUpVC_rightAnswersName_label".localized
        wrongAnswersNameLabel.text = "browseWordPopUpVC_wrongAnswersName_label".localized
        addDateNameLabel.text = "browseWordPopUpVC_addDateName_label".localized
        wordLabelEdit.text = "browseWordPopUpVC_wordName_label".localized
        translationEditLabel.text = "browseWordPopUpVC_translationName_label".localized
        clearImageButton.setTitle("browseWordPopUpVC_imageClear_button".localized, for: .normal)
        changeImageButtonEditView.setTitle("browseWordPopUpVC_imageSet_button".localized, for: .normal)
    }
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var imageName = String()
    var relativeImagePath = String()
    var dictionaryID = String()
    private var learningImageText = String()
    private var learningLabelText = String()
    private var translateImageText = String()
    private var translateLabelText = String()
    var selectedImage = UIImage()
    private var imageIsSet = false
    private var imageCleared = false
    private var newImageName = String()
    private var tmpImageName = String()
    private var imageExtention = String()
    private var imageUrl: URL?
    var imageStatus = Bool()
    private var oneWordArray = Word()
    var wordID = String()
    var dicROstatus = Bool()
    var dicID = String()
    private var currentUserEmail = String()
    
    private var editedWord = String()
    private var editedTranslation = String()
    
    var tableReloadDelegate: UpdateView?
    private var coreDataManager = CoreDataManager()
    private let mainModel = MainModel()
    private let fireDB = Firebase()
    
    private var editScreenActive = false
    private var deleteScreenActive = false
    private var infoScreenActive = false
    private var currentFramePosY = CGFloat()
    private var bottomYPosition = CGFloat()
    
    
    init() {
        super.init(nibName: "BrowseWordsPairPopUp", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
       
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        localizeElements()
        coreDataManager.loadParentDictionaryData(dicID: dictionaryID, userID: mainModel.loadUserData().userID, data: context)
        coreDataManager.loadWordsForSelectedDictionary(dicID: coreDataManager.parentDictionaryData.first?.dicID ?? "", userID: mainModel.loadUserData().userID, context: context)
        popUpBackgroundSettings()
        standartState()
        elementsDesign()
        setDataForWord()
        infoWindowActive()
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
    
    func standartState(){
        currentUserEmail = mainModel.loadUserData().email
        dicID = (coreDataManager.parentDictionaryData.first?.dicID)!
        oneWordArray = coreDataManager.loadWordDataByID(wrdID: wordID, userID: mainModel.loadUserData().userID, data: context).first!
    }
    
    func flipViewAnimation(view:UIView,direction:String) {
        var flipDirection = UIView.AnimationOptions()
        switch direction{
        case "right":
            flipDirection = .transitionFlipFromRight
        case "left":
            flipDirection = .transitionFlipFromLeft
        case "top":
            flipDirection = .transitionFlipFromTop
        case "bottom":
            flipDirection = .transitionFlipFromBottom
        default: break
        }
            UIView.transition(with: view, duration: 0.6, options: flipDirection, animations: {
            }, completion: nil)
        }
    
    func elementsDesign(){
        mainView.clipsToBounds = true
        mainView.layer.cornerRadius = 10
        wordImage.layer.cornerRadius = 10
        warningView.layer.cornerRadius = 10
    }
    
    func infoWindowActive(){
        setDataForWord()
        headerLabel.text = "browseWordPopUpVC_header_label_info".localized
        warningView.isHidden = true
        infoView.isHidden = false
        editView.isHidden = true
        deleteView.isHidden = true
        saveButton.isHidden = true
        cancelButoon.isHidden = false
        if dicROstatus{
            editButton.isHidden = true
        } else {
            editButton.isHidden = false
        }
        deleteButton.isHidden = true
        confirmButton.isHidden = true
        learningLanguageImageInfo.layer.cornerRadius = 5
        translateLanguageImageInfo.layer.cornerRadius = 5
        infoScreenActive = true
        editScreenActive = false
        deleteScreenActive = false
    }
    
    func deleteWindowActive(){
        headerLabel.text = "browseWordPopUpVC_header_label_delete".localized
        learningLanguageDeleteImage.layer.cornerRadius = 5
        translateLanguageDeleteImage.layer.cornerRadius = 5
        let learningLanguage = coreDataManager.parentDictionaryData.first!.dicLearningLanguage!
        let translateLanguage = coreDataManager.parentDictionaryData.first!.dicTranslateLanguage!
        learningLanguageDeleteImage.image = UIImage(named: learningLanguage)
        learningLanguageDeleteLabel.text = learningLanguage
        translateLanguageDeleteImage.image = UIImage(named: translateLanguage)
        translateLanguageDeleteLabel.text = translateLanguage
        warningView.isHidden = true
        deleteView.isHidden = false
        editView.isHidden = true
        infoView.isHidden = true
        saveButton.isHidden = true
        editButton.isHidden = true
        cancelButoon.isHidden = false
        confirmButton.isHidden = false
        deleteButton.isHidden = true
        wordDeleteViewLabel.text = oneWordArray.wrdWord
        translationDeleteViewLabel.text = oneWordArray.wrdTranslation
        deleteScreenActive = true
        editScreenActive = false
        infoScreenActive = false
    }
    
    func editWindowActive(){
        headerLabel.text = "browseWordPopUpVC_header_label_edit".localized
        warningView.isHidden = true
        infoView.isHidden = true
        deleteView.isHidden = true
        editView.isHidden = false
        deleteButton.isHidden = false
        confirmButton.isHidden = true
        editButton.isHidden = true
        saveButton.isHidden = false
        cancelButoon.isHidden = false
        deleteView.layer.cornerRadius = 5
        clearImageButton.layer.cornerRadius = 5
        changeImageButtonEditView.layer.cornerRadius = 5
        imageEditView.layer.cornerRadius = 10
        imageEditView.image = setImageForWord()
        wordTextFieldEditView.text = oneWordArray.wrdWord
        translationTextFiedEditView.text = oneWordArray.wrdTranslation
        deleteButton.layer.cornerRadius = 5
        editedWord = String()
        editedTranslation = String()
        imageIsSet = false
        editScreenActive = true
        deleteScreenActive = false
        infoScreenActive = false
    }
    
    func setDataForWord(){
        coreDataManager.loadWordsForSelectedDictionary(dicID: coreDataManager.parentDictionaryData.first?.dicID ?? "", userID: mainModel.loadUserData().userID, context: context)
        wordLabel.text = oneWordArray.wrdWord
        translationLabel.text = oneWordArray.wrdTranslation
        testedLabel.text = String(oneWordArray.wrdWrongAnswers+oneWordArray.wrdRightAnswers)
        addDateLabel.text = oneWordArray.wrdAddDate
        let learningLanguage = coreDataManager.parentDictionaryData.first?.dicLearningLanguage
        let translateLanguage = coreDataManager.parentDictionaryData.first?.dicTranslateLanguage
        let dicID = coreDataManager.parentDictionaryData.first?.dicID ?? ""
        relativeImagePath = mainModel.relativeImagePath(dicID: dicID , imageName: oneWordArray.imageName ?? "")
        wordImage.image = setImageForWord()
        learningLanguageImageInfo.image = UIImage(named: learningLanguage!)
        learningLanguageLabelInfo.text = learningLanguage
        translateLanguageImageInfo.image = UIImage(named: translateLanguage!)
        translateLanguageLabelInfo.text = translateLanguage
        rightAnswersLabel.text = String(oneWordArray.wrdRightAnswers)
        wrongAnswersLabel.text = String(oneWordArray.wrdWrongAnswers)
    }
    
    func setImageForWord()->UIImage{
        print("Current image status is: \(imageStatus)\n")
        print("\(relativeImagePath)\n")
        if imageStatus{
            print("ReletivePath is: \(relativeImagePath)\n")
            return  UIImage(contentsOfFile: relativeImagePath) ?? UIImage(named: "stop")!
        } else {
            return UIImage(named: "noimage")!
        }
    }
    
    func popUpBackgroundSettings(){
        self.view.backgroundColor = .clear
        backgroundView.backgroundColor = .black.withAlphaComponent(0.6)
        backgroundView.alpha = 0
        mainView.alpha = 0
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

    func warningViewAppearAnimate(_ type:String, _ text:String){
        switch type{
        case "green":
            warningImage.image = UIImage(named: "done")
        case "red":
            warningImage.image = UIImage(named: "stop")
        case "yellow":
            warningImage.image = UIImage(named: "attention")
        default: break
        }
        warningLabel.text = text
        warningView.isHidden = false
        warningView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.warningView.alpha = 1
        } completion: { Bool in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.warningView.isHidden = true
            }
        }
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        flipViewAnimation(view: mainView, direction: "left")
        editWindowActive()
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        flipViewAnimation(view: mainView, direction: "top")
        deleteWindowActive()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        hideKeyboard()
        editedWord = wordTextFieldEditView.text ?? "empty word"
        editedTranslation = translationTextFiedEditView.text ?? "empty translation"
        if enteredChecking(){
            if checkForDoubles(){
                oneWordArray.wrdWord = editedWord
                oneWordArray.wrdTranslation = editedTranslation
                let wrdID = oneWordArray.wrdID!
                if mainModel.isInternetAvailable(){
                    fireDB.updateWordInFirebase(wrdID: wordID , newWord: editedWord, newTranslation: editedTranslation)
                    coreDataManager.setWasSynchronizedStatusForWord(data: context, wrdID: wrdID, sync: true)
                } else {
                    coreDataManager.setWasSynchronizedStatusForWord(data: context, wrdID: wrdID, sync: false)
                }
                coreDataManager.saveData(data: context)
                if imageIsSet{
                    saveImageToAppDirectory(image: selectedImage, isImageSelected: imageIsSet, temp:false)
                    let oldImageName = oneWordArray.imageName ?? ""
                    mainModel.deleteFileInFolder(folderName: "\(oneWordArray.wrdUserID ?? "")/\(oneWordArray.wrdDicID ?? "")/", fileName: oneWordArray.imageName ?? "")
                    oneWordArray.imageName = newImageName
                    oneWordArray.wrdImageIsSet = true
                    imageStatus = true
                    coreDataManager.saveData(data: context)
                    relativeImagePath = mainModel.relativeImagePath(dicID: oneWordArray.wrdDicID ?? "", imageName: newImageName)
                    wordImage.image = setImageForWord()
                    mainModel.deleteFileInFolder(folderName: "\(oneWordArray.wrdUserID ?? "")/\(oneWordArray.wrdDicID ?? "")/", fileName: "tempImage.\(imageExtention)")
                    coreDataManager.saveData(data: context)
                    if mainModel.isInternetAvailable(){
                        fireDB.uploadImageToFirestore(userID: oneWordArray.wrdUserID ?? "", dicID: oneWordArray.wrdDicID ?? "", imageName: newImageName, word: oneWordArray.wrdWord ?? "", context: context)
                        fireDB.deleteImageFromStorage(imageName: oldImageName, userID: oneWordArray.wrdUserID ?? "", dicID: oneWordArray.wrdDicID ?? "")
                        coreDataManager.setWasSynchronizedStatusForWord(data: context, wrdID: wrdID, sync: true)
                    } else {
                        coreDataManager.setWasSynchronizedStatusForWord(data: context, wrdID: wrdID, sync: false)
                    }
                } else if imageCleared{
                    imageCleared = false
                    coreDataManager.parentDictionaryData.first?.dicImagesCount -= 1
                    fireDB.updateImagesCountFirebase(dicID: oneWordArray.wrdID ?? "", increment: false)
                    mainModel.deleteFileInFolder(folderName: "\(oneWordArray.wrdUserID ?? "")/\(oneWordArray.wrdDicID ?? "")/", fileName: oneWordArray.imageName ?? "")
                    oneWordArray.wrdImageIsSet = false
                    
                    oneWordArray.wrdImageFirestorePath = String()
                    imageName = String()
                    imageStatus = false
                    
                    if mainModel.isInternetAvailable(){
                        fireDB.clearWordImageURLInFirebase(wrdID: wordID)
                        fireDB.deleteImageFromStorage(imageName: oneWordArray.imageName ?? "", userID: oneWordArray.wrdUserID ?? "", dicID: oneWordArray.wrdDicID ?? "")
                        fireDB.updateImagesCountFirebase(dicID: oneWordArray.wrdDicID ?? "", increment: false)
                    } else {
                        coreDataManager.setWasSynchronizedStatusForWord(data: context, wrdID: wrdID, sync: false)
                    }
                    oneWordArray.imageName = String()
                    coreDataManager.saveData(data: context)
                    wordImage.image = UIImage(named: "noimage")
                }
                tableReloadDelegate?.didUpdateView(sender: "")
                infoWindowActive()
                warningViewAppearAnimate("green", "browseWordPopUpVC_changesSaved_message".localized)
            }
        } else {
            warningViewAppearAnimate("red", "browseWordPopUpVC_noChanges_message".localized)
        }
    }
    
    func checkForDoubles()->Bool{
        var foundDoubles = 0
        let wordsArray = coreDataManager.wordsArray
        for i in 0..<wordsArray.count{
            if wordsArray[i].wrdWord == editedWord {
                if imageCleared || imageIsSet || oneWordArray.wrdTranslation != editedTranslation{
                    foundDoubles -= 1
                } else{
                    warningViewAppearAnimate("red", "browseWordPopUpVC_wordExist_message".localized)
                    foundDoubles += 1
                }
            }
        }
        if foundDoubles > 0 {
            return false
        } else {
            return true
        }
    }

    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        hideKeyboard()
        if editScreenActive{
            flipViewAnimation(view: mainView, direction: "right")
            infoWindowActive()
        }
       else if deleteScreenActive{
            flipViewAnimation(view: mainView, direction: "bottom")
            editWindowActive()
        }
       else if infoScreenActive{
            hide()
        }
    }
    
    @IBAction func changeImageButtonPressed(_ sender: UIButton) {
        imageIsSet = false
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func clearImageButtonPressed(_ sender: UIButton) {
        if oneWordArray.wrdImageIsSet{
            imageEditView.image = UIImage(named: "noimage")
            imageCleared = true
            warningViewAppearAnimate("green", "browseWordPopUpVC_imageCleared_message".localized)
        } else {
            warningViewAppearAnimate("yellow", "browseWordPopUpVC_noImagetoClear_message".localized)
            
        }
    }
    
    
    @IBAction func confirmDeletingPressed(_ sender: UIButton) {
        hideKeyboard()
        let wrdDicID = oneWordArray.wrdDicID!
        if oneWordArray.wrdImageIsSet == true {
            coreDataManager.setCountsInParentDictionary(increment: false, isSetImage: true, dicID: wrdDicID, context: context)
            coreDataManager.setImagesCountForDictionary(dicID: wrdDicID, increment: false, context: context)
        } else {
            coreDataManager.setCountsInParentDictionary(increment: false, isSetImage: false, dicID: wrdDicID, context: context)
        }
        if mainModel.isInternetAvailable(){
            if oneWordArray.imageName != nil{
                fireDB.deleteImageFromStorage(imageName: imageName, userID: mainModel.loadUserData().userID, dicID: oneWordArray.wrdDicID ?? "")
                fireDB.updateImagesCountFirebase(dicID: oneWordArray.wrdDicID ?? "", increment: false)
            }
            fireDB.deleteWordFromFirebase(wrdID: oneWordArray.wrdID ?? "")
            fireDB.updateWordsCountFirebase(dicID: oneWordArray.wrdDicID ?? "", increment: false)
           
            coreDataManager.deleteWordFromCoreData(wrdID: oneWordArray.wrdID ?? "", context: context)
            context.delete(oneWordArray)
        } else {
            let wrdID = oneWordArray.wrdID!
            let dicID = oneWordArray.wrdDicID!
            coreDataManager.setWasSynchronizedStatusForWord(data: context, wrdID: wrdID, sync: false)
            coreDataManager.setDeletedStatusForWord(data: context, wrdID: wrdID)
            coreDataManager.setSyncronizedStatusForDictionary(data: context, dicID: dicID, sync: false)
            coreDataManager.saveData(data: context)
        }
        tableReloadDelegate?.didUpdateView(sender: "")
        if oneWordArray.imageName != nil {
            mainModel.deleteFileInFolder(folderName: "\(oneWordArray.wrdUserID ?? "")/\(oneWordArray.wrdDicID ?? "")", fileName: oneWordArray.imageName ?? "")
        }
        warningViewAppearAnimate("green", "Words pair successfuly deleted")
        cancelButoon.isEnabled = false
        confirmButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.hide()
        }
    }
    
    func saveImageToAppDirectory(image: UIImage, isImageSelected: Bool, temp:Bool) {
        switch temp{
        case false:
            if isImageSelected{
                newImageName = "\(mainModel.uniqueIDgenerator(prefix: "img")).\(imageExtention)"
                imageUrl = mainModel.getDocumentsFolderPath().appendingPathComponent("\(oneWordArray.wrdUserID ?? "")/\(oneWordArray.wrdDicID ?? "")/\(newImageName)")
                if let imageData = image.jpegData(compressionQuality: 0.8) {
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
        case true:
            let tempImageName = "tempImage.\(imageExtention)"
            let tempImageUrl: URL? = mainModel.getDocumentsFolderPath().appendingPathComponent("\(oneWordArray.wrdUserID ?? "")/\(oneWordArray.wrdDicID ?? "")/\(tempImageName)")
            
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                do {
                    if let imageWithUrl = tempImageUrl{
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
        editedWord = wordTextFieldEditView.text!
        editedTranslation = translationTextFiedEditView.text!
        if editedTranslation.isEmpty && editedWord.isEmpty{
            return false
        } else if editedTranslation.isEmpty{
            return false
        } else if editedWord.isEmpty{
            return false
        } else {
            return true
        }
    }
    
}
extension BrowseWordsPairPopUp: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageFromGallery = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            selectedImage = imageFromGallery
            if let imageUrl = info[.imageURL] as? URL {
                imageExtention = imageUrl.pathExtension
            }
            saveImageToAppDirectory(image: selectedImage, isImageSelected: false, temp: true)
            let path = mainModel.relativeImagePath(dicID: oneWordArray.wrdDicID ?? "", imageName: "tempImage.\(imageExtention)")
            
            imageEditView.image = UIImage(contentsOfFile: path)
            imageIsSet = true
        } else {
            print("No IMAGE!")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

