//
//  FindAPairController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 24.04.23.
//

import UIKit
import CoreData

class FindAPairController: UIViewController, PerformToSegue, UpdateView {
  
//MARK: - Delegate functions
    func didUpdateView(sender: String) {
       // coreDataManager.loadTestData(testIdentifier: selectedTestIdentifier, data: context)
        coreDataManager.loadParentDictionaryData(dicID: selectedDicID, userID: mainModel.loadUserData().userID, data: context)
        coreDataManager.loadWordsForSelectedDictionary(dicID: coreDataManager.parentDictionaryData.first?.dicID ?? "", userID: mainModel.loadUserData().userID, data: context)
        mainModel.wordsStatusClearing(array: coreDataManager.wordsArray, statusToClear: 0, data: context)
        restartTest()
        standartState()
        designUI()
        //startTest()
        //mainModel.findAPairEngine(arrayOfWords: coreDataManager.wordsArray)
    }
    
    func performToSegue(identifier: String, dicID: String, roundsNumber:Int) {
            performSegue(withIdentifier: identifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        _ = segue.destination as! TestsController
    }
 
//MARK: - Outlets
   // @IBOutlet weak var testFifishedLabel: UILabel!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var commentImage: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var scoresLabel: UILabel!
    @IBOutlet weak var errorsNumberLabel: UILabel!
    @IBOutlet weak var headerTranslationLabel: UILabel!
    @IBOutlet weak var headerWordLabel: UILabel!
    @IBOutlet weak var translationLanguageImage: UIImageView!
    @IBOutlet weak var learningLanguageImage: UIImageView!
    @IBOutlet weak var translationLanguageLabel: UILabel!
    @IBOutlet weak var learningLanguageLabel: UILabel!
    @IBOutlet weak var testNameLabel: UILabel!
    @IBOutlet weak var dictionaryNameLabel: UILabel!
    @IBOutlet weak var wordsBackgroundView: UIView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var toResultsButton: UIButton!
    @IBOutlet weak var againButton: UIButton!
    @IBOutlet weak var warningLabel: UILabel!
//MARK: - words buttons outlets
    @IBOutlet weak var firstWordButton: UIButton!
    @IBOutlet weak var secondWordButton: UIButton!
    @IBOutlet weak var thirdWordButton: UIButton!
    @IBOutlet weak var fouthWordButton: UIButton!
    @IBOutlet weak var fifthWordButton: UIButton!
    @IBOutlet weak var sixthWordButton: UIButton!
    @IBOutlet weak var seventhWordButton: UIButton!
//MARK: - translations buttons outlets
    @IBOutlet weak var firstTranslateButton: UIButton!
    @IBOutlet weak var secondTranslateButton: UIButton!
    @IBOutlet weak var thirdTranslateButton: UIButton!
    @IBOutlet weak var fouthTranslateButton: UIButton!
    @IBOutlet weak var fifthTranslateButton: UIButton!
    @IBOutlet weak var sixthTranslateButton: UIButton!
    @IBOutlet weak var seventhTranslateButton: UIButton!
   
    func localizeElemants(){
        
    }
    
//MARK: - Constants and variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var sevenUIButtonsWordsArray = [UIButton]()
    private var sevenUIButtonsTranslationsArray = [UIButton]()
    private var sevenWordsArray = [Word]()
    private var sevenTranslationsArray = [Word]()
    private var sevenButtonsWordsArray = [String]()
    private var wordsButtonsVolumesDictionary = [Int:String]()
    private var sevenButtonsTranslationsArray = [String]()
    private var translationsButtonsVolumesDictionary = [Int:String]()
    
    var selectedDicID = String()
    var selectedTestIdentifier = String()
    private var translationsForCheckArray = [String]()
    private var isWordSelected = Bool()
    private var isTranslationSelected = Bool()
    private var selectedWord = String()
    private var selectedTranslation = String()
    private var selectedWordTranslation = String()
    private var selectedTranslationWord = String()
    private var translateButtonPressed = UIButton()
    private var wordButtonPressed = UIButton()
    private var pressedWordButtonId = Int()
    private var pressedTranslationButtonId = Int()
    private var scores = Int()
    private var errors = Int()
    private var filteredByStatusWordsArray = [Word]()
    var roundNumber = Int()
    private let defaults = Defaults()
    private let mainModel = MainModel()
    private var coreDataManager = CoreDataManager()
    private let testModel = TestModel()
    
//MARK: - View Did Load Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeElemants()
       // coreDataManager.loadTestData(testIdentifier: selectedTestIdentifier, data: context)
        coreDataManager.loadParentDictionaryData(dicID: selectedDicID, userID: mainModel.loadUserData().userID, data: context)
        coreDataManager.loadWordsForSelectedDictionary(dicID: coreDataManager.parentDictionaryData.first?.dicID ?? "", userID: mainModel.loadUserData().userID, data: context)
        mainModel.wordsStatusClearing(array: coreDataManager.wordsArray, statusToClear: 0, data: context)
        standartState()
        designUI()
        startTest()
    }
    
//MARK: - Test engine functions
    private func startTest(){
        let queryResults = testModel.findAPairEngine(arrayOfWords: coreDataManager.wordsArray)
        sevenWordsArray = queryResults.0
        sevenButtonsWordsArray = queryResults.1
        wordsButtonsVolumesDictionary = queryResults.2
        sevenTranslationsArray = queryResults.3
        sevenButtonsTranslationsArray = queryResults.4
        translationsButtonsVolumesDictionary = queryResults.5
        
        for i in 0...6{ // in loop set the buttons titles and volumes for words and translations groups
            sevenUIButtonsWordsArray[i].setTitle(sevenWordsArray[i].wrdWord, for: .normal)
            sevenUIButtonsTranslationsArray[i].setTitle(sevenTranslationsArray[i].wrdTranslation, for: .normal)
        }
    }
    private func restartTest(){
        startTest()
        isWordSelected = false
        isTranslationSelected = false
        selectedWord = String()
        selectedTranslation = String()
        headerWordLabel.text = selectedWord
        headerTranslationLabel.text = selectedTranslation
        selectedWordTranslation = String()
        selectedTranslationWord = String()
        translateButtonPressed = UIButton()
        wordButtonPressed = UIButton()
        pressedWordButtonId = Int()
        pressedTranslationButtonId = Int()
        scores = 0
        scoresLabel.text = String(scores)
        errors = 0
        errorsNumberLabel.text = String(errors)
        roundNumber = 1
        for button in sevenUIButtonsWordsArray{
            button.isEnabled = true
            button.layer.borderWidth = 0
            button.backgroundColor = .clear
        }
        for button in sevenUIButtonsTranslationsArray{
            button.isEnabled = true
            button.layer.borderWidth = 0
            button.backgroundColor = .clear
        }
    }
    
