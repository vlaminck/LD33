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
    
    var damage: Int {
        get {
            switch self {
            case .Slow, .Fast: return 1
            case .Double: return 2
            }
        }
    }
    
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
    
    func laserShape() -> SKShapeNode {
        switch self {
        case .Slow, .Fast, .Double:
            let laserShape = SKShapeNode(rect: CGRect(x: 0, y: -2, width: 20, height: 4))
            laserShape.fillColor = SKColor.whiteColor()
            laserShape.strokeColor = SKColor.redColor()
            laserShape.glowWidth = 3
            return laserShape
        }
    }
    
    func bulletNode() -> Bullet { // TODO: probably move this into Bullet.swift
        switch self {
        case .Slow, .Fast:
            let bullet = Bullet(type: self)
            bullet.addChild(laserShape())
            return bullet
        case .Double:

            let topLaser = laserShape()
            topLaser.position.y = 12
            let bottomLaser = laserShape()
            bottomLaser.position.y = -12
            
            let bullet = Bullet(type: self)
            bullet.addChild(topLaser)
            bullet.addChild(bottomLaser)
            return bullet
        }
    }
    
}
