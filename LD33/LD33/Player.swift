//
//  Player.swift
//  LD33
//
//  Created by Steven Vlaminck on 8/22/15.
//  Copyright © 2015 MikeDave. All rights reserved.
//

import SpriteKit

public enum PlayerError: ErrorType {
    case PlayerDied
}

enum PlayerPowerup: Int {
    case SlowBullet = 0
    case FastBullet

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
}

class Player: SKSpriteNode {
    
    var powerupLevel: PlayerPowerup = .SlowBullet
    
    func incrementPowerup() {
        if let powerupLevel = powerupLevel.next() {
            self.powerupLevel = powerupLevel
        }
    }
    
    func decrementPowerup() throws {
        guard let powerupLevel = powerupLevel.previous() else { throw PlayerError.PlayerDied }
        self.powerupLevel = powerupLevel
    }
    
}
