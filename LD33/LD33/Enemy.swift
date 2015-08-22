//
//  Enemy.swift
//  LD33
//
//  Created by Steven Vlaminck on 8/22/15.
//  Copyright © 2015 MikeDave. All rights reserved.
//

import SpriteKit

enum EnemyType: String {
    case A = "Spaceship" // "EnemyTypeA"
    
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
            case .A: return 2.5
            }
        }
    }
}

class Enemy: SKSpriteNode {
    
    var type: EnemyType = .A

    convenience init(type: EnemyType) {
        self.init(imageNamed: type.rawValue)
        self.type = type
        color = SKColor.redColor()
        
        // spaceship shit
        xScale = 0.3
        yScale = 0.3
        zRotation = CGFloat(M_PI_2)
    }
    
    func attackOn(scene: SKScene?) {
        guard let scene = scene else { return }
        scene.addChild(self)
        
//        position = CGPoint(x: size.width, y: size.height/4)
        
        runAction(SKAction.sequence([
            SKAction.waitForDuration(2.5),
            SKAction.sequence([
                SKAction.followPath(type.path(scene.size), asOffset: true, orientToPath: false, duration: type.pathDuration),
                SKAction.removeFromParent()
            ])
        ]))
    }
 
}
