//
//  EditDictionaryViewController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 08.10.23.
//

import UIKit
import Foundation

class EditDictionaryPopUp: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var dictionaryNameTextField: UITextField!
    @IBOutlet weak var sharedSwitch: UISwitch!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var warningImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var changeDicLabel: UILabel!
    @IBOutlet weak var changeDescLabel: UILabel!
    @IBOutlet weak var shareDictionaryLabel: UILabel!
    @IBOutlet weak var allowCommentsLabel: UILabel!
    @IBOutlet weak var commentsSwitch: UISwitch!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var allowCommentsStackView: UIStackView!
    
    private func localizeElements(){
        headerLabel.text = "editDictionaryVC_header_label".localized
        changeDicLabel.text = "editDictionaryVC_changeName_label".localized
        changeDescLabel.text = "editDictionaryVC_changeDescription_label".localized
        cancelButton.setTitle("editDictionaryVC_cancel_button".localized, for: .normal)
        saveButton.setTitle("editDictionaryVC_save_button".localized, for: .normal)
        shareDictionaryLabel.text = "editDictionaryVC_shareDictionary_label".localized
        allowCommentsLabel.text = "editDictionaryVC_allowComments_label".localized
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var tableReloadDelegate: UpdateView?
    var oldName = String()
    var newName = String()
    var oldDescription = String()
    var newDescription = String()
    var dicID = String()
    var coreDataManager = CoreDataManager()
    var dictionariesArray = [Dictionary]()
    private let defaults = Defaults()
    private let mainModel = MainModel()
    private let fireDB = Firebase()
    private var systemSharedStatus = Bool()
    private var newSharedStatus = Bool()
    private var sharedStatus = false
    private var sharedStatusChanged = false
    private var newAllowedCommentsStatus = Bool()
    private var allowedCommentsStatus = Bool()
    private var currentFramePosY = CGFloat()
    private var bottomYPosition = CGFloat()
    
    init() {
        super.init(nibName: "EditDictionaryPopUp", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeElements()
        coreDataManager.loadParentDictionaryData(dicID: dicID, userID: mainModel.loadUserData().userID, data: context)
        standartState()
        popUpBackgroundSettings()
        elementsDesign()
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
    
    deinit {
            NotificationCenter.default.removeObserver(self)
        }
    
    private func standartState(){
        //allowCommentsStackView.isHidden = true
        oldName = coreDataManager.parentDictionaryData.first?.dicName ?? ""
        oldDescription = coreDataManager.parentDictionaryData.first?.dicDescription ?? ""
        dictionaryNameTextField.text = oldName
        descriptionTextView.text = oldDescription
        systemSharedStatus = coreDataManager.parentDictionaryData.first!.dicShared
        newSharedStatus = systemSharedStatus
        allowedCommentsStatus = coreDataManager.parentDictionaryData.first!.dicCommentsOn
        newAllowedCommentsStatus = allowedCommentsStatus
        sharedSwitch.isOn = systemSharedStatus
        //allowCommentsStackView.isHidden = !systemSharedStatus
        if systemSharedStatus{
            commentsSwitch.isEnabled = true
        } else {
            commentsSwitch.isEnabled = false
        }
        commentsSwitch.isOn = allowedCommentsStatus
        warningView.isHidden = true
        
    }
    
    private func elementsDesign(){
        warningView.layer.cornerRadius = 10
        mainView.clipsToBounds = true
        mainView.layer.cornerRadius = 10
        descriptionTextView.layer.cornerRadius = 5
    }
    
    private func popUpBackgroundSettings(){
        self.view.backgroundColor = .clear
        backgroundView.backgroundColor = .black.withAlphaComponent(0.6)
        backgroundView.alpha = 0
        mainView.alpha = 0
    }
    
    func appear(sender: DictionariesController) {
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

    private func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.backgroundView.alpha = 0
            self.mainView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
            self.removeFromParent()
        }
    }
    
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           let maxLength = 40
           let currentLength = textField.text?.count ?? 0
           let newLength = currentLength + string.count - range.length
           return newLength <= maxLength
       }
    
    private  func checkForChanges()->Bool{
        var checkOK : Bool
        let wordsCount = Int(coreDataManager.parentDictionaryData.first?.dicWordsCount ?? 0)
        if let isSetNewName = dictionaryNameTextField.text, let isDescriptionSet = descriptionTextView.text {
            newName = isSetNewName
            newDescription = isDescriptionSet
        }
        switch (oldName == newName, oldDescription == newDescription, systemSharedStatus == newSharedStatus){
        case (true,true,true):
            if allowedCommentsStatus == newAllowedCommentsStatus{
                warningViewAppearAnimate(type: "red", text: "editDictionaryVC_nothingToChange_message".localized)
                checkOK = false
            } else {
                checkOK = true
            }
        case (false,true,true),(false,false,true),(false, true, false),(false,false,false):
            switch (newName.isEmpty,wordsCount<7){
            case (true,true),(true,false): //Here show message about name emptyness
                warningViewAppearAnimate(type: "red", text: "editDictionaryVC_dictionaryNameIsEmpty_message".localized)
                commentsSwitch.isOn = false
                checkOK = false
            case (false,true): //Here show message about is not enough words
                if oldName != newName && !sharedSwitch.isOn{
                    checkOK = true
                } else {
                    warningViewAppearAnimate(type: "red", text: "editDictionaryVC_notEnoughWords_message".localized)
                    print("Stage 1")
                    checkOK = false
                    sharedSwitch.isOn = systemSharedStatus
                    newSharedStatus = systemSharedStatus
                    commentsSwitch.isOn = false
                    commentsSwitch.isEnabled = false
                }
                
            case (false,false):
                checkOK = true
            }
        case (true,false,true):
            checkOK = true
        case (true,true,false),(true, false, false):
            if wordsCount<7{ //Here show message about is not enough words
                warningViewAppearAnimate(type: "red", text: "editDictionaryVC_notEnoughWords_message".localized)
                checkOK = false
                sharedSwitch.isOn = systemSharedStatus
                newSharedStatus = systemSharedStatus
//                UIStackView.animate(withDuration: 0.3) {
//                    self.allowCommentsStackView.isHidden = true
//                    self.view.layoutIfNeeded()
//                }
                commentsSwitch.isOn = false
                commentsSwitch.isEnabled = false
                // sharedStatusChanged = false
            } else {
                checkOK = true
            }
        }
        return checkOK
    }
    
//    private func commentsAllowedStatus()->Bool{
//        var commentsAllowed: Bool
//        switch (sharedSwitch.isOn,commentsSwitch.isOn){
//        case (true,true):
//            commentsAllowed = true
//        case (true,false),(false,true),(false,false):
//            commentsAllowed = false
//        }
//        return commentsAllowed
//    }
    
//    private func saveCommentsAllowedOnly(commentsAllowed:Bool){
//        if commentsAllowed{
//            coreDataManager.parentDictionaryData.first?.dicCommentsOn = true
//        } else {
//            coreDataManager.parentDictionaryData.first?.dicCommentsOn = false
//        }
//        coreDataManager.saveData(data: context)
//        tableReloadDelegate?.didUpdateView(sender: "")
//        warningViewAppearAnimate(type: "green", text: defaults.editDoneMessage)
//        saveButton.isEnabled = false
//        cancelButton.isEnabled = false
//        if mainModel.isInternetAvailable(){
//            fireDB.updateDictionaryInFirebase(dicID: dicID, dicName: newName, dicDescription: newDescription, dicShared: sharedStatus)
//            coreDataManager.parentDictionaryData.first?.dicSyncronized = true
//        } else {
//            coreDataManager.parentDictionaryData.first?.dicSyncronized = false
//        }
//        coreDataManager.saveData(data: context)
//        UIView.animate(withDuration: 0.2) {
//            self.mainWindowView.alpha = 0
//        } completion: { Bool in }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            self.hide()
//        }
//    }
    
    private func saveChangedData(sharedStatus:Bool, commentsAllowed:Bool){
        hideKeyboard()
        coreDataManager.parentDictionaryData.first?.dicName = newName
        coreDataManager.parentDictionaryData.first?.dicDescription = newDescription
        switch (sharedStatus,commentsAllowed){
        case (true,true):
            coreDataManager.parentDictionaryData.first?.dicShared = true
            coreDataManager.parentDictionaryData.first?.dicCommentsOn = true
        case (false,true):
            coreDataManager.parentDictionaryData.first?.dicShared = false
            coreDataManager.parentDictionaryData.first?.dicCommentsOn = false
        case (false,false):
            coreDataManager.parentDictionaryData.first?.dicShared = false
            coreDataManager.parentDictionaryData.first?.dicCommentsOn = false
        case (true,false):
            coreDataManager.parentDictionaryData.first?.dicShared = true
            coreDataManager.parentDictionaryData.first?.dicCommentsOn = false
        }
        // TODO: Check internet connection and realise sync if internet is absent
        let dicID = coreDataManager.parentDictionaryData.first?.dicID ?? ""
        coreDataManager.saveData(data: context)
        tableReloadDelegate?.didUpdateView(sender: "")
        warningViewAppearAnimate(type: "green", text: defaults.editDoneMessage)
        saveButton.isEnabled = false
        cancelButton.isEnabled = false
        if mainModel.isInternetAvailable(){
            
            fireDB.updateDictionaryInFirebase(dicID: dicID, dicName: newName, dicDescription: newDescription, dicShared: sharedStatus, dicComments: commentsAllowed)
            coreDataManager.parentDictionaryData.first?.dicSyncronized = true
        } else {
            coreDataManager.parentDictionaryData.first?.dicSyncronized = false
        }
        coreDataManager.saveData(data: context)
        UIView.animate(withDuration: 0.2) {
            self.mainView.alpha = 0
        } completion: { Bool in }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.hide()
        }
    }
    
    func warningViewAppearAnimate(type:String, text:String){
        warningView.isHidden = false
        warningView.alpha = 0
        switch type{
        case "red":
            warningImage.image = UIImage(named: "stop")
            warningLabel.text = text
        case "green":
            warningImage.image = UIImage(named: "done")
            warningLabel.text = text
        default: break
        }
        UIView.animate(withDuration: 0.5) {
            
            self.warningView.alpha = 1
        } completion: { Bool in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.warningView.isHidden = true
            }
        }
    }
   
    @IBAction func sharedSwitchToggled(_ sender: UISwitch) {
        newSharedStatus = sharedSwitch.isOn
        if sharedSwitch.isOn{
            commentsSwitch.isEnabled = true
        } else {
            commentsSwitch.isEnabled = false
        }
    }
    
    @IBAction func allowCommentsSwitchToggled(_ sender: Any) {
        newAllowedCommentsStatus = commentsSwitch.isOn
    }
  
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        hideKeyboard()
        hide()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        hideKeyboard()
        if checkForChanges(){
            switch (sharedSwitch.isOn, commentsSwitch.isOn){
            case (true,true):
                saveChangedData(sharedStatus: true, commentsAllowed: true)
            case (true,false):
                saveChangedData(sharedStatus: true, commentsAllowed: false)
            case (false,false):
                saveChangedData(sharedStatus: false, commentsAllowed: false)
            case (false,true):
                saveChangedData(sharedStatus: false, commentsAllowed: false)
            }
        }
    }
}
