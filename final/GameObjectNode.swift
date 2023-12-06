//
//  GameObjectNode.swift
//  FinalProjectMurray
//
//  Created by user249178 on 11/15/23.
//

import SpriteKit

struct CollisionCategoryBitmask 
{
    static let Player: UInt32 = 0x00
    static let Coin: UInt32 = 0x01
    static let Enemy: UInt32 = 0x02
}

class GameObjectNode: SKNode 
{
    func collisionWithPlayer(player: SKNode) -> Bool 
    {
        return false
    }
    
    func collisionWithLaser(laser: SKNode) -> Bool 
    {
        return false
    }

    func collisionWithEnemy(enemy: SKNode) -> Bool
    {
        return false
    }
    
    func checkNodeRemoval(playerY: CGFloat) 
    {
        let magicNumForPositionalRemoval = 300
        if playerY > self.position.y + magicNumForPositionalRemoval {
            self.removeFromParent()
        }
        //should remove it it goes too far up, i think
        if playerY < self.position.y - magicNumForPositionalRemoval {
            self.removeFromParent()
        }
    }
}

class PointNode: GameObjectNode 
{
    let pointSound = SKAction.playSoundFileNamed(".wav", waitForCompletion: false)
    
    override func collisionWithPlayer(player: SKNode) -> Bool 
    {
        //play sound and add to score
        run(pointSound, completion: {self.removeFromParent()})
        //Award score
        GameState.sharedInstance.score += 20
        //the HUD needs to be updated to show the new stars and score
        GameState.sharedInstance.points += 1
        return true
    }
}

class LaserNode: GameObjectNode
{
    //fill in sound
    let laserSound = SKAction.playSoundFileNamed(".wav", waitForCompletion: false)

    override func collisionWithEnemy(enemy: SKNode) -> Bool 
    {
        //remove itself, the 4enemy will resolve its own collisions
        self.removeFromParent()
        return true
    }
}
    
class EnemyNode: GameObjectNode 
{
    let enemyDeathSound = SKAction.playSoundFileNamed(".wav", waitForCompletion: false)
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        //deduct a life
        GameState.sharedInstance.lives -= 1
        run(enemyDeathSound, completion: {self.removeFromParent()})
        return true
    }
    override func collisionWithLaser(laser: SKNode) -> Bool {
        //die and spawn a point
        GameState.sharedInstance.score += 3
        run(enemyDeathSound, completion: {self.removeFromParent()})
        return true
    }
}

