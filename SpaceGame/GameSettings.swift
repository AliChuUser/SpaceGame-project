//
//  GameSettings.swift
//  SpaceGame
//
//  Created by Aleksei Chudin on 06/05/2019.
//  Copyright © 2019 Aleksei Chudin. All rights reserved.
//

import UIKit

// saving game settings to and fetching them from UserDefaults container
class GameSettings: NSObject {
    
    var highScore: Int
    var currentScore: Int
    var lastScore: Int
    var lives: Int
    
    let startingNumberOfLives = 3
    
    let keyHighScore = "highScore"
    let keyLastScore = "lastScore"
    
    override init() {
        highScore = 0
        currentScore = 0
        lastScore = 0
        lives = startingNumberOfLives
        
        super.init()
        
        loadGameSettings()
    }
    
    func recordScores(score: Int) {
        
        if score > highScore {
            highScore = score
        }
        lastScore = score
        
        saveGameSettings()
    }
    
    func saveGameSettings() {
        
        // saving data to UserDefaults
        UserDefaults.standard.set(highScore, forKey: keyHighScore)
        UserDefaults.standard.set(lastScore, forKey: keyLastScore)
    }
    
    func loadGameSettings() {
        
        // fetching data from UserDefaults
        highScore = UserDefaults.standard.integer(forKey: keyHighScore)
        lastScore = UserDefaults.standard.integer(forKey: keyLastScore)
    }
    
    // local game reset
    func reset() {
        currentScore = 0
        lives = startingNumberOfLives
    }
    
    // completely reset settings (not yet implemented)
    func resetHighScore() {
        highScore = 0
        lastScore = 0
        saveGameSettings()
    }
    
    // default description (test version)
    override var description: String {
        return "highScore: \(highScore), lastScore: \(lastScore), currentScore: \(currentScore)"
    }

}
