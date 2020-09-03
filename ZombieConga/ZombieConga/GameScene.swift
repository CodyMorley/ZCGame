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
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black ///spritekit uses colors of type SKColor
        // Sprites
        let background = SKSpriteNode(imageNamed: "background1") ///This is a sprite it uses SKSpriteNode
        let zombie = SKSpriteNode(imageNamed: "zombie1")
        
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) /// default
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        //background.zRotation = CGFloat.pi / 8
        zombie.position = CGPoint(x: 400, y: 400)
        zombie.scale(to: CGSize(width: zombie.size.width * 2, height: zombie.size.height * 2))
        
        
        addChild(background) /// This adds the sprite (SKNode) as a child of the scene (SKScene)
        addChild(zombie)
        let mySize = background.size
        print("Size: \(mySize)")
    }
}
