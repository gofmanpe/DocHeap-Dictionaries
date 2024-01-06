//
//  ThreeWordsTestController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 10.04.23.
//

import UIKit
    //import CoreData

class ThreeWordsTestController: UIViewController, PerformToSegue, UpdateView{
    
//MARK: - Protocols delegate functions
    func didUpdateView(sender:String) {
        switch sender{
        case "reStartTest":
            errorsFixed = false
            errorsRepetitionMode = false
            coreDataManager.loadParentDictionaryData(dicID: selectedDictionary, userID: mainModel.loadUserData().userID, data: context)
            coreDataManager.loadWordsForSelectedDictionary(dicID: coreDataManager.parentDictionaryData.first?.dicID ?? "", userID: mainModel.loadUserData().userID, data: context)
            standartState()
            mainModel.wordsStatusClearing(array: coreDataManager.wordsArray, statusToClear: 1, data: context)
            mainModel.wordsStatusClearing(array: coreDataManager.wordsArray, statusToClear: 2, data: context)
            reloadTestData()
            coreDataManager.saveData(data: context)
            threeWordsTestStart()
        case "fixErrors":
            errorsFixed = false
            errorsRepetitionMode = true
            errorsModeLabel.isHidden = false
            errorsModeLabel.text = "threeWordsTestVC_repetitionMode_label".localized
            roundNumber = 0
            coreDataManager.loadParentDictionaryData(dicID: selectedDictionary, userID: mainModel.loadUserData().userID, data: context)
            coreDataManager.loadWordsForSelectedDictionary(dicID: coreDataManager.parentDictionaryData.first?.dicID ?? "", userID: mainModel.loadUserData().userID, data: context)
            
            standartState()
            mainModel.wordsStatusClearing(array: coreDataManager.wordsArray, statusToClear: 1, data: context)
            reloadTestData()
            errorsRepetition()
        default:
            return
        }
    }
    
    func performToSegue(identifier: String, dicID: String, roundsNumber:Int) {
       
            performSegue(withIdentifier: identifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        _ = segue.destination as! TestsController
    }
    
//MARK: - Outlets
    @IBOutlet weak var wordsBackgroundView: UIView!
    @IBOutlet weak var headerWordsWindow: UIStackView!
    @IBOutlet weak var commentImage: UIImageView!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var errorsModeLabel: UILabel!
    @IBOutlet weak var learningImage: UIImageView!
    @IBOutlet weak var translationImage: UIImageView!
    @IBOutlet weak var learningLabel: UILabel!
    @IBOutlet weak var translateLabel: UILabel!
    @IBOutlet weak var scoresLabel: UILabel!
    @IBOutlet weak var testNameLabel: UILabel!
    @IBOutlet weak var dictionaryNameLabel: UILabel!
    @IBOutlet weak var mainWordLabel: UILabel!
    @IBOutlet weak var firstWordButton: UIButton!
    @IBOutlet weak var secondWordButton: UIButton!
    @IBOutlet weak var thirdWordButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var toResultsButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var roundNumberLabel: UILabel!
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var roundNameLabel: UILabel!
    @IBOutlet weak var scoresNameLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    
//MARK: - Localization
    func localizeElements(){
        roundNameLabel.text = "threeWordsTestVC_roundsName_label".localized
        scoresNameLabel.text = "threeWordsTestVC_scoresName_label".localized
        instructionLabel.text = "threeWordsTestVC_instructionLabel_label".localized
        checkButton.setTitle("threeWordsTestVC_check_button".localized, for: .normal)
        nextButton.setTitle("threeWordsTestVC_next_button".localized, for: .normal)
        toResultsButton.setTitle("threeWordsTestVC_toResults_button".localized, for: .normal)
        progressLabel.text = "threeWordsTestVC_testProgress_label".localized
    }
    
//MARK: - Constants and variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var mainWord = String()
    var mainWordTranslation = String()
    var threeButtonsTranstlationsArray = [String]()
    var threeButtonsVolumesDictionary = [Int:String]()
    var filteredArray = [Word]()
    var mainWordIndex = Int()
    var wrongWordsArray = [Word]()
    var numberOfRounds = Int()
    var selectedDictionary = String()
    var selectedTestIdentifier = String()
    var answer = false
    var rightAnswers = Int()
    var wordsCount = Int()
    var choiseMaided = false
    var progressBarProgress = Double()
    var errorsFixed = Bool()
    var errorsRepetitionMode = false
    var roundNumber = Int()
    var pressedButton = UIButton()
    var selectedWord = String()
    var threeUIButtonsArray = [UIButton]()
    private var defaults = Defaults()
    private var mainModel = MainModel()
    private var coreDataManager = CoreDataManager()
    
//MARK: - Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeElements()
        coreDataManager.loadParentDictionaryData(dicID: selectedDictionary, userID: mainModel.loadUserData().userID, data: context)
        coreDataManager.loadWordsForSelectedDictionary(dicID: coreDataManager.parentDictionaryData.first?.dicID ?? "", userID: mainModel.loadUserData().userID, data: context)
        standartState()
        mainModel.wordsStatusClearing(array: coreDataManager.wordsArray, statusToClear: 1, data: context)
        mainModel.wordsStatusClearing(array: coreDataManager.wordsArray, statusToClear: 2, data: context)
        coreDataManager.saveData(data: context)
        threeWordsTestStart()
    }
    
//MARK: - Test engine functions
    
