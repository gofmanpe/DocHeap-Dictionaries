//
//  SelectDictionaryForTestController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 06.04.23.
//

import UIKit
import CoreData

class SelectDictionaryForTestPopUp: UIViewController {
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var dictionaryButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var selectDictionaryLabel: UILabel!
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var roundNumberLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var numberOfRoundsLabel: UILabel!
    @IBOutlet weak var warningImage: UIImageView!
    @IBOutlet weak var stepper: UIStepper!
  //  @IBOutlet weak var roundsStack: UIStackView!
    @IBOutlet weak var roundsNumberView: UIView!
    
    
    func localizeElements(){
        headerLabel.text = "selectDictionaryVC_header_label".localized
        selectDictionaryLabel.text = "selectDictionaryVC_selectDictionary_label".localized
        dictionaryButton.setTitle("selectDictionaryVC_tapToSelect_button".localized, for: .normal)
        roundNumberLabel.text = "selectDictionaryVC_roundsNumber_label".localized
        cancelButton.setTitle("selectDictionaryVC_cancel_button".localized, for: .normal)
        selectButton.setTitle("selectDictionaryVC_select_button".localized, for: .normal)
    }
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var selectedDicID = String()
    var selectedTestIdentifier = String()
    var testName = String()
    var mainModel = MainModel()
    let defaults = Defaults()
    var coreDataManager = CoreDataManager()
    var performToSegueDelegate: PerformToSegue?
    private var numberOfRounds = Int()
    
