//
//  GameScene.swift
//  CommunicationTest
//
//  Created by Carlos José Bulado on 2019-10-31.
//  Copyright © 2019 Parrot. All rights reserved.
//

import SpriteKit
import GameplayKit
import WatchConnectivity

class GameScene : SKScene
{
    var session : WCSession!
    var isGameStarted : Bool = true
    var numLoops : Int = 0
    var seconds : Int = 0
    var lastCurrentTime : Int = 0
    
    var hpLabel : SKLabelNode!
    var hungerLabel : SKLabelNode!
    var feedBtn : SKLabelNode!
    
    var pokemon : SKSpriteNode?
    
    var hp : Double = 100
    var hunger : Double = 0
    
    override func didMove(to view: SKView)
    {
        self.initWCSessionDelegate()
        
        // Add life label
        self.hpLabel = SKLabelNode(text: "HP: \(self.hp) %")
        self.hpLabel.position = CGPoint(x: 10, y: self.size.height - 100)
        self.hpLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        self.hpLabel.fontColor = UIColor.magenta
        self.hpLabel.fontSize = 22
        self.hpLabel.fontName = "Avenir"
        self.hpLabel.zPosition = 102
        addChild(self.hpLabel)
        
        // Add hunger label
        self.hungerLabel = SKLabelNode(text: "Hunger: \(self.hunger) %")
        self.hungerLabel.position = CGPoint(x: 150, y: self.size.height - 100)
        self.hungerLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        self.hungerLabel.fontColor = UIColor.magenta
        self.hungerLabel.fontSize = 22
        self.hungerLabel.fontName = "Avenir"
        self.hungerLabel.zPosition = 102
        addChild(self.hungerLabel)
        
        // Add hunger label
        self.feedBtn = SKLabelNode(text: "FEED")
        self.feedBtn.position = CGPoint(x: 150, y: self.size.height - 180)
        self.feedBtn.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        self.feedBtn.fontColor = UIColor.blue
        self.feedBtn.fontSize = 22
        self.feedBtn.fontName = "Avenir"
        self.feedBtn.zPosition = 102
        addChild(self.feedBtn)
        
        initWCSessionDelegate()
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        self.movePokemon()
        self.sendGiveYourPokemonAName()
        
        if self.isGameStarted
        {
            let now : Int = Int(currentTime)
            
            if now > self.lastCurrentTime
            {
                self.seconds = self.seconds + 1
            }
            
            if self.seconds % 5 == 0
            {
                self.numLoops = self.numLoops + 1
                
                self.hunger = self.hunger + 10
                
                if self.hunger >= 80
                {
                    self.hp = self.hp - 5
                }
                
                self.hungerLabel.text = "Hunger: \(self.hunger) %"
                self.hpLabel.text = "HP: \(self.hp) %"
                
                self.seconds = 1
            }
            
            self.lastCurrentTime = Int(currentTime)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let mousePosition = touches.first?.location(in: self) else {
            return
        }

        let touchPosition = CGPoint(x: mousePosition.x, y: mousePosition.y)
        let touchRect = CGRect(x: mousePosition.x, y: mousePosition.y, width: 1, height: 1)
        
        if self.feedBtn.frame.intersects(touchRect)
        {
            self.feedPokemon()
        }
        
    }
    
    func movePokemon()
    {
        if self.pokemon == nil
        {
            let pokemonType : String = UserDefaults.standard.string(forKey: "POKEMON")!
            // Add pokemon
            self.pokemon = SKSpriteNode(imageNamed: pokemonType)
            self.pokemon!.position = CGPoint(x: 200, y: 200)
            addChild(self.pokemon!)
            
            let upMoveAction = SKAction.moveBy(x: 0, y: 50, duration: 1)
            let rightMoveAction = SKAction.moveBy(x: 50, y: 0, duration: 1)
            let downMoveAction = SKAction.moveBy(x: 0, y: -50, duration: 1)
            let leftMoveAction = SKAction.moveBy(x: -50, y: 0, duration: 1)
            
            let animation = SKAction.sequence(
                [upMoveAction, rightMoveAction, downMoveAction, leftMoveAction]
            )
            
            let foreverAnimation = SKAction.repeatForever(animation)
            self.pokemon?.run(foreverAnimation)
        }
    }
    
    func feedPokemon()
    {
        self.hunger = self.hunger - 12
        if self.hunger <= 0
        {
            self.hunger = 0
        }
        self.hungerLabel.text = "Hunger: \(self.hunger) %"
    }
    
    func hibernate()
    {
        self.isGameStarted = false
    }
    
    func wakeUpFromHibernation()
    {
        self.isGameStarted = true
    }
}

// Extension for implement WCSessionDelegate
extension GameScene : WCSessionDelegate
{
    func initWCSessionDelegate()
    {
        if WCSession.isSupported()
        {
            print("WC is supported!")
            self.session = WCSession.default
            self.session.delegate = self
            self.session.activate()
        }
        else { print("WC NOT supported!") }
    }
    
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any])
//    {
//        print("PHONE: I received a message: \(message)")
//        let pokemonName = message["POKEMONNAME"] as! String
//        if pokemonName != "" { UserDefaults.standard.setValue(pokemonName, forKey: "POKEMONNAME") }
//        
//        let action = message["ACTION"] as! String
//        if action == "FEED" { self.feedPokemon() }
//        if action == "HIBERNATE" { self.hibernate() }
//        if action == "WAKEUPFROMHIBERNATE" { self.wakeUpFromHibernation() }
//    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        
        // When a message is received from the watch, output a message to the UI
        // NOTE: Since session() runs in background, you cannot directly update UI from the background thread.
        // Therefore, you need to wrap any UI updates inside a DispatchQueue for it to work properly.
        DispatchQueue.main.async {
            print("PHONE: I received a message: \(message)")
            let pokemonName = message["POKEMONNAME"] as? String
            if pokemonName != "" { UserDefaults.standard.setValue(pokemonName, forKey: "POKEMONNAME") }
            
            let action = message["ACTION"] as? String
            if action == "FEED" { self.feedPokemon() }
            if action == "HIBERNATE" { self.hibernate() }
            if action == "WAKEUPFROMHIBERNATE" { self.wakeUpFromHibernation() }
        }
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { print("GameScene - session") }
    
    func sessionDidBecomeInactive(_ session: WCSession) { print("GameScene - sessionDidBecomeInactive") }
    
    func sessionDidDeactivate(_ session: WCSession) { print("GameScene - sessionDidDeactivate") }
    
    func sendPoints()
    {
//        if self.session.isReachable
//        {
//            self.session.sendMessage(["Points" : self.points], replyHandler: nil)
//            print("Message with points: \(self.points)")
//        }
//        else { print("No message was sent.") }
    }
    
    func sendGiveYourPokemonAName()
    {
        if self.session.isReachable && ViewController.pokemonName == ""
        {
            self.session.sendMessage(["POKEMONCHOICE" : ViewController.pokemonChoice], replyHandler: nil)
        }
    }
}

