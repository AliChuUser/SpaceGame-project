//
//  PauseViewController.swift
//  SpaceGame
//
//  Created by Aleksei Chudin on 05/05/2019.
//  Copyright © 2019 Aleksei Chudin. All rights reserved.
//

import UIKit

protocol PauseViewControllerDelegate {
    func pauseViewControllerPlayButtonPressed(viewController: PauseViewController)
    func pauseViewControllerStoreButtonPressed(viewController: PauseViewController)
    func pauseViewControllerMenuButtonPressed(viewController: PauseViewController)
    func pauseViewControllerMusicButtonPressed(viewController: PauseViewController)
    func pauseViewControllerSoundButtonPressed(viewController: PauseViewController)
}

class PauseViewController: UIViewController {
    
    var delegate: PauseViewControllerDelegate!
    
    @IBOutlet weak var soundButtonn: UIButton!
    @IBOutlet weak var musicButton: UIButton!
    
    @IBAction func soundButtonPressed(_ sender: Any) {
        delegate.pauseViewControllerSoundButtonPressed(viewController: self)
    }
    
    @IBAction func musicButtonPressed(_ sender: Any) {
        delegate.pauseViewControllerMusicButtonPressed(viewController: self)
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        delegate.pauseViewControllerPlayButtonPressed(viewController: self)
    }
    
    @IBAction func storeButtonPressed(_ sender: Any) {
        delegate.pauseViewControllerStoreButtonPressed(viewController: self)
    }
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        delegate.pauseViewControllerMenuButtonPressed(viewController: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
