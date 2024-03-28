//
//  FilterSharedDicController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 25.12.23.
//

import UIKit

class FilterSharedDicPopUp: UIViewController {

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var lernLangNameLabel: UILabel!
    @IBOutlet weak var transLangNameLabel: UILabel!
    @IBOutlet weak var transLangButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var langPicker: UIPickerView!
    @IBOutlet weak var learnLangButton: UIButton!
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    
    func localizeElements(){
        headerLabel.text = "filterSharedDictionariesPopUp_header".localized
        lernLangNameLabel.text = "filterSharedDictionariesPopUp_learnLang_label".localized
        transLangNameLabel.text = "filterSharedDictionariesPopUp_transLang_label".localized
        learnLangButton.setTitle("filterSharedDictionariesPopUp_learnLang_button".localized, for: .normal)
        transLangButton.setTitle("filterSharedDictionariesPopUp_transLang_button".localized, for: .normal)
        clearButton.setTitle("filterSharedDictionariesPopUp_clear_button".localized, for: .normal)
        applyButton.setTitle("filterSharedDictionariesPopUp_apply_button".localized, for: .normal)
    }
    
    var dictionarisArray = [SharedDictionary]()
    var sendFilteredDataDelegate: GetFilteredData?
    private let defaults = Defaults()
    var selectedLearn = String()
    var selectedTrans = String()
    private var pressedButton = Int()
    var selectedLearning = String()
    var selectedTranslate = String()
    
    init() {
        super.init(nibName: "FilterSharedDicPopUp", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeElements()
        popUpBackgroundSettings()
        standartState()
        isFilterApplied()
    }
    
    func isFilterApplied(){
        let learnLangValue = defaults.langArray.filter({$0.lang == selectedLearn})
        let transLangValue = defaults.langArray.filter({$0.lang == selectedTrans})
        switch (selectedLearn.isEmpty, selectedTrans.isEmpty){
        case (false,true):
            learnLangButton.setTitle(learnLangValue.first?.langValue, for: .normal)
        case (true,false):
            transLangButton.setTitle(transLangValue.first?.langValue, for: .normal)
        case (false,false):
            learnLangButton.setTitle(learnLangValue.first?.langValue, for: .normal)
            transLangButton.setTitle(transLangValue.first?.langValue, for: .normal)
        case (true,true):
            return
        }
    }
    
    func standartState(){
        mainView.layer.cornerRadius = 10
        learnLangButton.layer.cornerRadius = 10
        transLangButton.layer.cornerRadius = 10
        langPicker.isHidden = true
        langPicker.delegate = self
        warningView.isHidden = true
        selectedLearning = selectedLearn
        selectedTranslate = selectedTrans
        langPicker.layer.cornerRadius = 10
        let buttons = [learnLangButton!,transLangButton!]
            for button in buttons{
                button.layer.shadowColor = UIColor.systemGray2.cgColor
                button.layer.shadowOffset = CGSize(width: 1, height: 1)
                button.layer.shadowRadius = 2.0
                button.layer.shadowOpacity = 0.5
                button.layer.cornerRadius = 10
            }
    }
    
    func popUpBackgroundSettings(){
        self.view.backgroundColor = .clear
        background.backgroundColor = .black.withAlphaComponent(0.6)
        background.alpha = 0
        mainView.alpha = 0
    }
    
    func appear(sender: NetworkController) {
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
    
    func checkDifference()->Bool{
        switch (selectedLearning.isEmpty, selectedTranslate.isEmpty){
        case (true,true):
            warningView.isHidden = false
            return false
        case (true,false),(false,true):
            return true
        case (false,false):
            if selectedLearning == selectedTranslate{
                return false
            } else {
                return true
            }
        }
    }
    
    func buttonScaleAnimation(targetButton:UIButton){
        UIView.animate(withDuration: 0.2) {
            targetButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { (bool) in
            targetButton.transform = .identity
        }
    }
    
    @IBAction func learnLangButtonPressed(_ sender: UIButton) {
        buttonScaleAnimation(targetButton: learnLangButton)
        if langPicker.isHidden{
            langPicker.isHidden = false
        } else {
            langPicker.isHidden = true
        }
        pressedButton = 1
    }
    
    @IBAction func transLangButtonPressed(_ sender: UIButton) {
        buttonScaleAnimation(targetButton: transLangButton)
        if langPicker.isHidden{
            langPicker.isHidden = false
        } else {
            langPicker.isHidden = true
        }
        pressedButton = 2
    }
    

    @IBAction func clearButtonPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.sendFilteredDataDelegate?.setDataAfterFilter(array: [], learnLang: "", transLang: "", clear: true)
        }
        hide()
    }
    
    @IBAction func applyButtonPressed(_ sender: UIButton) {
        if checkDifference(){
            switch (selectedLearning.isEmpty, selectedTranslate.isEmpty){
            case (true, true):
                return
            case (false,true):
                let filteredArray = dictionarisArray.filter({$0.dicLearnLang == selectedLearning})
                sendFilteredDataDelegate?.setDataAfterFilter(array: filteredArray, learnLang: selectedLearning, transLang: selectedTranslate, clear: false)
                hide()
            case (true,false):
                let filteredArray = dictionarisArray.filter({$0.dicTransLang == selectedTranslate})
                sendFilteredDataDelegate?.setDataAfterFilter(array: filteredArray, learnLang: selectedLearning, transLang: selectedTranslate, clear: false)
                hide()
            case (false,false):
                let filteredArray = dictionarisArray.filter({$0.dicLearnLang == selectedLearning && $0.dicTransLang == selectedTranslate})
                sendFilteredDataDelegate?.setDataAfterFilter(array: filteredArray, learnLang: selectedLearning, transLang: selectedTranslate, clear: false)
                hide()
            }
        } else {
            applyButton.isEnabled = false
        }
    }
            

    
}
extension FilterSharedDicPopUp: UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return defaults.langArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return defaults.langArray[row].langValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        applyButton.isEnabled = true
            switch pressedButton {
            case 1:
                learnLangButton.setTitle(defaults.langArray[row].langValue, for: .normal)
                selectedLearning = defaults.langArray[row].lang
            case 2:
                transLangButton.setTitle(defaults.langArray[row].langValue, for: .normal)
                selectedTranslate = defaults.langArray[row].lang
            default:
                return
            }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
           return 40.0
       }
}
