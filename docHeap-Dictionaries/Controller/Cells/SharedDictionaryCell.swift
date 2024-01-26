//
//  SharedDictionaryCell.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 18.12.23.
//

import UIKit

class SharedDictionaryCell: UITableViewCell {
    
    @IBOutlet weak var dictionaryName: UILabel!
    @IBOutlet weak var learningLanguage: UILabel!
    @IBOutlet weak var translateLanguage: UILabel!
    @IBOutlet weak var wordsCount: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var lLangImage: UIImageView!
    @IBOutlet weak var tLangImage: UIImageView!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var downloadsLabel: UILabel!
    @IBOutlet weak var messagesLabel: UILabel!
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var messagesStack: UIStackView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        cellView.layer.cornerRadius = 15
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOpacity = 0.2
        cellView.layer.shadowOffset = .zero
        cellView.layer.shadowRadius = 2
        lLangImage.layer.cornerRadius = 5
        tLangImage.layer.cornerRadius = 5
        userAvatarImage.layer.cornerRadius = userAvatarImage.frame.size.width/2
        
    }
    

    
}
