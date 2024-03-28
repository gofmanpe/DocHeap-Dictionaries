//
//  ResultsPopUpController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 14.04.23.
//

import UIKit
import CoreData

class TestResultsPopUp: UIViewController{
    
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var firstStarImage: UIImageView!
    @IBOutlet weak var secondStarImage: UIImageView!
    @IBOutlet weak var thirdStarImage: UIImageView!
    @IBOutlet weak var fouthStarImage: UIImageView!
    @IBOutlet weak var scoresNameLabel: UILabel!
    @IBOutlet weak var testNameLabel: UILabel!
    @IBOutlet weak var scoresLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var restartTestButton: UIButton!
    @IBOutlet weak var fixMistakesButton: UIButton!
    
    private func localazeElements(){
        closeButton.setTitle("resultsPopUp_close_button".localized, for: .normal)
        restartTestButton.setTitle("resultsPopUp_restart_button".localized, for: .normal)
        scoresNameLabel.text = "resultsPopUp_scoresName_label".localized
        fixMistakesButton.setTitle("resultsPopUp_fixMistakes_button".localized, for: .normal)
    }
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var rightAnswers = Int()
    var errors = Int()
    var wordsCount = Int()
    var errorsFixed = Bool()
    var roundsNumber = Int()
    var selectedDictionary = String()
    var selectedTestIdentifier = String()
    private var raitingRatio = Double()
    var performToSegueDelegate: PerformToSegue?
    var didUpdateViewDelegate: UpdateView?
    private var statisticDataArray = [Statistic]()
    private var coreDataManager = CoreDataManager()
    private var mainModel = MainModel()
    private let firebase = Firebase()
    private var userData : UserData?
    private var testsArray: [Tests] = TestDataModel.tests
    private var errorsCount = Int()
    
    init() {
        super.init(nibName: "TestResultsPopUp", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localazeElements()
        loadData()
        elementsDesign(selectedTestIdentifier)
        starsSetting(selectedTestIdentifier)
        isErrorsExisting()
        updateUserScoresData(userID: mainModel.loadUserData().userID)
        statisticUpload()
    }
    
    func loadData(){
        userData = coreDataManager.loadUserDataByID(userID: mainModel.loadUserData().userID, context: context)
    }
    
    func updateUserScoresData(userID:String){
        let userResults = UserData(
            userID: userData!.userID,
            userName: userData!.userName,
            userBirthDate: userData!.userBirthDate,
            userCountry: userData?.userCountry ?? "",
            userAvatarFirestorePath: userData?.userAvatarFirestorePath ?? "",
            userAvatarExtention: "jpg",
            userNativeLanguage: userData?.userNativeLanguage ?? "",
            userScores: rightAnswers,
            userShowEmail: userData?.userShowEmail ?? false,
            userEmail: userData?.userEmail ?? "",
            userSyncronized: userData?.userSyncronized ?? false,
            userType: "",
            userRegisterDate: userData!.userRegisterDate,
            userInterfaceLanguage: userData?.userInterfaceLanguage ?? "",
            userMistakes: errorsCount,
            userRightAnswers: rightAnswers,
            userTestsCompleted: 1, 
            userIdentityToken: userData?.userIdentityToken ?? "")
        if mainModel.isInternetAvailable(){
            firebase.updateUserDataFirebase(userData: userResults)
            coreDataManager.updateUserDataAfterTest(userData: userResults, context: context)
            coreDataManager.updateUserFieldData(
                userID: mainModel.loadUserData().userID,
                field: "userSyncronized",
                argument: true,
                context: context)
        } else {
            coreDataManager.updateUserDataAfterTest(userData: userResults, context: context)
            coreDataManager.updateUserFieldData(
                userID: mainModel.loadUserData().userID,
                field: "userSyncronized",
                argument: false,
                context: context)
        }
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
    
    @IBAction func fixMistakesButtonPressed(_ sender: UIButton) {
        didUpdateViewDelegate?.didUpdateView(sender:"fixErrors")
        hide()
    }
    
    func isErrorsExisting(){
        switch selectedTestIdentifier{
        case "fiveWordsTest","threeWordsTest":
            let errors = wordsCount-rightAnswers
           
            if errors != 0{
                if errorsFixed{
                    fixMistakesButton.isHidden = true
                } else {
                    fixMistakesButton.isHidden = false}
            }
        case "findAPairTest", "findAnImageTest":
            fixMistakesButton.isHidden = true
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
        fixMistakesButton.isHidden = true
        let foundTest = TestDataModel.tests.first(where: { $0.identifier == selectedTestIdentifier})
        testNameLabel.text = foundTest!.name
        fixMistakesButton.layer.cornerRadius = 5
        fixMistakesButton.clipsToBounds = true
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
            errorsCount = wordsCount - rightAnswers
            messageLabel.text = String(format: NSLocalizedString("resultsPopUp_threeWordsTest_message", comment: ""), wordsCount, errorsCount)
        case "findAPairTest":
            wordsCount = 7
            scoresLabel.text = String(rightAnswers-errors)
            errorsCount = errors
            messageLabel.text = String(format: NSLocalizedString("resultsPopUp_findAPairTest_message", comment: ""), errors)
        case "falseOrTrueTest":
            scoresLabel.text = String(rightAnswers)
            errorsCount = errors
            messageLabel.text = String(format: NSLocalizedString("resultsPopUp_falseOrTrueTest_message", comment: ""), rightAnswers, errors)
        case "findAnImageTest":
            errors = roundsNumber - rightAnswers
            errorsCount = errors
            scoresLabel.text = String(rightAnswers)
            messageLabel.text = String(format: NSLocalizedString("resultsPopUp_falseOrTrueTest_message", comment: ""), rightAnswers, errors)
        default: break
        }
    }
    
    func statisticUpload(){
        let statID = mainModel.uniqueIDgenerator(prefix: "stat")
        let date = mainModel.convertDateToString(currentDate: Date(), time:true)!
        let statisticData = StatisticData(
            statID: statID,
            statDate: date,
            statMistekes: errorsCount,
            statDicID: selectedDictionary,
            statScores: rightAnswers,
            statUserID: mainModel.loadUserData().userID,
            statTestIdentifier: selectedTestIdentifier,
            statRightAnswers: rightAnswers,
            statSyncronized: true
        )
        if mainModel.isInternetAvailable(){
            coreDataManager.createStatisticRecord(statisticData: statisticData, context: context)
            firebase.createStatisticRecord(statData: statisticData)
        } else {
            coreDataManager.createStatisticRecord(statisticData: statisticData, context: context)
            coreDataManager.updateStatisticFieldData(
                statID: statID,
                field: "statSyncronized",
                argument: false,
                context: context)
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
