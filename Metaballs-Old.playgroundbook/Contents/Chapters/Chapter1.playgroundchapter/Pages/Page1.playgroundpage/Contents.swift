/*:
 <something about metaballs>
 
 A *B* **B**
 
 This is a [test](http://apple.com)
 
 Instructions:
 * Tap anywhere to create a new metaball
 * Drag the metaballs around to move them
 * Double tap the metaballs to remove them from the system
*/

//#-hidden-code
import PlaygroundSupport
import UIKit


let view = MetaballView2D(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
setTestDraw(view: view)

let system = view.system
system.resolution = 1 / 10
//#-end-hidden-code

//#-code-completion(identifier, hide, setupPlayground2D(), view)
//#-editable-code
for _ in 0..<10 {
    let ball = Metaball2D(
        position:
        CGPoint(
            x: CGFloat.random * CGFloat(system.width),
            y: CGFloat.random * CGFloat(system.height)
        ),
        radius: 30
    )
    system.balls.append(ball)
}
//#-end-editable-code

//#-hidden-code
let page = PlaygroundPage.current
page.needsIndefiniteExecution = true
page.liveView = view

view.setNeedsDisplay()
//#-end-hidden-code
