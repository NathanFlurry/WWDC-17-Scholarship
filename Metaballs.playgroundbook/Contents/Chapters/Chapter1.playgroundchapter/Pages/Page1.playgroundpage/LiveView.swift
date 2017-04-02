import PlaygroundSupport
import UIKit

let view = setupPlayground2D()
view.drawBlock = { view, context in
    context.setLineWidth(1)
    context.setStrokeColor(UIColor.white.cgColor)
    view.drawCells(context: context, interpolate: true)
}
