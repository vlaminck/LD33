//
//  BulletType.swift
//  LD33
//
//  Created by Steven Vlaminck on 8/22/15.
//  Copyright © 2015 MikeDave. All rights reserved.
//

import SpriteKit

enum BulletType: Int { // consider renaming
    case Slow = 0
    case Fast
    case Double
    
    var imageName: String {
        get {
            return "Spaceship"
        }
    }
    
    var shootingSpeed: NSTimeInterval {
        get {
            switch self {
            case .Slow: return 0.2
            case .Fast: return 0.1
            case .Double: return 0.1
            }
        }
    }
    
    func isFirst() -> Bool {
        return self == .Slow
    }
    
    func isLast() -> Bool {
        return self == .Double
    }
    
    func next() -> BulletType? {
        return BulletType(rawValue: self.rawValue + 1)
    }
    
    func previous() -> BulletType? {
        return BulletType(rawValue: self.rawValue - 1)
    }
    
    func bulletAction(sceneSize size: CGSize) -> SKAction {
        switch self {
        case .Slow: return SKAction.sequence([
            SKAction.moveByX(size.width, y: 0, duration: 1),
            SKAction.removeFromParent()
            ])
        case .Fast: return SKAction.sequence([
            SKAction.moveByX(size.width, y: 0, duration: 0.5),
            SKAction.removeFromParent()
            ])
        case .Double: return SKAction.sequence([
            SKAction.moveByX(size.width, y: 0, duration: 0.5),
            SKAction.removeFromParent()
            ])
        }
    }
    
    func bulletNode() -> SKSpriteNode {
        switch self {
        case .Slow, .Fast:
            let node = SKSpriteNode(texture: nil, size: CGSize(width: 20, height: 4))
            let bulletNode = SKShapeNode(rect: CGRect(x: 0, y: -2, width: 20, height: 4))
            bulletNode.fillColor = SKColor.whiteColor()
            bulletNode.strokeColor = SKColor.redColor()
            bulletNode.glowWidth = 3
            node.addChild(bulletNode)
            return node
        case .Double:
            let bulletNode = SKSpriteNode(texture: nil, size: CGSize(width: 20, height: 20))
            
            let topBullet = BulletType.Slow.bulletNode()
            topBullet.position.y = 12
            let bottomBullet = BulletType.Slow.bulletNode()
            bottomBullet.position.y = -12
            
            bulletNode.addChild(topBullet)
            bulletNode.addChild(bottomBullet)
            
            return bulletNode
        }
    }
    
}
