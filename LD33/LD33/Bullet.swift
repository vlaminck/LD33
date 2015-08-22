//
//  Bullet.swift
//  LD33
//
//  Created by Steven Vlaminck on 8/22/15.
//  Copyright © 2015 MikeDave. All rights reserved.
//

import SpriteKit

class Bullet: SKSpriteNode {
    
    var type: BulletType
    
    init(type: BulletType) {
        self.type = type
        super.init(texture: nil, color: UIColor.clearColor(), size: Bullet.bulletSize(type))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func bulletSize(type: BulletType) -> CGSize {
        switch type {
        case .Slow, .Fast: return CGSize(width: 20, height: 4)
        case .Double: return CGSize(width: 20, height: 20)
        }
    }
    
}
