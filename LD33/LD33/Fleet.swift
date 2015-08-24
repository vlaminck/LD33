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

protocol FleetDelegate {
    func didFinish()
}

class Fleet {
    
    let type: EnemyType
    let count: Int
    var aliveCount: Int
    private weak var scene: SKScene?
    let patternOrder: FleetPatternOrder
    let delegate: FleetDelegate?
    
    deinit {
        if let delegate = delegate {
            delegate.didFinish()
        }
    }
    
    init(type: EnemyType, count: Int, scene: SKScene?, patternOrder: FleetPatternOrder, delegate: FleetDelegate?) {
        self.type = type
        self.count = count
        self.scene = scene
        self.patternOrder = patternOrder
        self.delegate = delegate

        self.aliveCount = count
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
        switch type {
        case .A:
            let start = CGPoint(x: sceneSize.width + 200, y: 200)
            let center = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
            let end = CGPoint(x: -200, y: sceneSize.height - 200)

            let bezierPath = UIBezierPath()
            bezierPath.moveToPoint(start)
            bezierPath.addCurveToPoint(center, controlPoint1: CGPointMake(start.x, start.y), controlPoint2: CGPointMake(center.x, start.y))
            bezierPath.addCurveToPoint(end, controlPoint1: CGPointMake(center.x, end.y), controlPoint2: CGPointMake(end.x, end.y))

            return bezierPath.CGPath
        case .B:
            let start = CGPoint(x: sceneSize.width + 200, y: 200)
            let center = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
            let end = CGPoint(x: -200, y: sceneSize.height - 200)
            
            let bezierPath = UIBezierPath()
            bezierPath.moveToPoint(start)
            bezierPath.addCurveToPoint(center, controlPoint1: start, controlPoint2: CGPointMake(center.x, start.y))
            bezierPath.addCurveToPoint(end, controlPoint1: CGPointMake(center.x, end.y), controlPoint2: start)

            return bezierPath.CGPath
        }
    }
    
    func createInversePath(sceneSize: CGSize) -> CGPath {
        switch type {
        case .A:
            let start = CGPoint(x: sceneSize.width + 200, y: sceneSize.height - 200)
            let center = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
            let end = CGPoint(x: -200, y: 200)

            let bezierPath = UIBezierPath()
            bezierPath.moveToPoint(start)
            bezierPath.addCurveToPoint(center, controlPoint1: CGPointMake(start.x, start.y), controlPoint2: CGPointMake(center.x, start.y))
            bezierPath.addCurveToPoint(end, controlPoint1: CGPointMake(center.x, end.y), controlPoint2: CGPointMake(end.x, end.y))
            
            return bezierPath.CGPath
        case .B:
            let start = CGPoint(x: sceneSize.width + 200, y: sceneSize.height - 200)
            let center = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
            let end = CGPoint(x: -200, y: 200)
            
            let bezierPath = UIBezierPath()
            bezierPath.moveToPoint(start)
            bezierPath.addCurveToPoint(center, controlPoint1: CGPointMake(end.x, sceneSize.height), controlPoint2: CGPointMake(end.x, center.y))
            bezierPath.addCurveToPoint(end, controlPoint1: CGPointMake(start.x, center.y), controlPoint2: center)
            
            return bezierPath.CGPath
        }
    }
    
    func createEnemies() -> [Enemy] {
        return (0..<count).map { _ in return Enemy(type: type, delegate: self) }
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
                SKAction.followPath(path, asOffset: false, orientToPath: false, duration: type.pathDuration),
                SKAction.removeFromParent()
            ])
        }
    }
    
    func totalDuration() -> NSTimeInterval {
        return type.pathDuration * NSTimeInterval(count)
    }
    
}

extension Fleet: EnemyDelegate {
    func didRemoveEnemy() {
        aliveCount--
    }
}
