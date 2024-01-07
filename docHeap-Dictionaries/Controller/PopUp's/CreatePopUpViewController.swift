//
//  CreatePopUpViewController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 27.03.23.
//

import UIKit
import CoreData


class CreatePopUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var learningButton: UIButton!
    @IBOutlet weak var translateButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var dictionaryNameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var enterNameLabel: UILabel!
    @IBOutlet weak var chooseLangLabel: UILabel!
    
    func localizeElements(){
        descriptionLabel.text = "createDictionaryPopUpVC_description_label".localized
        descriptionTextField.placeholder = "createDictionaryPopUpVC_description_placeholder".localized
        headerLabel.text = "createDictionaryPopUpVC_header_label".localized
        enterNameLabel.text = "createDictionaryPopUpVC_enterName_label".localized
        dictionaryNameTextField.placeholder = "createDictionaryPopUpVC_dictionaryName_placeholder".localized
        chooseLangLabel.text = "createDictionaryPopUpVC_chooseLanguages_label".localized
        learningButton.setTitle("createDictionaryPopUpVC_langSelect_Button".localized, for: .normal)
        translateButton.setTitle("createDictionaryPopUpVC_langSelect_Button".localized, for: .normal)
        cancelButton.setTitle("createDictionaryPopUpVC_cancel_button".localized, for: .normal)
        createButton.setTitle("createDictionaryPopUpVC_create_button".localized, for: .normal)
    }
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var tableReloadDelegate: UpdateView?
    private var selectedLearning = String()
    private var selectedTranslate = String()
    private var pressedButton = Int()
    private var errorText = String()
    private var userID = String()
    private var dictionariesArray = [Dictionary]()
    private let defaults = Defaults()
    private let coreDataManager = CoreDataManager()
    private let mainModel = MainModel()
    private let fireDB = Firebase()
    
    init() {
        super.init(nibName: "CreatePopUpViewController", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeElements()
        dictionaryNameTextField.delegate = self
        elementsDesign()
        standartState()
    }
    
    func appear(sender: DictionariesController) {
        sender.present(self, animated: false) {
            self.show()
        }
    }
    
    private func show() {
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.mainView.alpha = 1
            self.background.alpha = 1
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.background.alpha = 0
            self.mainView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
            self.removeFromParent()
        }
    }
    
    func elementsDesign(){
        mainView.clipsToBounds = true
        mainView.layer.cornerRadius = 10
        headerView.clipsToBounds = true
        headerView.layer.cornerRadius = 10
        headerView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        view.backgroundColor = .clear
        background.backgroundColor = .black.withAlphaComponent(0.6)
        background.alpha = 0
        mainView.alpha = 0
        cancelButton.layer.cornerRadius = 10
        cancelButton.layer.maskedCorners = [.layerMinXMaxYCorner]
        createButton.layer.cornerRadius = 10
        createButton.layer.maskedCorners = [.layerMaxXMaxYCorner]
        translateButton.layer.borderWidth = 1
        translateButton.layer.borderColor = UIColor(red: 0.00, green: 0.68, blue: 1.00, alpha: 1.00).cgColor
        translateButton.layer.cornerRadius = 5
        learningButton.layer.borderWidth = 1
        learningButton.layer.borderColor = UIColor(red: 0.00, green: 0.68, blue: 1.00, alpha: 1.00).cgColor
        learningButton.layer.cornerRadius = 5
        pickerView.layer.cornerRadius = 10
        warningView.layer.cornerRadius = 10
        warningView.clipsToBounds = true
        warningView.backgroundColor = .systemGray6
        warningView.layer.borderWidth = 3
        warningView.layer.borderColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.00).cgColor
        dictionaryNameTextField.layer.cornerRadius = 3
        dictionaryNameTextField.clipsToBounds = true
    }
    
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           let maxLength = 30
           let currentLength = textField.text?.count ?? 0
           let newLength = currentLength + string.count - range.length
           return newLength <= maxLength
       }
    
    func standartState(){
        warningView.isHidden = true
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.isHidden = true
        translateButton.backgroundColor = UIColor(red: 0.00, green: 0.68, blue: 1.00, alpha: 1.00)
        translateButton.setTitleColor(.white, for: .normal)
        learningButton.backgroundColor = UIColor(red: 0.00, green: 0.68, blue: 1.00, alpha: 1.00)
        learningButton.setTitleColor(.white, for: .normal)
    }
    
    func activeButton(button:Int){
        switch button {
        case 1:
            learningButton.backgroundColor = .white
            learningButton.setTitleColor(.tintColor, for: .normal)
            translateButton.backgroundColor = UIColor(red: 0.00, green: 0.68, blue: 1.00, alpha: 1.00)
            translateButton.setTitleColor(.white, for: .normal)
        case 2:
            translateButton.backgroundColor = .white
            translateButton.setTitleColor(.tintColor, for: .normal)
            learningButton.backgroundColor = UIColor(red: 0.00, green: 0.68, blue: 1.00, alpha: 1.00)
            learningButton.setTitleColor(.white, for: .normal)
        default:
            return
        }
    }

    
    func checkRulesForSelectedLanguages(learningLanguage:String,translateLanguage:String,dicName:String) -> Bool{
        switch (learningLanguage.isEmpty, translateLanguage.isEmpty, dicName.isEmpty) {
        case (true, true, true): // Nothing selected
            warningViewAppearAnimate("createDictionaryPopUpVC_dictionary_warning".localized)
            return false
        case (true, false, true), (false, true, true), (true, false, false), (false, true, false) : //One empty
            warningViewAppearAnimate("createDictionaryPopUpVC_dictionaryNameOrOneLang_warning".localized)
            return false
        case (false, false, true) where learningLanguage == translateLanguage: // Same languages
            warningViewAppearAnimate("createDictionaryPopUpVC_sameLanguages_warning".localized)
            return false
        case (false, false, false): // All selected
            if learningLanguage == translateLanguage{
                warningViewAppearAnimate("createDictionaryPopUpVC_sameLanguages_warning".localized)
                return false
            } else {
                return true
            }
        case (false, false, true): // Name dont entered
            warningViewAppearAnimate("createDictionaryPopUpVC_dictionary_warning".localized)
            return false
        case (true, true, false): // langueges not selected
            warningViewAppearAnimate("createDictionaryPopUpVC_noLanguages_warning".localized)
            return false
        }
    }
    
    func warningViewAppearAnimate(_ text:String){
        warningLabel.text = text
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
    
    @IBAction func cancelPressed(_ sender: Any) {
        hide()
    }
    
    @IBAction func learningButtonPressed(_ sender: UIButton) {
        pressedButton = 1
        warningView.isHidden = true
        if pickerView.isHidden{
            pickerView.isHidden = false
            activeButton(button: 1)
        } else {
            standartState()
        }
    }
    
    @IBAction func translateButtonPressed(_ sender: UIButton) {
        pressedButton = 2
        warningView.isHidden = true
        if pickerView.isHidden{
            pickerView.isHidden = false
            activeButton(button: 2)
        } else {
            standartState()
        }
    }
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
        if checkRulesForSelectedLanguages(learningLanguage: selectedLearning, translateLanguage: selectedTranslate, dicName: dictionaryNameTextField.text ?? ""){
            let newDictionary = Dictionary(context: context)
            newDictionary.dicName = dictionaryNameTextField.text
            newDictionary.dicDescription = descriptionTextField.text
            newDictionary.dicLearningLanguage = selectedLearning
            newDictionary.dicTranslateLanguage = selectedTranslate
            let dicID = mainModel.uniqueIDgenerator(prefix: "dic")
            newDictionary.dicID = dicID
            newDictionary.dicUserID = mainModel.loadUserData().userID
            newDictionary.dicAddDate = mainModel.convertDateToString(currentDate: Date(), time: false)
            mainModel.createFolderInDocuments(withName: "\(mainModel.loadUserData().userID)/\(dicID)")
            newDictionary.dicDeleted = false
            newDictionary.dicShared = false
            newDictionary.dicReadOnly = false
            if mainModel.isInternetAvailable(){
                fireDB.createDictionary(
                    dicName: dictionaryNameTextField.text!,
                    dicUserID: mainModel.loadUserData().userID,
                    dicLearningLang: selectedLearning,
                    dicTranslationLang: selectedTranslate,
                    dicDescription: descriptionTextField.text ?? "",
                    dicWordsCount: 0,
                    dicID: dicID,
                    dicImagesCount: 0,
                    dicAddDate: mainModel.convertDateToString(currentDate: Date(), time: false), 
                    dicShared: false
                )
                newDictionary.dicSyncronized = true
            } else {
                newDictionary.dicSyncronized = false
            }
            coreDataManager.saveData(data: context)
            tableReloadDelegate?.didUpdateView(sender:"")
            hide()
        }
    }
    
}

extension CreatePopUpViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return defaults.languagesVolumesArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        warningView.isHidden = true
        return defaults.languagesVolumesArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            switch pressedButton {
            case 1:
                learningButton.setTitle(defaults.languagesVolumesArray[row], for: .normal)
                selectedLearning = defaults.languagesKeysArray[row]
            case 2:
                translateButton.setTitle(defaults.languagesVolumesArray[row], for: .normal)
                selectedTranslate = defaults.languagesKeysArray[row]
            default:
                return
            }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
           return 40.0
       }
    
}


