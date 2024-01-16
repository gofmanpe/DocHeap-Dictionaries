//
//  ChatViewController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 02.01.24.
//

import UIKit
import Firebase
import CoreData
import AlamofireImage
import Alamofire

class ChatViewController: UIViewController, UITextViewDelegate{
    
//MARK: - Table Delegate and dataSource functions
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextView: UITextView!
    
//MARK: - Constants and variables
    var dicID = String()
    var networkUsers = [NetworkUser]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let mainModel = MainModel()
    private let firebase = Firebase()
    private let coreData = CoreDataManager()
    private var coreDataMessages = [ChatMessage]()
    private var userData : UserData?
    private let defaults = Defaults()
    private let alamo = Alamo()
    private let sync = SyncModel()
    private var avatarFileName = String()
    private var isTextEmpty = true
    private var currentUserCell = String()

//MARK: - Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        if mainModel.isInternetAvailable(){
            sync.syncNetworkUsersDataWithFirebase(context: context)
        }
        messageTextView.layer.cornerRadius = 10
        getMessagesForDictionary()
        getDownloadedUsersForDictionary()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chatTable.reloadData()
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if mainModel.isInternetAvailable(){
            sync.syncMessages(coreDataMessages: coreDataMessages)
        }
        chatTable.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

//MARK: - Controller functions
    func loadData(){
        if let uData = coreData.loadUserDataByID(userID: mainModel.loadUserData().userID, context: context).first{
           userData = uData
        }
        networkUsers = coreData.loadAllNetworkUsers(data: context)
        chatTable.delegate = self
        chatTable.dataSource = self
        messageTextView.delegate = self
        chatTable.register(UINib(nibName: "ChatUserCell", bundle: nil), forCellReuseIdentifier: "chatUserCell")
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.delegate = self
        chatTable.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
            if gestureRecognizer.state == .began {
                // Получаем точку нажатия
                let point = gestureRecognizer.location(in: chatTable)
                        // Выводим координаты в консоль
                        print("Координаты точки нажатия: \(point)")

                // Получаем IndexPath для ячейки, на которую нажали
                if let indexPath = chatTable.indexPathForRow(at: point) {
                    // Выполняем действие для ячейки по indexPath
                    handleLongPress(for: indexPath)
                }
            }
        }
    
    func getDownloadedUsersForDictionary(){
        let db = Firestore.firestore()
        db.collection("Dictionaries").whereField("dicID", isEqualTo: dicID).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error getting messages: \(error)\n")
            } else {
                guard let document = querySnapshot?.documents.first else {return}
                let dictionaryData = document.data()
                let downloadedUsers = dictionaryData["dicDownloadedUsers"] as? [String] ?? [String()]
                for user in downloadedUsers{
                    let isUserInCoreData = self.networkUsers.filter({$0.nuID == user})
                    if isUserInCoreData.isEmpty{
                        db.collection("Users").whereField("userID", isEqualTo: user).getDocuments { querySnapshot, error in
                            if let error = error {
                                print("Error getting messages: \(error)\n")
                            } else {
                                guard let document = querySnapshot?.documents.first else {return}
                                let userData = document.data()
                                if let userName = userData["userName"] as? String,
                                   let userID = userData["userID"] as? String,
                                   let userAvatarFirestorePath = userData["userAvatarFirestorePath"] as? String,
                                   let userBirthDate = userData["userBirthDate"] as? String,
                                   let userNativeLanguage = userData["userNativeLanguage"] as? String,
                                   let userCountry = userData["userCountry"] as? String,
                                   let userRegisterDate = userData["userRegisterDate"] as? String,
                                   let userShowEmail = userData["userShowEmail"] as? Bool,
                                   let userEmail = userData["userEmail"] as? String
                                {
                                    let newNetworkUser = NetworkUser(context: self.context)
                                    newNetworkUser.nuID = userID
                                    newNetworkUser.nuName = userName
                                    newNetworkUser.nuFirebaseAvatarPath = userAvatarFirestorePath
                                    newNetworkUser.nuBirthDate = userBirthDate
                                    newNetworkUser.nuNativeLanguage = userNativeLanguage
                                    newNetworkUser.nuCountry = userCountry
                                    newNetworkUser.nuRegisterDate = userRegisterDate
                                    newNetworkUser.nuShowEmail = userShowEmail
                                    if userShowEmail{
                                        newNetworkUser.nuEmail = userEmail
                                    }
                                    self.coreData.saveData(data: self.context)
                                    self.alamo.downloadChatUserAvatar(url: userAvatarFirestorePath, senderID: userID, userID: self.mainModel.loadUserData().userID) { avatarName in
                                        newNetworkUser.nuLocalAvatar = avatarName
                                        self.coreData.saveData(data: self.context)
                                    }
                                }
                                self.networkUsers = self.coreData.loadAllNetworkUsers(data: self.context)
                                self.chatTable.reloadData()
                            }
                            
                        }
                        
                    }
                }
            }
        }
    }

    func getMessagesForDictionary() {
        let db = Firestore.firestore()
        db.collection("Messages").whereField("msgDicID", isEqualTo: dicID).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                print("Error getting messages: \(error)\n")
                  } else {
                      for document in querySnapshot!.documents {
                          let messageData = document.data()
                          let msgID = messageData["msgID"] as? String ?? ""
                          self.coreDataMessages = self.coreData.getMessagesByDicID(dicID: self.dicID, context: self.context)
                          let messageForCheck = self.coreDataMessages.filter({$0.msgID == msgID})
                          switch messageForCheck.isEmpty{
                          case true:
                              if let msgBody = messageData["msgBody"] as? String,
                                 let msgDateTime = messageData["msgDateTime"] as? String,
                                 let msgDicID = messageData["msgDicID"] as? String,
                                 let msgSenderID = messageData["msgSenderID"] as? String,
                                 let msgOrdering = messageData["msgOrdering"] as? Int
                              {
                                  let newMessage = DicMessage(context: self.context)
                                  newMessage.msgID = msgID
                                  newMessage.msgBody = msgBody
                                  newMessage.msgDateTime = msgDateTime
                                  newMessage.msgDicID = msgDicID
                                  newMessage.msgSenderID = msgSenderID
                                  newMessage.msgOrdering = Int64(msgOrdering)
                                  newMessage.msgSyncronized = true
                                  self.coreData.saveData(data: self.context)
                              }
                              self.firebase.createNetworkUsersData(dicID: self.dicID, context: self.context)
                          case false:
                              continue
                          }
                      }
                      self.coreDataMessages = self.coreDataMessages.sorted{$0.msgOrdering < $1.msgOrdering}
                      DispatchQueue.main.async {
                          self.chatTable.reloadData()
                          var rowsCount = Int()
                          if self.coreDataMessages.count == 0 {
                              rowsCount = 0
                              return
                          } else {
                              rowsCount = self.coreDataMessages.count - 1
                              let indexPath = IndexPath(row: rowsCount, section: 0)
                              self.chatTable.scrollToRow(at: indexPath, at: .top, animated: true)
                          }
                      }
                  }
        }
    }
    
    private func popUpApear(user:NetworkUser){
            let overLayerView = UserInfoViewController()
            overLayerView.networkUser = user
            overLayerView.appear(sender: self)
    }
    
    func buttonScaleAnimation(targetButton:UIButton, scale:Bool){
        switch scale{
        case true:
            UIView.animate(withDuration: 0.3) {
                targetButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                targetButton.tintColor = UIColor(named: "Main_header")
            }
        case false:
            UIView.animate(withDuration: 0.3) {
                targetButton.transform = .identity
                targetButton.tintColor = .systemGray3
            }
        }
    }
    
    func sendMessage(_ message: String){
        let msgID = mainModel.uniqueIDgenerator(prefix: "msg")
        switch (message.isEmpty, mainModel.isInternetAvailable()){
            case (true,true): //Internet connected, message is empty
                return
            case (true,false): // No internet connection, message is empty
                return
            case (false,true): // Internet connected, message is not empty
                firebase.createMessage(msgSenderID: mainModel.loadUserData().userID, msgDicID: dicID, msgBody: message, msgID: msgID, replayTo: nil)
                getMessagesForDictionary()
            case (false,false): // No internet connection, message is not empty
                let newMessage = DicMessage(context: self.context)
                newMessage.msgID = msgID
                newMessage.msgBody = message
                let msgDateTime = mainModel.convertDateToString(currentDate: Date(), time: true)
                newMessage.msgDateTime = msgDateTime
                newMessage.msgDicID = dicID
                newMessage.msgSenderID = mainModel.loadUserData().userID
                newMessage.msgOrdering = Int64(mainModel.convertCurrentDateToInt())
                newMessage.msgSyncronized = false
                self.coreData.saveData(data: self.context)
        }
        DispatchQueue.main.async {
            self.chatTable.reloadData()
            var rowsCount = Int()
            if self.coreDataMessages.count == 0 {
                rowsCount = 0
                return
            } else {
                rowsCount = self.coreDataMessages.count - 1
                let indexPath = IndexPath(row: rowsCount, section: 0)
                self.chatTable.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let isCurrentlyEmpty = textView.text.isEmpty
        if isTextEmpty != isCurrentlyEmpty {
            if isCurrentlyEmpty {
                buttonScaleAnimation(targetButton: sendButton, scale: false)
            } else {
                buttonScaleAnimation(targetButton: sendButton, scale: true)
            }
            isTextEmpty = isCurrentlyEmpty
        }
    }
    
    private func filterMessage(_ originalText: String) -> String {
        let filteredText = originalText.trimmingCharacters(in: .whitespacesAndNewlines)
        return filteredText
    }
    
    private func shouldSendMessage(_ message: String) -> Bool {
        return !message.isEmpty
    }
 
   
//MARK: - Actions
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard let originalText = messageTextView.text  else {
            return
        }
        messageTextView.text.removeAll()
        let filteredText = filterMessage(originalText)
        if shouldSendMessage(filteredText) {
            sendMessage(filteredText)
        }
        messageTextView.delegate?.textViewDidChange?(messageTextView)
    }
    
}
//MARK: - Table Delegate and dataSource functions
extension ChatViewController: UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coreDataMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userCell = chatTable.dequeueReusableCell(withIdentifier: "chatUserCell", for: indexPath) as! ChatUserCell
        let message = coreDataMessages[indexPath.row]
        if message.msgSenderID == mainModel.loadUserData().userID {
            
            userCell.currentUserBackgroundView.isHidden = false
            userCell.netUserBackgroundView.isHidden = true
            userCell.currentUserMessageBody.text = message.msgBody
            userCell.currentUserDateTime.text = message.msgDateTime
            currentUserCell = String()
            currentUserCell = "local"
        } else {
            let networkUser = networkUsers.filter({$0.nuID == message.msgSenderID}).first
            userCell.currentUserBackgroundView.isHidden = true
            userCell.netUserBackgroundView.isHidden = false
            userCell.netUserNameLabel.text = networkUser?.nuName
            userCell.netUserMessageBody.text = message.msgBody
            userCell.netUserDateTime.text = message.msgDateTime
            userCell.netUserAvatar.image = UIImage(contentsOfFile: mainModel.getDocumentsFolderPath().appendingPathComponent("\(mainModel.loadUserData().userID)/\(networkUser?.nuLocalAvatar ?? "")").path)
            currentUserCell = String()
            currentUserCell = "network"
        }
        userCell.selectionStyle = .none
        return userCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let networkUser = networkUsers.filter({$0.nuID == coreDataMessages[indexPath.row].msgSenderID}).first ?? NetworkUser()
        let message = coreDataMessages[indexPath.row]
        if message.msgSenderID != mainModel.loadUserData().userID{
            popUpApear(user: networkUser)
        }
    }
    
    func handleLongPress(for indexPath: IndexPath) {
        let networkUser = networkUsers.filter({$0.nuID == coreDataMessages[indexPath.row].msgSenderID}).first ?? NetworkUser()
        let message = coreDataMessages[indexPath.row]
        
        if message.msgSenderID != mainModel.loadUserData().userID{
            popUpApear(user: networkUser)
        }
        
    }
}
