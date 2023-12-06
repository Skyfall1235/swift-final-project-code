//
//  GameScene.swift
//  MegaJumpMurray
//
//  Created by user249178 on 11/14/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate 
{
    var backgroundNode: SKNode!
    var midgroundNode: SKNode!
    var foregroundNode: SKNode!
    var hudNode: SKNode!
    
    //Labels for score and stars
    var lblScore: SKLabelNode!
    var lblStars: SKLabelNode!

    
    var maxPlayerY: Int!
    
    var gameOver = false
    
    //Height at which the level end
    var endLevelY = 0
    
    //tap to start node
    let tapToStartNode = SKSpriteNode(imageNamed: "TapToStart")     
    //player
    var player: SKNode!
    
    var scaleFactor: CGFloat!

    override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = SKColor.white
        maxPlayerY = 80
        GameState.sharedInstance.score = 0
        gameOver = false         
        //add some gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: -2)
        //Set contact delegate
        physicsWorld.contactDelegate = self         
        self.scaleFactor = self.size.width / 320
        backgroundNode = createBackgroundNode()
        addChild(backgroundNode)
        //Midground
        midgroundNode = createMidgroundNode()
        addChild(midgroundNode)    
        //foreground
        foregroundNode = SKNode()
        addChild(foregroundNode)
        //HUD
        hudNode = SKNode()
        addChild(hudNode)
        //Load the level
        let levelPlist = Bundle.main.path(forResource: "Level01", ofType: "plist")
        let levelData = NSDictionary(contentsOfFile: levelPlist!)!
        //height at which the player ends the level
        endLevelY = levelData["EndY"]! as! Int
        //Add the platforms
        let platforms = levelData["Platforms"] as! NSDictionary
        let platformPatterns = platforms["Patterns"] as! NSDictionary
        let platformPositions = platforms["Positions"] as! [NSDictionary]
        for platformPosition in platformPositions {
        let patternX = platformPosition["x"] as! CGFloat
        let patternY = platformPosition["y"] as! CGFloat
        let pattern = platformPosition["pattern"] as! String
        //look up the pattern
        let plaformPattern = platformPatterns[pattern] as! [NSDictionary]
        for platformPoint in plaformPattern {
        let x = platformPoint["x"] as! CGFloat
        let y = platformPoint["y"] as! CGFloat
        let type = PlatformType(rawValue: platformPoint["type"] as! Int)
        let positionX = x + patternX
        let positionY = y + patternY
        let platformNode = createPlatformAtPosition(position: CGPoint(x: positionX, y: positionY), ofType: type!)
        foregroundNode.addChild(platformNode)
            }
            // Build the HUD
            // Stars
            // 1
            let star = SKSpriteNode(imageNamed: "Star")
            star.position = CGPoint(x: 25, y: self.size.height-30)
            hudNode.addChild(star)
             // 2
            lblStars = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
            lblStars.fontSize = 30
            lblStars.fontColor = SKColor.white
            lblStars.position = CGPoint(x: 50, y: self.size.height-40)
            lblStars.horizontalAlignmentMode = .left
            // 3
            lblStars.text = String(format: "X %d", GameState.sharedInstance.stars)
            hudNode.addChild(lblStars)
             // Score
            // 4
            lblScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
            lblScore.fontSize = 30
            lblScore.fontColor = SKColor.white
            lblScore.position = CGPoint(x: self.size.width-20, y: self.size.height-40)
            lblScore.horizontalAlignmentMode = .right
            // 5
            lblScore.text = "0"
            hudNode.addChild(lblScore)
        }
        
        let stars = levelData["Stars"] as! NSDictionary
        let starPatterns = stars["Patterns"] as! NSDictionary
        let starPositions = stars["Positions"] as! [NSDictionary]
        for starPosition in starPositions {
        let patternX = starPosition["x"] as! CGFloat
        let patternY = starPosition["y"] as! CGFloat
        let pattern = starPosition["pattern"] as! NSString
        // Look up the pattern
        let starPattern = starPatterns[pattern] as! [NSDictionary]
        for starPoint in starPattern {
        let x = starPoint["x"] as! CGFloat
        let y = starPoint["y"] as! CGFloat
        let type = StarType(rawValue: starPoint["type"] as! Int)
        let positionX = x + patternX
        let positionY = y + patternY
        let starNode = createStarAtPosition(position: CGPoint(x: positionX, y: positionY), ofType: type!)
        foregroundNode.addChild(starNode)
            }
        }
        collisionWithPlayer
        //add the player
        player = createPlayer()
        foregroundNode.addChild(player)
        //Tap to Start
        tapToStartNode.position = CGPoint(x: size.width/2, y: 180)
        hudNode.addChild(tapToStartNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
    }

    func createBackgroundNode() -> SKNode{
    //1 create the node
    let backgroundNode = SKNode()
    let ySpacing = 64.0 * scaleFactor
    //2 go through the images until the entire background is built
        for index in 0...19 {
            //3
            let imageName = String(format:"Background%02d", index+1)
            let node = SKSpriteNode(imageNamed: imageName)
            //4
            node.setScale(scaleFactor)
            node.anchorPoint = CGPoint(x: 0.5, y: 0)
            node.position = CGPoint(x: size.width/2, y: ySpacing * CGFloat(index))
            //5
            backgroundNode.addChild(node)
            
        }
    //6 return the completed background node
    return backgroundNode
}
    override func update(_ currentTime: TimeInterval) {
        if gameOver {return}
        //New max height?
        //1
        if Int(player.position.y) > maxPlayerY! {
            //2
            GameState.sharedInstance.score += Int(player.position.y) - maxPlayerY!
            //3
            maxPlayerY = Int(player.position.y)
            //4
            lblScore.text = String(format: "X %d", GameState.sharedInstance.score)
        }
        //remove game objects that have passed by
        foregroundNode.enumerateChildNodes(withName: "PLATFORM", using: {
            (node, stop) in
            let platform = node as! PlatformNode
            platform.checkNodeRemoval(playerY: self.player.position.y)
        })
        foregroundNode.enumerateChildNodes(withName: "STAR", using: {
            (node, stop) in
            let star = node as! StarNode
            star.checkNodeRemoval(playerY: self.player.position.y)
        })
        // Called before each frame is rendered
        //Calculate the player y offset
        if player.position.y > 200 {
            backgroundNode.position = CGPoint(x: 0, y:-((player.position.y - 200)/10))
            midgroundNode.position = CGPoint(x: 0, y:-((player.position.y - 200)/4))
            foregroundNode.position = CGPoint(x: 0, y:-(player.position.y - 200))
        }
        if(player.position.x > size.width - player.frame.size.width) {
            player.position.x = size.width - player.frame.size.width
            player.physicsBody?.velocity.dx = 0
        }
        if(player.position.x < player.frame.size.width) {
            player.position.x = player.frame.size.width
            player.physicsBody?.velocity.dx = 0
        }
        
        //1 Check if we have finished the level
        if Int(player.position.y) > endLevelY {
            endGame()
        }
        //2 Check if we have fallen too far
        if Int(player.position.y) < maxPlayerY - 800 {
            endGame()
        }
    }
    
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    //if we are playing, ignore touches

    if player.physicsBody!.isDynamic {
    return
    }
    //2 remove the tap to start node
    tapToStartNode.removeFromParent()
    //3 start the player by putting them into the physics simulation
    player.physicsBody?.isDynamic = true
    //4
    player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
}
    
