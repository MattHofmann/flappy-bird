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
    
    
    // UI
    
    var scoreLabel = SKLabelNode()
    var score = 0
    var highscoreLabel = SKLabelNode()
    var highscore = 0
    var endScoreLabel = SKLabelNode()
    
    var headerLabel = SKLabelNode()
    var playBTN = SKSpriteNode()
    var versionImg = SKSpriteNode()
    
    var gameOverLabel = SKLabelNode()
    var gameOverMsg1 = SKLabelNode()
    var gameOverMsg2 = SKLabelNode()

    var tapHereImg = SKSpriteNode()
    var getReadyLabel = SKLabelNode()
    
    var restartBTN = SKSpriteNode()

    
    // Timer
    
    var timer = Timer()
    
    enum ColliderType: UInt32 {
    
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    var gameOver = false
    var gameStarted = false
    var gamePipes = false

    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if gameOver == false {
        
            if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
                score += 1
                scoreLabel.text = String(score)
            } else {
                // GameOver
                // set gameSpeed to 0
                self.speed = 0
                // Update status
                gameOver = true
                gameStarted = false
                gamePipes = false
                
                //Stop timer
                timer.invalidate()
            
                restartMenu()
            
            }
        }

    }
    
    
    // startMenu
    func startMenu() {
    
        // Background
        createBackground()
        
        // create Bird
        createBird()
        
        // Set FlappyBird-Text
        headerLabel.fontName = "04b_19"
        headerLabel.fontSize = 120
        headerLabel.text = "FlappyBird"
        headerLabel.fontColor = UIColor.white
        headerLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 250)
        self.addChild(headerLabel)
        
        // version
        versionImg = SKSpriteNode(imageNamed: "versionImg")
        versionImg.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 180)
        versionImg.zPosition = 6
        // restartBTN.setScale(0)
        self.addChild(versionImg)
        
        
        // Play Button

        playBTN = SKSpriteNode(imageNamed: "playBTN")
        // restartBTN.size = CGSizeMake(200, 100)
        playBTN.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 200)
        playBTN.zPosition = 6
        
        // for splashscreen generation
        // playBTN.setScale(0)
        // self.speed = 0
        // ---
        
        self.addChild(playBTN)
        
        // Update status
        gameOver = false
        gameStarted = false
        gamePipes = false
        
        
    }
    
    func startGame() {
        // remove all objects
        self.removeAllChildren()
        self.removeAllActions()
        
        // Update status
        gameOver = false
        gameStarted = true
        gamePipes = false
        
        setupGame()
        self.speed = 1
        
        
    }
    
    func restartScene() {
        // remove all objects
        self.removeAllChildren()
        // no more actions (eg. pipes)
        self.removeAllActions()
        // end game
        // Update status
        gameOver = false
        gameStarted = true
        gamePipes = false
        
        // reset score
        score = 0
        //
        self.speed = 1
        // set up game again
        setupGame()
    }
    
    
    // MARK: like viewDidload
    override func didMove(to view: SKView) {
        
        // set contactDelegate
        self.physicsWorld.contactDelegate = self
        // start with menu
        startMenu()
        
    }
    
    // Background
    func createBackground() {
        
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
    
    }
    
    func createGround() {
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
    }
    
    
    // restartBTN
    func restartMenu() {
        
        scoreLabel.removeFromParent()
        
        print("restartMenu called")
        
        gameOverLabel.fontName = "04b_19"
        gameOverLabel.fontSize = 120
        gameOverLabel.text = "Game Over!"
        gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 250)
        self.addChild(gameOverLabel)
        
        gameOverMsg1.fontName = "04b_19"
        gameOverMsg1.fontSize = 40
        gameOverMsg1.text = "Press"
        gameOverMsg1.fontColor = UIColor.black
        gameOverMsg1.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 100)
        self.addChild(gameOverMsg1)
        
        gameOverMsg2.fontName = "04b_19"
        gameOverMsg2.fontSize = 40
        gameOverMsg2.text = "to play again."
        gameOverMsg2.fontColor = UIColor.black
        gameOverMsg2.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 150)
        self.addChild(gameOverMsg2)
        
        restartBTN = SKSpriteNode(imageNamed: "restartBTN")
        // restartBTN.size = CGSizeMake(200, 100)
        restartBTN.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        restartBTN.zPosition = 6
        // restartBTN.setScale(0)
        self.addChild(restartBTN)
        
        // restartBTN.run(SKAction.scale(to: 1.0, duration: 0.3))
    
        // save new highscore
        if (score > highscore) {
            highscore = score
            // save to core data
            // Default (core data)
            UserDefaults.standard.set(highscore, forKey: "highscore")
            // display highscore
            highscoreLabel.text = "Highscore: \(highscore)"
        } else {
            // retrieve core data highscore and show
            let highscoreObject = UserDefaults.standard.object(forKey: "highscore")
            if let highscore = highscoreObject as? Int {
                highscoreLabel.text = "Highscore: \(highscore)"
            }
        }
        
        // endScoreLabel
        endScoreLabel.fontName = "04b_19"
        endScoreLabel.fontSize = 50
        endScoreLabel.text = "Your Score: \(score)"
        endScoreLabel.fontColor = UIColor.black
        endScoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 300)
        self.addChild(endScoreLabel)
        
        // highscoreLabel
        highscoreLabel.fontName = "04b_19"
        highscoreLabel.fontSize = 50
        highscoreLabel.fontColor = UIColor.black
        highscoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 400)
        self.addChild(highscoreLabel)
    
    }
    

    
    func createBird() {
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
    }
    
    // Method to create pipes
    func createPipes() {
        
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
    
    func createScoreLabel() {
        // scoreLabel
        scoreLabel.fontName = "04b_19"
        scoreLabel.fontSize = 100
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height/2 - 200)
        self.addChild(scoreLabel)
    }
    
    func setupGame() {
        // Background
        createBackground()
        // Bird
        createBird()
        // Ground
        createGround()
        // score
        createScoreLabel()
        // add tapHereImg
        tapHereImg = SKSpriteNode(imageNamed: "tapHere")
        tapHereImg.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        tapHereImg.zPosition = -1
        // restartBTN.setScale(0)
        self.addChild(tapHereImg)
        
        // GetReady Label
        getReadyLabel.fontName = "04b_19"
        getReadyLabel.fontSize = 100
        getReadyLabel.text = "Get Ready!"
        getReadyLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 250)
        self.addChild(getReadyLabel)
        
        
    }

    func addPipesAndTimer() {
        // Timer
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.createPipes), userInfo: nil, repeats: true)
        
        // remove tapHelp und GetReadyLabel
        tapHereImg.removeFromParent()
        getReadyLabel.removeFromParent()
        
        // Update status
        gameOver = false
        gameStarted = true
        gamePipes = true
        
    }
    
    
    // user touches the stream
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // enable birdmovement if gane is running
        if gameOver == false && gameStarted == true {
         
            // add physics after the first touch
            bird.physicsBody!.isDynamic = true
            
            // on tap shift bird 50px upwards
            bird.physicsBody!.velocity = CGVector(dx:0, dy: 0)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 60))
            
        }
        
        if gameStarted == true && gamePipes == false {
            addPipesAndTimer()
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if gameStarted == false && gameOver == false {
                if playBTN.contains(location) {
                    startGame()
                }
            }
            
            if gameOver == true {
                if restartBTN.contains(location) {
                    restartScene()
                }

            }
        }
        
    }
    
    
    // called serveral times a second
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
