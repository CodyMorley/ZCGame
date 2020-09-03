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
        zombie.position = CGPoint(x: zombie.position.x + 8, y: zombie.position.y)
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
