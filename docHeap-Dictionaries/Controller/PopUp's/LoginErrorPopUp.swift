//
//  LoginErrorViewController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 13.12.23.
//

import UIKit

class LoginErrorPopUp: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    init() {
        super.init(nibName: "LoginErrorPopUp", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        elementsDesign()
    }
    
    func elementsDesign(){
        mainView.layer.cornerRadius = 10
        self.view.backgroundColor = .clear
        backgroundView.backgroundColor = .black.withAlphaComponent(0.6)
        backgroundView.alpha = 0
        mainView.alpha = 0
    }
    
  
    
    func appearOverlayer(sender: UIViewController, text:String) {
        sender.present(self, animated: false) {
            self.show()
        }
        errorMessageLabel.text = text
    }

    private func show() {
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.mainView.alpha = 1
            self.backgroundView.alpha = 1
        }
    }

    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.backgroundView.alpha = 0
            self.mainView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
            self.removeFromParent()
        }
    }

    @IBAction func okButtonPressed(_ sender: UIButton) {
        hide()
    }
    
}
