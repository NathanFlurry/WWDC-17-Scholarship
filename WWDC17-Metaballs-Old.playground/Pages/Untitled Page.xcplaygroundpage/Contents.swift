//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

//#-hidden-code
import SpriteKit
//#-end-hidden-code

var view = MetaballView2D(frame: CGRect(x: 0, y: 0, width: 200, height: 300))
var system = view.system
system.resolution = 1 / 10

// Generate random balls
for _ in 0..<10 {
    let ball = Metaball2D(
        position:
        CGPoint(
            x: CGFloat.random * CGFloat(system.width),
            y: CGFloat.random * CGFloat(system.height)
        ),
        radius: 20
    )
    system.balls.append(ball)
}

// Set a block for what to draw
view.drawBlock = { view, context in
    
    context.setLineWidth(1)
    
    context.setFillColor(UIColor.darkGray.cgColor)
    view.drawGrid(context: context, useAlpha: true)
    
    context.setStrokeColor(UIColor.cyan.cgColor)
    view.drawCircles(context: context)
    
    context.setStrokeColor(UIColor.red.cgColor)
    view.drawCells(context: context, interpolate: true)
    
    //    view.drawValues(context: context)
}

let page = PlaygroundPage.current
page.needsIndefiniteExecution = true
page.liveView = view
view.setNeedsDisplay()
