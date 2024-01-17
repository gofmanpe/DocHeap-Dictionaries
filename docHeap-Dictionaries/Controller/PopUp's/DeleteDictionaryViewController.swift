//
//  DelDictionaryViewController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 09.10.23.
//

import UIKit
import CoreData
import Alamofire

class DeleteDictionaryViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainWindowView: UIView!
    @IBOutlet weak var dictionaryNameLabel: UILabel!
    @IBOutlet weak var learningImage: UIImageView!
    @IBOutlet weak var translateImage: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var learningLanguageLabel: UILabel!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var translateLanguageLabel: UILabel!
    @IBOutlet weak var dialogLabel: UILabel!
    
    func localizeElements(){
        headerLabel.text = "deleteDictionaryVC_header_label".localized
        dialogLabel.text = "deleteDictionaryVC_dialog_label".localized
        cancelButton.setTitle("deleteDictionaryVC_cancel_button".localized, for: .normal)
        deleteButton.setTitle("deleteDictionaryVC_delete_button".localized, for: .normal)
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var tableReloadDelegate: UpdateView?
    var dicID = String()
    private var coreDataManager = CoreDataManager()
    private let mainModel = MainModel()
    private var dictionariesArray = [Dictionary]()
    private var defaults = Defaults()
    private let fireDB = Firebase()
    private let alamo = Alamo()
    private var parentDictionary = Dictionary()
   
    
    init() {
        super.init(nibName: "DeleteDictionaryViewController", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
       
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeElements()
        setupData()
        coreDataManager.loadParentDictionaryData(dicID: dicID, userID: mainModel.loadUserData().userID, data: context)
            popUpBackgroundSettings()
            elementsDesign()
      
    }
    
    func setupData(){
        parentDictionary = coreDataManager.getParentDictionaryData(dicID: dicID, userID: mainModel.loadUserData().userID, data: context)
    }
    
    
    func elementsDesign(){
        let dicName = parentDictionary.dicName ?? "NO_DICTIONARY"
        dictionaryNameLabel.text = dicName
        if let lrnName = parentDictionary.dicLearningLanguage{
            learningImage.image = UIImage(named: lrnName)
        }
        if let trnName = parentDictionary.dicTranslateLanguage{
            translateImage.image = UIImage(named: trnName)
        }
        if let lrnLabel = parentDictionary.dicLearningLanguage{
            learningLanguageLabel.text = lrnLabel
        }
        if let trnLabel = parentDictionary.dicTranslateLanguage{
            translateLanguageLabel.text = trnLabel
        }
        commentView.layer.cornerRadius = 10
        commentView.isHidden = true
        mainWindowView.clipsToBounds = true
        mainWindowView.layer.cornerRadius = 10
        learningImage.clipsToBounds = true
        learningImage.layer.cornerRadius = 5
        translateImage.clipsToBounds = true
        translateImage.layer.cornerRadius = 5
    }
    
    func popUpBackgroundSettings(){
        self.view.backgroundColor = .clear
        backgroundView.backgroundColor = .black.withAlphaComponent(0.6)
        backgroundView.alpha = 0
        mainWindowView.alpha = 0
    }
    
    func appear(sender: DictionariesController) {
        sender.present(self, animated: false) {
            self.show()
        }
    }

    private func show() {
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.mainWindowView.alpha = 1
            self.backgroundView.alpha = 1
        }
    }

    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.backgroundView.alpha = 0
            self.mainWindowView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
            self.removeFromParent()
        }
    }
    
    func commentViewAppearAnimate(_ text:String){
        commentLabel.text = text
        commentView.isHidden = false
        commentView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            
            self.commentView.alpha = 1
        } completion: { Bool in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.commentView.isHidden = true
            }
            
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        hide()
    }
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        mainModel.deleteFolderInDocuments(folderName: "\(mainModel.loadUserData().userID)/\(dicID)")
        let dictionaryWords = coreDataManager.loadWordsByDictionryID(dicID: dicID, data: context)
        if parentDictionary.dicReadOnly{
            if mainModel.isInternetAvailable(){
                coreDataManager.delWordsFromDictionaryByDicID(dicID: dicID, userID: mainModel.loadUserData().userID, context: context)
                coreDataManager.deleteRODictionaryFromCoreData(dicID: dicID, userID: mainModel.loadUserData().userID, context: context)
                coreDataManager.deleteMessagesFromCoreData(dicID: dicID, context: context)
            } else {
                coreDataManager.setDeletedStatusForDictionary(data: context, dicID: dicID)
                coreDataManager.setSyncronizedStatusForDictionary(data: context, dicID: dicID, sync: false)
                coreDataManager.setDeletedStatusForWordsInDictionary(data: context, dicID: dicID)
                coreDataManager.setSyncronizedStatusForWordsInDictionary(data: context, dicID: dicID, sync: false)
                coreDataManager.deleteMessagesFromCoreData(dicID: dicID, context: context)
            }
            
            coreDataManager.saveData(data: context)
        } else {
            if mainModel.isInternetAvailable(){
                if !dictionaryWords.isEmpty{
                    for word in dictionaryWords{
                        if word.wrdImageIsSet{
                            fireDB.deleteImageFromStorage(imageName: word.imageName ?? "NO_IMAGE", userID: mainModel.loadUserData().userID, dicID: word.wrdDicID ?? "")
                        }
                        fireDB.deleteWordFromFirebase(wrdID: word.wrdID ?? "")
                    }
                }
                fireDB.deleteDictionaryFirebase(dicID: dicID) { error in
                    if let error = error {
                        print("Error deleting dictionary from Firestore: \(error)\n")
                    }
                }
                coreDataManager.delWordsFromDictionaryByDicID(dicID: dicID, userID: mainModel.loadUserData().userID, context: context)
                context.delete(coreDataManager.parentDictionaryData.first!)
                coreDataManager.parentDictionaryData.remove(at: 0)
                coreDataManager.saveData(data: context)
                let arrayOfWords = coreDataManager.loadWordsForDictionary(dicID: dicID, data: context)
                fireDB.deleteAllImagesFromDictionaryStorage(userID: mainModel.loadUserData().userID, dicID: dicID, arrayOfWords: arrayOfWords)
                coreDataManager.deleteMessagesFromCoreData(dicID: dicID, context: context)
            } else {
                coreDataManager.setDeletedStatusForDictionary(data: context, dicID: dicID)
                coreDataManager.setSyncronizedStatusForDictionary(data: context, dicID: dicID, sync: false)
                coreDataManager.setDeletedStatusForWordsInDictionary(data: context, dicID: dicID)
                coreDataManager.setSyncronizedStatusForWordsInDictionary(data: context, dicID: dicID, sync: false)
                coreDataManager.deleteMessagesFromCoreData(dicID: dicID, context: context)
            }
        }
        deleteButton.isEnabled = false
        tableReloadDelegate?.didUpdateView(sender: "")
        cancelButton.isEnabled = false
        deleteButton.isEnabled = false
        commentViewAppearAnimate(defaults.succDeleteMessage)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            self.hide()
//        }
        UIView.animate(withDuration: 0.2) {
            self.mainWindowView.alpha = 0
        } completion: { Bool in }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.hide()
        }
    }
    
 

}
