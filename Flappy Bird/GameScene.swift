//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Matthias Hofmann on 31.08.16.
//  Copyright © 2016 MatthiasHofmann. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    
    var scoreLabel = SKLabelNode()
    var score = 0
    
    var gameOverLabel = SKLabelNode()
    
    var timer = Timer()
    
    enum ColliderType: UInt32 {
    
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    var gameOver = false
    
    // Method to create pipes
    func makePipes() {
        
        // Add and remove Pipes
        
        let movePipes = SKAction.move(by: CGVector(dx: -2*self.frame.width, dy: 0), duration: TimeInterval(self.frame.width/100))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        let gapHeight = bird.size.height * 4
        let movementAmount = arc4random() % UInt32(self.frame.height/2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.height/4
        
        // add pipe1
        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        let pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeTexture.size().height/2 + gapHeight/2 + pipeOffset)
        pipe1.run(moveAndRemovePipes)
        
        // create physicsBody for pipe1
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture.size())
        // disable physics(gravity) for pipe1
        pipe1.physicsBody!.isDynamic = false
        
        // Pipe1 BitMask (Eg. Collision)
        pipe1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        pipe1.zPosition = -1
        
        self.addChild(pipe1)
        
        // add pipe2
        let pipeTexture2 = SKTexture(imageNamed: "pipe2.png")
        let pipe2 = SKSpriteNode(texture: pipeTexture2)
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipeTexture2.size().height/2 - gapHeight/2 + pipeOffset)
        pipe2.run(moveAndRemovePipes)
        
        // create physicsBody for pipe2
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture2.size())
        // disable physics(gravity) for pipe2
        pipe2.physicsBody!.isDynamic = false
        
        // Pipe2 BitMask (Eg. Collision)
        pipe2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        pipe2.zPosition = -1

        
        self.addChild(pipe2)
        
        // Scoring (detect score with gap collision)
        
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeTexture.size().width, height: gapHeight))
        gap.physicsBody!.isDynamic = false
        gap.run(moveAndRemovePipes)
        
        // gap BitMask (Eg. Collision)
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        
        self.addChild(gap)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if gameOver == false {
        
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
            score += 1
            scoreLabel.text = String(score)
        } else {
            // GameOver
            // set gameSpeed to 0
            self.speed = 0
            gameOver = true
            //Stop timer
            timer.invalidate()
            
            gameOverLabel.fontName = "Helvetica"
            gameOverLabel.fontSize = 30
            gameOverLabel.text = "Game Over! Tap to play again."
            gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            
            self.addChild(gameOverLabel)
        }
        }

    }
    
    // like viewDidload
    override func didMove(to view: SKView) {
        
        // set contactDelegate
        self.physicsWorld.contactDelegate = self
        
        setupGame()
        }
    
    func setupGame() {
        
        // Timer
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makePipes), userInfo: nil, repeats: true)
        
        // Background
        
        // create background texture
        let bgTexture = SKTexture(imageNamed: "bg.png")
        // move backgound to the left
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0), duration: 7)
        let shiftBGAnimation = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0), duration: 0)
        let moveBGForever = SKAction.repeatForever(SKAction.sequence([moveBGAnimation, shiftBGAnimation]))
        
        var i: CGFloat = 0
        while i < 3 {
            
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: bgTexture.size().width*i, y: self.frame.midY)
            bg.size.height = self.frame.height
            bg.run(moveBGForever)
            
            // keep background in background
            bg.zPosition = -2
            
            self.addChild(bg)
            
            i += 1
        }
        
        // Bird
        
        // define textures
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        // create animation
        let animation = SKAction.animate(with: [birdTexture,birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        bird = SKSpriteNode(texture: birdTexture)
        
        
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        // animate
        bird.run(makeBirdFlap)
        
        // add physics to Bird
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height/2)
        // disable physics (before the first touch)
        bird.physicsBody!.isDynamic = false
        
        // Bird BitMask (Eg. Collision)
        bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody!.collisionBitMask = ColliderType.Bird.rawValue
        
        // add bird
        self.addChild(bird)
        
        // Add the Ground
        let ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height/2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody!.isDynamic = false
        
        // Ground Bitmask (Eg. Collision)
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(ground)
        
        scoreLabel.fontName = "Joystix"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height/2 - 70)
        self.addChild(scoreLabel)
        
    }
    
    
    // user touches the stream
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // disable birdmovement is game is over
        if gameOver == false {
         
            // add physics after the first touch
            bird.physicsBody!.isDynamic = true
            
            // on tap shift bird 50px upwards
            bird.physicsBody!.velocity = CGVector(dx:0, dy: 0)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 60))

        } else {
            gameOver = false
            score = 0
            self.speed = 1
            
            // remove all
            self.removeAllChildren()
            setupGame()
            
        }
        
        
    }
    
    // called serveral times a second
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
