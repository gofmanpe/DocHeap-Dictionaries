//
//  NetworkViewController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 16.12.23.
//

import UIKit
import Firebase
import CoreData
import MBProgressHUD

class NetworkViewController: UIViewController, GetFilteredData, SetDownloadedMarkToDictionary{
    func dictionaryWasDownloaded(dicID: String) {
        if let index = sharedDictionaries.firstIndex(where: { $0.dicID == dicID }) {
            sharedDictionaries[index].dicDownloaded = true
        }
        sharedDictionaries = sharedDictionaries.filter({$0.dicDownloaded == false})
    }
    
    func setDataAfterFilter(array: [SharedDictionary], learnLang: String, transLang: String, clear:Bool) {
        learnFilterImage.layer.cornerRadius = 5
        transFilterImage.layer.cornerRadius = 5
        if clear{
            filterIsSet = false
            showHUD()
            fetchData { success in
                self.hideHUD()
                if success {
                } else {
                    print("Failed to load data.")
                }
            }
            sharedTable.dataSource = self
            sharedTable.delegate = self
            sharedTable.reloadData()
            learnFilterImage.image = UIImage(named: "noFlagTransp")
            transFilterImage.image = UIImage(named: "noFlagTransp")
            selectedLearnFromDelegate = String()
            selectedTransFromDelegate = String()
        }
        switch (learnLang.isEmpty, transLang.isEmpty){
        case (false,false),(false,true),(true,false):
            if learnLang.isEmpty {
                learnFilterImage.image = UIImage(named: "noFlagTransp")
            } else {
                learnFilterImage.image = UIImage(named: learnLang)
                filterIsSet = true
            }
            if transLang.isEmpty {
                transFilterImage.image = UIImage(named: "noFlagTransp")
            } else {
                transFilterImage.image = UIImage(named: transLang)
                filterIsSet = true
            }
            if !transLang.isEmpty && !learnLang.isEmpty{
                learnFilterImage.image = UIImage(named: learnLang)
                transFilterImage.image = UIImage(named: transLang)
                filterIsSet = true
            }
                selectedTransFromDelegate = transLang
                selectedLearnFromDelegate = learnLang
                sharedDictionaries = array
                sharedTable.reloadData()
        case (true,true):
            selectedLearnFromDelegate = String()
            selectedTransFromDelegate = String()
            sharedTable.reloadData()
            return
        }
    }
   
    @IBOutlet weak var noInetView: UIView!
    @IBOutlet weak var sharedTable: UITableView!
    @IBOutlet weak var useFilterButton: UIButton!
    @IBOutlet weak var currentFilterLabel: UILabel!
    @IBOutlet weak var learnFilterImage: UIImageView!
    @IBOutlet weak var transFilterImage: UIImageView!
    
    
    private let firebase = Firebase()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var sharedDictionaries = [SharedDictionary]()
    private var filteredDictionaries = [SharedDictionary]()
    private var originalArray = [SharedDictionary]()
    private var sharedWords = [SharedWord]()
    private let mainModel = MainModel()
    private let coreData = CoreDataManager()
    private var userDictionaries = [Dictionary]()
    private var dicOwnerData = [DicOwnerData]()
    private var defaults = Defaults()
    private var selectedLearnFromDelegate = String()
    private var selectedTransFromDelegate = String()
    private var filterIsSet = Bool()
    private var messagesArray : [ChatMessage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if mainModel.isInternetAvailable(){
            sharedTable.isHidden = false
            noInetView.isHidden = true
            sharedTable.dataSource = self
            sharedTable.delegate = self
            sharedTable.reloadData()
           // loadAllMessages()
        } else {
            noInetView.isHidden = false
            sharedTable.isHidden = true
        }
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if mainModel.isInternetAvailable(){
            standartState()
            if !filterIsSet{
                showHUD()
                fetchData { success in
                    self.hideHUD()
                    if success {
                    self.getWords(dicArray: self.sharedDictionaries)
                    } else {
                        print("Failed to load data.")
                    }
                }
            }
            isFilterSet()
            sharedTable.dataSource = self
            sharedTable.delegate = self
            sharedTable.reloadData()
        } else {
            noInetView.isHidden = false
            sharedTable.isHidden = true
        }
    }
    
