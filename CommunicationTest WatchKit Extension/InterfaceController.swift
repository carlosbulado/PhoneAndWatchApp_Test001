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
    
    // MARK: Delegate functions
    // ---------------------

    // Default function, required by the WCSessionDelegate on the Watch side
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //@TODO
    }
    
    // 3. Get messages from PHONE
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("WATCH: Got message from Phone")
        // Message from phone comes in this format: ["course":"MADT"]
        let isPokemonNameTBD = message["POKEMONCHOICE"] as! String
        if isPokemonNameTBD != ""
        {
            self.txtPokemon.setEnabled(true)
            self.btnPokemon.setEnabled(true)
        }
    }
    


    
    // MARK: WatchKit Interface Controller Functions
    // ----------------------------------
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.txtPokemon.setEnabled(false)
        self.btnPokemon.setEnabled(false)
        
        
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
            print("Attempting to send message to phone \(self.txtPokemon)")
            WCSession.default.sendMessage(
                ["POKEMONNAME" : self.txtPokemon],
                replyHandler: {
                    (_ replyMessage: [String: Any]) in
                    // @TODO: Put some stuff in here to handle any responses from the PHONE
                    print("Message sent, put something here if u are expecting a reply from the phone")
                   
            }, errorHandler: { (error) in
                //@TODO: What do if you get an error
                print("Error while sending message: \(error)")
            })

            self.txtPokemon.setEnabled(false)
            self.btnPokemon.setEnabled(false)
        }
        else {
            print("Phone is not reachable")
        }
    }
}
