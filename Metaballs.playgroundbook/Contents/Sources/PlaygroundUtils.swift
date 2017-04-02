import PlaygroundSupport
import CoreGraphics

public func setupPlayground2D() -> MetaballView2D {
    let view = MetaballView2D(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    
    let page = PlaygroundPage.current
    page.needsIndefiniteExecution = true
    page.liveView = view
    
    view.setNeedsDisplay()
    
    return view
}
