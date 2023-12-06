//
//  GameState.swift
//  FinalProjectMurray
//
//  Created by user249178 on 11/15/23.
//

import Foundation

class GameState {
    var score: Int
    var highScore: Int
    var points: Int
    var lives: Int
    
    class var sharedInstance :GameState {
        struct Singleton {
            static let instance = GameState()
        }
        return Singleton.instance
    }
    
    init() {
        // Init
        score = 0
        highScore = 0
        points = 0
        lives = 3
        // Load game state
        let defaults = UserDefaults.standard
        highScore = defaults.integer(forKey: "highScore")
        points = defaults.integer(forKey: "points")
        lives = defaults.integer(forKey: "lives")
    }
    
    func saveState() {
        // Update highScore if the current score is greater
        highScore = max(score, highScore)
        // Store in user defaults
        let defaults = UserDefaults.standard
        defaults.set(highScore, forKey: "highScore")
        defaults.set(points, forKey: "points")
        defaults.set(lives, forKey: "lives")
        UserDefaults.standard.synchronize()
    }
}
