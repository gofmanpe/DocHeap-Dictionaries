//
//  FindAnImageTestController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 04.08.23.
//

import UIKit
import CoreData

class FindAnImageTestController: UIViewController , PerformToSegue, UpdateView {
  
    func performToSegue(identifier: String, dicID: String, roundsNumber:Int) {
        performSegue(withIdentifier: identifier, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    _ = segue.destination as! TestsController
    }
    
    func didUpdateView(sender: String) {
        
       // coreDataManager.loadParentDictionaryData(dicID: selectedDictionary, userID: mainModel.loadUserData().userID, data: context)
//        coreDataManager.loadWordsForSelectedDictionary(dicID: coreDataManager.parentDictionaryData.first?.dicID ?? "", userID: mainModel.loadUserData().userID, data: context)
        loadData()
        standartState()
        mainModel.wordsStatusClearing(array: /*coreDataManager.wordsArray*/wordsForTestArray, statusToClear: 1, data: context)
        mainModel.wordsStatusClearing(array: /*coreDataManager.wordsArray*/wordsForTestArray, statusToClear: 2, data: context)
        reloadTestData()
        coreDataManager.saveData(data: context)
        testStart()
    }
    
    @IBOutlet weak var learningLanguageImage: UIImageView!
    
    @IBOutlet weak var learningLanguageLabel: UILabel!
    @IBOutlet weak var translateLanguageImage: UIImageView!
    
    @IBOutlet weak var translateLanguageLabel: UILabel!
    @IBOutlet weak var dictionaryNameLabel: UILabel!
    @IBOutlet weak var testNameLabel: UILabel!
    @IBOutlet weak var roundNumberLabel: UILabel!
    @IBOutlet weak var scoresNumberLabel: UILabel!
    @IBOutlet weak var wordsBackgroundView: UIView!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var roundsNameLabel: UILabel!
    @IBOutlet weak var scoresNameLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var testProgressLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentImage: UIImageView!
    @IBOutlet weak var mainWordLabel: UILabel!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var fouthButton: UIButton!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var toResultsButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var progressBarLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    func localizeElements(){
        roundsNameLabel.text = "findAnImageVC_round_label".localized
        instructionLabel.text = "findAnImageVC_instruction_label".localized
        scoresNameLabel.text = "findAnImageVC_scores_label".localized
        testProgressLabel.text = "findAnImageVC_testProgress_label".localized
        checkButton.setTitle("findAnImageVC_check_button".localized, for: .normal)
        toResultsButton.setTitle("findAnImageVC_toResults_button".localized, for: .normal)
        nextButton.setTitle("findAnImageVC_next_button".localized, for: .normal)
        warningLabel.text = "sharedElements_noChose_label".localized
    }
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var fourImagesWordsArray = [String?]()
    private var fourImagesPathArray = [String]()
    private var mainWord = String()
    private var mainWordImage = String()
    private var filteredArray = [Word]()
    private var mainWordIndex = Int()
    var numberOfRounds = Int()
    var selectedDicID = String()
    var selectedTestIdentifier = String()
    private var wordsArray = [Word]()
    private var wordsWithImagesArray = [Word]()
    private var wordsForTestArray = [Word]()
    private var parentDictionaryData = Dictionary()
    private var wordsCount = Int()
    private var fourButtonsArray = [UIButton]()
    private var pressedButton = UIButton()
    private var choiseMaided = Bool()
    private var selectedImage = String()
    private var rightAnswers = 0
    private var roundNumber = 0
    private var defaults = Defaults()
    private var mainModel = MainModel()
    private var coreDataManager = CoreDataManager()
    private let testModel = TestModel()
    private var progressBarProgress = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeElements()
        loadData()
        mainModel.wordsStatusClearing(array: wordsForTestArray, statusToClear: 0, data: context)
        standartState()
        testStart()
    }
    
