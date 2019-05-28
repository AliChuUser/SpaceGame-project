//
//  StartViewController.swift
//  SpaceGame
//
//  Created by Aleksei Chudin on 07/05/2019.
//  Copyright © 2019 Aleksei Chudin. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var crownImageView: UIImageView!
    
    // property for animation of changing scale of startButton
    var max: Bool = true
    
    // property for rotating animation of the crownImage
    var rotationDegree: CGFloat = 0
    
    // permanent changing the scale and rotation of button to one or another side
    func startButtonAnimation() {
        
        // change max value for accepting new values of scale startButton
        max = !max
        
        // duration of animation
        let duration: Double = 1
        
        // full cirlce in radians
        let fullCircle = 2 * Double.pi
        
        // define the direction and the scale
        let upAndDown = (max ? CGFloat(-1/16 * fullCircle) : CGFloat(1/16 * fullCircle))
        let scale: (CGFloat, CGFloat) = (max ? (1.0, 1.0) : (1.3, 1.3))
        
        // run startButton animation
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            
            let rotationAnimation = CGAffineTransform(rotationAngle: upAndDown)
            let scaleAnimation = CGAffineTransform.init(scaleX: scale.0, y: scale.1)
            
            self.startButton.transform = rotationAnimation.concatenating(scaleAnimation)
            
        }) { (finished) in
            
            // repeat func recursivly with changing max property
            self.startButtonAnimation()
        }
    }
    
    // permanent rotation of circle (crownImageView in our case)
    func circleAnimation(withObject object: UIImageView) {
        
        UIView.animate(withDuration: 0.01, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
            
            object.transform = CGAffineTransform.init(rotationAngle: self.rotationDegree)
            
        }) { (finished) in
            
            // increase rotation degree and repeat func recursivly
            self.rotationDegree += CGFloat(Double.pi / 180)
            self.circleAnimation(withObject: object)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButtonAnimation()
        circleAnimation(withObject: crownImageView)
    }
    
    // action button linked with the main screen by segue
    @IBAction func startButtonPressed(_ sender: Any) {
    }
}
