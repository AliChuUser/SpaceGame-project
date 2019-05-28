//
//  GameViewController.swift
//  SpaceGame
//
//  Created by Aleksei Chudin on 29/04/2019.
//  Copyright © 2019 Aleksei Chudin. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    // declare properties for linking main view controller with other view controllers
    var gameScene: GameScene!
    var pauseViewController: PauseViewController!
    var gameOverViewController: GameOverViewController!
    var gameSettings: GameSettings!
    
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    // live images (hearts in the left bottom side)
    @IBOutlet weak var theFirstLiveImage: UIImageView!
    @IBOutlet weak var theSecondLiveImage: UIImageView!
    @IBOutlet weak var theThirdLiveImage: UIImageView!
    
    @IBAction func pauseButtonPressed(_ sender: AnyObject) {
        gameScene.pauseTheGame()
        showPauseOrGameOverScreen(viewController: pauseViewController)
    }
    
    // offtop - to accept aspect ration property when rotate iphone (except background) use the: override func viewDidLayoutSubviews() {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init gameSettings VC
        gameSettings = GameSettings()
        
        // init pause VC
        pauseViewController = (storyboard?.instantiateViewController(withIdentifier: "pauseViewController") as! PauseViewController)
        
        // assign main VC as a delegate of pauseViewController (look at extension)
        pauseViewController.delegate = self
        
        // init gameOver VC
        gameOverViewController = (storyboard?.instantiateViewController(withIdentifier: "gameOverViewController") as! GameOverViewController)
        
        // assign main VC as a delegate of gameOverViewController (look at extension)
        gameOverViewController.delegate = self
        
        // transfer game settings to gameOver VC
        gameOverViewController.gameSettings = gameSettings
        
        // launch the GameScene screen
        if let view = self.view as! SKView? {
            
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                
                // assign gameScene to current scene
                gameScene = scene as? GameScene
                
                // set GameViewController as a delegate of GameScene
                gameScene.gameDelegate = self
                
                // transfer game settings to GameScene
                gameScene.gameSettings = gameSettings
                
                // set the scale mode to scale to fit the window
                scene.size = UIScreen.main.bounds.size
                scene.scaleMode = .aspectFill
                
                // present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            // show scene settings in the right bottom side
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
    }
    
    func showPauseOrGameOverScreen(viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        
        // appearence the pause screen with animation
        viewController.view.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            viewController.view.alpha = 1
        }
    }
    
    func hidePauseOrGameOverScreen(viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.removeFromParent()
        
        // animation for unpause screen
        viewController.view.alpha = 1
        
        UIView.animate(withDuration: 0.5, animations: {
            viewController.view.alpha = 0
        }) { (complited) in
          viewController.view.removeFromSuperview()
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    // hide statusBar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: Game Delegate

extension GameViewController: GameDelegate {
    
    func gameDelegateDidUpdateLives() {
        updateUILives()
    }
    
    func updateUILives() {
        
        // update UI with animation
        UIView.animate(withDuration: 0.3) {
            
            // change the transparansy of live hearts when player lose lives
            switch self.gameSettings.lives {
            case 0:
                self.theFirstLiveImage.alpha = 0
                self.theSecondLiveImage.alpha = 0
                self.theThirdLiveImage.alpha = 0
            case 1:
                self.theFirstLiveImage.alpha = 0
                self.theSecondLiveImage.alpha = 0
                self.theThirdLiveImage.alpha = 0.6
            case 2:
                self.theFirstLiveImage.alpha = 0
                self.theSecondLiveImage.alpha = 0.8
                self.theThirdLiveImage.alpha = 0.6
            default:
                self.theFirstLiveImage.alpha = 1
                self.theSecondLiveImage.alpha = 0.8
                self.theThirdLiveImage.alpha = 0.6
            }
        }
    }
    
    func gameDelegateDidUpdateScore(score: Int) {
        scoreLabel.text = "\(gameSettings.currentScore)"
    }
    
    func gameDelegateReset() {
        scoreLabel.text = "\(gameSettings.currentScore)"
        updateUILives()
    }
    
    func gameDelegateGameOver(score: Int) {
        showPauseOrGameOverScreen(viewController: gameOverViewController)
    }
}

// MARK: GameOver ViewController Delegate

extension GameViewController: GameOverViewControllerDelegate {
    
    func gameOverViewControllerResetButtonPressed(viewController: GameOverViewController) {
        gameScene.resetTheGame()
        hidePauseOrGameOverScreen(viewController: gameOverViewController)
    }
    
    func gameOverViewControllerTopScoreButtonPressed(viewController: GameOverViewController) {
        // not yet implemented
    }
    
    func gameOverViewControllerMenuButtonPressed(viewController: GameOverViewController) {
        // not yet implemented
    }
}

// MARK: Pause ViewController Delegate

extension GameViewController: PauseViewControllerDelegate {
    
    func pauseViewControllerPlayButtonPressed(viewController: PauseViewController) {
        hidePauseOrGameOverScreen(viewController: pauseViewController)
        gameScene.unpauseTheGame()
    }
    
    func pauseViewControllerStoreButtonPressed(viewController: PauseViewController) {
        // not yet implemented
    }
    
    func pauseViewControllerMenuButtonPressed(viewController: PauseViewController) {
        // not yet implemented
    }
    
    func pauseViewControllerMusicButtonPressed(viewController: PauseViewController) {
        
        // change the bool value and run the func
        gameScene.musicON = !gameScene.musicON
        gameScene.musicOnOrOff()
        
        // change the On/off status image
        changeTheSoundStatusImage(for: viewController.musicButton, with: gameScene.musicON)
    }
    
    func pauseViewControllerSoundButtonPressed(viewController: PauseViewController) {
        
        // change the bool value and run the func
        gameScene.soundON = !gameScene.soundON
        gameScene.soundOnOrOff()
        
        // change the On/off status image
        changeTheSoundStatusImage(for: viewController.soundButtonn, with: gameScene.soundON)
    }
    
    func changeTheSoundStatusImage(for button: UIButton, with statusON: Bool) {

        let image = statusON ? UIImage(named: "onImage") : UIImage(named: "offImage")
        button.setImage(image, for: .normal)
    }
}