    func threeWordsTestStart(){
        threeWordsTestUIState()
        threeButtonsTranstlationsArray.removeAll()
        let wordsArray = coreDataManager.wordsArray
        let wordsNumber = numberOfRounds + 2
        let arrayOfWords = Array(wordsArray.prefix(wordsNumber))
        filteredArray = arrayOfWords.filter({$0.wrdStatus == 0}) // filtering an array of words by status 0
        mainWordIndex = Int.random(in: 0..<filteredArray.count) // randomizing select the main testing word index
        filteredArray[mainWordIndex].wrdStatus = 1 // setting status 1 to the main testing word (for avoid repeating)
        
        let queryRestult = mainModel.wordsTestingEngine(arrayOfWords: filteredArray, mainWordIndex: mainWordIndex, numberOfWords: 3)
        mainWord = queryRestult.0
        mainWordTranslation = queryRestult.1
        threeButtonsTranstlationsArray = queryRestult.2
        threeButtonsVolumesDictionary = queryRestult.3
        
        for i in 0...2 {
            threeUIButtonsArray[i].setTitle(threeButtonsTranstlationsArray[i], for: .normal)
        }
        errorsModeLabel.isHidden = true
        roundNumber += 1
        roundNumberLabel.text = String(roundNumber)
        mainWordLabel.text = mainWord
    }
    
    func errorsRepetition(){
        threeWordsTestUIState()
        let arrayOfWords = coreDataManager.wordsArray
        filteredArray = arrayOfWords.filter({$0.wrdStatus == 0})
        wrongWordsArray = arrayOfWords.filter({$0.wrdStatus == 2})
        mainWordIndex = Int.random(in: 0..<wrongWordsArray.count)
        wrongWordsArray[mainWordIndex].wrdStatus = 1
        let queryResult = mainModel.errorsRepetitionMode(arrayOfWords: coreDataManager.wordsArray, arrayOfMistakes:wrongWordsArray, mainWordIndex: mainWordIndex, numberOfWords: 3)
        mainWord = queryResult.0
        mainWordTranslation = queryResult.1
        threeButtonsTranstlationsArray = queryResult.2
        threeButtonsVolumesDictionary = queryResult.3
        for i in 0...2 {
            threeUIButtonsArray[i].setTitle(threeButtonsTranstlationsArray[i], for: .normal)
        }
        roundNumber += 1
        roundNumberLabel.text = String(roundNumber)
        mainWordLabel.text = mainWord
    }
    
