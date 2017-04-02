import PlaygroundSupport
import UIKit

public func setupPlayground2D() -> MetaballView2D {
    let view = MetaballView2D(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    
    let page = PlaygroundPage.current
    page.needsIndefiniteExecution = true
    page.liveView = view
    
    return view
}

public func setTestDraw(view: MetaballView2D) {
    view.drawBlock = { view, context in
        context.setLineWidth(1)
        
        context.setFillColor(UIColor.darkGray.cgColor)
        view.drawGrid(context: context, useAlpha: true)
        
        context.setStrokeColor(UIColor.cyan.cgColor)
        view.drawCircles(context: context)
        
        context.setStrokeColor(UIColor.red.cgColor)
        view.drawCells(context: context, interpolate: true)
    }
}