    private func standartState(){
        commentView.isHidden = true
        blockView.isHidden = true
        nextButton.isHidden = true
        toResultsButton.isHidden = true
        checkButton.isHidden = false
        warningLabel.isHidden = true
        againButton.isHidden = true
        sevenUIButtonsWordsArray = [
            firstWordButton,
            secondWordButton,
            thirdWordButton,
            fouthWordButton,
            fifthWordButton,
            sixthWordButton,
            seventhWordButton]
        sevenUIButtonsTranslationsArray = [
            firstTranslateButton,
            secondTranslateButton,
            thirdTranslateButton,
            fouthTranslateButton,
            fifthTranslateButton,
            sixthTranslateButton,
            seventhTranslateButton]
        dictionaryNameLabel.text = coreDataManager.parentDictionaryData.first?.dicName
        let foundTest = TestDataModel.tests.first(where: { $0.identifier == selectedTestIdentifier})
        testNameLabel.text = foundTest!.name
        let learnImage:String = coreDataManager.parentDictionaryData.first!.dicLearningLanguage!
        let translateImage:String = coreDataManager.parentDictionaryData.first!.dicTranslateLanguage!
        learningLanguageImage.image = UIImage(named: "\(learnImage).png")
        translationLanguageImage.image = UIImage(named: "\(translateImage).png")
        learningLanguageLabel.text = coreDataManager.parentDictionaryData.first?.dicLearningLanguage
        translationLanguageLabel.text = coreDataManager.parentDictionaryData.first?.dicTranslateLanguage
    }
    
