//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Cody Morley on 9/27/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "MainMenu")
        background.position = CGPoint(x: size.width/2,
                                      y: size.height/2)
        self.addChild(background)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first != nil else { return }
        startGame()
    }
    
    private func startGame() {
        let newGameScene = GameScene(size: self.size)
        let transition = SKTransition.doorway(withDuration: 1.5)
        view?.presentScene(newGameScene, transition: transition)
    }
}
