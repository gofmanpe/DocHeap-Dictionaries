//
//  TestsController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 26.03.23.
//

import UIKit
import CoreData

class TestsController: UIViewController, PerformToSegue{
    
//MARK: - Protocols delegate functions
   // func getRoundsNumber(number: Int) {}
    
    func performToSegue(identifier: String, dicID: String, roundsNumber:Int) {
        numberOfRounds = roundsNumber
        segueIdentifier = identifier
        selectedDicID = dicID
        performSegue(withIdentifier: identifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier {
        case "fiveWordsTest":
            let destinationVC = segue.destination as! FiveWordsTestController
            destinationVC.selectedDicID = selectedDicID
            destinationVC.numberOfRounds = numberOfRounds
            destinationVC.selectedTestIdentifier = selectedTestIdentifier
        case "threeWordsTest":
            let destinationVC = segue.destination as! ThreeWordsTestController
            destinationVC.selectedDictionary = selectedDicID
            destinationVC.numberOfRounds = numberOfRounds
            destinationVC.selectedTestIdentifier = selectedTestIdentifier
        case "findAPairTest":
            let destinationVC = segue.destination as! FindAPairController
            destinationVC.selectedDicID = selectedDicID
            destinationVC.selectedTestIdentifier = selectedTestIdentifier
        case "falseOrTrueTest":
            let destinationVC = segue.destination as! FalseOrTrueTestController
            destinationVC.numberOfRounds = numberOfRounds
            destinationVC.selectedDictionary = selectedDicID
            destinationVC.selectedTestIdentifier = selectedTestIdentifier
        case "findAnImageTest":
            let destinationVC = segue.destination as! FindAnImageTestController
            destinationVC.numberOfRounds = numberOfRounds
            destinationVC.selectedDicID = selectedDicID
            destinationVC.selectedTestIdentifier = selectedTestIdentifier
        default:
            return
        }
    }
    
//MARK: - Outlets
    @IBOutlet weak var testsTable: UITableView!
    @IBOutlet weak var noDictionariesLabel: UILabel!
    @IBOutlet weak var testsLabel: UILabel!
    
    
//MARK: - Constants and variables
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var coreDataManager = CoreDataManager()
    var segueIdentifier = String()
    var selectedDicID = String()
    var selectedTestIdentifier = String()
    var numberOfRounds = Int()
    private var testsArray: [Tests] = TestDataModel.tests
    private var mainModel = MainModel()
    private var currentUserEmail = String()
 
//MARK: - Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        standartState()
        isDictionariesAvalible()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        standartState()
        isDictionariesAvalible()
    }
    
//MARK: - Controller functions
    func localizeElements(){
        
    }
    
    func isDictionariesAvalible(){
        coreDataManager.loadDictionariesForCurrentUser(userID: mainModel.loadUserData().userID, data: context)
        if coreDataManager.dictionariesArray.isEmpty{
            testsTable.isHidden = true
            noDictionariesLabel.isHidden = false
            noDictionariesLabel.text = "testVC_noDictionariesCreated_message".localized
        } else {
            testsTable.reloadData()
            testsTable.isHidden = false
            noDictionariesLabel.isHidden = true
        }
    }
    
    func standartState(){
        currentUserEmail = mainModel.loadUserData().email
        testsTable.dataSource = self
        testsTable.delegate = self
        self.navigationItem.setHidesBackButton(true, animated: false)
        testsLabel.text = "testVC_tests_label".localized
        testsTable.register(UINib(nibName: "TestNewCell", bundle: nil), forCellReuseIdentifier: "testNewCell")
    }

    func popUpApear(){
        let overLayerView = SelectDictionaryForTestController()
        overLayerView.performToSegueDelegate = self
        overLayerView.selectedTestIdentifier = selectedTestIdentifier
        overLayerView.appear(sender: self)
    }
}

//MARK: - Tests table Datasource & Delegate
extension TestsController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let testCell = testsTable.dequeueReusableCell(withIdentifier: "testCell") as! TestCell
        let testCell = testsTable.dequeueReusableCell(withIdentifier: "testNewCell") as! TestNewCell
        testCell.testName.text = testsArray[indexPath.row].name
        testCell.testImage.image = UIImage(named: testsArray[indexPath.row].image)
        testCell.testDescription.text = testsArray[indexPath.row].testDescription
        testCell.selectionStyle = .none
        return testCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTestIdentifier = testsArray[indexPath.row].identifier
        popUpApear()
    }
}