    private func loadData(){
        wordsForTestArray = coreDataManager.getWordsForDictionary(dicID: selectedDicID, userID: mainModel.loadUserData().userID, context: context)
        parentDictionaryData = coreDataManager.getParentDictionaryData(dicID: selectedDicID, userID: mainModel.loadUserData().userID, context: context)
    }
    
    private func testStart(){
        choiseMaided = false
        fourImagesWordsArray.removeAll() // clearing array of translations
        fourImagesPathArray.removeAll()
        let wordsNumber = numberOfRounds + 3
        let arrayOfWords = Array(wordsForTestArray.prefix(wordsNumber))
        let filteredByImageArray = arrayOfWords.filter({$0.wrdImageIsSet == true}) // filtering an array of words by image status 1
        filteredArray = filteredByImageArray.filter({$0.wrdStatus == 0})
        mainWordIndex = Int.random(in: 0..<filteredArray.count) // randomizing select the main testing word index
        filteredArray[mainWordIndex].wrdStatus = 1 // setting status 1 to the main testing word (for avoid repeating)
        let queryResult = testModel.findAnImageTestEngine(arrayOfWords: filteredArray, mainWordIndex: mainWordIndex)
        mainWord = queryResult.0
        mainWordImage = queryResult.1
        fourImagesWordsArray = queryResult.2
       // print("Images words array: \(fourImagesWordsArray)\n")
        fourImagesPathArray = queryResult.3
       // print("Images path array: \(fourImagesPathArray)\n")
        roundNumber += 1
        roundNumberLabel.text = String(roundNumber)
        standartState()
        mainWordLabel.text = mainWord
        for i in 0...3 {
            let filePath = "\(mainModel.loadUserData().userID)/\(selectedDicID)/\(fourImagesPathArray[i])"
            let image = UIImage(contentsOfFile:  mainModel.getDocumentsFolderPath().appendingPathComponent(filePath).path)
            fourButtonsArray[i].setImage(image, for: .normal)
        }
    }
   
   private func standartState(){
        blockView.isHidden = true
        commentView.isHidden = true
        nextButton.isHidden = true
        checkButton.isHidden = false
        toResultsButton.isHidden = true
        warningLabel.isHidden = true
        fourButtonsArray = [firstButton,secondButton,thirdButton,fouthButton]
        for button in fourButtonsArray {
            button.clipsToBounds = true
            button.layer.cornerRadius = 10
            button.isEnabled = true
        }
        wordsBackgroundView.layer.shadowColor = UIColor.black.cgColor
        wordsBackgroundView.layer.shadowOpacity = 0.2
        wordsBackgroundView.layer.shadowOffset = .zero
        wordsBackgroundView.layer.shadowRadius = 2
        commentView.layer.cornerRadius = 10
        commentView.layer.borderWidth = 3
        dictionaryNameLabel.text = parentDictionaryData.dicName
        let foundTest = TestDataModel.tests.first(where: { $0.identifier == selectedTestIdentifier})
        testNameLabel.text = foundTest!.name
        learningLanguageLabel.text = parentDictionaryData.dicLearningLanguage
        let learnImage:String = parentDictionaryData.dicLearningLanguage!
        let translateImage:String = parentDictionaryData.dicTranslateLanguage!
        learningLanguageImage.image = UIImage(named: "\(learnImage).png")
        translateLanguageImage.image = UIImage(named: "\(translateImage).png")
        translateLanguageLabel.text = parentDictionaryData.dicTranslateLanguage
        //progressLabel.text = defaults.labelTestProgressText
        scoresNumberLabel.text = String(rightAnswers)
        nextButton.layer.cornerRadius = 10
        checkButton.layer.cornerRadius = 10
        wordsBackgroundView.layer.cornerRadius = 10
        mainWordLabel.clipsToBounds = true
        mainWordLabel.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        mainWordLabel.layer.cornerRadius = 10
        checkButton.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        nextButton.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        toResultsButton.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        toResultsButton.layer.cornerRadius = 10
    }
    
