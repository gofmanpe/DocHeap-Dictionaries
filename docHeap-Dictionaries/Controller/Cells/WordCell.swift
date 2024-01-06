//
//  WordCell.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 31.03.23.
//

import UIKit

class WordCell: UITableViewCell {

    @IBOutlet weak var learningLanguageImage: UIImageView!
    @IBOutlet weak var learningLanguageLabel: UILabel!
    @IBOutlet weak var translateLanguageImage: UIImageView!
    @IBOutlet weak var translateLanguageLabel: UILabel!
    @IBOutlet weak var isSetImageLabel: UILabel!
    @IBOutlet weak var isSetImageBackgroundView: UIView!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var statusImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        cellView.layer.cornerRadius = 10
        isSetImageLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        // Configure the view for the selected state
    }

}
