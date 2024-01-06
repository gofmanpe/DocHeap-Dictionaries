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
    @IBOutlet weak var dicDescription: UILabel!
    @IBOutlet weak var wordsNameLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var downloadedView: UIView!
    @IBOutlet weak var dowloadedLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        cellView.layer.cornerRadius = 15
        cellView.layer.cornerRadius = 15
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOpacity = 0.2
        cellView.layer.shadowOffset = .zero
        cellView.layer.shadowRadius = 2
        lLangImage.layer.cornerRadius = 5
        tLangImage.layer.cornerRadius = 5
        dowloadedLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
    }
    

    
}
