//
//  GameScene.swift
//  FinalProjectMurray
//
//  Created by user249178 on 11/15/23.
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
    var lblcoins: SKLabelNode!
    var lbllives: SKLabelNode!
    
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
        backgroundColor = SKColor.gray
        maxPlayerY = 80
        GameState.sharedInstance.score = 0
        gameOver = false
        //add some gravity
        //physicsWorld.gravity = CGVector(dx: 0, dy: -2)
        //Set contact delegate
        self.scaleFactor = self.size.width / 320
        
        
        
        //sets up the background and foreground nodes
        setupBackground()
        //builds the hud for the player
        buildHud()

        

        
        //add the player
        player = createPlayer()
        foregroundNode.addChild(player)
        //Tap to Start
        tapToStartNode.position = CGPoint(x: size.width/2, y: 180)
        hudNode.addChild(tapToStartNode)
    }
    required init?(coder aDecoder: NSCoder) 
    {
    fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    override func update(_ currentTime: TimeInterval) 
    {
        if gameOver {return}
        
        //remove game objects that have passed by
        foregroundNode.enumerateChildNodes(withName: "Enemy", using: 
        {
            (node, stop) in
            let enemy = node as! EnemyNode
            enemy.checkNodeRemoval(playerY: self.player.position.y)
        })        
        foregroundNode.enumerateChildNodes(withName: "Point", using: 
        {
            (node, stop) in
            let point = node as! PointNode
            point.checkNodeRemoval(playerY: self.player.position.y)
        })
        foregroundNode.enumerateChildNodes(withName: "Laser", using: 
        {
            (node, stop) in
            let laser = node as! LaserNode
            laser.checkNodeRemoval(playerY: self.player.position.y)
        })
        // Called before each frame is rendered
        //Calculate the player y offset
        if(player.position.x > size.width - player.frame.size.width) 
        {
            player.position.x = size.width - player.frame.size.width
            player.physicsBody?.velocity.dx = 0
        }
        if(player.position.x < player.frame.size.width) 
        {
            player.position.x = player.frame.size.width
            player.physicsBody?.velocity.dx = 0
        }
        
        //if the player gets hit by an enemy, the game ends
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) 
    {

        //if we are playing, ignore touches
        if player.physicsBody!.isDynamic {return }

        //remove the starting node
        tapToStartNode.removeFromParent()
        //start shooting lasers


        //also, start spawning enemies

        player.physicsBody?.isDynamic = true
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) 
    {
    guard let touch = touches.first
    else {return}
    if(touch.location(in: self).x > player.position.x) 
        {
        player.physicsBody?.velocity.dx = 80 //applyImpulse((CGVector(dx: 5, dy: 0)))
        }
    else 
        {
        player.physicsBody?.velocity.dx = -80 //applyImpulse((CGVector(dx: -5, dy: 0)))
        }
    }
    
    
    
    //THIS IS WHERE YOU CHECK FOR COLLISIONS
    //im sleep deprived, IGNORE ME
    func didBegin(_ contact: SKPhysicsContact) 
    {
        //i need both collsion nodes
        let bodyA = contact.bodyA.node
        let bodyB = contact.bodyB.node
        //i need this to be initialized before we start the computations
        var updateHUD = false
        

        //enemy to player
        if bodyA.categoryBitMask == CollisionCategoryBitmask.Player && bodyB.categoryBitMask == CollisionCategoryBitmask.Enemy
        {
            let player = bodyA.node as! SKNode
            let enemy = bodyB.node as! GameObjectNode
            //removed a life from the player,
            let loseLife = enemy.collisionWithPlayer(bodyA.node)
            

        }
        //enemy to laser
        if bodyA.categoryBitMask == CollisionCategoryBitmask.Enemy && bodyB.categoryBitMask == CollisionCategoryBitmask.Laser
        {
            let enemy = bodyA.node as! GameObjectNode
            let laser = bodyB.node as! GameObjectNode
            //kills the enemy and gives points
            let enemyDeath = enemy.collisionWithLaser(laser)
            //removes the laser
            let laserhit = laser.collisionWithEnemy(enemy)

            updateHUD = true

        }
        //player to coin (point was the bitmask and im too lazy to change it)
        if bodyA.categoryBitMask == CollisionCategoryBitmask.Player && bodyB.categoryBitMask == CollisionCategoryBitmask.Coin
        {
            let player = bodyA.node as! SKNode
            //load the collsion for the coin with the player
            let point = bodyB.node as! GameObjectNode
            point.collisionWithPlayer(player)
            updateHUD = true

        }


        
        //Update the HUD if necessary
        if updateHUD   
        {
        lblStars.text = String(format: "X %d", GameState.sharedInstance.points)
        lblScore.text = String(format: "X %d", GameState.sharedInstance.score)
        }
    }






    
    func createCoinAtPosition(_ position: CGPoint) -> PointNode 
    {
        //basic setup for the node
        let node = PointNode()
        node.position = CGPoint(x: position.x * scaleFactor, y: position.y)
        node.name = "Point"
        //set up the image sprite
        var sprite: SKSpriteNode
        sprite = SKSpriteNode(imageNamed: "coin2")
        node.addChild(sprite)
        //do the physics setup
        node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player
        node.physicsBody?.collisionBitMask = 0
        return node
    }
    
    func createPlayer() -> SKNode 
    {
        let playerNode = SKNode()
        playerNode.position = CGPoint(x: size.width/2, y: 80)
        let sprite = SKSpriteNode(imageNamed: "Player")
        playerNode.addChild(sprite)
        playerNode.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
        playerNode.physicsBody?.isDynamic = false
        playerNode.physicsBody?.allowsRotation = false
        playerNode.physicsBody?.restitution = 1
        playerNode.physicsBody?.friction = 0
        playerNode.physicsBody?.angularDamping = 0
        playerNode.physicsBody?.linearDamping = 0
        playerNode.physicsBody?.usesPreciseCollisionDetection = true
        playerNode.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player
        playerNode.physicsBody?.collisionBitMask = 0
        playerNode.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Coin | CollisionCategoryBitmask.Enemy    
        return playerNode
    }

    //spawns and starts a move up action for the laser
    func shootLaser(_ position: CGPoint) -> SKNode
    {
        let laserNode = LaserNode()
        laserNode.position = CGPoint(x: position.x * scaleFactor, y: position.y)
        laserNode.name = "Laser"

        //setup thye sprite and physics
        var sprite: SKSpriteNode
        sprite = SKSpriteNode(imageNamed: "laser1")
        laserNode.addChild(sprite)
        laserNode.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
        laserNode.physicsBody?.isDynamic = true
        laserNode.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Laser
        laserNode.physicsBody?.collisionBitMask = 1

        //run the move up action
        let moveUp = moveObjectUp()
        self.run(moveUp)
    }

    //spawns and starts a move down action for the enemy
    func createEnemy(_ position: CGPoint) -> SKNode
    {
        let enemyNode = EnemyNode()
        enemyNode.position = CGPoint(x: position.x * scaleFactor, y: position.y)
        enemyNode.name = "Enemy"

        var sprite: SKSpriteNode
        sprite = SKSpriteNode(imageNamed: "coin2")
        node.addChild(sprite)
        enemyNode.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
        enemyNode.physicsBody?.isDynamic = true
        enemyNode.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Enemy
        enemyNode.physicsBody?.collisionBitMask = 2


        //run the move down action
        let movedown = moveObjectDown()
        self.run(movedown)
    }

    //sets up a background node (may be expanded later)
    func createBackgroundNode() -> SKNode
    {
        let backgroundNode = SKSpriteNode(imageNamed: "background")

        return backgroundNode
    }
    
    func setupBackground()
    {
        backgroundNode = createBackgroundNode()
        addChild(backgroundNode)
    
        //foreground
        foregroundNode = SKNode()
        addChild(foregroundNode)
        //HUD
        hudNode = SKNode()
        addChild(hudNode)
        //start generating the level
    }

    func buildHud()
    {
        // Build the HUD
        //coins and text besides them
        let coin = SKSpriteNode(imageNamed: "coin2")
        coin.position = CGPoint(x: 25, y: self.size.height-30)
        hudNode.addChild(coin)
        lblcoins = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblcoins.fontSize = 30
        lblcoins.fontColor = SKColor.white
        lblcoins.position = CGPoint(x: 50, y: self.size.height-40)
        lblcoins.horizontalAlignmentMode = .left
        lblcoins.text = String(format: "X %d", GameState.sharedInstance.points)
        hudNode.addChild(lblcoins)
        // Score
        lblScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblScore.fontSize = 30
        lblScore.fontColor = SKColor.white
        lblScore.position = CGPoint(x: self.size.width-20, y: self.size.height-40)
        lblScore.horizontalAlignmentMode = .right
        lblScore.text = "0"
        hudNode.addChild(lblScore)
    }


    //movment funcs so i dont need to call them up SO MANY TIMES 
    func moveObjectUp() -> SKAction
    {
        let moveUpAction = SKAction.move(by: CGVector(dx: 0, dy: 100), duration: 1)

        // Repeat the action forever to create continuous upward movement
        let repeatAction = SKAction.repeatForever(moveUpAction)
        return repeatAction
    }

    func moveObjectDown() -> SKAction
    {
        let moveDownAction = SKAction.move(by: CGVector(dx: 0, dy: -100), duration: 1)

        // Repeat the action forever to create continuous upward movement
        let repeatAction = SKAction.repeatForever(moveDownAction)
        return repeatAction
    }
    
    //spawns in the enemy is formations randomly closen, along with coins for higher difficulty spawns
    func SpawnElements()
    {
        let spawnAction = SKAction
        //choose a location, spawn, and generate around it

        // Create a spawn action using SKAction.run
        let spawnAction = SKAction.run 
        {
            // this needs to be in the loop else it will only execute once
            // Create a random position within the screen bounds
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            let positionX = CGFloat.random(in: 0..<screenWidth)
            
            let positionY = screenHeight

            //spawn the base enemy
            let enemyNode = createEnemy(position: CGPoint(x: positionX, y: positionY))
            foregroundNode.addChild(coinNode)

            // generate any adittional units
            let addtionalUnits = Int.random(in: 0..<3)
            switch additionalUnits 
            {
                case 0:
                    // there are no additional units
                    print("No additional units")
                case 1:
                    // there is 1 additional unit
                    print("Spawn 1 additional unit")
                    let addtionalNode = createEnemy(position: CGPoint(x: positionX - 60, y: positionY))
                    foregroundNode.addChild(coinNode)
                case 2:
                    // there are 2 additional units, flanking each side of the basic unit
                    print("Spawn 2 additional units")
                    let addtionalNode = createEnemy(position: CGPoint(x: positionX - 60, y: positionY + 15))
                    foregroundNode.addChild(coinNode)
                    let addtionalNode = createEnemy(position: CGPoint(x: positionX + 60, y: positionY + 15))
                    foregroundNode.addChild(coinNode)

                    //add a coin in behind the main enemy
                    let addtionalNode = createCoinAtPosition(position: CGPoint(x: positionX, y: positionY + 60))
                    foregroundNode.addChild(coinNode)
                    default:
                    break   
            }
        }
        // Create a wait action to control the time between spawns
        let waitAction = SKAction.wait(forDuration: 1.00) 
        // spawn, wait, repeat
        let sequenceAction = SKAction.sequence([spawnAction, waitAction])
        // Repeat the sequence forever
        let repeatForeverAction = SKAction.repeatForever(sequenceAction)
        // Run the repeatForeverAction on the scene or a specific node
        self.run(repeatForeverAction)
    }

    //runs to close out the game and transition to the game over screen
    func endGame() 
    {
        gameOver = true
        // save points and high score
        GameState.sharedInstance.saveState()
        let reveal = SKTransition.fade(withDuration: 0.5)
        let endGameScene = EndGameScene(size: self.size)
        self.view!.presentScene(endGameScene, transition: reveal)
    }

    
}
