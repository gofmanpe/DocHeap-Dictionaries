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

class ChatViewController: UIViewController {
    
//MARK: - Table Delegate and dataSource functions
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextView: UITextView!
    
//MARK: - Constants and variables
    var dicID = String()
    var networkUsers : [NetworkUser]?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let mainModel = MainModel()
    private let firebase = Firebase()
    private let coreData = CoreDataManager()
    private var coreDataMessages = [DicMessage]()
    private var userData = Users()
    private let defaults = Defaults()
    private let alamo = Alamo()
    private var avatarFileName = String()

//MARK: - Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        messageTextView.layer.cornerRadius = 10
        syncMessages()
        getMessagesForDictionary()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chatTable.reloadData()
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        chatTable.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

//MARK: - Controller functions
    func loadData(){
        userData = coreData.loadUserDataByID(userID: mainModel.loadUserData().userID, data: context)
        chatTable.delegate = self
        chatTable.dataSource = self
        chatTable.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "chatCell")
        chatTable.register(UINib(nibName: "UserChatCell", bundle: nil), forCellReuseIdentifier: "userChatCell")
    }
    
    func syncMessages(){
        if mainModel.isInternetAvailable(){
            let unsyncMessages = coreDataMessages.filter({$0.msgSyncronized == false})
            if !unsyncMessages.isEmpty{
                for message in unsyncMessages{
                    firebase.createUnsynchronedMessage(
                        msgSenderID: message.msgSenderID!,
                        msgDicID: message.msgDicID!,
                        msgBody: message.msgBody!,
                        msgID: message.msgID!,
                        msgDateTime: message.msgDateTime!,
                        msgSenderAvatar: message.msgSenderAvatarPath!,
                        msgSenderName: message.msgSenderName!,
                        msgOrdering: Int(message.msgOrdering)
                    )
                    message.msgSyncronized = true
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
                                 let msgSenderName = messageData["msgSenderName"] as? String,
                                 let msgSenderAvatarPath = messageData["msgSenderAvatarPath"] as? String,
                                 let msgOrdering = messageData["msgOrdering"] as? Int
                              {
                                  let newMessage = DicMessage(context: self.context)
                                  newMessage.msgID = msgID
                                  newMessage.msgBody = msgBody
                                  newMessage.msgDateTime = msgDateTime
                                  newMessage.msgDicID = msgDicID
                                  newMessage.msgSenderAvatarPath = msgSenderAvatarPath
                                  newMessage.msgSenderID = msgSenderID
                                  newMessage.msgSenderName = msgSenderName
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
    
 

//MARK: - Actions
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        
        let msgID = mainModel.uniqueIDgenerator(prefix: "msg")
        guard let msgBody = messageTextView.text else {return}
        switch (msgBody.isEmpty, mainModel.isInternetAvailable()){
        case (true,true): //Internet connected, message is empty
            return
        case (true,false): // No internet connection, message is empty
            return
        case (false,true): // Internet connected, message is not empty
            firebase.createMessage(msgSenderID: mainModel.loadUserData().userID, msgDicID: dicID, msgBody: msgBody, msgID: msgID, replayTo: nil, msgSenderAvatar: userData.userAvatarFirestorePath ?? defaults.emptyAvatarPath, msgSenderName: userData.userName ?? "Anonimus")
            //     if coreDataMessages.isEmpty{
                getMessagesForDictionary()
          //  }
            messageTextView.text?.removeAll()
        case (false,false): // No internet connection, message is not empty
            let newMessage = DicMessage(context: self.context)
            newMessage.msgID = msgID
            newMessage.msgBody = msgBody
            let msgDateTime = mainModel.convertDateToString(currentDate: Date(), time: true)
            newMessage.msgDateTime = msgDateTime
            newMessage.msgDicID = dicID
            newMessage.msgSenderAvatarPath = userData.userAvatarFirestorePath
            newMessage.msgSenderID = mainModel.loadUserData().userID
            newMessage.msgSenderName = mainModel.loadUserData().userName
            newMessage.msgOrdering = Int64(mainModel.convertCurrentDateToInt())
            newMessage.msgSyncronized = false
            self.coreData.saveData(data: self.context)
            messageTextView.text?.removeAll()
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
    
}

//MARK: - Table Delegate and dataSource functions
extension ChatViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coreDataMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let networkUserCell = chatTable.dequeueReusableCell(withIdentifier: "chatCell") as! ChatCell
        networkUserCell.messageBody.text = coreDataMessages[indexPath.row].msgBody
        networkUserCell.dateTimeLabel.text = coreDataMessages[indexPath.row].msgDateTime
        networkUserCell.messageView.backgroundColor = UIColor.white
        networkUserCell.senderNameLabel.isHidden = false
        networkUserCell.senderNameLabel.text = coreDataMessages[indexPath.row].msgSenderName
        networkUserCell.senderAvatarImage.isHidden = false
        let networkUserAvatar = networkUsers?.filter({$0.nuID == self.coreDataMessages[indexPath.row].msgSenderID}).first?.nuLocalAvatar
            networkUserCell.senderAvatarImage.image = UIImage(contentsOfFile:  mainModel.getDocumentsFolderPath().appendingPathComponent("\(mainModel.loadUserData().userID)/\(networkUserAvatar ?? "")").path)
        if let imageUrl = URL(string: coreDataMessages[indexPath.row].msgSenderAvatarPath ?? ""){
                networkUserCell.senderAvatarImage.af.setImage(withURL: imageUrl)
            }
        let currentUserCell = chatTable.dequeueReusableCell(withIdentifier: "userChatCell") as! UserChatCell
        currentUserCell.messageView.backgroundColor = UIColor(named: "userMessageBg")
        currentUserCell.dateAndTimeLabel.text = coreDataMessages[indexPath.row].msgDateTime
        currentUserCell.messageBodyLabel.text = coreDataMessages[indexPath.row].msgBody
        if coreDataMessages[indexPath.row].msgSenderID == mainModel.loadUserData().userID {
            return currentUserCell
        } else {
            return networkUserCell
        }
    }
    
    
}