    private func designUI(){
        wordsBackgroundView.layer.cornerRadius = 10
        wordsBackgroundView.clipsToBounds = true
        commentView.layer.cornerRadius = 10
        commentView.layer.borderWidth = 3
    }
    
    private func pressedButtonBehavor(buttonId:Int,button:UIButton,value:String,type:String){
        switch type {
        case "word":
            wordButtonPressed = button
            pressedWordButtonId = buttonId
            isWordSelected = true
            selectedWordTranslation = value
            selectedWord = wordsButtonsVolumesDictionary[buttonId]!
            headerWordLabel.text = selectedWord
            button.layer.borderColor = UIColor(red: 0.78, green: 0.78, blue: 0.80, alpha: 1.00).cgColor
            button.backgroundColor = UIColor.systemGray6
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 5
            for button in sevenUIButtonsWordsArray where button != wordButtonPressed{
                button.backgroundColor = .clear
                button.layer.borderWidth = 0
            }
            warningLabel.isHidden = true
        case "translation":
            pressedTranslationButtonId = buttonId
            translateButtonPressed = button
            isTranslationSelected = true
            selectedTranslationWord = value
            selectedTranslation = translationsButtonsVolumesDictionary[buttonId]!
            headerTranslationLabel.text = translationsButtonsVolumesDictionary[buttonId]!
            button.backgroundColor = UIColor.systemGray6
            button.layer.borderColor = UIColor(red: 0.78, green: 0.78, blue: 0.80, alpha: 1.00).cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 5
            for button in sevenUIButtonsTranslationsArray where button != translateButtonPressed{
                button.backgroundColor = .clear
                button.layer.borderWidth = 0
            }
            warningLabel.isHidden = true
        default: break
        }
    }
    
    private func commentViewSettings(_ feedback:String){
        switch feedback {
        case "right":
            commentView.isHidden = false
            commentLabel.isHidden = false
            commentImage.image = UIImage(named: "done.png")
            commentView.layer.borderColor = UIColor(red: 0.20, green: 0.60, blue: 0.35, alpha: 1.00).cgColor
            commentLabel.textColor = UIColor(red: 0.20, green: 0.60, blue: 0.35, alpha: 1.00)
            commentLabel.text = defaults.rightCommentsArray.randomElement()
            commentView.backgroundColor = UIColor(red: 0.93, green: 1.00, blue: 0.95, alpha: 1.00)
        case "wrong":
            commentLabel.textColor = UIColor(red: 0.87, green: 0.00, blue: 0.00, alpha: 1.00)
            commentLabel.text = defaults.wrongCommentsArray.randomElement()
            commentView.layer.borderColor = UIColor(red: 0.87, green: 0.00, blue: 0.00, alpha: 1.00).cgColor
            commentImage.image = UIImage(named: "stop.png")
            commentView.isHidden = false
            commentLabel.isHidden = false
            commentView.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 1.00, alpha: 1.00)
        case "finish":
            nextButton.isHidden = true
            checkButton.isHidden = true
            toResultsButton.isHidden = false
            blockView.backgroundColor = .lightGray
            blockView.isHidden = false
            commentView.isHidden = false
            commentLabel.isHidden = false
            commentImage.image = UIImage(named: "theend.png")
            commentLabel.text = defaults.labelTestFinishedText
            commentLabel.textColor = UIColor(red: 0.00, green: 0.67, blue: 1.00, alpha: 1.00)
            commentView.layer.borderColor = UIColor(red: 0.00, green: 0.67, blue: 1.00, alpha: 1.00).cgColor
            commentView.backgroundColor = UIColor(red: 0.90, green: 0.98, blue: 1.00, alpha: 1.00)
        
        default: break
        }
    }
    
   private func resultsPopUpApear(){
        let overLayerView = ResultsPopUpController()
        overLayerView.performToSegueDelegate = self
        overLayerView.didUpdateViewDelegate = self
        overLayerView.rightAnswers = scores
        overLayerView.errors = errors
        overLayerView.wordsCount = roundNumber
        overLayerView.selectedDictionary = selectedDicID
        overLayerView.selectedTestIdentifier = selectedTestIdentifier
        overLayerView.appearOverlayer(sender: self)
    }
    
    private func warningViewAppearAnimate(_ text:String){
        warningLabel.isHidden = false
        warningLabel.text = text
        warningLabel.alpha = 0
        UIView.animate(withDuration: 0.75) {
            self.warningLabel.alpha = 1
        } completion: { Bool in
            UIView.animate(withDuration: 0.75) {
                self.warningLabel.alpha = 0
            }
        }
    }
    
