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
        
        coreDataManager.loadParentDictionaryData(dicID: selectedDictionary, userID: mainModel.loadUserData().userID, data: context)
        coreDataManager.loadWordsForSelectedDictionary(dicID: coreDataManager.parentDictionaryData.first?.dicID ?? "", userID: mainModel.loadUserData().userID, data: context)
       // coreDataManager.loadTestData(testIdentifier: selectedTestIdentifier, data: context)
        standartState()
        mainModel.wordsStatusClearing(array: coreDataManager.wordsArray, statusToClear: 1, data: context)
        mainModel.wordsStatusClearing(array: coreDataManager.wordsArray, statusToClear: 2, data: context)
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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fourImagesWordsArray = [String?]()
    var fourImagesPathArray = [String]()
    var mainWord = String()
    var mainWordImage = String()
    var filteredArray = [Word]()
    var mainWordIndex = Int()
    var numberOfRounds = Int()
    var selectedDictionary = String()
    var selectedTestIdentifier = String()
    var wordsArray = [Word]()
    var wordsWithImagesArray = [Word]()
    var wordsCount = Int()
    var fourButtonsArray = [UIButton]()
    var pressedButton = UIButton()
    var choiseMaided = Bool()
    var selectedImage = String()
    var rightAnswers = 0
    var roundNumber = 0
    private var defaults = Defaults()
    private var mainModel = MainModel()
    private var coreDataManager = CoreDataManager()
    private var currentUserEmail = String()
    private var dicID = String()
   // private var selectedTestName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coreDataManager.loadWordsWithImagesForSelectedDictionary(data: context, dicID: selectedDictionary)
       // coreDataManager.loadTestData(testIdentifier: selectedTestIdentifier, data: context)
        coreDataManager.loadParentDictionaryData(dicID: selectedDictionary, userID: mainModel.loadUserData().userID, data: context)
        mainModel.wordsStatusClearing(array: coreDataManager.wordsArray, statusToClear: 0, data: context)
        //mainModel.findAnImageTestEngine(arrayOfImages: coreDataManager.wordsWithImagesArray)
        standartState()
        testStart()
    }
    
    func testStart(){
        
        fourImagesWordsArray.removeAll() // clearing array of translations
        fourImagesPathArray.removeAll()
       // let arrayOfWords = coreDataManager.wordsArray
        let wordsArray = coreDataManager.wordsArray
        let wordsNumber = numberOfRounds + 3
        let arrayOfWords = Array(wordsArray.prefix(wordsNumber))
        let filteredByImageArray = arrayOfWords.filter({$0.wrdImageIsSet == true}) // filtering an array of words by image status 1
        filteredArray = filteredByImageArray.filter({$0.wrdStatus == 0})
        mainWordIndex = Int.random(in: 0..<filteredArray.count) // randomizing select the main testing word index
        filteredArray[mainWordIndex].wrdStatus = 1 // setting status 1 to the main testing word (for avoid repeating)
        
        
        let queryResult = mainModel.findAnImageTestEngine(arrayOfWords: filteredArray, mainWordIndex: mainWordIndex)
        mainWord = queryResult.0
        mainWordImage = queryResult.1
        fourImagesWordsArray = queryResult.2
        fourImagesPathArray = queryResult.3
       
        roundNumber += 1
        roundNumberLabel.text = String(roundNumber)
        standartState()

        mainWordLabel.text = mainWord
       // let documentsDirectory = mainModel.getDocumentsFolderPath()//FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
       // let userCatalog = mainModel.loadUserEmail().email
        for i in 0...3 {
            let filePath = "\(mainModel.loadUserData().userID)/\(dicID)/\(fourImagesPathArray[i])"
            let image = UIImage(contentsOfFile:  mainModel.getDocumentsFolderPath().appendingPathComponent(filePath).path)
            fourButtonsArray[i].setImage(image, for: .normal)
        }
    }
    
   
    func standartState(){
        blockView.isHidden = true
        commentView.isHidden = true
        nextButton.isHidden = true
        checkButton.isHidden = false
        toResultsButton.isHidden = true
        warningLabel.isHidden = true
        currentUserEmail = mainModel.loadUserData().email
        dicID = coreDataManager.parentDictionaryData.first!.dicID!
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
        dictionaryNameLabel.text = coreDataManager.parentDictionaryData.first?.dicName
        let foundTest = TestDataModel.tests.first(where: { $0.identifier == selectedTestIdentifier})
        testNameLabel.text = foundTest!.name
        learningLanguageLabel.text = coreDataManager.parentDictionaryData.first?.dicLearningLanguage
        let learnImage:String = coreDataManager.parentDictionaryData.first!.dicLearningLanguage!
        let translateImage:String = coreDataManager.parentDictionaryData.first!.dicTranslateLanguage!
        learningLanguageImage.image = UIImage(named: "\(learnImage).png")
        translateLanguageImage.image = UIImage(named: "\(translateImage).png")
        translateLanguageLabel.text = coreDataManager.parentDictionaryData.first?.dicTranslateLanguage
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
    
    func pressedButtonBehavor(buttonId:Int,button:UIButton){
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
    
    func buttonsBhvrTheEnd(){
        for button in fourButtonsArray{
            button.isEnabled = false
            button.backgroundColor = .clear
        }
        commentViewSettings("finish")
        
      //  progressLabel.text = defaults.labelTestProgressText
    }
    
    func resultsPopUpApear(){
        let overLayerView = ResultsPopUpController()
        overLayerView.performToSegueDelegate = self
        overLayerView.didUpdateViewDelegate = self
        overLayerView.rightAnswers = rightAnswers
        overLayerView.wordsCount = wordsCount
        overLayerView.roundsNumber = roundNumber
        //overLayerView.errorsFixed = errorsFixed
        overLayerView.selectedDictionary = selectedDictionary
        overLayerView.selectedTestIdentifier = selectedTestIdentifier
        overLayerView.appearOverlayer(sender: self)
    }
    
    func reloadTestData(){
        choiseMaided = false
        rightAnswers = 0
        roundNumber = 0
        scoresNumberLabel.text = String(rightAnswers)
        wordsCount = 0
//        progressLabel.text = defaults.labelTestProgressText
//        progressBarProgress = 0
//        progressBar.progress = Float(progressBarProgress)
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
              //  answer = true
                wordsCount += 1
                filteredArray[mainWordIndex].wrdRightAnswers += 1
//                pressedButton.layer.borderWidth = 0
//                pressedButton.layer.cornerRadius = 10
//                pressedButton.layer.borderColor = UIColor(red: 0.00, green: 0.80, blue: 0.00, alpha: 1.00).cgColor
//                pressedButton.backgroundColor = .clear
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
//                pressedButton.layer.borderWidth = 0
//                pressedButton.layer.cornerRadius = 10
//                pressedButton.layer.borderColor = UIColor(red: 0.87, green: 0.00, blue: 0.00, alpha: 1.00).cgColor
//                pressedButton.backgroundColor = .clear
                blockView.isHidden = false
                blockView.backgroundColor = .systemRed
                blockView.alpha = 0.5
                nextButton.isHidden = false
                checkButton.isHidden = true
                commentViewSettings("wrong")
            }
        } else {
            warningLabel.isHidden = false
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        for button in fourButtonsArray{
            button.layer.borderWidth = 0
        }
        commentView.isHidden = true
        if filteredArray.count <= 4 {
            mainModel.wordsStatusClearing(array: coreDataManager.wordsArray, statusToClear: 1, data: context)
            buttonsBhvrTheEnd()
            coreDataManager.saveData(data: context)
        } else {
//            for button in fourButtonsArray{
//                button.isEnabled = true
//            }
            blockView.isHidden = true
            testStart()
        }
    }
    
    @IBAction func toResutlsButtonPressed(_ sender: Any) {
        buttonsBhvrTheEnd()
        resultsPopUpApear()
    }
    
}
