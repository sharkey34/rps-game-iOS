//
//  ViewController.swift
//  SharkeyEric_5.2
//
//  Created by Eric Sharkey on 8/13/18.
//  Copyright © 2018 Eric Sharkey. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {
    
    // Creating outlet collections
    @IBOutlet var rpsImageViews: [UIImageView]!
    @IBOutlet var userChoiceImages: [UIImageView]!
    @IBOutlet var profileImages: [UIImageView]!
    @IBOutlet var wdlLables: [UILabel]!
    @IBOutlet var tallyCollection: [UILabel]!
    
    // Creating outlets
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var roShamBoLabel: UILabel!
    @IBOutlet weak var user2Label: UILabel!
    @IBOutlet weak var user1Label: UILabel!
    @IBOutlet weak var vsLabel: UILabel!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var playSelectedLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    // Creating variables.
    var session: MCSession!
    var peerId: MCPeerID!
    var advertisor: MCAdvertiserAssistant!
    var browser: MCBrowserViewController!
    var counter = 0
    var win = 0
    var draw = 0
    var loss = 0
    var user1selectedImage: String!
    var user2selectedImage: String!
    var timer = Timer()
    var timerCounter = 3
    var playCounter = 0
    var connectedPeer = ""
    let serviceId = "sharkeyEric-52"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up the peerID, session, advertiser, and calling the setup funcion.
        peerId = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerId)
        session.delegate = self
        advertisor = MCAdvertiserAssistant(serviceType: serviceId, discoveryInfo: nil, session: session)
        advertisor.start()
        
        setup()
    }
    
    // Function to display the browser view controller when the connect button has been tapped.
    @IBAction func connectTap(_ sender: UIBarButtonItem) {
        browser = MCBrowserViewController(serviceType: serviceId, session: session)
        browser.delegate = self
        
        self.present(browser, animated: true, completion: nil)
    }
    
    
    
    //MARK - MCBrowserViewControllerDelegate
    
    // Functions to dismiss the browser.
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK - MCSessionDelegate callbacks
    
    // Remote peer changed state.
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState){
        
        // Switching on the status of the state.
        DispatchQueue.main.async {
            switch state {
                
                // If the state is connected then setting the nave title to display connected and setting the user labels to that of the two connected players.
                // Setting the welcome labels to nil and changing the top views color and assigning the two emoji images.
            case .connected:
                self.navItem.title = "Connected"
                self.activity.stopAnimating()
                self.activity.isHidden = true
                self.user1Label.text = UIDevice.current.name
                self.user2Label.text = peerID.displayName
                self.playButton.setTitle("Play", for: .normal)
                self.connectedPeer = peerID.displayName
                self.topView.backgroundColor = UIColor.init(red:0.38, green:0.69, blue:0.80, alpha:1.0)
                for imageView in  self.profileImages{
                    imageView.image = #imageLiteral(resourceName: "win")
                }
            
                // Setting up the win draw loss labels.
                 self.wdlLables[0].text = "Win"
                 self.wdlLables[1].text = "Draw"
                 self.wdlLables[2].text = "Loss"
                
                for label in  self.tallyCollection{
                    label.text = "0"
                }
                
                // Changing the button to say disconnect.
                self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Disconnect", style: .plain  , target: self, action: #selector(self.disconnectTapped))
                
                
            case .notConnected:
                
                // If the state changes to disconnected then resetting the labels and topviews colors back to what they were at the beginning.
                self.welcomeLabel.text = "Welcome!\n Click connect to choose your oponent\n and start the game!"
                self.roShamBoLabel.text = "RoShamBo!!"
                
                self.topView.backgroundColor = UIColor.init(red:0.59, green:0.67, blue:0.70, alpha:1.0)
                
                self.navItem.title = "Disconnected"
                self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Connect", style: .plain, target: self, action: #selector(self.connectTap(_:)))
                
                for label in self.wdlLables{
                    label.text = nil
                }
                
                self.resultLabel.text = nil
                self.user1Label.text = nil
                self.user2Label.text = nil
                self.vsLabel.text = nil
                self.counterLabel.text = nil
                self.playSelectedLabel.text = nil
                self.activity.stopAnimating()
                self.activity.isHidden = true
                
                for image in self.userChoiceImages{
                    image.image = nil
                }
                
                for image in self.profileImages{
                    image.image = nil
                }
                
                for label in self.tallyCollection{
                    label.text = nil
                }
                
                self.draw = 0
                self.win = 0
                self.loss = 0
                
                self.playButton.setTitle(nil, for: .normal)
                
                // Displaying an alert when the user is disconnected.
                    let alert = UIAlertController(title: "Disconnected", message: "You have been disconnected from \(self.connectedPeer)", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                
                // If the state is connecting changing the nav title to connecting..
                // Starting the activity indicator and setting the welcome label and roshambo label to nil
            case .connecting:
                self.navItem.title = "Connecting..."
                self.activity.isHidden = false
                self.activity.startAnimating()
                self.welcomeLabel.text = nil
                self.roShamBoLabel.text = nil
            @unknown default:
                fatalError()
            }
        }
    }
    
    
    // Received data from remote peer.
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID){
        
        // Decoding the sent data.
        if let data: String = String(data: data, encoding: String.Encoding.utf8){
            DispatchQueue.main.async {
                
                // If the data sent was play then increasing the play counter, alerting the user that the other player is ready and calling the players Ready function.
                if data == "Play"{
                    self.playCounter += 1
                    self.playSelectedLabel.text = "\(peerID.displayName) is ready..."
                    self.resultLabel.text = nil
                    self.playersReady()
                
                    // Otherwise using a switch and setting the selected image.
                } else{
                    switch data{
                    case "r":
                        self.user2selectedImage = "r"
                    case "p":
                        self.user2selectedImage = "p"
                    case "s":
                        self.user2selectedImage = "s"
                    default:
                        print("Image failed.")
                        
                    }
                }
            }
        }
    }
    
    
    // Received a byte stream from remote peer.
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID){
        
    }
    
    
    // Start receiving a resource from remote peer.
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress){
        
    }
    
    
    // Finished receiving a resource from remote peer and saved the content
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?){
        
    }
    
    // Setup function setting all the variables and colors to their needed values and calling in the ViewDidLoad.
    func setup(){
        
        // Setting colors.
        topView.backgroundColor = UIColor.init(red:0.59, green:0.67, blue:0.70, alpha:1.0)
        view.backgroundColor = UIColor.init(red:0.59, green:0.67, blue:0.70, alpha:1.0)
        
        // Setting images.
        rpsImageViews[0].image = #imageLiteral(resourceName: "rock")
        rpsImageViews[1].image = #imageLiteral(resourceName: "paper")
        rpsImageViews[2].image = #imageLiteral(resourceName: "scissors")
        
        // Assigning tap gestures to the imageViews, enabling user interaction and hiding the image Views.
        for imageView in rpsImageViews{
            let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.rpsTapped(sender:)))
            imageView.addGestureRecognizer(tap)
            imageView.isUserInteractionEnabled = true
            imageView.isHidden = true
        }
        
        // Setting the labels, and play button to nil.
        for label in wdlLables{
            label.text = nil
        }
        welcomeLabel.text = "Welcome!\n Click connect to choose your oponent\n and start the game!"
        resultLabel.text = nil
        user1Label.text = nil
        user2Label.text = nil
        vsLabel.text = nil
        counterLabel.text = nil
        playSelectedLabel.text = nil
        for label in tallyCollection{
            label.text = nil
        }
        
        playButton.setTitle(nil, for: .normal)
        activity.isHidden = true
    }
    
   @objc func rpsTapped(sender: UITapGestureRecognizer){
    
   guard let selectedView = sender.view as? UIImageView else {return}
    
    // switching on the selected views tag and setting the image and user1SelectedImage value.
    switch selectedView.tag {
    case 0:
        userChoiceImages[0].image = #imageLiteral(resourceName: "rock")
        user1selectedImage = "r"
    case 1:
        userChoiceImages[0].image = #imageLiteral(resourceName: "paper")
        user1selectedImage = "p"
    case 2:
        userChoiceImages[0].image = #imageLiteral(resourceName: "scissors")
        user1selectedImage = "s"
    default:
        print("Incorrect image tag")
    }
    

    // Deciding string and sending to the connected peers.
    if let text =  user1selectedImage.data(using: String.Encoding.utf8){
        do{
            try session.send(text, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
        } catch{
            print(error.localizedDescription)
        }
    }
    
    }
    
    // When play is tapped setting the userChoiceImages to nil, increasing the counter, hiding the playbutton, and sending the sending Play to the connected peers then calling the playerReady function.
    @IBAction func playTapped(_ sender: UIButton) {
        
        resultLabel.text = nil
        for imageView in userChoiceImages{
            imageView.image = nil
        }
        playCounter += 1
        
        playButton.isHidden = true
        
            guard let buttonText = playButton.titleLabel?.text else {return}
        
            if let text = buttonText.data(using: String.Encoding.utf8) {
        
                do{
                    try session.send(text, toPeers: session.connectedPeers, with: MCSessionSendDataMode.reliable)
                    playSelectedLabel.text = "Waiting for \(connectedPeer)...."
                } catch{
                    print(error.localizedDescription)
                }
            }
        
        playersReady()
    }
    
    // Checking the timercounter and updating the counterLabel.
    @objc func checkImage (){
      
        if timerCounter > 0 {
            counterLabel.text = "\(timerCounter)"
            timerCounter -= 1
        } else {
            
            // When the timerCounter equals 0 then switching on the first users selected image.
            // Checking to see who won and setting the resultLabel, profileImage, and win draw loss values accordingly.
            switch user1selectedImage{
            case nil:
                if user2selectedImage == nil{
                    resultLabel.text = "Time has run out! it's a Draw!"
                    profileImages[0].image = #imageLiteral(resourceName: "draw")
                    profileImages[1].image = #imageLiteral(resourceName: "draw")
                    draw += 1
                }  else if user2selectedImage == "r"{
                    userChoiceImages[1].image = #imageLiteral(resourceName: "rock")
                    resultLabel.text = "You ran out of time! You Lose!"
                    profileImages[0].image = #imageLiteral(resourceName: "loss")
                    profileImages[1].image = #imageLiteral(resourceName: "win")
                    loss += 1
                } else if user2selectedImage == "p"{
                    userChoiceImages[1].image = #imageLiteral(resourceName: "paper")
                    resultLabel.text = "You ran out of time! You Lose!"
                    profileImages[0].image = #imageLiteral(resourceName: "loss")
                    profileImages[1].image = #imageLiteral(resourceName: "win")
                    loss += 1
                } else if user2selectedImage == "s"{
                    userChoiceImages[1].image = #imageLiteral(resourceName: "scissors")
                    resultLabel.text = "You ran out of time! You Lose!"
                    profileImages[0].image = #imageLiteral(resourceName: "loss")
                    profileImages[1].image = #imageLiteral(resourceName: "win")
                    loss += 1
                } else {
                    print("whoa")
                }
            case "r":
                if user2selectedImage == nil{
                    resultLabel.text = "\(connectedPeer) Ran out of time! You Win!"
                    profileImages[0].image = #imageLiteral(resourceName: "win")
                    profileImages[1].image = #imageLiteral(resourceName: "loss")
                    win += 1
                } else if user2selectedImage == "r"{
                    userChoiceImages[1].image = #imageLiteral(resourceName: "rock")
                    resultLabel.text = "Draw!"
                    profileImages[0].image = #imageLiteral(resourceName: "draw")
                    profileImages[1].image = #imageLiteral(resourceName: "draw")
                    draw += 1
                } else if user2selectedImage == "p"{
                    userChoiceImages[1].image = #imageLiteral(resourceName: "paper")
                    resultLabel.text = "You Lose!"
                    profileImages[0].image = #imageLiteral(resourceName: "loss")
                    profileImages[1].image = #imageLiteral(resourceName: "win")
                    loss += 1
                } else if user2selectedImage == "s"{
                    userChoiceImages[1].image = #imageLiteral(resourceName: "scissors")
                    resultLabel.text = "You Win!"
                    profileImages[0].image = #imageLiteral(resourceName: "win")
                    profileImages[1].image = #imageLiteral(resourceName: "loss")
                    win += 1
                } else {
                    print("whoa")
                }
            case "p":
                if user2selectedImage == nil{
                    resultLabel.text = "\(connectedPeer) Ran out of time! You Win!"
                    profileImages[0].image = #imageLiteral(resourceName: "win")
                    profileImages[1].image = #imageLiteral(resourceName: "loss")
                    win += 1
                } else if user2selectedImage == "r"{
                    userChoiceImages[1].image = #imageLiteral(resourceName: "rock")
                    resultLabel.text = "You Win!"
                    profileImages[0].image = #imageLiteral(resourceName: "win")
                    profileImages[1].image = #imageLiteral(resourceName: "loss")
                    win += 1
                } else if user2selectedImage == "p"{
                    userChoiceImages[1].image = #imageLiteral(resourceName: "paper")
                    resultLabel.text = "Draw!"
                    profileImages[0].image = #imageLiteral(resourceName: "draw")
                    profileImages[1].image = #imageLiteral(resourceName: "draw")
                    draw += 1
                } else if user2selectedImage == "s"{
                    userChoiceImages[1].image = #imageLiteral(resourceName: "scissors")
                    resultLabel.text = "You Lose!"
                    profileImages[0].image = #imageLiteral(resourceName: "loss")
                    profileImages[1].image = #imageLiteral(resourceName: "win")
                    loss += 1
                } else {
                    print("whoa")
                }
            case "s":
                if user2selectedImage == nil{
                    resultLabel.text = "\(connectedPeer) Ran out of time! You Win!"
                    profileImages[0].image = #imageLiteral(resourceName: "win")
                    profileImages[1].image = #imageLiteral(resourceName: "loss")
                    win += 1
                } else if user2selectedImage == "r"{
                    userChoiceImages[1].image = #imageLiteral(resourceName: "rock")
                    resultLabel.text = "You Lose!"
                    profileImages[0].image = #imageLiteral(resourceName: "loss")
                    profileImages[1].image = #imageLiteral(resourceName: "win")
                    loss += 1
                } else if user2selectedImage == "p"{
                    userChoiceImages[1].image = #imageLiteral(resourceName: "paper")
                    resultLabel.text = "You Win!"
                    profileImages[0].image = #imageLiteral(resourceName: "win")
                    profileImages[1].image = #imageLiteral(resourceName: "loss")
                    win += 1
                } else if user2selectedImage == "s"{
                    userChoiceImages[1].image = #imageLiteral(resourceName: "scissors")
                    resultLabel.text = "Draw!"
                    profileImages[0].image = #imageLiteral(resourceName: "draw")
                    profileImages[1].image = #imageLiteral(resourceName: "draw")
                    draw += 1
                } else {
                    print("whoa")
                }
            default:
                print("Image comparison")
            }

            // Updating the tally
            tallyCollection[0].text = "\(win)"
            tallyCollection[1].text = "\(draw)"
            tallyCollection[2].text = "\(loss)"
            
            // Resetting the timer counter, invalidating the timer and setting the counter label to nil.
            timerCounter = 3
            timer.invalidate()
            counterLabel.text = nil
            
            // Hiding the rpsImageVIews, playbuttin and setting selected images to nil.
            for imageview in rpsImageViews{
                imageview.isHidden = true
            }
            playButton.isHidden = false
            user1selectedImage = nil
            user2selectedImage = nil
        }
       
        
    }
    
    // Checking to see if both players are ready, if they are then showing the rpsImageViews and starting the timer.
    func playersReady(){
        if playCounter == 2 {
            playSelectedLabel.text = nil
            
            for imageView in rpsImageViews{
                imageView.isHidden = false
            }
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkImage), userInfo: nil, repeats: true)
            playCounter = 0
        }
    }
    
    // Disonnecting when the Disconnect button is tapped.
    @objc func disconnectTapped(){
        session.disconnect()
    }
}

