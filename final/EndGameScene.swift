//
//  EndGameScene.swift
//  MegaJumpMurray
//
//  Created by user249178 on 11/14/23.
//

import SpriteKit

 

class EndGameScene: SKScene 
{
    required init?(coder aDecoder: NSCoder) 
    {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) 
    {
        super.init(size: size)
        // Stars
        
        let coin = SKSpriteNode(imageNamed: "coin")
        coin.position = CGPoint(x: 25, y: self.size.height-30)
        addChild(coin)
        let lblcoins = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblcoins.fontSize = 30
        lblcoins.fontColor = SKColor.white
        lblcoins.position = CGPoint(x: 50, y: self.size.height-40)
        lblcoins.horizontalAlignmentMode = .left
        lblcoins.text = String(format: "X %d", GameState.sharedInstance.score)
        addChild(lblcoins)
        // Score
        let lblScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblScore.fontSize = 60
        lblScore.fontColor = SKColor.white
        lblScore.position = CGPoint(x: self.size.width / 2, y: 300)
        lblScore.horizontalAlignmentMode = .center
        lblScore.text = String(format: "%d", GameState.sharedInstance.score)
        addChild(lblScore)
        // High Score
        let lblHighScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblHighScore.fontSize = 30
        lblHighScore.fontColor = SKColor.cyan
        lblHighScore.position = CGPoint(x: self.size.width / 2, y: 150)
        lblHighScore.horizontalAlignmentMode = .center
        lblHighScore.text = String(format: "High Score: %d", GameState.sharedInstance.highScore)
        addChild(lblHighScore)
        // Try again
        let lblTryAgain = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblTryAgain.fontSize = 30
        lblTryAgain.fontColor = SKColor.white
        lblTryAgain.position = CGPoint(x: self.size.width / 2, y: 50)
        lblTryAgain.horizontalAlignmentMode = .center
        lblTryAgain.text = "Tap To Try Again"
        addChild(lblTryAgain)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) 
    {
        // Transition back to the Game
        let reveal = SKTransition.fade(withDuration: 0.5)
        let gameScene = GameScene(size: self.size)
        self.view!.presentScene(gameScene, transition: reveal)
    }
    
    
}
