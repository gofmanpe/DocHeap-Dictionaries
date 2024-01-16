//
//  EditDictionaryViewController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 08.10.23.
//

import UIKit
import Foundation

class EditDictionaryViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var dictionaryNameTextField: UITextField!
    
    @IBOutlet weak var sharedSwitch: UISwitch!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var mainWindowView: UIView!
    @IBOutlet weak var warningImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var changeDicLabel: UILabel!
    @IBOutlet weak var changeDescLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var shareDictionaryLabel: UILabel!
    
    func localizeElements(){
        headerLabel.text = "editDictionaryVC_header_label".localized
        changeDicLabel.text = "editDictionaryVC_changeName_label".localized
        changeDescLabel.text = "editDictionaryVC_changeDescription_label".localized
        cancelButton.setTitle("editDictionaryVC_cancel_button".localized, for: .normal)
        saveButton.setTitle("editDictionaryVC_save_button".localized, for: .normal)
        shareDictionaryLabel.text = "editDictionaryVC_shareDictionary_label".localized
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
    private var sharedStatus = false
    private var sharedStatusChanged = false
    
    init() {
        super.init(nibName: "EditDictionaryViewController", bundle: nil)
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
    }
    
    func standartState(){
            oldName = coreDataManager.parentDictionaryData.first?.dicName ?? ""
            oldDescription = coreDataManager.parentDictionaryData.first?.dicDescription ?? ""
        
            dictionaryNameTextField.text = oldName
            descriptionTextField.text = oldDescription
            if let switchStatus = coreDataManager.parentDictionaryData.first?.dicShared{
                sharedSwitch.isOn = switchStatus
                
            }
            warningView.isHidden = true
    }
    
    func elementsDesign(){
        warningView.layer.cornerRadius = 10
        mainWindowView.clipsToBounds = true
        mainWindowView.layer.cornerRadius = 10
    }
    
    func popUpBackgroundSettings(){
        self.view.backgroundColor = .clear
        backgroundView.backgroundColor = .black.withAlphaComponent(0.6)
        backgroundView.alpha = 0
        mainWindowView.alpha = 0
    }
    
    func appear(sender: DictionariesController) {
        sender.present(self, animated: false) {
            self.show()
        }
    }

    private func show() {
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.mainWindowView.alpha = 1
            self.backgroundView.alpha = 1
        }
    }

    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.backgroundView.alpha = 0
            self.mainWindowView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
            self.removeFromParent()
        }
    }
    
   
    @IBAction func sharedSwitchToggled(_ sender: UISwitch) {
        if sharedSwitch.isOn{
            sharedStatus = true
        }
        sharedStatusChanged = true
    }
    
    func checkEnteredData()->Bool{
        
        if let isSetNewName = dictionaryNameTextField.text, let isDescriptionSet = descriptionTextField.text {
            newName = isSetNewName
            newDescription = isDescriptionSet
        }
        
        var nameNotChanged = false
        var descriptionNotChanged = false
        var nameIsEmpty = false
       // var sharedStatNotChanged = false
        let wordsCount = Int(coreDataManager.parentDictionaryData.first?.dicWordsCount ?? 0)
        
        if oldName == newName {
            nameNotChanged = true
        }
        if newName.isEmpty {
            nameIsEmpty = true
        }
        if oldDescription == newDescription{
            descriptionNotChanged = true
        }
        if nameNotChanged, descriptionNotChanged{
            if sharedStatusChanged{
                if wordsCount == 0 {
                    warningViewAppearAnimate(type: "red", text: defaults.noWordsInDictionary)
                    return false
                } else {
                    return true
                }
                
            } else {
                warningViewAppearAnimate(type: "red", text: defaults.warningMessage)
                return false
            }
        } else if nameIsEmpty{
            warningViewAppearAnimate(type: "red", text: defaults.noDicionaryNameMessage)
            return false
        } else {
            return true
        }
    }
    
    func saveChangedData(){
        coreDataManager.parentDictionaryData.first?.dicName = newName
        coreDataManager.parentDictionaryData.first?.dicDescription = newDescription
        coreDataManager.parentDictionaryData.first?.dicShared = sharedStatus
        let dicID = coreDataManager.parentDictionaryData.first?.dicID ?? ""
        coreDataManager.saveData(data: context)
        tableReloadDelegate?.didUpdateView(sender: "")
        warningViewAppearAnimate(type: "green", text: defaults.editDoneMessage)
        saveButton.isEnabled = false
        cancelButton.isEnabled = false
        if mainModel.isInternetAvailable(){
            fireDB.updateDictionaryInFirebase(dicID: dicID, dicName: newName, dicDescription: newDescription, dicShared: sharedStatus)
            coreDataManager.parentDictionaryData.first?.dicSyncronized = true
        } else {
                coreDataManager.parentDictionaryData.first?.dicSyncronized = false
            }
        coreDataManager.saveData(data: context)
        UIView.animate(withDuration: 0.2) {
            self.mainWindowView.alpha = 0
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
   
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        hide()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if checkEnteredData(){
            saveChangedData()
        }
        
        
    }
}
