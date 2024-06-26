//
//  FalseOrTrueTestController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 29.06.23.
//

import UIKit

class FalseOrTrueTestController: UIViewController, PerformToSegue, UpdateView {
  
    func didUpdateView(sender: String) {
        coreDataManager.loadWordsForSelectedDictionary(dicID: coreDataManager.parentDictionaryData.first?.dicID ?? "", userID: mainModel.loadUserData().userID, context: context)
        coreDataManager.loadParentDictionaryData(dicID: selectedDictionary, userID: mainModel.loadUserData().userID, data: context)
        standartState()
        mainModel = MainModel()
        reloadTestData()
        falseOrTrueTestStart()
    }
    
    func performToSegue(identifier: String, dicID: String, roundsNumber:Int) {
        numberOfRounds = roundsNumber
        performSegue(withIdentifier: identifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        _ = segue.destination as! TestsController
    }

    @IBOutlet weak var testNameLabel: UILabel!
    @IBOutlet weak var dictionaryNameLabel: UILabel!
    @IBOutlet weak var learningImage: UIImageView!
    @IBOutlet weak var translationImage: UIImageView!
    @IBOutlet weak var learningLanguageLabel: UILabel!
    @IBOutlet weak var translationLanguageLabel: UILabel!
    @IBOutlet weak var roundNumberLabel: UILabel!
    @IBOutlet weak var scoresLabel: UILabel!
    @IBOutlet weak var roundNameLabel: UILabel!
    @IBOutlet weak var scoresNameLabel: UILabel!
    @IBOutlet weak var testProgressLabel: UILabel!
    @IBOutlet weak var instructionLabel: UILabel!
    
    @IBOutlet weak var wordsBackgroundView: UIView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var header: UIStackView!
    @IBOutlet weak var trueButton: UIButton!
    @IBOutlet weak var falseButton: UIButton!
    @IBOutlet weak var toResultsButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentImage: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var blockView: UIView!
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    private func localizeElements(){
        roundNameLabel.text = "trueOrFalseTestVC_roundName_label".localized
        scoresNameLabel.text = "trueOrFalseTestVC_scoresName_label".localized
        instructionLabel.text = "trueOrFalseTestVC_instruction_label".localized
        testProgressLabel.text = "trueOrFalseTestVC_testProgress_label".localized
        trueButton.setTitle("trueOrFalseTestVC_true_button".localized, for: .normal)
        falseButton.setTitle("trueOrFalseTestVC_false_button".localized, for: .normal)
        nextButton.setTitle("trueOrFalseTestVC_next_button".localized, for: .normal)
        toResultsButton.setTitle("trueOrFalseTestVC_toResults_button".localized, for: .normal)
    }
    
    private var filteredArray = [Word]()
    private var mainWordIndex = Int()
    private var mainWord = String()
    private var mainWordTranslation = String()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedDictionary = String()
    var selectedTestIdentifier = String()
    private  var scores = 0
    private var mistakes = 0
    private var roundsNumber = 0
    private var rightWord = String()
    private var rightTranslation = String()
    private var randomTranslation = String()
    private var rightAnswer = 2
    private var coreDataManager = CoreDataManager()
    private var mainModel = MainModel()
    private let defaults = Defaults()
    var numberOfRounds = Int()
    private var progressBarProgress = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeElements()
        elementsDesign()
        coreDataManager.loadParentDictionaryData(dicID: selectedDictionary, userID: mainModel.loadUserData().userID, data: context)
        coreDataManager.loadWordsForSelectedDictionary(dicID: coreDataManager.parentDictionaryData.first?.dicID ?? "", userID: mainModel.loadUserData().userID, context: context)
        mainModel.wordsStatusClearing(array: coreDataManager.wordsArray, statusToClear: 0, data: context)
        falseOrTrueTestStart()
    }
    
    private func standartState(){
        resultLabel.text = " "
        blockView.isHidden = true
        commentView.isHidden = true
        toResultsButton.isHidden = true
        trueButton.isHidden = false
        falseButton.isHidden = false
        nextButton.isHidden = true
        dictionaryNameLabel.text = coreDataManager.parentDictionaryData.first?.dicName
        learningLanguageLabel.text = coreDataManager.parentDictionaryData.first?.dicLearningLanguage
        translationLanguageLabel.text = coreDataManager.parentDictionaryData.first?.dicTranslateLanguage
        let foundTest = TestDataModel.tests.first(where: { $0.identifier == selectedTestIdentifier})
        testNameLabel.text = foundTest!.name
        let learnImage = coreDataManager.parentDictionaryData.first!.dicLearningLanguage!
        let translateImage = coreDataManager.parentDictionaryData.first!.dicTranslateLanguage!
        learningImage.image = UIImage(named: "\(learnImage)")
        translationImage.image = UIImage(named: "\(translateImage)")
    }
    
    private func elementsDesign(){
        wordsBackgroundView.layer.cornerRadius = 10
    }
    
