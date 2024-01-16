//
//  DictionaryCell.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 27.03.23.
//

import UIKit
import Foundation

class DictionaryCell: UITableViewCell {

    @IBOutlet weak var learningLanguageImage: UIImageView!
    @IBOutlet weak var learningLanguageLabel: UILabel!
    @IBOutlet weak var translateLanguageImage: UIImageView!
    @IBOutlet weak var globeImageView: UIImageView!
    @IBOutlet weak var translateLanguageLabel: UILabel!
    @IBOutlet weak var dictionaryNameLabel: UILabel!
    @IBOutlet weak var wordsInDictionaryLabel: UILabel!
    @IBOutlet weak var creatinDateLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var backgroundCell: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var wordsCountLabel: UILabel!
    @IBOutlet weak var createDateLabel: UILabel!
    @IBOutlet weak var btSeparatorView: UIView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var separatorOneButton: UIImageView!
    @IBOutlet weak var separatorTwoButtons: UIImageView!
    @IBOutlet weak var sharedDictionaryImage: UIImageView!
    @IBOutlet weak var infoIconsStack: UIStackView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var messagesLabel: UILabel!
    
    private func localizeElements(){
        wordsCountLabel.text = "dictionariesVC_wordsCount_label".localized
        
    }
    
    var cellButtonActionDelegate : CellButtonPressed?
    var dicName = String()
    var dicID = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        localizeElements()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        backgroundCell.layer.cornerRadius = 15
        backgroundCell.layer.shadowColor = UIColor.black.cgColor
        backgroundCell.layer.shadowOpacity = 0.2
        backgroundCell.layer.shadowOffset = .zero
        backgroundCell.layer.shadowRadius = 2
        learningLanguageImage.layer.cornerRadius = 5
        translateLanguageImage.layer.cornerRadius = 5
    }
    
    func buttonScaleAnimation(targetButton:UIButton){
        UIView.animate(withDuration: 0.2) {
            targetButton.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
            
        } completion: { (bool) in
            targetButton.transform = .identity
        }

    }
    @IBAction func editButtonPressed(_ sender: UIButton) {
        buttonScaleAnimation(targetButton: editButton)
        cellButtonActionDelegate?.cellButtonPressed(dicID: dicID, button:"Edit")
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        buttonScaleAnimation(targetButton: deleteButton)
        cellButtonActionDelegate?.cellButtonPressed(dicID: dicID, button:"Delete")
        
    }
}
