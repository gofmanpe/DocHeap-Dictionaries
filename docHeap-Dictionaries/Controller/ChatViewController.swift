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
    @IBOutlet weak var tableWithFieldView: UIView!
    
//MARK: - Constants and variables
    var dicID = String()
   // var networkUsers = [NetworkUser]()
    var networkUsers = [NetworkUserData]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let mainModel = MainModel()
    private let firebase = Firebase()
    private let coreData = CoreDataManager()
    private var coreDataComments = [Comment]()
    private var userData : UserData?
    private let defaults = Defaults()
    private let alamo = Alamo()
    private let sync = SyncModel()
    private var avatarFileName = String()
    private var isTextEmpty = true
    private var currentUserCell = String()
    private var currentFramePosY = CGFloat()
    private var bottomYPosition = CGFloat()
    private var isKeyboardVisible = false
    private var rowIndexPath = IndexPath()

//MARK: - Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        if mainModel.isInternetAvailable(){
            sync.syncNetworkUsersDataWithFirebase(context: context)
        }
        messageTextView.layer.cornerRadius = 10
        getCommentsForDictionary()
        keyboardBehavorSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chatTable.reloadData()
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if mainModel.isInternetAvailable(){
            sync.syncMessages(coreDataMessages: coreDataComments)
        }
        chatTable.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

