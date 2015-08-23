//
//  PowerUp.swift
//  LD33
//
//  Created by Steven Vlaminck on 8/22/15.
//  Copyright © 2015 MikeDave. All rights reserved.
//

import SpriteKit

class PowerUp: SKSpriteNode {

    convenience init() {
        self.init(texture: nil, color: UIColor.blueColor(), size: CGSize(width: 50, height: 50))

        let physicsBody = SKPhysicsBody(circleOfRadius: 50)
        physicsBody.affectedByGravity = false
        physicsBody.categoryBitMask = PhysicsCategory.Powerup
        physicsBody.collisionBitMask = PhysicsCategory.None
        physicsBody.contactTestBitMask = PhysicsCategory.Player
        self.physicsBody = physicsBody
        
    }

    func move() {
        runAction(SKAction.sequence([
            SKAction.moveByX(-position.x, y: 0, duration: 5),
            SKAction.removeFromParent()
        ]))
    }

}
