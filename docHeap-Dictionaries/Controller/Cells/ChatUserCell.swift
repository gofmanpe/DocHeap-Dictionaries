//
//  ChatUserCell.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 09.01.24.
//

import UIKit

class ChatUserCell: UITableViewCell {
    
    
    @IBOutlet weak var netUserAvatar: UIImageView!
    @IBOutlet weak var netUserNameLabel: UILabel!
    @IBOutlet weak var netUserMessageBody: UILabel!
    @IBOutlet weak var netUserDateTime: UILabel!
    @IBOutlet weak var netUserBackgroundView: UIView!
    @IBOutlet weak var newUserMessageView: UIView!
    
    @IBOutlet weak var currentUserBackgroundView: UIView!
    @IBOutlet weak var currentUserMessageBody: UILabel!
    @IBOutlet weak var currentUserDateTime: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        currentUserBackgroundView.layer.cornerRadius = 10
        currentUserBackgroundView.layer.borderWidth = 0.5
        currentUserBackgroundView.layer.borderColor = UIColor.lightGray.cgColor
        currentUserBackgroundView.backgroundColor = UIColor(named: "userMessageBg")
        newUserMessageView.layer.cornerRadius = 10
        newUserMessageView.layer.borderWidth = 0.5
        newUserMessageView.layer.borderColor = UIColor.lightGray.cgColor
        netUserAvatar.layer.cornerRadius = netUserAvatar.frame.size.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
