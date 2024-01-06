//
//  EditProfileViewController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 28.12.23.
//

import UIKit

class EditProfileViewController: UIViewController {

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
    
    init() {
        super.init(nibName: "EditProfileViewController", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var userData : Users?
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
        var selectedDay: Int?
        var selectedMonth: String?
        var selectedYear: Int?
        let days = Array(1...31)
        var months = [MonthArray]()
    var years = Array(1920...Calendar.current.component(.year, from: Date()) - 3)
       
    override func viewDidLoad() {
        super.viewDidLoad()
            dataSetup()
            popUpBackgroundSettings()
            elementsDesign()
        pickerView.dataSource = self
        pickerView.delegate = self
        dateOfBirthTextField.inputView = pickerView
        dateOfBirthTextField.delegate = self
        years = years.reversed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dataSetup()
    }
   
    func dataSetup(){
        userData = coreData.loadUserDataByID(userID: mainModel.loadUserData().userID, data: context)
        userNameTextField.text = userData?.userName
        dateOfBirthTextField.text = userData?.userBirthDate
        countryTextField.text = userData?.userCountry
        nativeLanguageTextField.text = userData?.userNativeLanguage
        months = defaults.monthArray
        
    }
    
//    func datePickerSettings(){

//    }
    
    func checkForChanges()->Bool{
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
    
    func elementsDesign(){
        mainView.layer.cornerRadius = 10
        warningView.layer.cornerRadius = 10
        warningView.isHidden = true
    }
    
    func popUpBackgroundSettings(){
        self.view.backgroundColor = .clear
        background.backgroundColor = .black.withAlphaComponent(0.6)
        background.alpha = 0
        mainView.alpha = 0
    }
    
    func appear(sender: ProfileController) {
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
    
    func warningViewAppearAnimate(_ text:String, problem:Bool){
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
        if checkForChanges(){
            warningViewAppearAnimate("All data was saved!", problem: false)
            userData?.userName = newUserName
            userData?.userBirthDate = newBirthDate
            userData?.userCountry = newCountry
            userData?.userNativeLanguage = newNativeLanguage
            coreData.saveData(data: context)
            userData = coreData.loadUserDataByID(userID: mainModel.loadUserData().userID, data: context)
            if mainModel.isInternetAvailable(){
                firebase.updateUserDataFirebase(userData: userData ?? Users())
                userData?.userSyncronized = true
            } else {
                userData?.userSyncronized = false
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
        hide()
    }
    
    
    @IBAction func birthDatePickerChangeValue(_ sender: UIDatePicker) {
               let selectedDate = sender.date
               print("Selected date: \(selectedDate)")
    }
    
}

extension EditProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
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
         // Обработка выбора значения в pickerView
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
        // Вызывается, когда пользователь начинает редактирование текстового поля
        updateTextField()
    }

    // Добавьте метод обновления значения текстового поля
    func updateTextField() {
        guard let selectedDay = selectedDay,
              let selectedMonth = selectedMonth,
              let selectedYear = selectedYear else {
            return
        }

        // Форматирование и установка значения текстового поля
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
