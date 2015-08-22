//
//  Player.swift
//  LD33
//
//  Created by Steven Vlaminck on 8/22/15.
//  Copyright © 2015 MikeDave. All rights reserved.
//

import SpriteKit

private let shootingKey = "playerShootingKey"

public enum PlayerError: ErrorType {
    case PlayerDied
}


class Player: SKSpriteNode {
    
    var bulletType: BulletType = .Slow {
        didSet {
            startShooting()
        }
    }
    var moveBulletAction: SKAction?
    
    
    convenience init() {
        let initialPowerupLevel: BulletType = .Slow
        self.init(imageNamed: initialPowerupLevel.imageName)

        // spaceship shit
        xScale = 0.3
        yScale = 0.3
        zRotation = CGFloat(-M_PI_2)
    }
    
    func incrementPowerup() {
        if let bulletType = bulletType.next() {
            self.bulletType = bulletType
        }
    }
    
    func decrementPowerup() throws {
        guard let bulletType = bulletType.previous() else { throw PlayerError.PlayerDied }
        self.bulletType = bulletType
    }
    
    func shoot() {
        guard let scene = scene, moveBulletAction = moveBulletAction else { return }
        
        let bulletNode = bulletType.bulletNode()
        bulletNode.position = CGPoint(x: position.x + size.width / 2, y: position.y)
        scene.addChild(bulletNode)
        bulletNode.runAction(moveBulletAction)
    }
    
    func updateBulletAction() {
        guard let scene = scene else { return }
        moveBulletAction = bulletType.bulletAction(sceneSize: scene.size)
    }
    
    func startShooting() {
        removeActionForKey(shootingKey)
        updateBulletAction()
        let shootingAction = SKAction.repeatActionForever(SKAction.sequence([
            SKAction.runBlock { [weak self] in self?.shoot() },
            SKAction.waitForDuration(bulletType.shootingSpeed)
        ]))
        runAction(shootingAction, withKey: shootingKey)
    }

    
}
