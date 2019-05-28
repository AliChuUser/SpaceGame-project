//
//  EnemySpaceShip.swift
//  SpaceGame
//
//  Created by Aleksei Chudin on 06/05/2019.
//  Copyright © 2019 Aleksei Chudin. All rights reserved.
//

import UIKit
import SpriteKit

class EnemySpaceShip: SKSpriteNode {
    
    init() {
        
        let enemyTexture = SKTexture(imageNamed: "enemySpaceship")
        
        super.init(texture: enemyTexture, color: UIColor.red, size: enemyTexture.size())
        
        // create phisics body for enemy ship
        physicsBody = SKPhysicsBody(texture: enemyTexture, size: enemyTexture.size())
        
        physicsBody?.affectedByGravity = false
        physicsBody?.allowsRotation = false
        
        physicsBody?.categoryBitMask = CollisionCategory.EnemySpaceShip
        physicsBody?.contactTestBitMask = CollisionCategory.PlayerLaser
        physicsBody?.collisionBitMask = CollisionCategory.PlayerLaser
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fly() {
        if let scene = scene {
            let randomX = CGFloat(arc4random_uniform(UInt32(scene.size.width - size.width))) + size.width/2
            position.x = randomX
            position.y = scene.size.height + size.height/2
            
            let moveDown = SKAction.moveBy(x: 0, y: -100, duration: 4)
            
            let moveLeft = SKAction.moveBy(x: -50, y: 0, duration: 2)
            moveLeft.timingMode = SKActionTimingMode.easeOut
            
            let moveRight = SKAction.moveBy(x: 50, y: 0, duration: 2)
            moveRight.timingMode = SKActionTimingMode.easeOut
            
            let sideMoveSequence = SKAction.sequence([moveLeft, moveRight])
            
            // group let us to do actions simultaniously
            let enemyGroupMovement = SKAction.group([moveDown, sideMoveSequence])
            
            let repeatMoveDownAction = SKAction.repeatForever(enemyGroupMovement)
            
            run(repeatMoveDownAction)
        }
    }
}
