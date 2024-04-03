//
//  BrowseSharedWordViewController.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 24.01.24.
//

import UIKit

class BrowseSharedWordsPairPopUp: UIViewController {
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var wordsPairImage: UIImageView!
    @IBOutlet weak var learningLangImage: UIImageView!
    @IBOutlet weak var learningLangLabel: UILabel!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var transLangImage: UIImageView!
    @IBOutlet weak var transLangLabel: UILabel!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    private func localizeElements(){
        headerLabel.text = "browseSharedWordPopUp_header_label".localized
        closeButton.setTitle("browseSharedWordPopUp_close_button".localized, for: .normal)
    }
    
    init() {
        super.init(nibName: "BrowseSharedWordsPairPopUp", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
       
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var wordsPair: SharedWord?
    var dicLearnLang = String()
    var dicTransLang = String()
    var mainModel = MainModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizeElements()
        popUpBackgroundSettings()
        elementsDesign()
        setupData()
    }
    
    private func elementsDesign(){
        wordsPairImage.layer.cornerRadius = 10
        mainView.layer.cornerRadius = 10
        learningLangImage.layer.cornerRadius = 5
        transLangImage.layer.cornerRadius = 5
    }
    
    private func setupData(){
        setImageForWordsPair()
        wordLabel.text = wordsPair?.wrdWord
        translationLabel.text = wordsPair?.wrdTranslation
        learningLangImage.image = UIImage(named: dicLearnLang)
        transLangImage.image = UIImage(named: dicTransLang)
        learningLangLabel.text = dicLearnLang
        transLangLabel.text = dicTransLang
    }
    
    private func setImageForWordsPair(){
        switch wordsPair?.wrdImageName.isEmpty{
        case true:
            wordsPairImage.image = UIImage(named: "noimage")
        case false:
            let tempPath = mainModel.relativeDocumentsFolderPath(insidePath: "/\(mainModel.loadUserData().userID)/Temp")
            guard let imageName = wordsPair?.wrdImageName else {return}
            let imagePath = "\(tempPath)/\(imageName)"
            wordsPairImage.image = UIImage(contentsOfFile: imagePath)
        case .none:
            return
        case .some(_):
            return
        }
    }
    
    private func popUpBackgroundSettings(){
        self.view.backgroundColor = .clear
        background.backgroundColor = .black.withAlphaComponent(0.6)
        background.alpha = 0
        mainView.alpha = 0
    }
    
    func appear(sender: BrowseSharedDicController) {
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
    
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        hide()
    }
}
