//
//  StatisticController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 26.03.23.
//

import UIKit
import CoreData

class StatisticController: UIViewController {

    
    @IBOutlet weak var windowDictionariesView: UIView!
    @IBOutlet weak var windowFiveWordsTestView: UIView!
    @IBOutlet weak var windowThreeWordsTestView: UIView!
    @IBOutlet weak var windowFindAPairTestView: UIView!
    @IBOutlet weak var windowFalseOrTrueTestView: UIView!
    @IBOutlet weak var windowFindAnImageTestView: UIView!
    
    @IBOutlet weak var threeWordsTestHeaderLabel: UILabel!
    @IBOutlet weak var dictionariesAndWordsHeaderLabel: UILabel!
    @IBOutlet weak var fiveWordsTestHeaderLabel: UILabel!
    @IBOutlet weak var findApairTestHeaderLabel: UILabel!
    @IBOutlet weak var falseOrTrueTestHeaderLabel: UILabel!
    @IBOutlet weak var findAnImageTestHeaderLabel: UILabel!
    
    @IBOutlet weak var pointsDictionariesCreatedLabel: UILabel!
    @IBOutlet weak var pointsWordsAddedLabel: UILabel!
    
    @IBOutlet weak var points5wtLaunchesLabel: UILabel!
    @IBOutlet weak var points5wtRightAnswersLabel: UILabel!
    @IBOutlet weak var points5wtMistakesLabel: UILabel!
    @IBOutlet weak var points5wtMistakesFixedLabel: UILabel!
    @IBOutlet weak var points5wtTotalScoresLabel: UILabel!
    
    @IBOutlet weak var points3wtLaunchesLabel: UILabel!
    @IBOutlet weak var points3wtRightAnswersLabel: UILabel!
    @IBOutlet weak var points3wtMistakesLabel: UILabel!
    @IBOutlet weak var points3wtMistakesFixedLabel: UILabel!
    @IBOutlet weak var points3wtTotalScoresLabel: UILabel!
    
    @IBOutlet weak var pointsFAPTLaunchesLabel: UILabel!
    @IBOutlet weak var pointsFAPTMistakesLabel: UILabel!
    @IBOutlet weak var pointsFAPTTotalScoresLabel: UILabel!
    
    @IBOutlet weak var pointsFOTTLaunchesLabel: UILabel!
    @IBOutlet weak var pointsFOTTMistakesLabel: UILabel!
    @IBOutlet weak var pointsFOTTTotalScoresLabel: UILabel!
    
    @IBOutlet weak var pointsFAITLaunchesLabel: UILabel!
    @IBOutlet weak var pointsFAITMistakesLabel: UILabel!
    @IBOutlet weak var pointsFAITTotalScoresLabel: UILabel!
    
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var coreDataManager = CoreDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        standartState()
        checkStatisticIsSet()
        dataForTests()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkStatisticIsSet()
        dataForTests()
    }
    