override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first
    else {return}
    if(touch.location(in: self).x > player.position.x) {
    player.physicsBody?.velocity.dx = 80 //applyImpulse((CGVector(dx: 5, dy: 0)))
    }
    else {
    player.physicsBody?.velocity.dx = -80 //applyImpulse((CGVector(dx: -5, dy: 0)))
    }
}
    
    
    
    
func didBegin(_ contact: SKPhysicsContact) {
    let bodyA = contact.bodyA.node
    let bodyB = contact.bodyB.node
    



    var updateHUD = false
    let whichNode = (contact.bodyA.node != player) ? contact.bodyA.node : contact.bodyB.node
    let other = whichNode as! GameObjectNode
    updateHUD = other.collisionWithPlayer(player: player)
    //Update the HUD if necessary
    if updateHUD {
        lblStars.text = String(format: "X %d", GameState.sharedInstance.stars)
        lblScore.text = String(format: "X %d", GameState.sharedInstance.score)
    }
}
    
func createPlatformAtPosition(position: CGPoint, ofType type: PlatformType) -> PlatformNode {
    //1
    let node = PlatformNode()
    node.position = CGPoint(x: position.x * scaleFactor, y: position.y)
    node.name = "PLATFORM"
    node.platformType = type
    //2
    var sprite: SKSpriteNode
    if type == .Break {
    sprite = SKSpriteNode(imageNamed: "PlatformBreak")
    }
    else {
    sprite = SKSpriteNode(imageNamed: "Platform")
    }
    node.addChild(sprite)
    //3
    node.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
    node.physicsBody?.isDynamic = false
    node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Platform
    node.physicsBody?.collisionBitMask = 0
    return node
    }
    
    
    
    func createStarAtPosition(position: CGPoint, ofType type: StarType) -> StarNode {
    //1
    let node = StarNode()
    node.position = CGPoint(x: position.x * scaleFactor, y: position.y)
    node.name = "STAR"
    //2
    node.starType = type
    var sprite : SKSpriteNode
    if type == .Special {
    sprite = SKSpriteNode(imageNamed: "StarSpecial")
        }
        else {
    sprite = SKSpriteNode(imageNamed: "Star")
    }
    node.addChild(sprite)
    //3
    node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
    //4
    node.physicsBody?.isDynamic = false
    node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Star
    node.physicsBody?.collisionBitMask = 0
    return node
}
    
