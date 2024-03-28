//
//  AboutAppPopUp.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 15.03.24.
//

import UIKit

class AboutAppPopUp: UIViewController {
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var aboutAppLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var verssionNameLabel: UILabel!
    @IBOutlet weak var publicationNameLabel: UILabel!
    @IBOutlet weak var publicationDateLabel: UILabel!
    
    private func localizeElements(){
        header.text = "aboutAppPopUp_header_label".localized
        verssionNameLabel.text = "aboutAppPopUp_version_label".localized
        publicationNameLabel.text = "aboutAppPopUp_publicationDate_label".localized
        aboutAppLabel.text = "aboutAppPopUp_aboutText_label".localized
        authorLabel.text = "aboutAppPopUp_author_label".localized
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.layer.cornerRadius = 10
        popUpBackgroundSettings()
        localizeElements()
    }

    init() {
        super.init(nibName: "AboutAppPopUp", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
       
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func popUpBackgroundSettings(){
        self.view.backgroundColor = .clear
        background.backgroundColor = .black.withAlphaComponent(0.6)
        background.alpha = 0
        mainView.alpha = 0
    }
    
    func appear(sender: UIViewController) {
        sender.present(self, animated: false) {
            self.show()
        }
    }

    private func show() {
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.mainView.alpha = 1
            self.background.alpha = 1
        }
    }

    private func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.background.alpha = 0
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