    init() {
        super.init(nibName: "SelectDictionaryForTestPopUp", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeElements()
        coreDataManager.loadDictionariesForCurrentUser(userID: mainModel.loadUserData().userID, data: context)
        standartState()
        elementsDesign()
        
    }
    func requiredWordsCount(row:Int, test:String){
        switch test {
        case "fiveWordsTest":
            if coreDataManager.dictionariesArray[row].dicWordsCount < 5 {
                warningView.isHidden = false
                warningLabel.text = mainModel.commentWithState(minWordsCount: 5, isSetImage: 0)
                selectButton.isEnabled = false
            } else {
                warningView.isHidden = true
                selectButton.isEnabled = true
            }
        case "threeWordsTest":
            if coreDataManager.dictionariesArray[row].dicWordsCount < 3 {
                warningView.isHidden = false
                warningLabel.text = mainModel.commentWithState(minWordsCount: 3, isSetImage: 0)
                selectButton.isEnabled = false
            } else {
                warningView.isHidden = true
                selectButton.isEnabled = true
            }
        case "findAPairTest":
            if coreDataManager.dictionariesArray[row].dicWordsCount < 7 {
                warningView.isHidden = false
                warningLabel.text = mainModel.commentWithState(minWordsCount: 7, isSetImage: 0)
                selectButton.isEnabled = false
            } else {
                warningView.isHidden = true
                selectButton.isEnabled = true
            }
            
        case "falseOrTrueTest":
            if coreDataManager.dictionariesArray[row].dicWordsCount < 2 {
                warningView.isHidden = false
                warningLabel.text = mainModel.commentWithState(minWordsCount: 2, isSetImage: 0)
                selectButton.isEnabled = false
            } else {
                warningView.isHidden = true
                selectButton.isEnabled = true
            }
        case "findAnImageTest":
            coreDataManager.loadWordsForSelectedDictionary(dicID: selectedDicID, userID: mainModel.loadUserData().userID , context: context)
            let filteredByImageArray = coreDataManager.wordsArray.filter({$0.wrdImageIsSet == true})
            if filteredByImageArray.count <= 4 {
                warningView.isHidden = false
                warningLabel.text = mainModel.commentWithState(minWordsCount: 5, isSetImage: 1)
                selectButton.isEnabled = false
            } else {
                warningView.isHidden = true
                selectButton.isEnabled = true
            }
        default:
            return
        }
        
    }
    
    func numberOfRounds(identifier:String, row:Int)->Int{
        let wordsCount = coreDataManager.dictionariesArray[row].dicWordsCount
        let wordsWithImages = coreDataManager.dictionariesArray[row].dicImagesCount
        switch identifier {
        case "fiveWordsTest":
            let number = wordsCount - 4
            return Int(number)
        case "threeWordsTest":
            let number = wordsCount - 2
            return Int(number)
        case "findAPairTest":
            return 0
        case "falseOrTrueTest":
            let number = wordsCount - 1
            return Int(number)
        case "findAnImageTest":
            let number = wordsWithImages - 3
            return Int(number)
        default:
            return 0
        }
    }
    
    @IBAction func selectDictionaryButtonPressed(_ sender: UIButton) {
        if pickerView.isHidden{
            pickerView.isHidden = false
        } else {
            pickerView.isHidden = true
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        hide()
    }
    
    @IBAction func selectButtonPressed(_ sender: UIButton) {
        if selectedDicID.isEmpty{
            warningViewAppearAnimate("red", "selectDictionaryVC_noDictionary_message".localized)
        } else {
            warningView.isHidden = true
            performToSegueDelegate?.performToSegue(identifier: selectedTestIdentifier, dicID: selectedDicID, roundsNumber:numberOfRounds)
            hide()
        }
        
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        let value = Int(sender.value)
        numberOfRoundsLabel.text = "\(value)"
        numberOfRounds = value
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
    
    func appear(sender: TestsController) {
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
        background.backgroundColor = .black.withAlphaComponent(0.6)
        background.alpha = 0
        mainView.alpha = 0
        mainView.clipsToBounds = true
        mainView.layer.cornerRadius = 10
        headerView.clipsToBounds = true
        headerView.layer.cornerRadius = 10
        headerView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        view.backgroundColor = .clear
        cancelButton.layer.cornerRadius = 10
        cancelButton.layer.maskedCorners = [.layerMinXMaxYCorner]
        selectButton.layer.cornerRadius = 10
        selectButton.layer.maskedCorners = [.layerMaxXMaxYCorner]
        pickerView.layer.cornerRadius = 10
        warningView.layer.cornerRadius = 10
        warningView.clipsToBounds = true
        warningView.backgroundColor = .systemGray6
        warningView.layer.borderWidth = 3
        warningView.layer.borderColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.00).cgColor
        dictionaryButton.clipsToBounds = true
        dictionaryButton.layer.cornerRadius = 5
        numberOfRoundsLabel.layer.borderWidth = 1
        numberOfRoundsLabel.layer.borderColor = UIColor.lightGray.cgColor
        numberOfRoundsLabel.layer.cornerRadius = 10
    }
    
    func standartState(){
        if selectedTestIdentifier == "falseOrTrueTest" {
            stepper.minimumValue = 4
        } else {
            stepper.minimumValue = 1
        }
        
        stepper.isEnabled = false
        stepper.stepValue = 2
        warningView.isHidden = true
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.isHidden = true
        if selectedTestIdentifier == "findAPairTest"{
            roundsNumberView.isHidden = true
        } else {
            roundsNumberView.isHidden = false
        }
    }
    
    
}

//MARK: - PickerView Datasource & Delegate
extension SelectDictionaryForTestPopUp: UIPickerViewDataSource, UIPickerViewDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coreDataManager.dictionariesArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coreDataManager.dictionariesArray[row].dicName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dictionaryButton.setTitle("\(coreDataManager.dictionariesArray[row].dicName!)", for: .normal)
        selectedDicID = coreDataManager.dictionariesArray[row].dicID!
        warningView.isHidden = true
        selectButton.setTitle("selectDictionaryVC_startTest_button".localized, for: .normal)
        var maxNumberOfRounds = numberOfRounds(identifier: selectedTestIdentifier, row: row)
        if maxNumberOfRounds < 0 {
            maxNumberOfRounds = 0
        }
        numberOfRounds = maxNumberOfRounds
        stepper.isEnabled = true
        stepper.maximumValue = Double(maxNumberOfRounds)
        stepper.value = Double(maxNumberOfRounds)
        numberOfRoundsLabel.text = String(maxNumberOfRounds)
        requiredWordsCount(row: row, test: selectedTestIdentifier)
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
           
           return 40.0
       }
}

