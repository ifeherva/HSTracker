//
//  AdvantageView.swift
//  HSTracker
//
//  Created by Istvan Fehervari on 17/01/2017.
//  Copyright © 2017 Benjamin Michotte. All rights reserved.
//

import Foundation

/** A view that acts as a horizontal bar showing the sum of all integer events for 2 parties. */
class AdvantageView: NSView {
    
    private var currentValue = 0
    private let cornerRad: CGFloat = 5.0 // corner radius
    public var colorA = NSColor.green
    public var colorB = NSColor.orange
    
    private var textAttributes = [String: Any]()
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        
        self.wantsLayer = true
        self.layer?.cornerRadius  = cornerRad
        
        var pstyle = NSParagraphStyle.default()
        if let style: NSMutableParagraphStyle =
            NSParagraphStyle.default().mutableCopy() as? NSMutableParagraphStyle {
            style.alignment = NSTextAlignment.center
            pstyle = style
        }
        
        textAttributes = [NSParagraphStyleAttributeName: pstyle,
                          NSForegroundColorAttributeName: NSColor.white,
                          NSFontAttributeName: NSFont(name: "Belwe Bd BT", size: 18) as Any,
                          NSStrokeWidthAttributeName: -1.5,
                          NSStrokeColorAttributeName: NSColor.black
        ]
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.wantsLayer = true
        self.layer?.cornerRadius  = cornerRad
        
        var pstyle = NSParagraphStyle.default()
        if let style: NSMutableParagraphStyle =
            NSParagraphStyle.default().mutableCopy() as? NSMutableParagraphStyle {
            style.alignment = NSTextAlignment.center
            pstyle = style
        }
        
        textAttributes = [NSParagraphStyleAttributeName: pstyle,
                          NSForegroundColorAttributeName: NSColor.white,
                          NSFontAttributeName: NSFont(name: "Belwe Bd BT", size: 18) as Any,
                          NSStrokeWidthAttributeName: -1.5,
                          NSStrokeColorAttributeName: NSColor.black
        ]
    }
    
    func increaseA(value: Int) {
        currentValue = currentValue + value
        self.needsDisplay = true
    }
    
    func increaseB(value: Int) {
        currentValue = currentValue - value
        self.needsDisplay = true
    }
    
    func reset() {
        currentValue = 0
        self.needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        // draw white background
        NSColor.white.set()
        NSRectFill(dirtyRect)
        
        let unit = dirtyRect.size.height
        let halfsize = dirtyRect.size.width/2
        let valueRectWidth = min(halfsize, unit*CGFloat(abs(currentValue)))
        
        var valueRect: NSRect
        if currentValue > 0 {
            colorA.set()
            valueRect = NSRect(x: halfsize, y: 0, width: valueRectWidth, height: unit)
            NSRectFill(valueRect)
        } else {
            colorB.set()
            valueRect = NSRect(x: halfsize-valueRectWidth, y: 0,
                                   width: valueRectWidth, height: unit)
            NSRectFill(valueRect)
        }
        
        let valueStr = String(abs(currentValue))
        
        let strSize = valueStr.size(withAttributes: textAttributes)
        let verAlign = abs(valueRect.size.height - strSize.height)
        
        (valueStr as NSString).draw(in: NSRect(x: valueRect.origin.x, y: verAlign,
            width: valueRect.size.width,
            height: valueRect.size.height), withAttributes: textAttributes)
    }    
}
