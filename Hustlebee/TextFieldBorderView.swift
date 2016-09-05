//
//  TextFieldBorderView.swift
//  Hustlebee
//
//  Created by Anthony Do on 7/14/16.
//  Copyright © 2016 Anthony Do. All rights reserved.
//

import UIKit

@IBDesignable
class TextFieldBorderView: UIView
{
    override func draw(_ rect: CGRect) {
        
        let tfArray = getTextFieldInView(view: self)
        
        for tf in tfArray {
            if tf.tag != 4 {
                let tfBottomPoint = CGPoint(x: tf.bounds.origin.x, y: tf.bounds.origin.y + tf.bounds.height)
                let tfEndPoint = CGPoint(x: tf.bounds.origin.x + tf.bounds.width, y: tf.bounds.origin.y + tf.bounds.height)
                
                let superViewBottomPt = tf.convert(tfBottomPoint, to: self)
                let superViewEndPt = tf.convert(tfEndPoint, to: self)
                
                drawLineFromPoint(start: superViewBottomPt, toPoint: superViewEndPt, inView: self).stroke()
            }
        }
    }
    
    private func getTextFieldInView(view: UIView) -> [UITextField] {
        var results = [UITextField]()
        for subview in view.subviews as [UIView] {
            if let textFieldView = subview as? UITextField {
                results += [textFieldView]
            } else {
                results += getTextFieldInView(view: subview)
            }
        }
        return results
    }
    
    private func drawLineFromPoint(start: CGPoint, toPoint end: CGPoint, inView view: UIView) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        path.lineWidth = 1.0
        UIColor.yellowTheme().withAlphaComponent(0.5).set()
        return path
    }

}
