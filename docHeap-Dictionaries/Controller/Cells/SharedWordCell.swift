//
//  SharedWordCell.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 20.12.23.
//

import UIKit

class SharedWordCell: UITableViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var imgBgView: UIView!
    @IBOutlet weak var imgLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        cellView.layer.cornerRadius = 10
        imgLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        // Configure the view for the selected state
    }

}