    func isFilterSet(){
        switch (selectedLearnFromDelegate.isEmpty,selectedTransFromDelegate.isEmpty){
        case (true,true):
            return
        case (false,true):
            let filteredArray = sharedDictionaries.filter({$0.dicLearnLang == selectedLearnFromDelegate})
            sharedDictionaries = filteredArray
        case (true,false):
            let filteredArray = sharedDictionaries.filter({$0.dicTransLang == selectedTransFromDelegate})
            sharedDictionaries = filteredArray
        case (false,false):
            let filteredArray = sharedDictionaries.filter({$0.dicTransLang == selectedTransFromDelegate && $0.dicTransLang == selectedTransFromDelegate})
            sharedDictionaries = filteredArray
        }
    
    }
    
    func loadAllMessages(){
        firebase.getAllMessages(completion: { messArray in
            self.messagesArray = messArray
        })
    }
    
    func standartState(){
        sharedTable.isHidden = false
        noInetView.isHidden = true
        useFilterButton.layer.cornerRadius = 5
    }
    
    func getDataFromFirestore(){
        let db = Firestore.firestore()
        db.collection("Dictionaries").whereField("dicShared", isEqualTo: true).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else { 
                self.userDictionaries = self.coreData.loadUserDictionaries(userID: self.mainModel.loadUserData().userID, data: self.context)
                self.sharedDictionaries.removeAll()
                self.originalArray.removeAll()
                for document in querySnapshot!.documents {
                    let dicData = document.data()
                    let dicID = dicData["dicID"] as? String ?? "NO_dicID"
                    let filteredUserDictionaries = self.userDictionaries.filter({$0.dicID == dicID})
                    if filteredUserDictionaries.isEmpty{
                        if let dicName = dicData["dicName"] as? String,
                           let dicDescription = dicData["dicDescription"] as? String,
                           let dicLearnLang = dicData["dicLearningLanguage"] as? String,
                           let dicTransLang = dicData["dicTranslateLanguage"] as? String,
                           let dicWordsCount = dicData["dicWordsCount"] as? Int,
                           let dicUserID = dicData["dicUserID"] as? String,
                           let dicImagesCount = dicData["dicImagesCount"] as? Int,
                           let dicDownloadedUsers = dicData["dicDownloadedUsers"] as? [String],
                           let dicLikes = dicData["dicLikes"] as? [String]
                        {
                            let dicAddDate = self.mainModel.convertDateToString(currentDate: Date(), time: false)
                            let dic = SharedDictionary(dicID: dicID, dicDescription: dicDescription, dicName: dicName, dicWordsCount: dicWordsCount, dicLearnLang: dicLearnLang, dicTransLang: dicTransLang, dicAddDate: dicAddDate!, dicUserID: dicUserID, dicImagesCount: dicImagesCount, dicDownloaded: false, dicDownloadedUsers: dicDownloadedUsers, dicLikes: dicLikes)
                            self.originalArray.append(dic)
                            self.sharedDictionaries.append(dic)
                        }
                    } else {
                        continue
                    }
                }
                self.sharedTable.reloadData()
            }
        }
    }
    
 
    
    func getWords(dicArray:[SharedDictionary]){
        sharedWords.removeAll()
        for dic in dicArray{
            getWordsDataFromFirestore(dicID: dic.dicID)
        }
    }

    func getDicOwnerDataFromFirestore(ownerID:String){
        let db = Firestore.firestore()
        db.collection("Users").whereField("userID", isEqualTo: ownerID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let ownerData = document.data()
                    if let ownerName = ownerData["userName"] as? String,
                       let ownerID = ownerData["userID"] as? String
                    {
                        let owner = DicOwnerData(ownerName: ownerName, ownerID: ownerID)
                        self.dicOwnerData.append(owner)
                    }
                }
            }
        }
    }
    

    
    func getWordsDataFromFirestore(dicID:String){
        let db = Firestore.firestore()
        db.collection("Words").whereField("wrdDicID", isEqualTo: dicID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let wordData = document.data()
                    if let wrdWord = wordData["wrdWord"] as? String,
                       let wrdTranslation = wordData["wrdTranslation"] as? String,
                       let wrdID = wordData["wrdID"] as? String,
                       let wrdOwnerID = wordData["wrdUserID"] as? String,
                       let wrdImageName = wordData["wrdImageName"] as? String,
                       let wrdImageFirestorePath = wordData["wrdImageFirestorePath"] as? String,
                       let wrdDicID = wordData["wrdDicID"] as? String
                    {
                        let word = SharedWord(
                            wrdWord: wrdWord,
                            wrdTranslation: wrdTranslation,
                            wrdDicID: wrdDicID,
                            wrdOwnerID: wrdOwnerID,
                            wrdID: wrdID,
                            wrdImageFirestorePath: wrdImageFirestorePath,
                            wrdImageName: wrdImageName)
                        self.sharedWords.append(word)
                    }
                }
            }
        }
    }
    
    private func fetchData(completion: @escaping (Bool) -> Void) {
           DispatchQueue.global().async {
               self.getDataFromFirestore()
               self.loadAllMessages()
               Thread.sleep(forTimeInterval: 2.0)
               completion(true)
           }
       }
    
    private func showHUD() {
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
        }

    private func hideHUD() {
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
    
    func popUpApear(){
                let overLayerView = FilterSharedDicController()
                overLayerView.selectedLearn = selectedLearnFromDelegate
                overLayerView.selectedTrans = selectedTransFromDelegate
                overLayerView.dictionarisArray = originalArray
                overLayerView.sendFilteredDataDelegate = self
                overLayerView.appear(sender: self)
    }
    
    @IBAction func useFilterButtonPressed(_ sender: UIButton) {
        popUpApear()
    }
    
  
}