    func buttonsBhvrTheEnd(){
        for button in threeUIButtonsArray{
            button.isEnabled = false
            button.backgroundColor = .clear
        }
        if errorsRepetitionMode{
            commentViewSettings("fixed")
        } else {
            commentViewSettings("finish")
        }
        progressLabel.text = "threeWordsTestVC_testProgress_label".localized
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
        case "fixed":
            nextButton.isHidden = true
            checkButton.isHidden = true
            toResultsButton.isHidden = false
            blockView.backgroundColor = .lightGray
            blockView.isHidden = false
            commentView.isHidden = false
            commentLabel.isHidden = false
            commentImage.image = UIImage(named: "fixed.png")
            commentLabel.text = defaults.labelMistakesFixedText
            commentLabel.textColor = UIColor(red: 0.20, green: 0.60, blue: 0.35, alpha: 1.00)
            commentView.layer.borderColor = UIColor(red: 0.20, green: 0.60, blue: 0.35, alpha: 1.00).cgColor
        default: break
        }
    }
    
    func threeWordsTestUIState() {
        warningView.isHidden = true
        choiseMaided = false
        answer = false
        nextButton.isHidden = true
        checkButton.isHidden = false
        blockView.backgroundColor = .clear
        blockView.alpha = 1
        for button in threeUIButtonsArray{
            button.clipsToBounds = true
            button.layer.cornerRadius = 10
            button.backgroundColor = .clear
        }
        toResultsButton.isHidden = true
        errorsModeLabel.clipsToBounds = true
        errorsModeLabel.layer.cornerRadius = 3
    }
    
    func standartState(){
        wordsBackgroundView.layer.shadowColor = UIColor.black.cgColor
        wordsBackgroundView.layer.shadowOpacity = 0.2
        wordsBackgroundView.layer.shadowOffset = .zero
        wordsBackgroundView.layer.shadowRadius = 2
        commentView.layer.cornerRadius = 10
        commentView.layer.borderWidth = 3
        threeUIButtonsArray = [firstWordButton,secondWordButton,thirdWordButton]
        dictionaryNameLabel.text = coreDataManager.parentDictionaryData.first?.dicName
        let foundTest = TestDataModel.tests.first(where: { $0.identifier == selectedTestIdentifier})
        testNameLabel.text = foundTest!.name
        learningLabel.text = coreDataManager.parentDictionaryData.first?.dicLearningLanguage
        let learnImage:String = coreDataManager.parentDictionaryData.first!.dicLearningLanguage!
        let translateImage:String = coreDataManager.parentDictionaryData.first!.dicTranslateLanguage!
        learningImage.image = UIImage(named: "\(learnImage).png")
        translationImage.image = UIImage(named: "\(translateImage).png")
        translateLabel.text = coreDataManager.parentDictionaryData.first?.dicTranslateLanguage
        progressLabel.text = "threeWordsTestVC_testProgress_label".localized
        scoresLabel.text = String(rightAnswers)
        nextButton.layer.cornerRadius = 10
        checkButton.layer.cornerRadius = 10
        wordsBackgroundView.layer.cornerRadius = 10
        headerWordsWindow.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        headerWordsWindow.layer.cornerRadius = 10
        checkButton.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        nextButton.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        toResultsButton.layer.cornerRadius = 10
        toResultsButton.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        nextButton.isHidden = true
        blockView.isHidden = true
        commentView.isHidden = true
        for button in threeUIButtonsArray{
            button.isEnabled = true
        }
        warningView.isHidden = true
    }
    
    func pressedButtonBehavor(buttonId:Int,button:UIButton){
        for button in threeUIButtonsArray{
            button.backgroundColor = .clear
            button.layer.borderWidth = 0
        }
        pressedButton = button
        choiseMaided = true
        warningView.isHidden = true
        button.backgroundColor = UIColor.systemGray6
        button.layer.borderColor = UIColor(red: 0.78, green: 0.78, blue: 0.80, alpha: 1.00).cgColor
        button.backgroundColor = UIColor.systemGray6
        button.layer.borderWidth = 1
        if let isWordExists = threeButtonsVolumesDictionary[buttonId]{
            selectedWord = isWordExists
        }
       
    }
    
    func reloadTestData(){
        answer = false
        choiseMaided = false
        rightAnswers = 0
        scoresLabel.text = String(rightAnswers)
        wordsCount = 0
        progressLabel.text = "threeWordsTestVC_testProgress_label".localized
        progressBarProgress = 0
        progressBar.progress = Float(progressBarProgress)
    }
    
    func resultsPopUpApear(){
        let overLayerView = ResultsPopUpController()
        overLayerView.performToSegueDelegate = self
        overLayerView.didUpdateViewDelegate = self
        overLayerView.rightAnswers = rightAnswers
        overLayerView.wordsCount = wordsCount
        overLayerView.errorsFixed = errorsFixed
        overLayerView.selectedDictionary = selectedDictionary
        overLayerView.selectedTestIdentifier = selectedTestIdentifier
        overLayerView.appearOverlayer(sender: self)
    }
    
    func warningViewAppearAnimate(_ text:String){
        warningView.isHidden = false
        warningLabel.text = text
        warningView.alpha = 0
        UIView.animate(withDuration: 0.75) {
            self.warningView.alpha = 1
        } completion: { Bool in
            UIView.animate(withDuration: 0.75) {
                              self.warningView.alpha = 0
                            }
        }
    }
    
