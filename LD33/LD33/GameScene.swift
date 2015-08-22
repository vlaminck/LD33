//
//  GameScene.swift
//  LD33
//
//  Created by Steven Vlaminck on 8/22/15.
//  Copyright (c) 2015 MikeDave. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let playerMovePointsPerSec: CGFloat = 800.0
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    var velocity = CGPointZero
    var lastTouchLocation: CGPoint?
    
    let player: SKSpriteNode = SKSpriteNode(imageNamed: "Spaceship")
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        player.position = CGPoint(x: 200, y: size.height / 2)
        player.zRotation = CGFloat(-M_PI_2)
        player.xScale = 0.25
        player.yScale = 0.25
        addChild(player)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        sceneTouched(touches.first)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        sceneTouched(touches.first)
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        if let lastTouch = lastTouchLocation {
            let diff = lastTouch - player.position
            if (diff.length() <= playerMovePointsPerSec * CGFloat(dt)) {
                player.position = lastTouchLocation!
                velocity = CGPointZero
            } else {
                moveSprite(player, velocity: velocity)
            }
        }
        
    }
    
    func sceneTouched(touch: UITouch?) {
        guard let touch = touch else { return }
        let location = touch.locationInNode(self)
        let offset = location - player.position
        let direction = offset.normalized()
        velocity = direction * playerMovePointsPerSec
        lastTouchLocation = location
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }
    
}