    func falseOrTrueTestStart(){
        standartState()
        let wordsArray = coreDataManager.wordsArray
        let wordsNumber = numberOfRounds
        let arrayOfWords = Array(wordsArray.prefix(wordsNumber))
        filteredArray = arrayOfWords.filter({$0.wrdStatus == 0})
        mainWordIndex = Int.random(in: 0..<filteredArray.count)
        mainWord = filteredArray[mainWordIndex].wrdWord ?? "no word"
        mainWordTranslation = filteredArray[mainWordIndex].wrdTranslation ?? "no translation"
        randomTranslation = filteredArray.randomElement()?.wrdTranslation ?? "none"
        filteredArray[mainWordIndex].wrdStatus = 1
        if !filteredArray.isEmpty{
            wordLabel.text = mainWord
            translationLabel.text = randomTranslation
            roundsNumber += 1
            roundNumberLabel.text = String(roundsNumber)
            if mainWordTranslation == randomTranslation{
                rightAnswer = 1
            } else {
                rightAnswer = 0
            }
        } else {
            commentViewSettings("finish")
            trueButton.isHidden = true
            falseButton.isHidden = true
            toResultsButton.isHidden = false
        }
    }
   
    private func commentViewSettings(_ feedback:String){
        commentView.layer.cornerRadius = 10
        commentView.layer.borderWidth = 3
        switch feedback {
        case "right":
            resultLabel.text = "trueOrFalseTestVC_true_button".localized
            scores += 1
            blockView.isHidden = false
            blockView.backgroundColor = .systemGreen
            blockView.alpha = 0.5
            commentView.isHidden = false
            commentLabel.isHidden = false
            commentImage.image = UIImage(named: "done.png")
            commentView.layer.borderColor = UIColor(red: 0.20, green: 0.60, blue: 0.35, alpha: 1.00).cgColor
            commentLabel.textColor = UIColor(red: 0.20, green: 0.60, blue: 0.35, alpha: 1.00)
            commentLabel.text = defaults.rightCommentsArray.randomElement()
            commentView.backgroundColor = UIColor(red: 0.93, green: 1.00, blue: 0.95, alpha: 1.00)
        case "wrong":
            resultLabel.text = "trueOrFalseTestVC_false_button".localized
            mistakes += 1
            blockView.isHidden = false
            blockView.backgroundColor = .systemRed
            blockView.alpha = 0.5
            commentLabel.textColor = UIColor(red: 0.87, green: 0.00, blue: 0.00, alpha: 1.00)
            commentLabel.text = defaults.wrongCommentsArray.randomElement()
            commentView.layer.borderColor = UIColor(red: 0.87, green: 0.00, blue: 0.00, alpha: 1.00).cgColor
            commentImage.image = UIImage(named: "stop.png")
            commentView.isHidden = false
            commentLabel.isHidden = false
            commentView.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 1.00, alpha: 1.00)
        case "finish":
            nextButton.isHidden = true
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
    
    private func reloadTestData(){
        scoresLabel.text = String(0)
        progressLabel.text = defaults.labelTestProgressText
        roundsNumber = 0
        roundNumberLabel.text = String(roundsNumber)
        mistakes = 0
        scores = 0
        progressBarProgress = 0
        progressBar.progress = Float(progressBarProgress)
    }
    
    
    @IBAction func trueButtonPressed(_ sender: Any) {
        switch rightAnswer{
        case 0:
            commentViewSettings("wrong")
            trueButton.isHidden = true
            falseButton.isHidden = true
            nextButton.isHidden = false
        case 1:
            commentViewSettings("right")
            scoresLabel.text = String(scores)
            trueButton.isHidden = true
            falseButton.isHidden = true
            nextButton.isHidden = false
        case 2:
            print("ERROR")
        default: break
        }
    }
    
    @IBAction func falseButtonPressed(_ sender: Any) {
        switch rightAnswer{
        case 0:
            commentViewSettings("right")
            scoresLabel.text = String(scores)
            trueButton.isHidden = true
            falseButton.isHidden = true
            nextButton.isHidden = false
        case 1:
            commentViewSettings("wrong")
            trueButton.isHidden = true
            falseButton.isHidden = true
            nextButton.isHidden = false
        case 2:
            print("ERROR")
        default: break
        }
    }
    
    @IBAction func toResultsButtonPressed(_ sender: Any) {
        let overLayerView = TestResultsPopUp()
        overLayerView.performToSegueDelegate = self
        overLayerView.didUpdateViewDelegate = self
        overLayerView.rightAnswers = scores
        overLayerView.roundsNumber = roundsNumber
        overLayerView.errors = mistakes
        overLayerView.selectedDictionary = selectedDictionary
        overLayerView.selectedTestIdentifier = selectedTestIdentifier
        overLayerView.appearOverlayer(sender: self)
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        let progressStepCount =  numberOfRounds
        progressBarProgress += (1.0 / Double(progressStepCount))
        progressBar.progress = Float(progressBarProgress)
        if filteredArray.count <= 1 {
            mainModel.wordsStatusClearing(array: coreDataManager.wordsArray, statusToClear: 1, data: context)
            commentViewSettings("finish")
            coreDataManager.saveData(data: context)
        } else {
            blockView.isHidden = true
            falseOrTrueTestStart()
        }
    }
}