    private func pressedButtonBehavor(buttonId:Int,button:UIButton){
        for button in fourButtonsArray{
            button.isEnabled = true
            button.layer.borderWidth = 0
        }
        pressedButton = button
        button.isEnabled = false
        choiseMaided = true
        warningLabel.isHidden = true
        button.layer.borderColor = UIColor(red: 0.00, green: 0.67, blue: 1.00, alpha: 1.00).cgColor
        button.layer.borderWidth = 5
        if let isWordExists = fourImagesWordsArray[buttonId]{
            selectedImage = isWordExists
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
    
   private func buttonsBhvrTheEnd(){
        for button in fourButtonsArray{
            button.isEnabled = false
            button.backgroundColor = .clear
        }
        commentViewSettings("finish")
    }
    
   private func resultsPopUpApear(){
        let overLayerView = ResultsPopUpController()
        overLayerView.performToSegueDelegate = self
        overLayerView.didUpdateViewDelegate = self
        overLayerView.rightAnswers = rightAnswers
        overLayerView.wordsCount = wordsCount
        overLayerView.roundsNumber = roundNumber
        overLayerView.selectedDictionary = selectedDicID
        overLayerView.selectedTestIdentifier = selectedTestIdentifier
        overLayerView.appearOverlayer(sender: self)
    }
    
    private func reloadTestData(){
        choiseMaided = false
        rightAnswers = 0
        roundNumber = 0
        scoresNumberLabel.text = String(rightAnswers)
        wordsCount = 0
        progressBarProgress = 0
        progressBar.progress = Float(progressBarProgress)
        
    }
    
    func warningViewAppearAnimate(_ text:String){
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

    @IBAction func firstButtonPressed(_ sender: Any) {
        pressedButtonBehavor(buttonId: 0, button: firstButton)
    }
    
    @IBAction func secondButtonPressed(_ sender: Any) {
        pressedButtonBehavor(buttonId: 1, button: secondButton)
    }
    
    @IBAction func thirdButtonPressed(_ sender: Any) {
        pressedButtonBehavor(buttonId: 2, button: thirdButton)
    }
    
    @IBAction func fouthButtonPressed(_ sender: Any) {
        pressedButtonBehavor(buttonId: 3, button: fouthButton)
    }
    
    @IBAction func checkButtonPressed(_ sender: Any) {
        if choiseMaided{
            if mainWord == selectedImage{
                wordsCount += 1
                filteredArray[mainWordIndex].wrdRightAnswers += 1
                blockView.isHidden = false
                blockView.backgroundColor = .systemGreen
                blockView.alpha = 0.5
                commentViewSettings("right")
                nextButton.isHidden = false
                checkButton.isHidden = true
                rightAnswers += 1
                scoresNumberLabel.text = String(rightAnswers)
            } else {
                filteredArray[mainWordIndex].wrdWrongAnswers += 1
                filteredArray[mainWordIndex].wrdStatus = 2
                blockView.isHidden = false
                blockView.backgroundColor = .systemRed
                blockView.alpha = 0.5
                nextButton.isHidden = false
                checkButton.isHidden = true
                commentViewSettings("wrong")
            }
        } else {
            warningViewAppearAnimate("sharedElements_noChose_label".localized)
//            warningLabel.isHidden = false
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        let progressStepCount =  numberOfRounds
        progressBarProgress += (1.0 / Double(progressStepCount))
        progressBar.progress = Float(progressBarProgress)
        for button in fourButtonsArray{
            button.layer.borderWidth = 0
        }
        commentView.isHidden = true
        if filteredArray.count <= 4 {
            mainModel.wordsStatusClearing(array: wordsForTestArray, statusToClear: 1, data: context)
            buttonsBhvrTheEnd()
            coreDataManager.saveData(data: context)
        } else {
            blockView.isHidden = true
            testStart()
        }
    }
    
    @IBAction func toResutlsButtonPressed(_ sender: Any) {
        buttonsBhvrTheEnd()
        resultsPopUpApear()
    }
    
}
