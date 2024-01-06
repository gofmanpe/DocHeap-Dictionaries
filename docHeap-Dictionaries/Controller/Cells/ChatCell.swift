//
//  ChatCell.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 02.01.24.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var messageBody: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var senderAvatarImage: UIImageView!
    @IBOutlet weak var senderNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageView.layer.cornerRadius = 10
        messageView.layer.borderWidth = 0.5
        messageView.layer.borderColor = UIColor.lightGray.cgColor
        senderAvatarImage.layer.cornerRadius = senderAvatarImage.frame.size.width/2
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