func createPlayer() -> SKNode {
    let playerNode = SKNode()
    playerNode.position = CGPoint(x: size.width/2, y: 80)
    let sprite = SKSpriteNode(imageNamed: "Player")
    playerNode.addChild(sprite)
    //1
    playerNode.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
    //2
    playerNode.physicsBody?.isDynamic = false
    //3
    playerNode.physicsBody?.allowsRotation = false
    //4
    playerNode.physicsBody?.restitution = 1
    playerNode.physicsBody?.friction = 0
    playerNode.physicsBody?.angularDamping = 0
    playerNode.physicsBody?.linearDamping = 0
    //1
    playerNode.physicsBody?.usesPreciseCollisionDetection = true
    //2
    playerNode.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player
    //3
    playerNode.physicsBody?.collisionBitMask = 0
    //4
    playerNode.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.coin | CollisionCategoryBitmask.enemy    
    return playerNode
}
    

func createMidgroundNode() -> SKNode {
    // Create the node
    let theMidgroundNode = SKNode()
    var anchor: CGPoint!
    var xPosition: CGFloat!
    // 1
    // Add some branches to the midground
    for index in 0...9 {
    
        var spriteName: String
        // 2
        let r = arc4random() % 2
        if r > 0 {
            spriteName = "BranchRight"
            anchor = CGPoint(x: 1.0, y: 0.5)
            xPosition = self.size.width
                }
        else {
            spriteName = "BranchLeft"
            anchor = CGPoint(x: 0.0, y: 0.5)
            xPosition = 0.0
            }
    // 3
    let branchNode = SKSpriteNode(imageNamed: spriteName)
    branchNode.anchorPoint = anchor
    branchNode.position = CGPoint(x: xPosition, y: 500.0 * CGFloat(index))
    theMidgroundNode.addChild(branchNode)
        }
    // Return the completed midground node
    return theMidgroundNode
    }
    
func endGame() {
    //1
    gameOver = true
    //2 save stars and high score
    GameState.sharedInstance.saveState()
    //3
    let reveal = SKTransition.fade(withDuration: 0.5)
    let endGameScene = EndGameScene(size: self.size)
    self.view!.presentScene(endGameScene, transition: reveal)
    }
    
    
}