//MARK: - Controller functions
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        chatTable.addGestureRecognizer(tapGesture)
        currentFramePosY = tableWithFieldView.frame.origin.y
        bottomYPosition = UIScreen.main.bounds.height - tableWithFieldView.frame.origin.y - tableWithFieldView.frame.size.height
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            tableWithFieldView.frame.origin.y = currentFramePosY - keyboardHeight + 10
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 10, right: 0.0)
            chatTable.contentInset = contentInsets
            chatTable.scrollIndicatorInsets = contentInsets
            if !coreDataComments.isEmpty{
                let indexPath = IndexPath(row: coreDataComments.count - 1, section: 0)
                chatTable.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        tableWithFieldView.frame.origin.y = currentFramePosY
        chatTable.contentInset = .zero
        chatTable.scrollIndicatorInsets = .zero
    }
    
    deinit {
            NotificationCenter.default.removeObserver(self)
        }
    
    func loadData(){
        if let uData = coreData.loadUserDataByID(userID: mainModel.loadUserData().userID, context: context){
           userData = uData
        }
        coreDataComments = coreData.getMessagesByDicID(dicID: dicID, context: context).sorted{$0.msgOrdering < $1.msgOrdering}
        DispatchQueue.main.async {
           self.chatTable.reloadData()
           var rowsCount = Int()
            if self.coreDataComments.count == 0 {
                rowsCount = 0
                return
            } else {
                rowsCount = self.coreDataComments.count - 1
                let indexPath = IndexPath(row: rowsCount, section: 0)
                self.chatTable.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
        networkUsers = coreData.getAllNetworkUsers(context: context)
        chatTable.delegate = self
        chatTable.dataSource = self
        messageTextView.delegate = self
        chatTable.register(UINib(nibName: "ChatUserCell", bundle: nil), forCellReuseIdentifier: "chatUserCell")
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
 func getCommentsForDictionary(){
     firebase.listenForNewComment(dicID: dicID, context: context) {newComment, error  in
            if let error = error {
                print("Error to get new comment: \(error)\n")
            } else {
                guard let comment = newComment else {return}
                if self.mainModel.loadUserData().userID == comment.msgSenderID{
                    self.coreData.createComment(comment: comment, context: self.context)
                    self.coreDataComments.append(comment)
                    self.coreDataComments = self.coreDataComments.sorted{$0.msgOrdering < $1.msgOrdering}
                    DispatchQueue.main.async {
                       self.chatTable.reloadData()
                       var rowsCount = Int()
                        if self.coreDataComments.count == 0 {
                            rowsCount = 0
                            return
                        } else {
                            rowsCount = self.coreDataComments.count - 1
                            let indexPath = IndexPath(row: rowsCount, section: 0)
                            self.chatTable.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                } else {
                    if !self.coreData.isNetworkUserExist(userID: comment.msgSenderID, data: self.context){
                      
                        self.firebase.getNetworkUserDataByID(userID: comment.msgSenderID) { networkUser, error in
                            if let error = error {
                                print("Error to get network user data: \(error)\n")
                            } else {
                                guard let netUser = networkUser else {return}
                                self.coreData.createNetworkUser(userData: netUser, context: self.context)
                                self.alamo.downloadChatUserAvatar(url: netUser.userAvatarFirestorePath, senderID: netUser.userID, userID: self.mainModel.loadUserData().userID) { avatarName in
                                    self.coreData.updateNetworkUserFieldData(userID: netUser.userID, field: "nuLocalAvatar", argument: avatarName, context: self.context)
                                    self.networkUsers = self.coreData.getAllNetworkUsers(context: self.context)
                                    self.coreData.createComment(comment: comment, context: self.context)
                                    self.coreDataComments.append(comment)
                                    self.coreDataComments = self.coreDataComments.sorted{$0.msgOrdering < $1.msgOrdering}
                                    DispatchQueue.main.async {
                                       self.chatTable.reloadData()
                                       var rowsCount = Int()
                                        if self.coreDataComments.count == 0 {
                                            rowsCount = 0
                                            return
                                        } else {
                                            rowsCount = self.coreDataComments.count - 1
                                            let indexPath = IndexPath(row: rowsCount, section: 0)
                                            self.chatTable.scrollToRow(at: indexPath, at: .top, animated: true)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        self.coreData.createComment(comment: comment, context: self.context)
                        self.coreDataComments.append(comment)
                        self.coreDataComments = self.coreDataComments.sorted{$0.msgOrdering < $1.msgOrdering}
                        DispatchQueue.main.async {
                           self.chatTable.reloadData()
                           var rowsCount = Int()
                            if self.coreDataComments.count == 0 {
                                rowsCount = 0
                                return
                            } else {
                                rowsCount = self.coreDataComments.count - 1
                                let indexPath = IndexPath(row: rowsCount, section: 0)
                                self.chatTable.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func popUpApear(user:NetworkUserData){
            let overLayerView = UserInfoViewController()
            overLayerView.networkUserData = user
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
           // getCommentsForDictionary()
        case (false,false): // No internet connection, message is not empty
            let newComment = Comment(
                msgID: msgID,
                msgBody: message,
                msgDateTime: mainModel.convertDateToString(currentDate: Date(), time: true)!,
                msgDicID: dicID,
                msgSenderID: mainModel.loadUserData().userID,
                msgOrdering: mainModel.convertCurrentDateToInt(),
                msgSyncronized: false)
            coreData.createComment(comment: newComment, context: context)
        }
        DispatchQueue.main.async {
            self.chatTable.reloadData()
            var rowsCount = Int()
            if self.coreDataComments.count == 0 {
                rowsCount = 0
                return
            } else {
                rowsCount = self.coreDataComments.count - 1
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
        return coreDataComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userCell = chatTable.dequeueReusableCell(withIdentifier: "chatUserCell", for: indexPath) as! ChatUserCell
        let message = coreDataComments[indexPath.row]
        if message.msgSenderID == mainModel.loadUserData().userID {
            userCell.currentUserBackgroundView.isHidden = false
            userCell.netUserBackgroundView.isHidden = true
            userCell.currentUserMessageBody.text = message.msgBody
            userCell.currentUserDateTime.text = message.msgDateTime
            currentUserCell = String()
            currentUserCell = "local"
        } else {
            let networkUser = networkUsers.filter({$0.userID == message.msgSenderID}).first
            userCell.currentUserBackgroundView.isHidden = true
            userCell.netUserBackgroundView.isHidden = false
            userCell.netUserNameLabel.text = networkUser?.userName
            userCell.netUserMessageBody.text = message.msgBody
            userCell.netUserDateTime.text = message.msgDateTime
            userCell.netUserAvatar.image = UIImage(contentsOfFile: mainModel.getDocumentsFolderPath().appendingPathComponent("\(mainModel.loadUserData().userID)/\(networkUser?.userLocalAvatar ?? "")").path)
            currentUserCell = String()
            currentUserCell = "network"
        }
        userCell.selectionStyle = .none
        return userCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let networkUser = networkUsers.filter({$0.userID == coreDataComments[indexPath.row].msgSenderID}).first else {return}
        let message = coreDataComments[indexPath.row]
        if message.msgSenderID != mainModel.loadUserData().userID{
            popUpApear(user: networkUser)
        }
    }
}
