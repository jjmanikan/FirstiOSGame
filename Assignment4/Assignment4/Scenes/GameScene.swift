//
//  GameScene.swift
//  Assignment4
//
//  Created by Justine Manikan on 11/29/18.
//  Copyright © 2018 Justine Manikan. All rights reserved.
//
import SpriteKit
import GameplayKit


struct PhysicsCategory{
    static let None : UInt32 = 0
    static let All : UInt32 = UInt32.max
    static let Villain : UInt32 = 0b1
    static let Hero : UInt32 = 0b10
    
    static let Projectile : UInt32 = 0b11
}

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var background = SKSpriteNode(imageNamed: "nyc.jpg")
    private var sportNode : SKSpriteNode?
    private var score : Int?
    private var health : Int?
    let scoreIncrement = 10
    let hpDecrement = 10
    private var lblScore : SKLabelNode?
    private var lblHealth : SKLabelNode?
    private var isRunning = true
    
    override func didMove(to view: SKView) {
        
        background.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        background.alpha = 0.2
        
        addChild(background)
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//gameLabel") as? SKLabelNode
        self.label?.text = "Avoid the goblins!"
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        sportNode = SKSpriteNode(imageNamed : "spiderman.png")
        sportNode?.position = CGPoint(x: 10, y: 10)
        
        addChild(sportNode!)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        sportNode?.physicsBody = SKPhysicsBody(circleOfRadius: (sportNode?.size.width)! / 2)
        sportNode?.physicsBody?.isDynamic = true
        sportNode?.physicsBody?.categoryBitMask = PhysicsCategory.Hero
        sportNode?.physicsBody?.contactTestBitMask = PhysicsCategory.Villain
        sportNode?.physicsBody?.collisionBitMask = PhysicsCategory.None
        sportNode?.physicsBody?.usesPreciseCollisionDetection = true
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addVillain),  SKAction.wait(forDuration: 0.5)])))
        
        score = 0000
        self.lblScore = self.childNode(withName: "//score") as? SKLabelNode
        self.lblScore?.text = "Score: \(score!)"
        if let slabel = self.lblScore{
            
            slabel.alpha = 0.0
            slabel.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        health = 100
        self.lblHealth = self.childNode(withName: "//health") as? SKLabelNode
        self.lblHealth?.text = "Health: \(health!)"
        if let slabel = self.lblHealth{
            slabel.alpha = 0.0
            slabel.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        
    }
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min:CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max-min) + min
    }
    
    func addVillain(){
        if(isRunning == true && health! > 0){
            let villain = SKSpriteNode(imageNamed: "goblin.png")
            villain.xScale = villain.xScale * -1
            
            let actualY = random(min: -size.width/2, max: size.width/2)
            villain.position = CGPoint(x: size.width/2,  y:actualY)
            addChild(villain)
            
            villain.physicsBody = SKPhysicsBody(rectangleOf: villain.size)
            villain.physicsBody?.isDynamic = true
            villain.physicsBody?.categoryBitMask = PhysicsCategory.Villain
            villain.physicsBody?.contactTestBitMask = PhysicsCategory.Hero
            villain.physicsBody?.collisionBitMask = PhysicsCategory.None
            
            let actualDuration = random(min: CGFloat(2.0), max:CGFloat(4.0))
            
            let actionMove = SKAction.move(to:CGPoint(x: -size.width/2 - villain.size.width, y: actualY),  duration: TimeInterval(actualDuration))
            let scoreIncrease = SKAction.run {
                self.score = (self.score! + self.scoreIncrement)
                self.lblScore?.text = "Score : \(self.score!)"
            }
            let actionMoveDone = SKAction.removeFromParent()
            villain.run(SKAction.sequence([actionMove, scoreIncrease, actionMoveDone]))
        }
        else{
            if(isRunning){
            isRunning = false
            self.label?.text = "Game Over! Ended with Score : \(self.score!)"
            
            var request = URLRequest(url: URL(string: "https://manikan.dev.fast.sheridanc.on.ca/Assignment4/parseData.php")!)
            
            request.httpMethod = "POST"
            let postString = "score=\(self.score!)"
            request.httpBody = postString.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("error=\(String(describing: error))")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(String(describing: responseString))")
            }
            task.resume()
            }
        }
    }
    
    func showTextDescription(message : String?){
        let alertController = UIAlertController(title: "Game Over", message: message, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: nil, style: .cancel, handler: nil))
        
    }
    
    func heroDidCollideWithVillain(hero: SKSpriteNode, villain: SKSpriteNode){
        
        print("hit")
        health = health! - hpDecrement
        self.lblHealth?.text = "Health : \(health!)"
        if let slabel = self.lblHealth{
            slabel.alpha = 0.0
            slabel.run(SKAction.fadeIn(withDuration: 2.0))
        }

    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody : SKPhysicsBody
        var secondBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if((firstBody.categoryBitMask & PhysicsCategory.Villain != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Hero != 0) && health! > 0) {
            
            
            heroDidCollideWithVillain(hero: firstBody.node as! SKSpriteNode, villain: secondBody.node as! SKSpriteNode)
            
        } else{
            score = score! + scoreIncrement
            self.lblScore?.text = "Score : \(score!)"
            
        }
        
    }
    
    func moveHero(toPoint pos : CGPoint){
        let actionMove = SKAction.move(to: pos, duration: TimeInterval(2.0))
        let actionMoveDone = SKAction.rotate(byAngle: CGFloat(360.0), duration: TimeInterval(1.0))
        sportNode?.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
        
        moveHero(toPoint: pos)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
            
            moveHero(toPoint: pos)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
