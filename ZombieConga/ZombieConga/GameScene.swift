//
//  GameScene.swift
//  ZombieConga
//
//  Created by Cody Morley on 9/1/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    // Sprites
    let background = SKSpriteNode(imageNamed: "background1") ///This is a sprite it uses SKSpriteNode
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    
    // Update Timer
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    let zombmieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black ///spritekit uses colors of type SKColor
        
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) /// default
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        //background.zRotation = CGFloat.pi / 8
        
        zombie.position = CGPoint(x: 400, y: 400)
        //zombie.scale(to: CGSize(width: zombie.size.width * 2, height: zombie.size.height * 2)) ///Method of SKSpriteNode
        //zombie.setScale(2) ///Method of SKNode
        
        addChild(background) /// This adds the sprite (SKNode) as a child of the scene (SKScene)
        addChild(zombie)
        //let mySize = background.size
        //print("Size: \(mySize)")
    }
    
    override func update(_ currentTime: TimeInterval) {
        checkUpdateTime(currentTime)
        
        /// Game loop
        //zombie.position = CGPoint(x: zombie.position.x + 8, y: zombie.position.y)
        //move(sprite: zombie, velocity: CGPoint(x: zombmieMovePointsPerSec, y: 0))
        move(sprite: zombie,
             velocity: velocity)
        boundsCheckZombie()
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt),
                                   y: velocity.y * CGFloat(dt))
        print("Amount to move: \(amountToMove)")
        sprite.position = CGPoint(x: sprite.position.x + amountToMove.x,
                                  y: sprite.position.y + amountToMove.y)
        
    }
    
    func moveZombieToward(location: CGPoint) {
        let offset = CGPoint(x: location.x - zombie.position.x,
                             y: location.y - zombie.position.y)
        let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
        let direction = CGPoint(x: offset.x / CGFloat(length),
                                y: offset.y / CGFloat(length))
        velocity = CGPoint(x: direction.x * zombmieMovePointsPerSec,
                           y: direction.y * zombmieMovePointsPerSec)
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        moveZombieToward(location: touchLocation)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint.zero
        let topRight = CGPoint(x: size.width, y: size.height)
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    private func checkUpdateTime(_ currentTime: TimeInterval) {
        /// Print time since update info
        if lastUpdateTime > 0 {
          dt = currentTime - lastUpdateTime
        } else {
          dt = 0
        }
        lastUpdateTime = currentTime
        print("\(dt*1000) milliseconds since last update")
    }
}
