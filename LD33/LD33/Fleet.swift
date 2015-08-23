//
//  Fleet.swift
//  LD33
//
//  Created by Steven Vlaminck on 8/23/15.
//  Copyright © 2015 MikeDave. All rights reserved.
//

import SpriteKit

enum FleetPatternOrder {
    case Normal
    case Inverse
    case Mixed
}

class Fleet {
    
    let type: EnemyType
    let count: Int
    private weak var scene: SKScene?
    let patternOrder: FleetPatternOrder
    
    init(type: EnemyType, count: Int, scene: SKScene?, patternOrder: FleetPatternOrder) {
        self.type = type
        self.count = count
        self.scene = scene
        self.patternOrder = patternOrder
    }
    
    func attack() {
        guard let scene = scene else { return }
        
        let enemies = createEnemies()
        let paths = actionPaths(scene.size)
        let actions = enemyActions(paths)

        for (enemy, action) in zip(enemies, actions) {
            scene.addChild(enemy)
            enemy.runAction(action)
        }
        
    }
    
    func createPath(sceneSize: CGSize) -> CGPath {
        let start = CGPoint(x: sceneSize.width + 200, y: 200)
        let center = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        let end = CGPoint(x: -200, y: sceneSize.height - 200)
        
        switch type {
        case .A:
            let bezierPath = UIBezierPath()
            bezierPath.moveToPoint(start)
            bezierPath.addCurveToPoint(center, controlPoint1: CGPointMake(start.x, start.y), controlPoint2: CGPointMake(center.x, start.y))
            bezierPath.addCurveToPoint(end, controlPoint1: CGPointMake(center.x, end.y), controlPoint2: CGPointMake(end.x, end.y))
            return bezierPath.CGPath
        }
    }
    
    func createInversePath(sceneSize: CGSize) -> CGPath {
        let start = CGPoint(x: sceneSize.width + 200, y: sceneSize.height - 200)
        let center = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        let end = CGPoint(x: -200, y: 200)
        
        switch type {
        case .A:
            let bezierPath = UIBezierPath()
            bezierPath.moveToPoint(start)
            bezierPath.addCurveToPoint(center, controlPoint1: CGPointMake(start.x, start.y), controlPoint2: CGPointMake(center.x, start.y))
            bezierPath.addCurveToPoint(end, controlPoint1: CGPointMake(center.x, end.y), controlPoint2: CGPointMake(end.x, end.y))
            return bezierPath.CGPath
        }
    }
    
    func createEnemies() -> [Enemy] {
        return (0..<count).map { _ in return Enemy(type: type) }
    }
    
    func actionPaths(sceneSize: CGSize) -> [CGPath] {
        switch patternOrder {
        case .Normal: return [createPath(sceneSize)]
        case .Inverse: return [createInversePath(sceneSize)]
        case .Mixed: return [createPath(sceneSize), createInversePath(sceneSize)]
        }
    }
    
    func enemyActions(paths: [CGPath]) -> [SKAction] {
        return (1...count).map { i in
            let path = paths[i % paths.count]
            return SKAction.sequence([
                SKAction.waitForDuration(NSTimeInterval(i)),
                SKAction.followPath(path, asOffset: false, orientToPath: false, duration: enemyPathDuration()),
                SKAction.removeFromParent()
            ])
        }
    }
    
    func enemyPathDuration() -> NSTimeInterval {
        var duration: NSTimeInterval = 0
        switch type {
        case .A: duration = 5
        }
        return duration
    }
    
    func totalDuration() -> NSTimeInterval {
        return enemyPathDuration() * NSTimeInterval(count)
    }
    
}
