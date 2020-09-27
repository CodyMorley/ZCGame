//
//  GameOverScene.swift
//  ZombieConga
//
//  Created by Cody Morley on 9/27/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    let won: Bool
    
    init(size: CGSize, didWin: Bool) {
        won = didWin
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    override func didMove(to view: SKView) {
        var background: SKSpriteNode
        
        switch won {
        case true:
            background = SKSpriteNode(imageNamed: "YouWin")
            run(SKAction.playSoundFileNamed("win.wav",
                                            waitForCompletion: false))
        case false:
            background = SKSpriteNode(imageNamed: "YouLose")
            run(SKAction.playSoundFileNamed("lose.wav",
                                            waitForCompletion: false))
        }
        background.position = CGPoint(x: size.width/2,
                                      y: size.height/2)
        self.addChild(background)
        
        let wait = SKAction.wait(forDuration: 3.0)
        let block = SKAction.run {
            let myScene = GameScene(size: self.size)
            myScene.scaleMode = self.scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(myScene, transition: reveal)
        }
        self.run(SKAction.sequence([wait, block]))
    }
}
