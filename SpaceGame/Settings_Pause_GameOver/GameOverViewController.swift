//
//  GameOverViewController.swift
//  SpaceGame
//
//  Created by Aleksei Chudin on 05/05/2019.
//  Copyright © 2019 Aleksei Chudin. All rights reserved.
//

import UIKit

protocol GameOverViewControllerDelegate {
    func gameOverViewControllerResetButtonPressed(viewController: GameOverViewController)
    func gameOverViewControllerTopScoreButtonPressed(viewController: GameOverViewController)
    func gameOverViewControllerMenuButtonPressed(viewController: GameOverViewController)
}

class GameOverViewController: UIViewController {
    
    var delegate: GameOverViewControllerDelegate!
    var gameSettings: GameSettings!

    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        delegate.gameOverViewControllerResetButtonPressed(viewController: self)
    }
    
    @IBAction func topScoreButtonPressed(_ sender: Any) {
        delegate.gameOverViewControllerTopScoreButtonPressed(viewController: self)
    }
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        delegate.gameOverViewControllerMenuButtonPressed(viewController: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scoreLabel.text = "\(gameSettings.highScore)"
        
        super.viewDidAppear(animated)
    }

}
