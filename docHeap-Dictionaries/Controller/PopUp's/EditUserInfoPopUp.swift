//
//  EditProfileViewController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 28.12.23.
//

import UIKit

class EditUserInfoPopUp: UIViewController {

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var nativeLanguageLabel: UILabel!
    @IBOutlet weak var nativeLanguageTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var warningImage: UIImageView!
    
    private func localizeElements(){
        headerLabel.text = "editUserInfoPopUp_header_label".localized
        userNameLabel.text = "editUserInfoPopUp_userName_label".localized
        dateOfBirthLabel.text = "editUserInfoPopUp_dateOfBirth_label".localized
        countryLabel.text = "editUserInfoPopUp_country_label".localized
        nativeLanguageLabel.text = "editUserInfoPopUp_nativeLanguage_label".localized
        saveButton.setTitle("editUserInfoPopUp_save_button".localized, for: .normal)
        cancelButton.setTitle("editUserInfoPopUp_cancel_button".localized, for: .normal)
    }
    
    init() {
        super.init(nibName: "EditUserInfoPopUp", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var userData : UserData?
    private let coreData = CoreDataManager()
    private let firebase = Firebase()
    private let mainModel = MainModel()
    private var newUserName = String()
    private var newBirthDate = String()
    private var newCountry = String()
    private var newNativeLanguage = String()
    var updateViewDelegate : UpdateView?
    let pickerView = UIPickerView()
    private let defaults = Defaults()
    private var selectedDay: Int?
    private var selectedMonth: String?
    private var selectedYear: Int?
    private let days = Array(1...31)
    private var months = [MonthArray]()
    private var years = Array(1920...Calendar.current.component(.year, from: Date()) - 3)
    private var currentFramePosY = CGFloat()
    private var bottomYPosition = CGFloat()

       
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeElements()
        dataSetup()
        popUpBackgroundSettings()
        elementsDesign()
        pickerView.dataSource = self
        pickerView.delegate = self
        dateOfBirthTextField.inputView = pickerView
        dateOfBirthTextField.delegate = self
        years = years.reversed()
        keyboardBehavorSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dataSetup()
    }
    
    private func keyboardBehavorSettings(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        currentFramePosY = mainView.frame.origin.y
        bottomYPosition = UIScreen.main.bounds.height - mainView.frame.origin.y - mainView.frame.size.height
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            mainView.frame.origin.y = currentFramePosY + (bottomYPosition - keyboardHeight) - 5.0
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        mainView.frame.origin.y = currentFramePosY
    }
   
    private func dataSetup(){
        userData = coreData.loadUserDataByID(userID: mainModel.loadUserData().userID, context: context)
        userNameTextField.text = userData?.userName
        dateOfBirthTextField.text = userData?.userBirthDate
        countryTextField.text = userData?.userCountry
        nativeLanguageTextField.text = userData?.userNativeLanguage
        months = defaults.monthArray
        
    }
    
    private func checkForChanges()->Bool{
        newUserName = userNameTextField.text ?? ""
        newBirthDate = dateOfBirthTextField.text ?? ""
        newCountry = countryTextField.text ?? ""
        newNativeLanguage = nativeLanguageTextField.text ?? ""
        switch (newUserName, newBirthDate, newCountry, newNativeLanguage) {
        case (userData?.userName, userData?.userBirthDate, userData?.userCountry, userData?.userNativeLanguage):
            return false
        case (_, _, _, _):
            return true
        }
    }
    
    private func elementsDesign(){
        mainView.layer.cornerRadius = 10
        warningView.layer.cornerRadius = 10
        warningView.isHidden = true
    }
    
    private func popUpBackgroundSettings(){
        self.view.backgroundColor = .clear
        background.backgroundColor = .black.withAlphaComponent(0.6)
        background.alpha = 0
        mainView.alpha = 0
    }
    
    func appear(sender: SettingsController) {
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

    private func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.background.alpha = 0
            self.mainView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
            self.removeFromParent()
        }
    }
    
    private func warningViewAppearAnimate(_ text:String, problem:Bool){
        warningLabel.text = text
        warningView.isHidden = false
        warningView.alpha = 0
        if problem{
            warningImage.image = UIImage(named: "stop")
        } else {
            warningImage.image = UIImage(named: "done")
        }
        UIView.animate(withDuration: 0.5) {
            
            self.warningView.alpha = 1
        } completion: { Bool in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.warningView.isHidden = true
            }
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        hideKeyboard()
        if checkForChanges(){
            warningViewAppearAnimate("All data was saved!", problem: false)
            let uData = UserData(
                userID: mainModel.loadUserData().userID,
                userName: newUserName,
                userBirthDate: newBirthDate,
                userCountry: newCountry,
                userAvatarFirestorePath: "",
                userAvatarExtention: "",
                userNativeLanguage: newNativeLanguage,
                userScores: 0,
                userShowEmail: false,
                userEmail: "",
                userSyncronized: true,
                userType: "",
                userRegisterDate: "",
                userInterfaceLanguage: "",
                userMistakes: userData?.userMistakes ?? 0,
                userRightAnswers: userData?.userRightAnswers ?? 0,
                userTestsCompleted: userData?.userTestsCompleted ?? 0, 
                userAppleIdentifier: userData?.userAppleIdentifier ?? ""
            )
            coreData.updateUserProfileData(userData: uData, context: context)
            userData = coreData.loadUserDataByID(userID: mainModel.loadUserData().userID, context: context)
            if mainModel.isInternetAvailable(){
                firebase.updateUserDataFirebase(userData: userData!)
                coreData.setSyncronizedStatusForUser(userID: mainModel.loadUserData().userID, status: true, context: context)
            } else {
                coreData.setSyncronizedStatusForUser(userID: mainModel.loadUserData().userID, status: false, context: context)
            }
            coreData.saveData(data: context)
            updateViewDelegate?.didUpdateView(sender: "")
            UIView.animate(withDuration: 0.2) {
                self.mainView.alpha = 0
            } completion: { Bool in }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.hide()
            }
        } else {
            warningViewAppearAnimate("Nothing was changed!", problem: true)
        }
    }
   
    
    @IBAction func camcelButtonPressed(_ sender: UIButton) {
        hideKeyboard()
        hide()
    }
    
    
    @IBAction func birthDatePickerChangeValue(_ sender: UIDatePicker) {
               let selectedDate = sender.date
               print("Selected date: \(selectedDate)")
    }
    
}

extension EditUserInfoPopUp: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 3 // Три компонента: день, месяц, год
     }

     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         switch component {
         case 0:
             return days.count
         case 1:
             return months.count
         case 2:
             return years.count
         default:
             return 0
         }
     }

     // MARK: - UIPickerViewDelegate

     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         switch component {
         case 0:
             return "\(days[row])"
         case 1:
             return "\(months[row].name)"
         case 2:
             return "\(years[row])"
         default:
             return nil
         }
     }

     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
         switch component {
         case 0:
             selectedDay = days[row]
         case 1:
             selectedMonth = months[row].value
         case 2:
             selectedYear = years[row]
         default:
             break
         }

         updateTextField()
     }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateTextField()
    }
    
    func updateTextField() {
        guard let selectedDay = selectedDay,
              let selectedMonth = selectedMonth,
              let selectedYear = selectedYear else {
            return
        }
        var displayedDay = String()
        if selectedDay < 10 {
            displayedDay = "0\(selectedDay)"
        } else {
            displayedDay = String(selectedDay)
        }
        let dateString = "\(displayedDay).\(selectedMonth).\(selectedYear)"
        dateOfBirthTextField.text = dateString
    }
    
}
