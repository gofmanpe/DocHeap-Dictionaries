//
//  UserChatCell.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 04.01.24.
//

import UIKit

class UserChatCell: UITableViewCell {
    @IBOutlet weak var messageBodyLabel: UILabel!
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        messageView.layer.cornerRadius = 10
        messageView.layer.borderWidth = 0.5
        messageView.layer.borderColor = UIColor.lightGray.cgColor
        messageView.backgroundColor = UIColor(named: "userMessageBg")
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
