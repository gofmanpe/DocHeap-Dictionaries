//
//  StatisticController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 26.03.23.
//

import UIKit
import CoreData

class StatisticController: UIViewController {
    
    @IBOutlet weak var statisticTable: UITableView!
    @IBOutlet weak var totalLaunchesLabel: UILabel!
    @IBOutlet weak var totalRightAnswersLabel: UILabel!
    @IBOutlet weak var totalMistakesLabel: UILabel!
    @IBOutlet weak var totalScoresLabel: UILabel!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var noStatisticLabel: UILabel!
    @IBOutlet weak var totalyLabel: UILabel!
    @IBOutlet weak var startsLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var wrongLabel: UILabel!
    @IBOutlet weak var scoresLabel: UILabel!
    @IBOutlet weak var statisticLabel: UILabel!
    
    func localizeElements(){
        totalyLabel.text = "statisticVC_totaly_label".localized
        startsLabel.text = "statisticVC_starts_label".localized
        rightLabel.text = "statisticVC_right_label".localized
        wrongLabel.text = "statisticVC_wrong_label".localized
        scoresLabel.text = "statisticVC_scores_label".localized
        statisticLabel.text = "statisticVC_statistic_label".localized
    }
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var coreDataManager = CoreDataManager()
    private let mainModel = MainModel()
    private var statisticArray = [StatisticForTest]()
    private var totalLaunches = Int()
    private var totalRightAnswers = String()
    private var totalMistakes = String()
    private var totalScores = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        controllerSetup()
        localizeElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        controllerSetup()
        statisticTable.reloadData()
    }
    
    private func controllerSetup(){
        statisticTable.register(UINib(nibName: "StatisticCell", bundle: nil), forCellReuseIdentifier: "statisticCell")
        statisticTable.dataSource = self
        statisticTable.delegate = self
        totalLaunchesLabel.text = String(totalLaunches)
        totalRightAnswersLabel.text = totalRightAnswers
        totalMistakesLabel.text = totalMistakes
        totalScoresLabel.text = totalScores
        
    }
    
    private func loadData(){
        statisticArray.removeAll()
        let allStatistic = coreDataManager.loadAllStatisticForUser(userID: mainModel.loadUserData().userID, context: context)
        if allStatistic.count < 1 {
            statisticTable.isHidden = true
            totalView.isHidden = true
            noStatisticLabel.isHidden = false
            noStatisticLabel.text = "statisticVC_noStatistic_label".localized
        } else {
            statisticTable.isHidden = false
            totalView.isHidden = false
            noStatisticLabel.isHidden = true
            let testsIdArray = TestDataModel.tests.map { $0.identifier }
            for test in testsIdArray{
                let testImage = TestDataModel.tests.filter({$0.identifier == test}).first?.image
                let testsArray = allStatistic.filter({$0.statTestIdentifier == test})
                let totalScores = testsArray.reduce(0) { $0 + $1.statScores }
                let toatlMistakes = testsArray.reduce(0) { $0 + $1.statMistekes }
                let totalRightAnswers = testsArray.reduce(0) { $0 + $1.statRightAnswers }
                let totalCount = testsArray.count
                let statData = StatisticForTest(
                    statTestImage: testImage ?? "NOTESTIMAGE",
                    statRightAnswers: totalRightAnswers,
                    statMistakes: toatlMistakes,
                    statLaunches: totalCount,
                    statScores: totalScores)
                switch totalCount{
                case  0:
                    continue
                default:
                    statisticArray.append(statData)
                }
            }
            totalLaunches = allStatistic.count
            totalRightAnswers = String(allStatistic.reduce(0) {$0 + $1.statRightAnswers})
            totalMistakes = String(allStatistic.reduce(0) {$0 + $1.statMistekes})
            totalScores = String(allStatistic.reduce(0) {$0 + $1.statScores})
        }
        }
       

}

extension StatisticController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statisticArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let statCell = statisticTable.dequeueReusableCell(withIdentifier: "statisticCell", for: indexPath) as! StatisticCell
        statCell.launchesLabel.text = String(statisticArray[indexPath.row].statLaunches)
        statCell.mistakesLabel.text = String(statisticArray[indexPath.row].statMistakes)
        statCell.rightAnswersLabel.text = String(statisticArray[indexPath.row].statRightAnswers)
        statCell.scoresLabel.text = String(statisticArray[indexPath.row].statScores)
        statCell.testImage.image = UIImage(named: statisticArray[indexPath.row].statTestImage)
        return statCell
    }
}

