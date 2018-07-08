//
//  MidiTempoTrack.swift
//  MidiParser
//
//  Created by Yuma Matsune on 2017/11/10.
//  Copyright © 2017年 matsune. All rights reserved.
//

import AudioToolbox
import Foundation

public final class MidiTempoTrack: MidiTrack {
    public private(set) var timeSignatures: [MidiTimeSignature] = []
    public private(set) var extendedTempos: [MidiExtendedTempo] = []
    
    override init(musicTrack: MusicTrack) {
        super.init(musicTrack: musicTrack)
        reloadEvents()
    }
    
    private func reloadEvents() {
        timeSignatures = []
        extendedTempos = []
        
        iterator.enumerate { eventInfo in
            guard let eventInfo = eventInfo,
                let eventData = eventInfo.data else {
                fatalError("MidiTempoTrack error")
            }
            
            if let eventType = MidiEventType(eventInfo.type) {
                switch eventType {
                case .meta:
                    var metaEvent = eventData.load(as: MIDIMetaEvent.self)
                    var data: [Int] = []
                    withUnsafeMutablePointer(to: &metaEvent.data) {
                        for i in 0 ..< Int(metaEvent.dataLength) {
                            data.append(Int($0.advanced(by: i).pointee))
                        }
                    }
                    if let metaType = MetaEventType(decimal: metaEvent.metaEventType) {
                        switch metaType {
                        case .timeSignature:
                            timeSignatures.append(MidiTimeSignature(timeStamp: eventInfo.timeStamp, data: data))
                        default:
                            break
                        }
                    }
                case .extendedTempo:
                    let extendedTempo = MidiExtendedTempo(timeStamp: eventInfo.timeStamp, bpm: eventData.load(as: ExtendedTempoEvent.self).bpm)
                    extendedTempos.append(extendedTempo)
                default:
                    break
                }
            }
        }
    }
}
