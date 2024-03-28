//
//  DescriptionPopUpController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 19.01.24.
//

import UIKit

class DescriptionPopUp: UIViewController {

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var userName: UILabel!
    
    var dicDescription = String()
    var netUserName = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpBackgroundSettings()
        descriptionView.layer.cornerRadius = 10
        descriptionLabel.text = dicDescription
        userName.text = netUserName
        
    }
    
    init() {
        super.init(nibName: "DescriptionPopUp", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
       
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func popUpBackgroundSettings(){
        self.view.backgroundColor = .clear
        background.backgroundColor = .black.withAlphaComponent(0.6)
        background.alpha = 0
        descriptionView.alpha = 0
    }
    
    func appear(sender: UIViewController) {
        sender.present(self, animated: false) {
            self.show()
        }
    }

    private func show() {
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.descriptionView.alpha = 1
            self.background.alpha = 1
        }
    }

    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.background.alpha = 0
            self.descriptionView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
            self.removeFromParent()
        }
    }

    @IBAction func okButtonPressed(_ sender: UIButton) {
        hide()
    }
    
}
