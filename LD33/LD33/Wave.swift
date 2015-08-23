//
//  Wave.swift
//  LD33
//
//  Created by Steven Vlaminck on 8/23/15.
//  Copyright © 2015 MikeDave. All rights reserved.
//

import SpriteKit

class Wave {
    
    let number: Int
    let scene: SKScene?
    
    init(number: Int, scene: SKScene) {
        self.number = number
        self.scene = scene
    }
    
    func start() {
        guard let scene = scene else { return }

        let fleets = createFleets()
        
        var delay = NSTimeInterval(0)

        let fleetActions: [SKAction] = fleets.map { fleet in
            let action = SKAction.sequence([
                SKAction.waitForDuration(delay),
                SKAction.runBlock {
                    fleet.attack()
                }
            ])
            delay += fleet.totalDuration()
            return action
        }
        
        for action in fleetActions {
            scene.runAction(action)
        }
        
        for fleet in fleets {
            scene.runAction(SKAction.sequence([
                SKAction.waitForDuration(delay),
                SKAction.runBlock {
                    delay = fleet.totalDuration()
                    fleet.attack()
                }
            ]))
        }
    }
    
    func fleetDelay() -> NSTimeInterval {
        return NSTimeInterval(2)
    }
    
    func createFleets() -> [Fleet] {
        guard let scene = scene else { return [] }
        
        switch number {
        case 0:
            return [
                Fleet(type: .A, count: 1, scene: scene, patternOrder: .Normal),
                Fleet(type: .A, count: 1, scene: scene, patternOrder: .Inverse),
                Fleet(type: .A, count: 8, scene: scene, patternOrder: .Mixed)
            ]
            default: return []
        }
    }
    
}