//    func isStatisticAvalable(){
//        if coreDataManager.dictionariesArray.isEmpty{
//            windowDictionariesView.isHidden = true
//            windowFiveWordsTestView.isHidden = true
//            windowThreeWordsTestView.isHidden = true
//            windowFindAPairTestView.isHidden = true
//            windowFindAnImageTestView.isHidden = true
//        }
//    }
    
    func checkStatisticIsSet(){
        coreDataManager.loadStatistics(data: context)
        if coreDataManager.fiveWordsStatisticArray.isEmpty{
            windowFiveWordsTestView.isHidden = true
        } else {
            windowFiveWordsTestView.isHidden = false
        }
        if coreDataManager.threeWordsStatisticArray.isEmpty{
            windowThreeWordsTestView.isHidden = true
        } else {
            windowThreeWordsTestView.isHidden = false
        }
        if coreDataManager.findAPairStatisticArray.isEmpty{
            windowFindAPairTestView.isHidden = true
        } else {
            windowFindAPairTestView.isHidden = false
        }
        if coreDataManager.findAnImageStatisticArray.isEmpty{
            windowFindAnImageTestView.isHidden = true
        } else {
            windowFindAnImageTestView.isHidden = false
        }
        if coreDataManager.falseOrTrueStatisticArray.isEmpty{
            windowFalseOrTrueTestView.isHidden = true
        } else {
            windowFalseOrTrueTestView.isHidden = false
        }
        if coreDataManager.dictionariesArray.isEmpty{
            windowDictionariesView.isHidden = true
        } else {
            windowDictionariesView.isHidden = false
        }
    }
    
    func standartState(){
        windowDesignUI(windowDictionariesView, dictionariesAndWordsHeaderLabel)
        windowDesignUI(windowFiveWordsTestView, fiveWordsTestHeaderLabel)
        windowDesignUI(windowThreeWordsTestView, threeWordsTestHeaderLabel)
        windowDesignUI(windowFindAPairTestView, findApairTestHeaderLabel)
        windowDesignUI(windowFalseOrTrueTestView, falseOrTrueTestHeaderLabel)
        windowDesignUI(windowFindAnImageTestView, findAnImageTestHeaderLabel)
    }
    
    func windowDesignUI(_ view:UIView,_ label:UILabel) {
        
        label.layer.cornerRadius = 10
        label.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 2
        view.layer.cornerRadius = 10
    }
    
    func dataForTests(){
        let dictionariesAndWordsData = coreDataManager.statisticDataForDictionariesAndWords(data: context)
        pointsDictionariesCreatedLabel.text = dictionariesAndWordsData["dictionaries"]
        pointsWordsAddedLabel.text = dictionariesAndWordsData["words"]
        let fiveWordsTestData = coreDataManager.statisticDataForFiveWordsTest(data: context)
        points5wtLaunchesLabel.text = String(fiveWordsTestData["fiveLaunches"]!)
        points5wtRightAnswersLabel.text = String(fiveWordsTestData["fiveRightAnswers"]!)
        points5wtMistakesLabel.text = String(fiveWordsTestData["fiveMistakes"]!)
        points5wtMistakesFixedLabel.text = String(fiveWordsTestData["fiveFixedMistakes"]!)
        points5wtTotalScoresLabel.text = String(fiveWordsTestData["fiveTotalScores"]!)
        let threeWordsTestData = coreDataManager.statisticDataForThreeWordsTest(data: context)
        points3wtLaunchesLabel.text = threeWordsTestData["launches"]
        points3wtRightAnswersLabel.text = threeWordsTestData["rightAnswers"]
        points3wtMistakesLabel.text = threeWordsTestData["mistakes"]
        points3wtMistakesFixedLabel.text = threeWordsTestData["fixedMistakes"]
        points3wtTotalScoresLabel.text = threeWordsTestData["totalScores"]
        let findAPairTestData = coreDataManager.statisticDataForFindAPairTest(data: context)
        pointsFAPTLaunchesLabel.text = findAPairTestData["launches"]
        pointsFAPTMistakesLabel.text = findAPairTestData["mistakes"]
        pointsFAPTTotalScoresLabel.text = findAPairTestData["totalScores"]
        let falseOrTrueTestData = coreDataManager.statisticDataForFalseOrTrueTest(data: context)
        pointsFOTTLaunchesLabel.text = falseOrTrueTestData["launches"]
        pointsFOTTMistakesLabel.text = falseOrTrueTestData["mistakes"]
        pointsFOTTTotalScoresLabel.text = falseOrTrueTestData["totalScores"]
        let findAnImageTestData = coreDataManager.statisticDataForFindAnImageTest(data: context)
        pointsFAITLaunchesLabel.text = findAnImageTestData["launches"]
        pointsFAITMistakesLabel.text = findAnImageTestData["mistakes"]
        pointsFAITTotalScoresLabel.text = findAnImageTestData["totalScores"]
    }
    
}

