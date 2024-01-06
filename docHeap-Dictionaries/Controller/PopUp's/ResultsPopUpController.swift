//
//  ResultsPopUpController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 14.04.23.
//

import UIKit
import CoreData

class ResultsPopUpController: UIViewController{
    
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var firstStarImage: UIImageView!
    @IBOutlet weak var secondStarImage: UIImageView!
    @IBOutlet weak var thirdStarImage: UIImageView!
    @IBOutlet weak var fouthStarImage: UIImageView!
    
    @IBOutlet weak var testNameLabel: UILabel!
    @IBOutlet weak var scoresLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var restartTestButton: UIButton!
    @IBOutlet weak var retestErrorsButton: UIButton!
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var rightAnswers = Int()
    var errors = Int()
    var wordsCount = Int()
    var errorsFixed = Bool()
    var roundsNumber = Int()
    var selectedDictionary = String()
    var selectedTestIdentifier = String()
   // var selectedTestName = String()
    var raitingRatio = Double()
    var performToSegueDelegate: PerformToSegue?
    var didUpdateViewDelegate: UpdateView?
    var statisticDataArray = [Statistic]()
    var coreDataManager = CoreDataManager()
    var mainModel = MainModel()
    private let firebase = Firebase()
    
    init() {
        super.init(nibName: "ResultsPopUpController", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  coreDataManager.loadTestData(testIdentifier: selectedTestIdentifier, data: context)
        elementsDesign(selectedTestIdentifier)
        starsSetting(selectedTestIdentifier)
        isErrorsExisting()
        statisticUpload(identifier: selectedTestIdentifier)
        coreDataManager.saveData(data: context)
        updateUserScoresData(userID: mainModel.loadUserData().userID)
    }
    
    func updateUserScoresData(userID:String){
        let userData = coreDataManager.loadUserDataByID(userID: userID, data: context)
        let existedScores =  userData.userScores
        let dataForAdd = Int64(rightAnswers - errors)
        userData.userScores = existedScores + dataForAdd
        if mainModel.isInternetAvailable(){
            firebase.updateUserDataFirebase(userData: userData)
            userData.userSyncronized = true
        } else {
            userData.userSyncronized = false
        }
        coreDataManager.saveData(data: context)
    }
    
    @IBAction func restartTestButtonPressed(_ sender: UIButton) {
        didUpdateViewDelegate?.didUpdateView(sender:"reStartTest")
        hide()
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        switch selectedTestIdentifier{
        case "fiveWordsTest":
            performToSegueDelegate?.performToSegue(identifier: "backToTestsList5", dicID: "", roundsNumber:0)
            hide()
        case "threeWordsTest":
            performToSegueDelegate?.performToSegue(identifier: "backToTestsList3", dicID: "", roundsNumber:0)
            hide()
        case "findAPairTest":
            performToSegueDelegate?.performToSegue(identifier: "backToTestsListP", dicID: "", roundsNumber:0)
            hide()
        case "falseOrTrueTest":
            performToSegueDelegate?.performToSegue(identifier: "backToTestsListFOT", dicID: "", roundsNumber:0)
            hide()
        case "findAnImageTest":
            performToSegueDelegate?.performToSegue(identifier: "backToTestsListFIT", dicID: "", roundsNumber:0)
            hide()
        default: break
        }
    }
    
    @IBAction func retestErrorsButtonPressed(_ sender: UIButton) {
        didUpdateViewDelegate?.didUpdateView(sender:"fixErrors")
        hide()
    }
    
    func isErrorsExisting(){
        switch selectedTestIdentifier{
        case "fiveWordsTest","threeWordsTest":
            let errors = wordsCount-rightAnswers
           
            if errors != 0{
                if errorsFixed{
                    retestErrorsButton.isHidden = true
                } else {
                    retestErrorsButton.isHidden = false}
            }
        case "findAPairTest", "findAnImageTest":
            retestErrorsButton.isHidden = true
        default: break
        }
    }
    
    func appearOverlayer(sender: UIViewController) {
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
    
    func elementsDesign(_ identifier:String){
        retestErrorsButton.isHidden = true
        let foundTest = TestDataModel.tests.first(where: { $0.identifier == selectedTestIdentifier})
        testNameLabel.text = foundTest!.name
        retestErrorsButton.layer.cornerRadius = 5
        retestErrorsButton.clipsToBounds = true
        mainView.clipsToBounds = true
        mainView.layer.cornerRadius = 10
        headerView.clipsToBounds = true
        headerView.layer.cornerRadius = 10
        headerView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        background.backgroundColor = .black.withAlphaComponent(0.6)
        restartTestButton.layer.cornerRadius = 10
        restartTestButton.layer.maskedCorners = [.layerMinXMaxYCorner]
        closeButton.layer.cornerRadius = 10
        closeButton.layer.maskedCorners = [.layerMaxXMaxYCorner]
        background.alpha = 0
        mainView.alpha = 0
        switch identifier{
        case "threeWordsTest","fiveWordsTest":
            scoresLabel.text = String(rightAnswers)
            let errorsCount = wordsCount - rightAnswers
            messageLabel.text = "Finished \(wordsCount) rounds \n with \(errorsCount) mistakes"
        case "findAPairTest":
            wordsCount = 7
            scoresLabel.text = String(rightAnswers-errors)
            messageLabel.text = "Finded \(String(rightAnswers)) pairs \n with \(String(errors)) mistakes"
        case "falseOrTrueTest":
            scoresLabel.text = String(rightAnswers)
            messageLabel.text = "Totaly \(String(rightAnswers)) right answers \n and \(String(errors)) mistakes"
        case "findAnImageTest":
            errors = roundsNumber - rightAnswers
            scoresLabel.text = String(rightAnswers)
            messageLabel.text = "Selected \(String(rightAnswers)) right images \n with \(String(errors)) mistakes"
        default: break
        }
    }
    
    func statisticUpload(identifier:String){
        switch identifier{
        case "findAnImageTest":
            //selectedTestName = coreDataManager.selectedTestData.first!.name!
            let newStatisticData = FindAnImageTestStatistic(context: context)
            //newStatisticData.testMethod = "Test"
            newStatisticData.testingDictionaryName = selectedDictionary
            newStatisticData.testDate = mainModel.convertDateToString(currentDate: Date(), time: true)
            //newStatisticData.testRatingRatio = Int64(raitingRatio)
            newStatisticData.scores = Int64(rightAnswers)
            newStatisticData.mistakes = Int64(errors)
            //newStatisticData.testMistakesFixing = false
        case "findAPairTest":
            //selectedTestName = coreDataManager.selectedTestData.first!.name!
            let newStatisticData = FindAPairTestStatistic(context: context)
            //newStatisticData.testMethod = "Test"
            newStatisticData.testingDictionaryName = selectedDictionary
            newStatisticData.testDate = mainModel.convertDateToString(currentDate: Date(), time: true)
            //newStatisticData.testRatingRatio = Int64(raitingRatio)
            newStatisticData.scores = Int64(rightAnswers)
            newStatisticData.mistakes = Int64(errors)
            //newStatisticData.testMistakesFixing = false
        case "falseOrTrueTest":
            //selectedTestName = coreDataManager.selectedTestData.first!.name!
            let newStatisticData = FalseOrTrueTestStatistic(context: context)
            //newStatisticData.testMethod = "Test"
            newStatisticData.testingDictionaryName = selectedDictionary
            newStatisticData.testDate = mainModel.convertDateToString(currentDate: Date(), time: true)
            //newStatisticData.testRatingRatio = Int64(raitingRatio)
            newStatisticData.scores = Int64(rightAnswers)
            newStatisticData.mistakes = Int64(errors)
            //newStatisticData.testMistakesFixing = false
        case "fiveWordsTest":
            if errorsFixed{
                //selectedTestName = coreDataManager.selectedTestData.first!.name!
                let newStatisticData = FiveWordsTestStatistic(context: context)
                newStatisticData.testMethod = "Fixing"
                //newStatisticData.testMistakesFixing = true
                newStatisticData.testingDictionaryName = selectedDictionary
                newStatisticData.testDate = mainModel.convertDateToString(currentDate: Date(), time: true)
                newStatisticData.scores = Int64(rightAnswers)
            } else{
                //selectedTestName = coreDataManager.selectedTestData.first!.name!
                let newStatisticData = FiveWordsTestStatistic(context: context)
                newStatisticData.testMethod = "Test"
                //newStatisticData.testMistakesFixing = false
                newStatisticData.testingDictionaryName = selectedDictionary
                newStatisticData.testDate = mainModel.convertDateToString(currentDate: Date(), time: true)
                //newStatisticData.testRatingRatio = Int64(raitingRatio)
                newStatisticData.scores = Int64(rightAnswers)
                newStatisticData.mistakes = Int64(wordsCount-rightAnswers)
            }
        case "threeWordsTest":
            if errorsFixed{
                let newStatisticData = ThreeWordsTestStatistic(context: context)
                newStatisticData.testMethod = "Fixing"
                newStatisticData.testingDictionaryName = selectedDictionary
                newStatisticData.testDate = mainModel.convertDateToString(currentDate: Date(), time: true)
                newStatisticData.scores = Int64(rightAnswers)
            } else{
                let newStatisticData = ThreeWordsTestStatistic(context: context)
                newStatisticData.testMethod = "Test"
                newStatisticData.testingDictionaryName = selectedDictionary
                newStatisticData.testDate = mainModel.convertDateToString(currentDate: Date(), time: true)
                newStatisticData.scores = Int64(rightAnswers)
                newStatisticData.mistakes = Int64(wordsCount-rightAnswers)
            }
        default:break
        }
        
    }
 
    
    func starsSetting(_ testId:String){
        switch testId {
        case "fiveWordsTest", "threeWordsTest":
            raitingRatio = (Double(rightAnswers)/Double(wordsCount)) * 100.00
        case "findAPairTest":
            raitingRatio = (Double(rightAnswers-errors)/7.00) * 100.00
        case "falseOrTrueTest", "findAnImageTest":
            raitingRatio = (Double(rightAnswers)/Double(roundsNumber)) * 100.00
        default:break
        }
        switch Int(raitingRatio) {
            case 0...5:
                firstStarImage.tintColor = .systemGray2
                secondStarImage.tintColor = .systemGray2
                thirdStarImage.tintColor = .systemGray2
                fouthStarImage.tintColor = .systemGray2
            case 6...25:
                firstStarImage.tintColor = .systemYellow
                secondStarImage.tintColor = .systemGray2
                thirdStarImage.tintColor = .systemGray2
                fouthStarImage.tintColor = .systemGray2
            case 26...50:
                firstStarImage.tintColor = .systemYellow
                secondStarImage.tintColor = .systemYellow
                thirdStarImage.tintColor = .systemGray2
                fouthStarImage.tintColor = .systemGray2
            case 51...75:
                firstStarImage.tintColor = .systemYellow
                secondStarImage.tintColor = .systemYellow
                thirdStarImage.tintColor = .systemYellow
                fouthStarImage.tintColor = .systemGray2
            case 76...100:
                firstStarImage.tintColor = .systemYellow
                secondStarImage.tintColor = .systemYellow
                thirdStarImage.tintColor = .systemYellow
                fouthStarImage.tintColor = .systemYellow
            default: return
            }
    }
}