extension NetworkViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharedDictionaries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sharedTable.dequeueReusableCell(withIdentifier: "sharedCell") as! SharedDictionaryCell
        let dictionary = sharedDictionaries[indexPath.row]
        getDicOwnerDataFromFirestore(ownerID: dictionary.dicUserID)
        cell.downloadedView.isHidden = true
        if sharedDictionaries[indexPath.row].dicDownloaded{
            cell.downloadedView.isHidden = false
        }
        cell.cellView.clipsToBounds = true
        cell.cellView.layer.cornerRadius = 10
        cell.dicDescription.text = dictionary.dicDescription
        cell.userName.text = dicOwnerData.first?.ownerName ?? "Anonimus"
        cell.dictionaryName.text = dictionary.dicName
        cell.learningLanguage.text = dictionary.dicLearnLang
        cell.translateLanguage.text = dictionary.dicTransLang
        cell.wordsCount.text = String(dictionary.dicWordsCount)
        let learnImage = dictionary.dicLearnLang
        cell.lLangImage.image = UIImage(named: "\(learnImage).png")
        let transImage = dictionary.dicTransLang
        cell.tLangImage.image = UIImage(named: "\(transImage).png")
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        performSegue(withIdentifier: "openSharedDictionary", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let destinationVC = segue.destination as! BrowseSharedDicViewController
            if let indexPath = sharedTable.indexPathForSelectedRow{
                let dicID = sharedDictionaries[indexPath.row].dicID
                destinationVC.dicID = dicID
                destinationVC.sharedDictionary = sharedDictionaries[indexPath.row]
                let filteredByDicWords = sharedWords.filter({$0.wrdDicID == dicID})
                destinationVC.messagesCount = String(messagesArray?.filter{$0.msgDicID == dicID}.count ?? 0)
                destinationVC.sharedWordsArray = filteredByDicWords
                destinationVC.dicOwnerData = dicOwnerData.first
                destinationVC.setDownloadedDelegate = self
            }
    }
}
