//
//  Constants.swift
//  amstel
//
//  Created by Robert Netzke on 7/2/25.
//
import BitcoinDevKit

#if DEBUG
    let NETWORK = Network.signet
#else
    let NETWORK = Network.bitcoin
#endif

#if DEBUG
    let RECOVERY_HEIGHT: UInt32 = 0
#else
    let RECOVERY_HEIGHT: UInt32 = 440_000
#endif

#if DEBUG
    let PORT: UInt16 = 38333
#else
    let PORT: UInt16 = 8333
#endif

#if DEBUG
    let ip_1 = IpAddress.fromIpv4(q1: 141, q2: 94, q3: 143, q4: 203)
    let ip_2 = IpAddress.fromIpv4(q1: 136, q2: 243, q3: 77, q4: 182)
    let ip_3 = IpAddress.fromIpv4(q1: 195, q2: 201, q3: 164, q4: 54)
    let PEER_1 = Peer(address: ip_1, port: PORT, v2Transport: false)
    let PEER_2 = Peer(address: ip_2, port: PORT, v2Transport: false)
    let PEER_3 = Peer(address: ip_3, port: PORT, v2Transport: false)
#endif

let LOCAL_HOST = IpAddress.fromIpv4(q1: 127, q2: 0, q3: 0, q4: 1)
let TOR_PROXY = Socks5Proxy(address: LOCAL_HOST, port: 9050)

let SIGNET_RECV = "wpkh([9122d9e0/84'/1'/0']tpubDCYVtmaSaDzTxcgvoP5AHZNbZKZzrvoNH9KARep88vESc6MxRqAp4LmePc2eeGX6XUxBcdhAmkthWTDqygPz2wLAyHWisD299Lkdrj5egY6/0/*)"
let SIGNET_CHANGE = "wpkh([9122d9e0/84'/1'/0']tpubDCYVtmaSaDzTxcgvoP5AHZNbZKZzrvoNH9KARep88vESc6MxRqAp4LmePc2eeGX6XUxBcdhAmkthWTDqygPz2wLAyHWisD299Lkdrj5egY6/1/*)"
