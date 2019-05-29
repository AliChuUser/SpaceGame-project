//
//  GameScene.swift
//  SpaceGame
//
//  Created by Aleksei Chudin on 29/04/2019.
//  Copyright © 2019 Aleksei Chudin. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

protocol GameDelegate {
    
    func gameDelegateDidUpdateScore(score: Int)
    func gameDelegateGameOver(score: Int)
    func gameDelegateReset()
    func gameDelegateDidUpdateLives()
}

// create categories for detecting collision (Bit masks)
struct CollisionCategory {
    
    // static is a property that belongs to own struct but not the instance of the struct
    static let None: UInt32 = 0
    static let PlayerSpaceShip: UInt32 = 0x1 << 0
    static let Asteroid: UInt32 = 0x1 << 1
    static let EnemySpaceShip: UInt32 = 0x1 << 2
    static let PlayerLaser: UInt32 = 0x1 << 3
}

// Bit masks implementation with enum (alternative option)

//enum CollisionCatefory: UInt32 {
//    case None = 1
//    case PlayerSpaceShip = 2
//    case Asteroid = 4
//    case EnemyShip = 8
//}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // create protocol delegate property to transfer data to main VC
    var gameDelegate: GameDelegate?
    
    // create gameSettings property to access game settings
    var gameSettings: GameSettings!
    
    // create property for defining the touch to the spaceShip
    var spaceShipPickedUp: Bool = false
    
    // create property for saving last spaceShip location
    var lastLocation: CGPoint = CGPoint.zero
    
    // create size for using in defining nodes position
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    // create nodes properties
    var spaceShip: SKSpriteNode!
    var background: SKSpriteNode!
    
    // create node layers properties
    var spaceShipLayer: SKNode!
    var asteroidLayer: SKNode!
    var starsLayer: SKNode!
    var enemyLayer: SKNode!
    var redLaserLayer: SKNode!
    
    // create pause game indicator
    var gameIsPaused: Bool = false
    
    // create music player with "play" and "stop" features
    var musicPlayer: AVAudioPlayer!
    
    // create variables for displaying music and sound
    var musicON: Bool = true
    var soundON: Bool = true
    
    // create gameOver indicator
    var gameOver: Bool = false
    
    // create lives counter (is to avoid double spend of lives due collisions with asteroids)
    var playerWasHit: Bool = false
    
    // create property for setting player immortable (test version)
    //var playerIsImmortable: Bool = true
    
    // switch game music on/off
    func musicOnOrOff() {
        if musicON {
            musicPlayer.play()
        } else {
            musicPlayer.stop()
        }
    }
    
    // switch game sound on/off (only with asteroid collisions)
    func soundOnOrOff() {
        if soundON {
            let hitSoundAction = SKAction.playSoundFileNamed("hitSound", waitForCompletion: true)
            run(hitSoundAction)
        }
    }
    
    func pauseTheGame() {
        gameIsPaused = true
        asteroidLayer.isPaused = true
        enemyLayer.isPaused = true
        redLaserLayer.isPaused = true
        physicsWorld.speed = 0
        musicOnOrOff()
    }
    
    func unpauseTheGame() {
        gameIsPaused = false
        asteroidLayer.isPaused = false
        enemyLayer.isPaused = false
        redLaserLayer.isPaused = false
        physicsWorld.speed = 1
        musicOnOrOff()
    }
    
    func resetTheGame() {
        
        // reset local game settings and update UI
        gameSettings.reset()
        gameDelegate?.gameDelegateReset()
        
        // set spaceShip at start position
        spaceShipLayer.position = CGPoint(x: width/2, y: height/4)
        
        // remove all asteroids and lasers from scene (screen)
        asteroidLayer.removeAllChildren()
        redLaserLayer.removeAllChildren()
        
        // set default indicators
        gameOver = false
        playerWasHit = false
        
        // unpause the game
        unpauseTheGame()
        
        // start the spawning of enemies
        enemySpawning()
    }
    
    // continue the game after collision while lives > 0
    func respawn() {
        
        unpauseTheGame()
        
        // set default indicator
        playerWasHit = false
        
        // set spaceShip at start position
        spaceShipLayer.position = CGPoint(x: width/2, y: height/4)
        
        // remove all asteroids and lasers from scene (screen)
        asteroidLayer.removeAllChildren()
        redLaserLayer.removeAllChildren()
    }
    
    // create and run enemy spaceShips
    func enemySpawning() {
        
        //
        let enemyAction = SKAction.run {
            
            // create enemy spaceShip
            let enemySpaceShip = EnemySpaceShip()
            
            // add enemy spaceShip to enemy layer
            self.enemyLayer.addChild(enemySpaceShip)
            
            // call fly method
            enemySpaceShip.fly()
        }
        
        // create pause between enemy creation
        let enemyWaitDuration = SKAction.wait(forDuration: 5, withRange: 3)
        
        // create sequence with eneymy creation and wait duration
        let enemySequence = SKAction.sequence([enemyAction, enemyWaitDuration])
        
        // create and run sequence forever
        let enemyRepeatSpawn = SKAction.repeatForever(enemySequence)
        run(enemyRepeatSpawn, withKey: "SpawnEnemy")
    }
    
    // spaceShip shooting feature
    @objc func playerSpaceShipFire() {
        
        // create red laser node
        let redLaser = SKSpriteNode(imageNamed: "redLaser")
        
        // reduce the scale of laser
        redLaser.xScale = 0.6
        redLaser.yScale = 0.6
        
        // set laser position on the scene (screen)
        redLaser.zPosition = 1
        redLaser.position = CGPoint(x: spaceShipLayer.position.x, y: spaceShipLayer.position.y)
        
        // create movement of laser
        let moveLaserAction = SKAction.move(by: CGVector(dx: 0, dy: 1000), duration: 3)
        
        // delete laser node from scene when it leave the screen
        let removeLaser = SKAction.removeFromParent()
        
        // create sequence with laser movement and deleting
        let laserSequence = SKAction.sequence([moveLaserAction, removeLaser])
        
        // run sequence forever
        redLaser.run(SKAction.repeatForever(laserSequence))
        
        // create phisics body of laser
        let redLaserTexture = SKTexture(imageNamed: "redLaser")
        redLaser.physicsBody = SKPhysicsBody(texture: redLaserTexture, size: redLaser.size)
        
        // set Bit mask category for laser and its collision and contact settings with other phisics bodies
        redLaser.physicsBody?.categoryBitMask = CollisionCategory.PlayerLaser
        redLaser.physicsBody?.contactTestBitMask = CollisionCategory.EnemySpaceShip
        redLaser.physicsBody?.collisionBitMask = CollisionCategory.EnemySpaceShip
        
        // gravity settings
        redLaser.physicsBody?.affectedByGravity = false
        redLaser.physicsBody?.isDynamic = false
        
        // add laser node to laser layer
        redLaserLayer.addChild(redLaser)
    }
    
    // analogue of viewDidLoad func
    
    override func didMove(to view: SKView) {
        
        // settings for random functions
        srand48(time(nil))
        
        // set GameScene as a delegate of SKPhysicsContactDelegate protocol
        physicsWorld.contactDelegate = self
        
        // change the gravity settings
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.8)
        
        // create and add to scene a background node
        background = SKSpriteNode(imageNamed: "background")
        background.zPosition = 0
        background.position = CGPoint(x: width/2, y: height/2)
        background.size = CGSize(width: width + 8, height: height + 12)
        addChild(background)
        
        // create stars emitter
        guard let starsPath = Bundle.main.path(forResource: "stars", ofType: "sks") else { return }
        let starsEmitter = NSKeyedUnarchiver.unarchiveObject(withFile: starsPath) as! SKEmitterNode
        starsEmitter.position = CGPoint(x: width/2, y: height)
        starsEmitter.particlePositionRange.dx = width
        starsEmitter.advanceSimulationTime(10)
        
        // create stars layer
        starsLayer = SKNode()
        starsLayer.zPosition = 1
        addChild(starsLayer)
        
        // add stars emitter to the stars layer
        starsLayer.addChild(starsEmitter)
        
        // create enemy layer
        enemyLayer = SKNode()
        enemyLayer.zPosition = 3
        addChild(enemyLayer)
        
        // create laser layer
        redLaserLayer = SKNode()
        redLaserLayer.zPosition = 1
        addChild(redLaserLayer)
        
        // create spaceShip and its phisics body properties
        spaceShip = SKSpriteNode(imageNamed: "spaceShip")
        spaceShip.physicsBody = SKPhysicsBody(texture: spaceShip.texture!, size: spaceShip.size)
        spaceShip.physicsBody?.isDynamic = false
        
        // reduce the scale of spaceShip
        spaceShip.xScale = 0.8
        spaceShip.yScale = 0.8
        
        // set Bit mask category for spaceShip and its collision and contact settings with other phisics bodies
        spaceShip.physicsBody?.categoryBitMask = CollisionCategory.PlayerSpaceShip
        spaceShip.physicsBody?.collisionBitMask = CollisionCategory.Asteroid
        spaceShip.physicsBody?.contactTestBitMask = CollisionCategory.Asteroid
        
        // create layer for spaceship and fire
        spaceShipLayer = SKNode()
        spaceShipLayer.zPosition = 2
        spaceShip.zPosition = 1
        
        // add spaceShip node to the spaceShip layer
        spaceShipLayer.addChild(spaceShip)
        addChild(spaceShipLayer)
        
        // create fire
        guard let firePath = Bundle.main.path(forResource: "fire", ofType: "sks") else { return }
        let fireEmitter = NSKeyedUnarchiver.unarchiveObject(withFile: firePath) as! SKEmitterNode
        fireEmitter.zPosition = 0
        fireEmitter.position.y = -40
        
        // reduce the scale of fireEmitter
        fireEmitter.xScale = 0.8
        fireEmitter.yScale = 0.8
        
        // add fire node to the spaceShip layer
        spaceShipLayer.addChild(fireEmitter)
        
        // create asteroid layer
        asteroidLayer = SKNode()
        asteroidLayer.zPosition = 3
        addChild(asteroidLayer)
        
        // create asteroids and add them to the asteroid layer
        let asteroidCreateAction = SKAction.run {
            let asteroid = self.creatAnAsteroid()
            self.asteroidLayer.addChild(asteroid)
        }
        
        // create and run forever the sequence of asteroid generation and delay between it
        let asteroidsPerSecond: Double = 1
        let asteroidCreationDelay = SKAction.wait(forDuration: 1.0 / asteroidsPerSecond, withRange: 0.5)
        let asteroidSequenceAction = SKAction.sequence([asteroidCreateAction, asteroidCreationDelay])
        let asteroidRunAction = SKAction.repeatForever(asteroidSequenceAction)
        asteroidLayer.run(asteroidRunAction)
        
        playMusic()
        resetTheGame()
        enemySpawning()
        
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(playerSpaceShipFire), userInfo: nil, repeats: true)
    }
    
    // background music
    func playMusic() {
        let musicPath = Bundle.main.url(forResource: "backgroundMusic", withExtension: "m4a")!
        musicPlayer = try! AVAudioPlayer(contentsOf: musicPath, fileTypeHint: nil)
        musicOnOrOff()
        
        // duration of background music with negative value of loops is infinite
        musicPlayer.numberOfLoops = -1
        musicPlayer.volume = 0.2
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !gameIsPaused {
            
            // take the first touch of screen
            if let toch = touches.first {
                
                // define the point of the first toch
                let tochLocation = toch.location(in: self)
                
//                // create spaceship action and accept it
//                let distance = distanceCalc(a: spaceShipLayer.position, b: tochLocation)
//                let speed: CGFloat = 600
//                let time = timeToTravelDistance(distance: distance, speed: speed)
//                let moveActoin = SKAction.move(to: tochLocation, duration: time)
//                moveActoin.timingMode = SKActionTimingMode.easeInEaseOut
//
//                spaceShipLayer.run(moveActoin)
//
//                // background paralax effect
//                let bgMoveAction = SKAction.move(to: CGPoint(x: -tochLocation.x / 80 + frame.size.width / 2, y: -tochLocation.y / 80 + frame.size.height / 2), duration: time)
//
//                background.run(bgMoveAction)
//
//                // stars move paralax effect
//                let starsMoveAction = SKAction.move(to: CGPoint(x: -tochLocation.x / 60, y: -tochLocation.y / 60), duration: time)
//
//                starsLayer.run(starsMoveAction)
                
                if atPoint(tochLocation) == spaceShip {
                    lastLocation = tochLocation
                    spaceShipPickedUp = true
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !gameIsPaused {
            if let toch = touches.first {
                
                // define the point of the first toch
                let tochLocation = toch.location(in: self)
                
                if spaceShipPickedUp {
                    
                    // move spaceShip with finger during the touch
                    let movement = CGPoint(x: tochLocation.x - lastLocation.x, y: tochLocation.y - lastLocation.y)
                    
                    // avoiding a micro jumps of spaceShip when player`s finger toches the spaceShip near it edge
                    spaceShipLayer.position.x += movement.x
                    spaceShipLayer.position.y += movement.y
                    
                    // save the last location of spaceShip
                    lastLocation = tochLocation
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        spaceShipPickedUp = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        spaceShipPickedUp = false
    }
    
    // distance calculation func (test version)
    func distanceCalc(a: CGPoint, b: CGPoint) -> CGFloat {
        return sqrt((b.x - a.x)*(b.x - a.x) + (b.y - a.y)*(b.y - a.y))
    }
    
    // flight time counting func
    func timeToTravelDistance(distance: CGFloat, speed: CGFloat) -> TimeInterval {
        let time = distance / speed
        return TimeInterval(time)
    }
    
    func creatAnAsteroid() -> SKSpriteNode {
        
        let asteroidImageArray = ["asteroid","asteroid2"]
        let randomIndex = Int(arc4random()) % asteroidImageArray.count
        let asterioid = SKSpriteNode(imageNamed: asteroidImageArray[randomIndex])
        
        // change the scale of asteroids within 0.2 - 0.5 from the initial size
        let randomScale = CGFloat(arc4random() % 4 + 2) / 10
        asterioid.xScale = randomScale
        asterioid.yScale = randomScale
        
        // set the position of appearence of asteroids
        asterioid.position.x = CGFloat(arc4random() % UInt32(frame.size.width))
        asterioid.position.y = frame.size.height + asterioid.size.height
        
        // assign a phisics body to the asteroid
        asterioid.physicsBody = SKPhysicsBody(texture: asterioid.texture!, size: asterioid.size)
        asterioid.name = "asteroid"
        
        asterioid.physicsBody?.categoryBitMask = CollisionCategory.Asteroid
        asterioid.physicsBody?.collisionBitMask = CollisionCategory.PlayerSpaceShip | CollisionCategory.Asteroid
        asterioid.physicsBody?.contactTestBitMask = CollisionCategory.PlayerSpaceShip
        
        asterioid.physicsBody?.angularVelocity = CGFloat(drand48() * 2 - 1) * 3
        let asteroidSpeedX: CGFloat = 100
        asterioid.physicsBody?.velocity.dx = CGFloat(drand48() * 2 - 1) * asteroidSpeedX
        
        return asterioid
    }
    
    override func update(_ currentTime: TimeInterval) {
//        let asteroid = creatAnAsteroid()
//        addChild(asteroid)
    }
    
    override func didSimulatePhysics() {
        asteroidLayer.enumerateChildNodes(withName: "asteroid") { (asteroid, stop) in
            if asteroid.position.y < 0 {
                asteroid.removeFromParent()
                
                self.addPoints(points: 1)
            }
        }
    }
    
    func addPoints(points: Int) {
        gameSettings.currentScore += points
        gameDelegate?.gameDelegateDidUpdateScore(score: gameSettings.currentScore)
    }
    
    // collision of two bodies
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == CollisionCategory.PlayerSpaceShip && contact.bodyB.categoryBitMask == CollisionCategory.Asteroid || contact.bodyB.categoryBitMask == CollisionCategory.PlayerSpaceShip && contact.bodyA.categoryBitMask == CollisionCategory.Asteroid {
            
            if !gameOver && !playerWasHit {
                
                playerWasHit = true
                pauseTheGame()
                // define animation of collision with asteroid
                
                // create disappearence effect
                let fadeOutAction = SKAction.fadeOut(withDuration: 0.1)
                fadeOutAction.timingMode = SKActionTimingMode.easeOut
                
                // create appearence effect
                let fadeInAction = SKAction.fadeIn(withDuration: 0.1)
                fadeInAction.timingMode = SKActionTimingMode.easeIn
                
                // unite effects above and repeat them 3 times (blink repeat action)
                let blinkAction = SKAction.sequence([fadeOutAction, fadeInAction])
                let blinkRepeatAction = SKAction.repeat(blinkAction, count: 3)
                
                // create action that wait 0.2 sec after blink effect
                let delayAction = SKAction.wait(forDuration: 0.2)
                
                // run block where we call the game over delegate method
                let gameOverAction = SKAction.run {
                    
                    // -1 live when spaceship hits by asteroid
                    self.gameSettings.lives -= 1
                    self.gameDelegate?.gameDelegateDidUpdateLives()
                    
                    if self.gameSettings.lives > 0 {
                        // continue the game
                        self.respawn()
                    } else {
                        self.gameSettings.recordScores(score: self.gameSettings.currentScore)
                        self.gameDelegate?.gameDelegateGameOver(score: self.gameSettings.currentScore)
                        self.gameOver = true
                        self.pauseTheGame()
                    }
                }
                
                // assign all actions in one sequence
                let gameOverSequence = SKAction.sequence([blinkRepeatAction, delayAction, gameOverAction])
                
                // assign the action sequence to spaceship
                spaceShipLayer.run(gameOverSequence)
            }
            soundOnOrOff()
        }
        
        if contact.bodyA.categoryBitMask == CollisionCategory.PlayerLaser && contact.bodyB.categoryBitMask == CollisionCategory.EnemySpaceShip || contact.bodyA.categoryBitMask == CollisionCategory.EnemySpaceShip && contact.bodyB.categoryBitMask == CollisionCategory.PlayerLaser {
            
            let firsBody = contact.bodyA.node
            let secondBody = contact.bodyB.node
            
            // avoiding multi collisions
            firsBody?.physicsBody?.categoryBitMask = CollisionCategory.None
            secondBody?.physicsBody?.categoryBitMask = CollisionCategory.None
            
            firsBody!.removeFromParent()
            secondBody!.removeFromParent()
            
            addPoints(points: 3)
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
    }
}
