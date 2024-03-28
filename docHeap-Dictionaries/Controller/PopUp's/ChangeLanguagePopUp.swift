//
//  ChangeLanguagePopUpController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 19.11.23.
//

import UIKit

class ChangeLanguagePopUp: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var attentionLabel: UILabel!
    @IBOutlet weak var currentLanguageLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var languagesPicker: UIPickerView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var exitMessageView: UIView!
    @IBOutlet weak var exitMessageLabel: UILabel!
    
    func localizeElements(){
        headerLabel.text = "changeLanguagePopUp_header_label".localized
        attentionLabel.text = "changeLanguagePopUp_attention_label".localized
        currentLanguageLabel.text = "changeLanguagePopUp_currentLanguage_label".localized
        cancelButton.setTitle("changeLanguagePopUp_cancel_button".localized, for: .normal)
        selectButton.setTitle("changeLanguagePopUp_select_button".localized, for: .normal)
        saveButton.setTitle("changeLanguagePopUp_save_button".localized, for: .normal)
        exitMessageLabel.text = "changeLanguagePopUp_beforeExit_label".localized
    }
    
    private var interfaceLanguagesArray = [String]()
    private var defaults = Defaults()
    private var selectedInterfaceLanguage = String()
    private let mainModel = MainModel()
    
    init() {
        super.init(nibName: "ChangeLanguagePopUp", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func appear(sender: SettingsController) {
        sender.present(self, animated: false) {
            self.show()
        }
    }
    
    private func show() {
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.exitMessageView.alpha = 1
            self.mainView.alpha = 1
            self.background.alpha = 1
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.exitMessageView.alpha = 0
            self.background.alpha = 0
            self.mainView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
            self.removeFromParent()
        }
    }
    
    func popUpBackgroundSettings(){
        self.view.backgroundColor = .clear
        background.backgroundColor = .black.withAlphaComponent(0.6)
        background.alpha = 0
        mainView.alpha = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            localizeElements()
            standartState()
            elementsDesign()
       
    }
    
    func standartState(){
        let currentAppLanguage = Bundle.main.preferredLocalizations.first
        languageLabel.text = defaults.currentLanguageDictionary[currentAppLanguage ?? "no_language"]
        exitMessageView.isHidden = true
        popUpBackgroundSettings()
        languagesPicker.delegate = self
        languagesPicker.dataSource = self
        interfaceLanguagesArray = [defaults.intefaceLanguage_en, defaults.intefaceLanguage_uk, defaults.intefaceLanguage_ru]
        languagesPicker.isHidden = true
        saveButton.isHidden = true
       // okButton.isHidden = true
    }
    
    func elementsDesign(){
        languagesPicker.layer.cornerRadius = 10
        exitMessageView.layer.cornerRadius = 10
        exitMessageView.alpha = 0.8
        mainView.layer.cornerRadius = 10
        
    }
    
    func changeLanguage(to languageCode: String) {
            UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
    
    func appExit(){
        exit(EXIT_SUCCESS)
    }

    @IBAction func selectButtonPressed(_ sender: UIButton) {
                if languagesPicker.isHidden{
                    languagesPicker.isHidden = false
                } else {
                    languagesPicker.isHidden = true
                }
    }
    
    func beforeExit(){
        languagesPicker.isHidden = true
        mainView.isHidden = true
        exitMessageView.isHidden = false
//        headerLabel.isHidden = true
//        currentLanguageLabel.isHidden = true
//        languageLabel.isHidden = true
//        cancelButton.isHidden = true
//        selectButton.isHidden = true
//        saveButton.isHidden = true
//        okButton.isHidden = false
        attentionLabel.text = "changeLanguagePopUp_beforeExit_label".localized
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        hide()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        changeLanguage(to: selectedInterfaceLanguage)
        beforeExit()
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        appExit()
    }
    
}

extension ChangeLanguagePopUp: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return interfaceLanguagesArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return interfaceLanguagesArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        languageLabel.text = interfaceLanguagesArray[row]
        currentLanguageLabel.text = "changeLanguagePopUp_newLanguage_label".localized
        selectButton.isHidden = true
        saveButton.isHidden = false
        switch row {
        case 0:
            selectedInterfaceLanguage = "en"
        case 1:
            selectedInterfaceLanguage = "uk"
        case 2:
            selectedInterfaceLanguage = "ru"
        default: break
        }
    }
}
