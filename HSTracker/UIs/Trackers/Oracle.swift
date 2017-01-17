//
//  Oracle.swift
//  HSTracker
//
//  Created by Istvan Fehervari on 17/01/2017.
//  Copyright © 2017 Benjamin Michotte. All rights reserved.
//

import Foundation

class Oracle: OverWindowController {
    
    @IBOutlet weak var manaView: AdvantageView!

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    func playerSpent(mana: Int) {
        manaView.increaseA(value: mana)
    }
    
    func opponentSpent(mana: Int) {
        manaView.increaseB(value: mana)
    }
    
    func reset() {
        manaView.reset()
    }

}

class OracleView: NSView {
    
    override func draw(_ dirtyRect: NSRect) {
        //super.draw(dirtyRect)
        // draw black background
        NSColor.black.set()
        NSRectFill(dirtyRect)
    }
}
