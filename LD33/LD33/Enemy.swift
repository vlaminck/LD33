//
//  Enemy.swift
//  LD33
//
//  Created by Steven Vlaminck on 8/22/15.
//  Copyright © 2015 MikeDave. All rights reserved.
//

import SpriteKit

enum EnemyType: Int {
    case A = 3
    case B = 4
    
    var imageName: String {
        get {
            switch self {
            case .A: return "Spaceship"
            case .B: return "Spaceship"
            }
        }
    }
    
    func path(size: CGSize) -> CGPath {
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: size.width + 100, y: size.height/4))
        path.addLineToPoint(CGPoint(x: size.width/2, y: size.height/2))
        path.addLineToPoint(CGPoint(x: -100, y: size.height/4))
        return path.CGPath
    }
    
    var pathDuration: NSTimeInterval {
        get {
            switch (self) {
            case .A: return 4.0
            case .B: return 4.0
            }
        }
    }
}

protocol EnemyDelegate {
    func didRemoveEnemy()
}

class Enemy: SKSpriteNode {
    
    var type: EnemyType = .A
    var health: Int = EnemyType.A.rawValue
    var dropsPowerup: Bool = false
    
    var delegate: EnemyDelegate?
    
    deinit {
        if let delegate = delegate {
            delegate.didRemoveEnemy()
        }
    }
    
    convenience init(type: EnemyType, delegate: EnemyDelegate?) {
//        self.init(imageNamed: type.imageName)
        self.init(texture: nil, color: SKColor.whiteColor(), size: CGSize(width: 100, height: 100))
        self.type = type
        self.health = type.rawValue
        self.delegate = delegate
        
        let physicsBody = SKPhysicsBody(circleOfRadius: 50)
        physicsBody.affectedByGravity = false
        physicsBody.categoryBitMask = PhysicsCategory.Enemy
        physicsBody.collisionBitMask = PhysicsCategory.None
        physicsBody.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Bullet
        self.physicsBody = physicsBody

        // spaceship shit
//        size = CGSize(width: 100, height: 100)
        zRotation = CGFloat(M_PI_2)
        
        // TODO: figure out something better here
        dropsPowerup = Int(arc4random_uniform(10)) == 3 // TODO: get something figured out here
        
        let label = SKLabelNode(text: "Good Guy")
        label.fontColor = SKColor.blackColor()
        label.fontSize = 21
        addChild(label)

    }
    
    func attackOn(scene: SKScene?) {
        guard let scene = scene else { return }
        scene.addChild(self)
        
        runAction(SKAction.sequence([
            SKAction.waitForDuration(2.5),
            SKAction.sequence([
                SKAction.followPath(type.path(scene.size), asOffset: true, orientToPath: false, duration: type.pathDuration),
                SKAction.removeFromParent()
            ])
        ]))
    }
    
    func hitByBullet(type: BulletType) throws {
        health -= type.damage
        if health <= 0 {
            die()
            throw GameError.EnemyDied
        }
    }
    
    func die() {
        if let scene = scene where dropsPowerup {
            let powerup = PowerUp()
            powerup.position = self.position
            scene.addChild(powerup)
            powerup.move()
        }
        removeFromParent()
    }
 
}
