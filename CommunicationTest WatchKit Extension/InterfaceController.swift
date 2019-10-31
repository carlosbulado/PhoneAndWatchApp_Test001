//
//  InterfaceController.swift
//  CommunicationTest WatchKit Extension
//
//  Created by Parrot on 2019-10-26.
//  Copyright © 2019 Parrot. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

@available(watchOSApplicationExtension 6.0, *)
class InterfaceController: WKInterfaceController, WCSessionDelegate {

    
    // MARK: Outlets
    // ---------------------
    @IBOutlet var txtPokemon: WKInterfaceTextField!
    @IBOutlet var btnPokemon: WKInterfaceButton!
    @IBOutlet var feedbtn: WKInterfaceButton!
    
    @IBOutlet var pikimg: WKInterfaceImage!
    @IBOutlet var catimg: WKInterfaceImage!
    @IBOutlet var hibbtn: WKInterfaceButton!
    @IBOutlet var wakbtn: WKInterfaceButton!
    @IBOutlet var labelPokemonInfo: WKInterfaceLabel!
    
    var pokemonName : String = ""
    // MARK: Delegate functions
    // ---------------------

    // Default function, required by the WCSessionDelegate on the Watch side
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //@TODO
    }
    
    // 3. Get messages from PHONE
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("WATCH: Got message from Phone \(message)")
        // Message from phone comes in this format: ["course":"MADT"]
        let pokemonChoice = message["POKEMONCHOICE"] as? String
        if pokemonChoice != ""
        {
            if self.pokemonName == ""
            {
                self.txtPokemon.setHidden(false)
                self.btnPokemon.setHidden(false)
            }
            
            if pokemonChoice == "CATERPIE"
            {
                print("CATERPIE")
                self.pikimg.setHidden(true)
                self.catimg.setHidden(false)
            }
            else
            {
                print("PIKACHU")
                self.pikimg.setHidden(false)
                self.catimg.setHidden(true)
            }
        }
        
        let seconds = message["SECONDS"] as? NSNumber
        if seconds != nil { self.labelPokemonInfo.setText("\(self.pokemonName) is \(seconds ?? 0) seconds old") }
        
        let gameOver = message["ISPOKEMONDEAD"] as? Bool
        if gameOver != nil && gameOver!
        {
            self.labelPokemonInfo.setText("GAME OVER!")
        }
    }
    
    // MARK: WatchKit Interface Controller Functions
    // ----------------------------------
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.txtPokemon.setHidden(false)
        self.btnPokemon.setHidden(false)
        self.wakbtn.setHidden(true)
        self.pikimg.setHidden(true)
        self.catimg.setHidden(true)

        self.feedbtn.setHidden(true)
        self.hibbtn.setHidden(true)
        self.wakbtn.setHidden(true)
        
        
        // 1. Check if teh watch supports sessions
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    
    // MARK: Actions
    // ---------------------
    @IBAction func okPokemonName()
    {
        if WCSession.default.isReachable
        {
            print("Attempting to send message to phone \(self.txtPokemon.description)")
            self.pokemonName = "Albert"
            WCSession.default.sendMessage(
                ["POKEMONNAME" : self.txtPokemon.description],
                replyHandler: {
                    (_ replyMessage: [String: Any]) in
                    // @TODO: Put some stuff in here to handle any responses from the PHONE
                    print("Message sent, put something here if u are expecting a reply from the phone")
                   
            }, errorHandler: { (error) in
                //@TODO: What do if you get an error
                print("Error while sending message: \(error)")
            })

            self.txtPokemon.setHidden(true)
            self.btnPokemon.setHidden(true)
            
            self.feedbtn.setHidden(false)
            self.hibbtn.setHidden(false)
            self.wakbtn.setHidden(true)
        }
        else {
            print("Phone is not reachable")
        }
    }
    
    @IBAction func feedPokemon()
    {
        if WCSession.default.isReachable
        {
            WCSession.default.sendMessage(
                ["ACTION" : "FEED"],
                replyHandler: {
                    (_ replyMessage: [String: Any]) in
                    // @TODO: Put some stuff in here to handle any responses from the PHONE
                    //print("Message sent, put something here if u are expecting a reply from the phone")
                   
            }, errorHandler: { (error) in
                //@TODO: What do if you get an error
                //print("Error while sending message: \(error)")
            })
        }
    }
    
    @IBAction func HIBERNATE()
    {
        if WCSession.default.isReachable
        {
            WCSession.default.sendMessage(
                ["ACTION" : "HIBERNATE"],
                replyHandler: {
                    (_ replyMessage: [String: Any]) in
                    // @TODO: Put some stuff in here to handle any responses from the PHONE
                    //print("Message sent, put something here if u are expecting a reply from the phone")
                   
            }, errorHandler: { (error) in
                //@TODO: What do if you get an error
                //print("Error while sending message: \(error)")
            })
            
            self.feedbtn.setHidden(true)
            self.hibbtn.setHidden(true)
            self.wakbtn.setHidden(false)
        }
    }
    
    @IBAction func wakeUp()
    {
        if WCSession.default.isReachable
        {
            WCSession.default.sendMessage(
                ["ACTION" : "WAKEUPFROMHIBERNATE"],
                replyHandler: {
                    (_ replyMessage: [String: Any]) in
                    // @TODO: Put some stuff in here to handle any responses from the PHONE
                    //print("Message sent, put something here if u are expecting a reply from the phone")
                   
            }, errorHandler: { (error) in
                //@TODO: What do if you get an error
                //print("Error while sending message: \(error)")
            })
            
            self.feedbtn.setHidden(false)
            self.hibbtn.setHidden(false)
            self.wakbtn.setHidden(true)
        }
    }
}
