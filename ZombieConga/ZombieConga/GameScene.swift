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
    //MARK: - Properties -
    // Sprites
    let background = SKSpriteNode(imageNamed: "background1") ///This is a sprite it uses SKSpriteNode
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    
    // Update Timer
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    // Physics and Scene Properties
    let zombmieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    let zombieRotationRadiansPerSec: CGFloat = 4.0 * π
    let playableRect: CGRect
    var lastTouchLocation: CGPoint?
    
    
    //SKActions
    let zombieAnimation: SKAction
    
    
    //MARK: - Inits -
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 2.16
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight)/2.0
        
        playableRect = CGRect(x: 0,
                              y: playableMargin,
                              width: size.width,
                              height: playableHeight)
        
        var textures:[SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        zombieAnimation = SKAction.animate(with: textures,
                                           timePerFrame: 0.1)
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Game State -
    override func update(_ currentTime: TimeInterval) {
        checkUpdateTime(currentTime)
        /// Game loop
        //zombie.position = CGPoint(x: zombie.position.x + 8, y: zombie.position.y)
        //move(sprite: zombie, velocity: CGPoint(x: zombmieMovePointsPerSec, y: 0))
        if let lastTouch = lastTouchLocation {
            let touchLocationDiff = lastTouch - zombie.position
            if touchLocationDiff.length() <= zombmieMovePointsPerSec * CGFloat(dt) {
                zombie.position = lastTouch
                velocity = CGPoint.zero
                stopZombieAnimation()
            } else {
                move(sprite: zombie,
                     velocity: velocity)
                rotate(sprite: zombie,
                       direction: velocity,
                       rotateRadiansPerSec: zombieRotationRadiansPerSec)
            }
        }
        boundsCheckZombie()
        checkCollisions()
    }
    
    
    //MARK: - Movement -
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
        //zombie.run(SKAction.repeatForever(zombieAnimation))
        
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
            self?.spawnEnemy()
                },
                SKAction.wait(forDuration: 2.0)]))) // Normally SpriteKit cleans up the memory for its' own nodes but in closures we must use weak references.
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnCat()
                },
                               SKAction.wait(forDuration: 1.0)])))
        //let mySize = background.size
        //print("Size: \(mySize)")
        debugDrawPlayableArea()
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        //print("Amount to move: \(amountToMove)")
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint) {
        startZombieAnimation()
        let offset = location - zombie.position
        let direction = offset.normalized()
        velocity = direction * zombmieMovePointsPerSec
    }
    
    func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation,
                                            angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    
    //MARK: - Animation -
    func startZombieAnimation() {
        if zombie.action(forKey: "animation") == nil {
            zombie.run(SKAction.repeatForever(zombieAnimation),
                       withKey: "animation")
        }
    }
    
    func stopZombieAnimation() {
        zombie.removeAction(forKey: "animation")
    }
    
    //MARK: - Touch -
    func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
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
    
    
    //MARK: - Playable Area -
    /*
     Might be a good idea to set playable area to device visible area.
     For this game it would make the ipad version very very easy but keep in mind for future.
     */
    func boundsCheckZombie() {
        //let bottomLeft = CGPoint.zero
        //let topRight = CGPoint(x: size.width, y: size.height)
        let bottomLeft = CGPoint(x: 0,
                                 y: playableRect.minY)
        let topRight = CGPoint(x: size.width,
                               y: playableRect.maxY)
        
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
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode(rect: playableRect)
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    
    //MARK: - Collision Detection -
    func zombieHit(cat: SKSpriteNode) {
        cat.removeFromParent()
    }
    
    func zombieHit(enemy: SKSpriteNode) {
        enemy.removeFromParent()
    }
    
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        var hitEnemies: [SKSpriteNode] = []
        
        enumerateChildNodes(withName: "cat") { node, _ in
            let cat = node as! SKSpriteNode
            if cat.frame.intersects(self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        
        enumerateChildNodes(withName: "enemy") { node, _ in
            let enemy = node as! SKSpriteNode
            if node.frame.insetBy(dx: 20, dy: 20).intersects(
                self.zombie.frame) {
                hitEnemies.append(enemy)
            }
        }
        
        for cat in hitCats {
            zombieHit(cat: cat)
        }
        
        for enemy in hitEnemies {
            zombieHit(enemy: enemy)
        }
    }
    
    
    //MARK: - Cat Lady -
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(x: size.width + enemy.size.width / 2,
                                 y: CGFloat.random(min: playableRect.minY + enemy.size.height / 2,
                                                   max: playableRect.maxY - enemy.size.height / 2))
        addChild(enemy)
        let actionMove = SKAction.moveTo(x: -enemy.size.width / 2,
                                         duration: 2)
        let actionRemove = SKAction.removeFromParent()
        /*
        let actionMidMove = SKAction.moveBy(
            x: -size.width / 2 - enemy.size.width / 2,
            y: -playableRect.height / 2 + enemy.size.height / 2,
            duration: 1.0)
        //let reverseMid = actionMidMove.reversed()
        let actionMove = SKAction.moveBy(
            x: -size.width / 2 - enemy.size.width / 2,
            y: playableRect.height / 2 - enemy.size.height / 2,
            duration: 1.0)
        //let reverseMove = actionMove.reversed()
        let wait = SKAction.wait(forDuration: 0.25)
        let logMessage = SKAction.run() {
            print("Reached Bottom.")
        }
        let halfSequence = SKAction.sequence([actionMidMove,
                                              logMessage,
                                              wait,
                                              actionMove])
        let sequence = SKAction.sequence([halfSequence,
                                         halfSequence.reversed()])
        /*let sequence = SKAction.sequence([actionMidMove,
                                          logMessage, wait,
                                          actionMove,
                                          reverseMove,
                                          logMessage, wait,
                                          reverseMid])*/
        let repeatAction = SKAction.repeatForever(sequence)
        */
        enemy.run(SKAction.sequence([actionMove,
                                     actionRemove]))
    }
    
    
    //MARK: - Cat -
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(x: CGFloat.random(min: playableRect.minX,
                                                 max: playableRect.maxX),
                               y: CGFloat.random(min: playableRect.minY,
                                                 max: playableRect.maxY))
        cat.setScale(0)
        addChild(cat)
        
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotate(byAngle: π / 8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence([scaleUp, scaleDown,
                                           scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeat(group, count: 10)
        let disappear = SKAction.scale(to: 0.0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        
        cat.run(SKAction.sequence(actions))
    }
    
    
    //MARK: - Helper Methods -
    private func checkUpdateTime(_ currentTime: TimeInterval) {
        /// Print time since update info
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        //print("\(dt*1000) milliseconds since last update")
    }
}
