//
//  GameScene.swift
//  LD33
//
//  Created by Steven Vlaminck on 8/22/15.
//  Copyright (c) 2015 MikeDave. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let playerMovePointsPerSec: CGFloat = 1000.0
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    var velocity = CGPointZero
    var lastTouchLocation: CGPoint?
    
    var player: Player!
    var moveBulletAction: SKAction!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        
        player = Player()
        player.position = CGPoint(x: 200, y: size.height / 2)
        addChild(player)
        player.startShooting()
        
        testEnemy()
        
        runAction(SKAction.sequence([
            SKAction.waitForDuration(2),
            SKAction.runBlock { [weak self] in self?.player.incrementPowerup() },
            SKAction.waitForDuration(2),
            SKAction.runBlock { [weak self] in self?.player.incrementPowerup() }
        ]))

    }
    
    func testEnemy() {
        Enemy(type: .A).attackOn(self)
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
    
    func shoot() {
        let bulletNode = SKShapeNode(rect: CGRect(x: 0, y: -2, width: 20, height: 4))
        bulletNode.fillColor = SKColor.whiteColor()
        bulletNode.strokeColor = SKColor.redColor()
        bulletNode.glowWidth = 3
        bulletNode.position = CGPoint(x: player.position.x + player.size.width / 2 - 20, y: player.position.y)
        addChild(bulletNode)
        bulletNode.runAction(moveBulletAction)
    }
    
    func updateBulletAction() {
        // TODO: update based on player powerup level
        moveBulletAction = SKAction.sequence([
            SKAction.moveByX(size.width, y: 0, duration: 1),
            SKAction.removeFromParent()
        ])
    }
    
}