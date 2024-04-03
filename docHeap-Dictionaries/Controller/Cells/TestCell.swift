//
//  TestCell.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 06.04.23.
//

import UIKit

class TestCell: UITableViewCell {
    @IBOutlet weak var testNameLabel: UILabel!
    @IBOutlet weak var testImage: UIImageView!
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var testDescription: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        testView.layer.cornerRadius = 15
        testView.layer.shadowColor = UIColor.black.cgColor
        testView.layer.shadowOpacity = 0.2
        testView.layer.shadowOffset = .zero
        testView.layer.shadowRadius = 2
        testDescription.contentMode = .top
    }

}
