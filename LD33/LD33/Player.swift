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

enum PlayerPowerup: Int {
    case SlowBullet = 0
    case FastBullet
    case DoubleBullet

    var imageName: String {
        get {
            return "Spaceship"
        }
    }
    
    var shootingSpeed: NSTimeInterval {
        get {
            switch self {
            case .SlowBullet: return 0.2
            case .FastBullet: return 0.1
            case .DoubleBullet: return 0.1
            }
        }
    }
    
    func isFirst() -> Bool {
        return self == .SlowBullet
    }

    func isLast() -> Bool {
        return self == .FastBullet
    }
    
    func next() -> PlayerPowerup? {
        return PlayerPowerup(rawValue: self.rawValue + 1)
    }

    func previous() -> PlayerPowerup? {
        return PlayerPowerup(rawValue: self.rawValue - 1)
    }
    
    func bulletAction(sceneSize size: CGSize) -> SKAction {
        switch self {
        case .SlowBullet: return SKAction.sequence([
            SKAction.moveByX(size.width, y: 0, duration: 1),
            SKAction.removeFromParent()
            ])
        case .FastBullet: return SKAction.sequence([
            SKAction.moveByX(size.width, y: 0, duration: 0.5),
            SKAction.removeFromParent()
            ])
        case .DoubleBullet: return SKAction.sequence([
            SKAction.moveByX(size.width, y: 0, duration: 0.5),
            SKAction.removeFromParent()
            ])
        }
    }
    
    func bulletNode() -> SKSpriteNode {
        switch self {
        case .SlowBullet, .FastBullet:
            let node = SKSpriteNode(texture: nil, size: CGSize(width: 20, height: 4))
            let bulletNode = SKShapeNode(rect: CGRect(x: 0, y: -2, width: 20, height: 4))
            bulletNode.fillColor = SKColor.whiteColor()
            bulletNode.strokeColor = SKColor.redColor()
            bulletNode.glowWidth = 3
            node.addChild(bulletNode)
            return node
        case .DoubleBullet:
            let bulletNode = SKSpriteNode(texture: nil, size: CGSize(width: 20, height: 20))

            let topBullet = PlayerPowerup.SlowBullet.bulletNode()
            topBullet.position.y = 12
            let bottomBullet = PlayerPowerup.SlowBullet.bulletNode()
            bottomBullet.position.y = -12
            
            bulletNode.addChild(topBullet)
            bulletNode.addChild(bottomBullet)

            return bulletNode
        }
    }

}

class Player: SKSpriteNode {
    
    var powerupLevel: PlayerPowerup = .SlowBullet {
        didSet {
            startShooting()
        }
    }
    var moveBulletAction: SKAction?
    
    
    convenience init() {
        let initialPowerupLevel: PlayerPowerup = .SlowBullet
        self.init(imageNamed: initialPowerupLevel.imageName)

        // spaceship shit
        xScale = 0.3
        yScale = 0.3
        zRotation = CGFloat(-M_PI_2)
    }
    
    func incrementPowerup() {
        if let powerupLevel = powerupLevel.next() {
            self.powerupLevel = powerupLevel
        }
    }
    
    func decrementPowerup() throws {
        guard let powerupLevel = powerupLevel.previous() else { throw PlayerError.PlayerDied }
        self.powerupLevel = powerupLevel
    }
    
    func shoot() {
        guard let scene = scene, moveBulletAction = moveBulletAction else { return }
        
        let bulletNode = powerupLevel.bulletNode()
        bulletNode.position = CGPoint(x: position.x + size.width / 2, y: position.y)// - bulletNode.size.width / 2)
        scene.addChild(bulletNode)
        bulletNode.runAction(moveBulletAction)
    }
    
    func updateBulletAction() {
        guard let scene = scene else { return }
        moveBulletAction = powerupLevel.bulletAction(sceneSize: scene.size)
    }
    
    func startShooting() {
        removeActionForKey(shootingKey)
        updateBulletAction()
        let shootingAction = SKAction.repeatActionForever(SKAction.sequence([
            SKAction.runBlock { [weak self] in self?.shoot() },
            SKAction.waitForDuration(powerupLevel.shootingSpeed)
        ]))
        runAction(shootingAction, withKey: shootingKey)
    }

    
}
