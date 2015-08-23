//
//  Wave.swift
//  LD33
//
//  Created by Steven Vlaminck on 8/23/15.
//  Copyright © 2015 MikeDave. All rights reserved.
//

import SpriteKit

protocol WaveDelegate {
    func waveCompleted(number: Int)
}

class Wave {
    
    let number: Int
    let scene: SKScene?
    
    var delegate: WaveDelegate?
    
    var fleetCount: Int = 0
    
    deinit {
        if let delegate = delegate {
            delegate.waveCompleted(number)
        }
    }
    
    init(number: Int, scene: SKScene, delegate: WaveDelegate?) {
        self.number = number
        self.scene = scene
        self.delegate = delegate
    }
    
    func start() {
        guard let scene = scene else { return }

        let fleets = createFleets()
        fleetCount = fleets.count
        
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
        
    }
    
    func fleetDelay() -> NSTimeInterval {
        return NSTimeInterval(2)
    }
    
    func createFleets() -> [Fleet] {
        guard let scene = scene else { return [] }
        
        switch number {
        case 1:
            return [
                Fleet(type: .A, count: 1, scene: scene, patternOrder: .Normal, delegate: self),
                Fleet(type: .A, count: 1, scene: scene, patternOrder: .Inverse, delegate: self),
                Fleet(type: .A, count: 8, scene: scene, patternOrder: .Mixed, delegate: self)
            ]
        case 2:
            return [
                Fleet(type: .B, count: 10, scene: scene, patternOrder: .Mixed, delegate: self)
            ]
        default: return []
        }
    }
    
}

extension Wave: FleetDelegate {
    func didFinish() {
        fleetCount--
    }
}