//MARK: - Action functions
    @IBAction func firstWordButtonPressed(_ sender: UIButton) {
        pressedButtonBehavor(buttonId: 0, button: firstWordButton, value: sevenWordsArray[0].wrdTranslation!, type: "word")
    }
    @IBAction func secondWordButtonPressed(_ sender: UIButton) {
        pressedButtonBehavor(buttonId: 1, button: secondWordButton, value: sevenWordsArray[1].wrdTranslation!, type: "word")
    }
    @IBAction func thirdWordButtonPressed(_ sender: UIButton) {
        pressedButtonBehavor(buttonId: 2, button: thirdWordButton, value: sevenWordsArray[2].wrdTranslation!, type: "word")
    }
    @IBAction func fouthWordButtonPressed(_ sender: UIButton) {
        pressedButtonBehavor(buttonId: 3, button: fouthWordButton, value: sevenWordsArray[3].wrdTranslation!, type: "word")
    }
    @IBAction func fifthWordButtonPressed(_ sender: UIButton) {
        pressedButtonBehavor(buttonId: 4, button: fifthWordButton, value: sevenWordsArray[4].wrdTranslation!, type: "word")
    }
    @IBAction func sixthWordButtonPressed(_ sender: UIButton) {
        pressedButtonBehavor(buttonId: 5, button: sixthWordButton, value: sevenWordsArray[5].wrdTranslation!, type: "word")
    }
    @IBAction func seventhWordButtonPressed(_ sender: UIButton) {
        pressedButtonBehavor(buttonId: 6, button: seventhWordButton, value: sevenWordsArray[6].wrdTranslation!, type: "word")
    }
    
    
    @IBAction func firstTranslationButtonPressed(_ sender: UIButton) {
        pressedButtonBehavor(buttonId: 0, button: firstTranslateButton, value: sevenTranslationsArray[0].wrdWord!, type: "translation")
    }
    @IBAction func secondTranslationButtonPressed(_ sender: UIButton) {
        pressedButtonBehavor(buttonId: 1, button: secondTranslateButton, value: sevenTranslationsArray[1].wrdWord!, type: "translation")
    }
    @IBAction func thirdWordTranslationButtonPressed(_ sender: UIButton) {
        pressedButtonBehavor(buttonId: 2, button: thirdTranslateButton, value: sevenTranslationsArray[2].wrdWord!, type: "translation")
    }
    @IBAction func fouthWordTranslationButtonPressed(_ sender: UIButton) {
        pressedButtonBehavor(buttonId: 3, button: fouthTranslateButton, value: sevenTranslationsArray[3].wrdWord!, type: "translation")
    }
    @IBAction func fifthWordTranslationButtonPressed(_ sender: UIButton) {
        pressedButtonBehavor(buttonId: 4, button: fifthTranslateButton, value: sevenTranslationsArray[4].wrdWord!, type: "translation")
    }
    @IBAction func sixthTranslationButtonPressed(_ sender: UIButton) {
        pressedButtonBehavor(buttonId: 5, button: sixthTranslateButton, value: sevenTranslationsArray[5].wrdWord!, type: "translation")
    }
    @IBAction func seventhTranslationButtonPressed(_ sender: UIButton) {
        pressedButtonBehavor(buttonId: 6, button: seventhTranslateButton, value: sevenTranslationsArray[6].wrdWord!, type: "translation")
    }
    
    @IBAction func checkButtonPressed(_ sender: UIButton) {
        if isTranslationSelected && isWordSelected{
            if selectedWordTranslation == selectedTranslation {
                wordButtonPressed.layer.borderWidth = 0
                wordButtonPressed.layer.cornerRadius = 5
                wordButtonPressed.backgroundColor = .clear
                translateButtonPressed.layer.borderWidth = 0
                translateButtonPressed.layer.cornerRadius = 5
                translateButtonPressed.backgroundColor = .clear
                translateButtonPressed.layer.borderColor = UIColor(red: 0.00, green: 0.80, blue: 0.00, alpha: 1.00).cgColor
                commentViewSettings("right")
                checkButton.isHidden = true
                nextButton.isHidden = false
                sevenWordsArray[pressedWordButtonId].wrdStatus = 1
                blockView.backgroundColor = .systemGreen
                blockView.isHidden = false
                scores += 1
                roundNumber += 1
                scoresLabel.text = String(scores)
                filteredByStatusWordsArray = sevenWordsArray.filter({$0.wrdStatus == 0})
                coreDataManager.saveData(data: context)
            } else {
                wordButtonPressed.layer.borderWidth = 0
                wordButtonPressed.backgroundColor = .clear
                translateButtonPressed.layer.borderWidth = 0
                translateButtonPressed.backgroundColor = .clear
                commentViewSettings("wrong")
                againButton.isHidden = false
                checkButton.isHidden = true
                blockView.backgroundColor = .systemRed
                blockView.isHidden = false
                errors += 1
                errorsNumberLabel.text = String(errors)
            }
        } else {
            if isTranslationSelected{
                warningLabel.text = defaults.findApairChooseWordText
                warningLabel.isHidden = false
            } else if isWordSelected{
                warningLabel.text = defaults.findApairChooseTranslationText
                warningLabel.isHidden = false
            } else {
                warningViewAppearAnimate("sharedElements_noChose_label".localized)
            }
        }
    }
  
    @IBAction func againButtonPressed(_ sender: UIButton) {
        for button in sevenUIButtonsWordsArray {
            button.backgroundColor = .clear
            button.layer.borderWidth = 0
        }
        for button in sevenUIButtonsTranslationsArray {
            button.backgroundColor = .clear
            button.layer.borderWidth = 0
        }
        commentView.isHidden = true
        blockView.isHidden = true
        isWordSelected = false
        isTranslationSelected = false
        selectedWord = String()
        selectedTranslation = String()
        selectedWordTranslation = String()
        selectedTranslationWord = String()
        headerWordLabel.text = String()
        headerTranslationLabel.text = String()
        isWordSelected = false
        againButton.isHidden = true
        checkButton.isHidden = false
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if !filteredByStatusWordsArray.isEmpty {
            headerWordLabel.text = String()
            headerTranslationLabel.text = String()
            isWordSelected = false
            isTranslationSelected = false
            selectedWord = String()
            selectedTranslation = String()
            selectedWordTranslation = String()
            selectedTranslationWord = String()
            wordButtonPressed.backgroundColor = .clear
            wordButtonPressed.layer.borderWidth = 0
            translateButtonPressed.backgroundColor = .clear
            translateButtonPressed.layer.borderWidth = 0
            wordButtonPressed.isEnabled = false
            translateButtonPressed.isEnabled = false
            wordButtonPressed = UIButton()
            translateButtonPressed = UIButton()
            againButton.isHidden = true
            nextButton.isHidden = true
            checkButton.isHidden = false
            if sevenWordsArray[pressedWordButtonId].wrdStatus == 1 {
                sevenUIButtonsWordsArray[pressedWordButtonId].isEnabled = false
                sevenUIButtonsTranslationsArray[pressedTranslationButtonId].isEnabled = false
            }
            blockView.isHidden = true
            commentView.isHidden = true
            
        } else
        {
            if sevenWordsArray[pressedWordButtonId].wrdStatus == 1 {
                sevenUIButtonsWordsArray[pressedWordButtonId].isEnabled = false
                sevenUIButtonsTranslationsArray[pressedTranslationButtonId].isEnabled = false
                commentViewSettings("finish")
            }
            commentViewSettings("finish")
            isWordSelected = false
            isTranslationSelected = false
            wordButtonPressed.backgroundColor = .clear
            wordButtonPressed.layer.borderWidth = 0
            translateButtonPressed.backgroundColor = .clear
            translateButtonPressed.layer.borderWidth = 0
            wordButtonPressed.isEnabled = false
            translateButtonPressed.isEnabled = false
            wordButtonPressed = UIButton()
            translateButtonPressed = UIButton()
            againButton.isHidden = true
            nextButton.isHidden = true
            checkButton.isHidden = true
            toResultsButton.isHidden = false
        }
    }
    
    @IBAction func toResultsPressed(_ sender: UIButton) {
        resultsPopUpApear()
    }
}