//MARK: - Actions
    @IBAction func firstButtonPressed(_ sender: UIButton) {
        pressedButtonBehavor(buttonId: 0, button: firstWordButton)
    }
    
    @IBAction func secondButtonPressed(_ sender: UIButton) {
        pressedButtonBehavor(buttonId: 1, button: secondWordButton)
    }
    
    @IBAction func thirdButtonPressed(_ sender: UIButton) {
        pressedButtonBehavor(buttonId: 2, button: thirdWordButton)
    }
    
    @IBAction func checkButtonPressed(_ sender: UIButton) {
        switch errorsRepetitionMode {
            case false:
                if choiseMaided {
                    wordsCount += 1
                    let progressStepCount =  numberOfRounds
                    progressBarProgress += (1.0 / Double(progressStepCount))
                    progressBar.progress = Float(progressBarProgress)
                    progressLabel.text = "threeWordsTestVC_testProgress_label".localized
                    roundNumberLabel.text = String(wordsCount)
                    if selectedWord == mainWordTranslation {
                        answer = true
                        filteredArray[mainWordIndex].wrdRightAnswers += 1
                        pressedButton.layer.borderWidth = 0
                        pressedButton.layer.cornerRadius = 10
                        pressedButton.layer.borderColor = UIColor(red: 0.00, green: 0.80, blue: 0.00, alpha: 1.00).cgColor
                        pressedButton.backgroundColor = .clear
                        blockView.isHidden = false
                        blockView.backgroundColor = .systemGreen
                        blockView.alpha = 0.5
                        commentViewSettings("right")
                        nextButton.isHidden = false
                        checkButton.isHidden = true
                        rightAnswers += 1
                        scoresLabel.text = String(rightAnswers)
                    } else {
                        filteredArray[mainWordIndex].wrdWrongAnswers += 1
                        filteredArray[mainWordIndex].wrdStatus = 2
                        pressedButton.layer.borderWidth = 0
                        pressedButton.layer.cornerRadius = 10
                        pressedButton.layer.borderColor = UIColor(red: 0.87, green: 0.00, blue: 0.00, alpha: 1.00).cgColor
                        pressedButton.backgroundColor = .clear
                        blockView.isHidden = false
                        blockView.backgroundColor = .systemRed
                        blockView.alpha = 0.5
                        nextButton.isHidden = false
                        checkButton.isHidden = true
                        commentViewSettings("wrong")
                    }
                } else {
                    warningViewAppearAnimate("sharedElements_noChose_label".localized)
                }
            case true:
                if choiseMaided {
                    wordsCount += 1
                    commentLabel.isHidden = true
                    progressBarProgress += (1.0 / Double(wrongWordsArray.count))
                    progressBar.progress = Float(progressBarProgress)
                    progressLabel.text = "threeWordsTestVC_testProgress_label".localized
                    if selectedWord == mainWordTranslation {
                        answer = true
                        wrongWordsArray[mainWordIndex].wrdRightAnswers += 1
                        pressedButton.layer.borderWidth = 1
                        pressedButton.layer.cornerRadius = 10
                        pressedButton.layer.borderColor = UIColor(red: 0.00, green: 0.80, blue: 0.00, alpha: 1.00).cgColor
                        pressedButton.backgroundColor = UIColor(red: 0.67, green: 1.00, blue: 0.60, alpha: 1.00)
                        blockView.isHidden = false
                        blockView.backgroundColor = .systemGreen
                        blockView.alpha = 0.5
                        commentViewSettings("right")
                        nextButton.isHidden = false
                        checkButton.isHidden = true
                        rightAnswers += 1
                        scoresLabel.text = String(rightAnswers)
                    } else {
                        wrongWordsArray[mainWordIndex].wrdWrongAnswers += 1
                        wrongWordsArray[mainWordIndex].wrdStatus = 2
                        pressedButton.layer.borderWidth = 1
                        pressedButton.layer.cornerRadius = 10
                        pressedButton.layer.borderColor = UIColor(red: 0.87, green: 0.00, blue: 0.00, alpha: 1.00).cgColor
                        pressedButton.backgroundColor = UIColor(red: 0.95, green: 0.82, blue: 0.78, alpha: 1.00)
                        blockView.isHidden = false
                        blockView.backgroundColor = .systemRed
                        blockView.alpha = 0.5
                        nextButton.isHidden = false
                        checkButton.isHidden = true
                        commentViewSettings("wrong")
                    }
                } else {
                    warningViewAppearAnimate("sharedElements_noChose_label".localized)
                }
            }
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        switch errorsRepetitionMode {
        case true:
            for button in threeUIButtonsArray{
                button.layer.borderWidth = 0
            }
            commentView.isHidden = true
            wrongWordsArray = coreDataManager.wordsArray.filter({$0.wrdStatus == 2})
            if wrongWordsArray.isEmpty {
                    errorsFixed = true
                    mainModel.wordsStatusClearing(array: coreDataManager.wordsArray, statusToClear: 2, data: context)
                    buttonsBhvrTheEnd()
                    coreDataManager.saveData(data: context)
            } else {
                for button in threeUIButtonsArray{
                    button.isEnabled = true
                }
                blockView.isHidden = true
                errorsRepetition()
            }
        case false:
            for button in threeUIButtonsArray{
                button.layer.borderWidth = 0
            }
            commentView.isHidden = true
            if filteredArray.count <= 3 {
                mainModel.wordsStatusClearing(array: coreDataManager.wordsArray, statusToClear: 1, data: context)
                buttonsBhvrTheEnd()
                coreDataManager.saveData(data: context)
            } else {
                for button in threeUIButtonsArray{
                    button.isEnabled = true
                }
                blockView.isHidden = true
                threeWordsTestStart()
            }
        }
    }
    
    
    @IBAction func toResultsButtonPressed(_ sender: UIButton) {
        buttonsBhvrTheEnd()
        resultsPopUpApear()
    }

}
