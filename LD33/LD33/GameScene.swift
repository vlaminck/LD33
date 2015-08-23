//
//  GameScene.swift
//  LD33
//
//  Created by Steven Vlaminck on 8/22/15.
//  Copyright (c) 2015 MikeDave. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None     : UInt32 = 0
    static let All      : UInt32 = UInt32.max
    static let Player   : UInt32 = 0b1      // 1
    static let Enemy    : UInt32 = 0b10     // 2
    static let Bullet   : UInt32 = 0b100    // 4
    static let Powerup  : UInt32 = 0b1000   // 8
}

let playerCategory: UInt32 = 0x1 << 0
let enemyCategory: UInt32 = 0x1 << 1
let bulletCategory: UInt32 = 0x1 << 2

class GameScene: SKScene {
    
    let playerMovePointsPerSec: CGFloat = 1000.0
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    var velocity = CGPointZero
    var lastTouchLocation: CGPoint?
    
    var player: Player!
    var moveBulletAction: SKAction!
    
    var score: Int = 0 {
        willSet {
            if score / 1000 < newValue / 1000 {
                // drop a free powerup for every 100 points earned
                dropPowerup()
            }
        }
        didSet {
            scoreLabel.text = String(format: "Score: %06d", score)
        }
    }
    var scoreLabel: SKLabelNode = SKLabelNode(text: "")
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        
        player = Player()
        player.position = CGPoint(x: -200, y: size.height / 2)
        addChild(player)
        
        physicsWorld.contactDelegate = self
        
        score = 0
        addChild(scoreLabel)
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.horizontalAlignmentMode = .Right
        scoreLabel.position = CGPoint(x: size.width - 20, y: size.height - scoreLabel.frame.size.height - 110)
     
        runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.playSoundFileNamed("Invader.mp3", waitForCompletion: true),
            SKAction.waitForDuration(10)
        ])))
        
        gameStart()
    }
    
    func gameStart() {
        let enemyString = SKAction.repeatAction(SKAction.sequence([
            SKAction.runBlock { [weak self] in Enemy(type: .A).attackOn(self) },
            SKAction.waitForDuration(0.5)
            ]), count: 5)
        
        let keepEmComing = SKAction.repeatActionForever(SKAction.sequence([
            enemyString,
            SKAction.waitForDuration(5)
            ]))
        
        runAction(SKAction.sequence([
            SKAction.waitForDuration(15),
            keepEmComing
        ]))
        
        
        let introScreen = SKSpriteNode(texture: nil, color: UIColor.blackColor(), size: size)
        introScreen.anchorPoint = CGPointZero
        addChild(introScreen)
        
        let label = SKLabelNode(text: "GAME TITLE!!!")
        label.fontSize = 100
        introScreen.addChild(label)
        label.position = CGPoint(x: introScreen.size.width / 2, y: introScreen.size.height / 2)
        
        introScreen.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.waitForDuration(0.1),
            SKAction.runBlock {
                introScreen.color = SKColor.whiteColor()
            },
            SKAction.waitForDuration(0.1),
            SKAction.runBlock { [weak self] in
                if let randomColor = self?.randomColor() {
                    introScreen.color = randomColor
                }
            },
            SKAction.waitForDuration(0.1),
            SKAction.runBlock {
                introScreen.color = SKColor.blackColor()
            },
        ])))
        introScreen.runAction(SKAction.sequence([
            SKAction.moveByX(-size.width, y: 0, duration: 15),
            SKAction.removeFromParent()
        ]))
        
        player.runAction(SKAction.scaleBy(2, duration: 0))
        player.position = CGPoint(x: size.width + 200, y: size.height * 3/4)
        player.zRotation = CGFloat(M_PI_2) // face left
        
        let flyIn = SKAction.moveByX(400, y: 0, duration: 2)
        flyIn.timingMode = .EaseOut
        player.runAction(SKAction.sequence([
            SKAction.waitForDuration(10),
            SKAction.moveByX((size.width + 400) * -1, y: 0, duration: 4),
            SKAction.moveTo(CGPoint(x: -200, y: size.height / 2), duration: 1),
            SKAction.scaleBy(0.5, duration: 0),
            SKAction.rotateToAngle(CGFloat(-M_PI_2), duration: 0),
            flyIn,
            SKAction.runBlock { [weak self] in self?.player.startShooting() }
        ]))

    }
    
    func randomColor() -> SKColor {
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
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
    
    func dropPowerup() {
        let powerup = PowerUp()
        powerup.position = CGPoint(x: size.width + 100, y: size.height / 2)
        addChild(powerup)
        powerup.move()
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBeginContact(contact: SKPhysicsContact) {

        if let (_, _) = collision(contact, ordered: (Player.self, Enemy.self)) {
            do {
                try player.decrementPowerup()
            } catch {
                player.die()
            }
        }
        
        if let (bullet, enemy) = collision(contact, ordered: (Bullet.self, Enemy.self)) {
            bullet.removeFromParent()
            do {
                try enemy.hitByBullet(bullet.type)
            } catch {
                score += enemy.type.rawValue
            }
        }
        
        if let (_, powerup) = collision(contact, ordered: (Player.self, PowerUp.self)) {
            player.incrementPowerup()
            powerup.removeFromParent()
            score += 100
        }
    }
    
    func collision<T, U>(contact: SKPhysicsContact, ordered: (T.Type, U.Type)) -> (T, U)? {
        let things = (contact.bodyA.node, contact.bodyB.node)
        if let first = things.0 as? T, second = things.1 as? U {
            return (first, second)
        }
        if let first = things.1 as? T, second = things.0 as? U {
            return (first, second)
        }
        return nil
    }
    
}

