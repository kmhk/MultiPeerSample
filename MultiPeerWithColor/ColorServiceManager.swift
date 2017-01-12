//
//  AppDelegate.swift
//  MultiPeerWithColor
//
//  Created by Com on 12/01/2017.
//  Copyright © 2017 Com. All rights reserved.
//


import Foundation
import MultipeerConnectivity

protocol ColorServiceManagerDelegate {
    
    func connectedDevicesChanged(_ manager : ColorServiceManager, connectedDevices: [String])
    func colorChanged(_ manager : ColorServiceManager, colorString: String)
    
}

class ColorServiceManager : NSObject {
    
    fileprivate let ColorServiceType = "example-color"
    fileprivate let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    fileprivate let serviceAdvertiser : MCNearbyServiceAdvertiser
    fileprivate let serviceBrowser : MCNearbyServiceBrowser
    var delegate : ColorServiceManagerDelegate?
	
	var session: MCSession
    
    override init() {
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ColorServiceType)

        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ColorServiceType)
		
		session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)

        super.init()
        
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
		
		session.delegate = self
    }
    
    deinit {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }

    func sendColor(_ colorName : String) {
        NSLog("%@", "sendColor: \(colorName)")
        
        if session.connectedPeers.count > 0 {
			try? session.send(colorName.data(using: .utf8, allowLossyConversion: false)!, toPeers: session.connectedPeers, with: .reliable)
        }

    }
	
}

extension ColorServiceManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping ((Bool, MCSession?) -> Void)) {
        
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }

}

extension ColorServiceManager : MCNearbyServiceBrowserDelegate {
	
	public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
		NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
	}
	
	func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
		NSLog("%@", "foundPeer: \(peerID)")
		NSLog("%@", "invitePeer: \(peerID)")
		browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
	}
	
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .notConnected: return "NotConnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        }
    }
    
}

extension ColorServiceManager : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
        self.delegate?.connectedDevicesChanged(self, connectedDevices: session.connectedPeers.map({$0.displayName}))
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data.count) bytes")
        let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
        self.delegate?.colorChanged(self, colorString: str)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
}
