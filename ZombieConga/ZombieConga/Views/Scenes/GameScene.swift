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
    /// Sprites & Gameplay Properties
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    var zombieInvincible: Bool = false
    var lives = 5
    var gameOver = false
    
    ///SKActions
    let zombieAnimation: SKAction
    let catCollisionSound = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    
    /// Physics and Scene Properties
    let playableRect: CGRect
    var lastTouchLocation: CGPoint?
    var velocity = CGPoint.zero
    let zombmieMovePointsPerSec: CGFloat = 480.0
    let zombieRotationRadiansPerSec: CGFloat = 4.0 * π
    let trainMovePointsPerSec: CGFloat = 480.0
    let cameraMovePointsPerSec: CGFloat = 200.0
    
    ///Camera
    let cameraNode = SKCameraNode()
    var cameraRect: CGRect {
        let x = cameraNode.position.x - size.width / 2 + (size.width - playableRect.width) / 2
        let y = cameraNode.position.y - size.height / 2 + (size.height - playableRect.height) / 2
        return CGRect(x: x,
                      y: y,
                      width: playableRect.width,
                      height: playableRect.height)
    }
    
    /// Update Timer
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    
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
        /*
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
        */
        move(sprite: zombie,
             velocity: velocity)
        rotate(sprite: zombie,
               direction: velocity,
               rotateRadiansPerSec: zombieRotationRadiansPerSec)
        
        boundsCheckZombie()
        moveTrain()
        
        if lives <= 0 && !gameOver {
            gameOver = true
            print("You Lose")
            backgroundMusicPlayer.stop()
            endGame(false)
        }
        
        //cameraNode.position = zombie.position
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    
    //MARK: - Movement -
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
//        let background = backgroundNode()
//        background.anchorPoint = CGPoint.zero
//        background.position = CGPoint.zero
//        background.name = "background"
//        background.zPosition = -1
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i) * background.size.width,
                                          y: 0)
            background.name = "background"
            background.zPosition = -1
            addChild(background)
        }
        
        zombie.position = CGPoint(x: 400, y: 400)
        zombie.zPosition = 100
        
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        addChild(zombie)
        addChild(cameraNode)
        
        run(SKAction.repeatForever(
                SKAction.sequence([SKAction.run() { [weak self] in
                    self?.spawnEnemy()
                },
                SKAction.wait(forDuration: 2.0)])))
        
        run(SKAction.repeatForever(
                SKAction.sequence([SKAction.run() { [weak self] in
                    self?.spawnCat()
                },
                SKAction.wait(forDuration: 1.0)])))
        
        //debugDrawPlayableArea()
        playBackgroundMusic(filename: "backgroundMusic.mp3")
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
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
    
    func moveTrain() {
        var targetPosition = zombie.position
        var trainCount = 0
        
        enumerateChildNodes(withName: "train") { node, stop in
            trainCount += 1
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let distancePerSec = direction * self.trainMovePointsPerSec
                let distanceToMove = distancePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveBy(x: distanceToMove.x,
                                                 y: distanceToMove.y,
                                                 duration: actionDuration)
                node.run(moveAction)
            }
            targetPosition = node.position
        }
        
        if trainCount >= 15 && !gameOver {
            gameOver = true
            print("YOU WIN!")
            backgroundMusicPlayer.stop()
            endGame(true)
        }
    }
    
    func moveCamera() {
        let backgroundVelocity = CGPoint(x: cameraMovePointsPerSec,
                                         y: 0)
        let distanceToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += distanceToMove
        
        enumerateChildNodes(withName: "background") { node, _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width < self.cameraRect.origin.x {
                background.position = CGPoint(x: background.position.x + background.size.width * 2,
                                              y: background.position.y)
            }
        }
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
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: cameraRect.minX,
                                 y: cameraRect.minY)
        let topRight = CGPoint(x: cameraRect.maxX,
                               y: cameraRect.maxY)
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = abs(velocity.x)
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
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1.0)
        cat.zRotation = 0
        
        let greenify = SKAction.colorize(with: SKColor.green,
                                         colorBlendFactor: 1.0,
                                         duration: 0.2)
        cat.run(greenify)
        run(catCollisionSound)
    }
    
    func zombieHit(enemy: SKSpriteNode) {
        zombieInvincible = true
        let blinks = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let slice = duration / blinks
            let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        let setHidden = SKAction.run() { [weak self] in
            self?.zombie.isHidden = false
            self?.zombieInvincible = false
        }
        zombie.run(SKAction.sequence([blinkAction, setHidden]))
        run(enemyCollisionSound)
        loseCats()
        lives -= 1
    }
    
    func loseCats() {
        var loseCount = 0
        enumerateChildNodes(withName: "train") { (node, stop) in
            var randomPosition = node.position
            randomPosition.x += CGFloat.random(min: 100, max: 100)
            randomPosition.y += CGFloat.random(min: 100, max: 100)
            
            node.name = ""
            node.run(SKAction.sequence(
                        [SKAction.group(
                            [SKAction.rotate(byAngle: π * 4, duration: 1.0),
                             SKAction.move(to: randomPosition, duration: 1.0),
                             SKAction.scale(to: 0, duration: 1.0)]),
                         SKAction.removeFromParent()]))
            
            loseCount += 1
            if loseCount >= 2 {
                stop[0] = true
            }
        }
    }
    
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        var hitEnemies: [SKSpriteNode] = []
        
        if zombieInvincible {
            return
        }
        
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
    
    
    //MARK: - Background -
    func backgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        
        backgroundNode.size = CGSize(width: background1.size.width + background2.size.width,
                                     height: background1.size.height)
        return backgroundNode
    }
    
    
    //MARK: - Cat Lady -
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(x: cameraRect.maxX + enemy.size.width / 2,
                                 y: CGFloat.random(min: cameraRect.minY + enemy.size.height / 2,
                                                   max: cameraRect.maxY - enemy.size.height / 2))
        enemy.zPosition = 50
        addChild(enemy)
        
        let actionMove = SKAction.moveBy(x: -(size.width + enemy.size.width),
                                         y: 0,
                                         duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    
    //MARK: - Cat -
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(x: CGFloat.random(min: cameraRect.minX,
                                                 max: cameraRect.maxX),
                               y: CGFloat.random(min: cameraRect.minY,
                                                 max: cameraRect.maxY))
        cat.zPosition = 50
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
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
    }
    
    private func endGame(_ didWin: Bool) {
        let gameOverScene = GameOverScene(size: size, didWin: didWin)
        gameOverScene.scaleMode = scaleMode
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        view?.presentScene(gameOverScene, transition: reveal)
    }
}
