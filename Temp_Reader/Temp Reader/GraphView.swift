//
//  GraphView.swift
//  Temp Reader
//
//  Created by Christopher Weaver on 12/10/17.
//  Copyright © 2017 Christopher Weaver. All rights reserved.
//

import Foundation
import UIKit

class LineGraph: UIView {
    
    var graphPoints:[Double] = []
    
    var startDate : String?
    var endDate : String?
    
    var startColor: UIColor = UIColor.green
    var endColor: UIColor = UIColor.green
    
    override func draw(_ rect: CGRect) {
        
        if !graphPoints.isEmpty {
        let width = rect.width
        let height = rect.height
        
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: UIRectCorner.allCorners,
                                cornerRadii: CGSize(width: 8.0, height: 8.0))
        path.addClip()
        
        //draw background color
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor.cgColor, endColor.cgColor]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:self.bounds.height)
        context!.drawLinearGradient(gradient!,
                                    start: startPoint,
                                    end: endPoint,
                                    options: CGGradientDrawingOptions(rawValue: UInt32(0)))
        
        let margin:CGFloat = 20.0
        
        // calculate the x point
        let columnXPoint = { (column:Int) -> CGFloat in
            //Calculate gap between points
            
            let spacer = (width - margin * 2  - 4) /
                CGFloat((self.graphPoints.count - 1))
            var x:CGFloat = CGFloat(column) * spacer
            x += margin + 2
            return x
        }
        
        let topBorder:CGFloat = 60
        let bottomBorder:CGFloat = 50
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = graphPoints.max()
        let minValue = graphPoints.min()

        // calculate the y point
        let columnYPoint = { (graphPoint:Double) -> CGFloat in
            var y:CGFloat = ((CGFloat(graphPoint) - CGFloat(minValue!)) ) / (CGFloat(maxValue!) - CGFloat(minValue!))
            y = y * graphHeight
            y = graphHeight + topBorder - y // Flip the graph
            return y
        }
        
        UIColor.white.setFill()
        UIColor.white.setStroke()
        
        let graphPath = UIBezierPath()
        graphPath.move(to: CGPoint(x:columnXPoint(0),
                                   y:columnYPoint(graphPoints[0])))
        
        
        // add points to graph
        for i in 1..<graphPoints.count {
            
            let nextPoint = CGPoint(x: columnXPoint(i),
                                    y:columnYPoint(graphPoints[i]))
            graphPath.addLine(to: nextPoint)
        }
        
        //draw the line on top of the clipped gradient
        graphPath.lineWidth = 3.0
        graphPath.stroke()
        
        //Draw the circles on top of graph stroke
        for i in 0..<graphPoints.count {
            
            var point = CGPoint(x:columnXPoint(i), y:columnYPoint(graphPoints[i]))
            point.x -= 5.0/2
            point.y -= 5.0/2
            
            let circle = UIBezierPath(ovalIn:
                CGRect(origin: point,
                       size: CGSize(width: 7.0, height: 7.0)))
            circle.fill()
        }
        
        //Draw horizontal graph lines on the top of everything
        let linePath = UIBezierPath()
        
        //top line
        linePath.move(to: CGPoint(x:margin, y: topBorder))
        linePath.addLine(to: CGPoint(x: width - margin,
                                     y:topBorder))
        let topLabel = UILabel(frame: CGRect(x: margin, y: topBorder - 23, width: 75, height: 20))
        topLabel.font = UIFont.systemFont(ofSize: 12)
        topLabel.text = String(describing: maxValue!) + "°"
        self.addSubview(topLabel)
        
        //center line
        linePath.move(to: CGPoint(x:margin,
                                  y: graphHeight/2 + topBorder))
        linePath.addLine(to: CGPoint(x:width - margin,
                                     y:graphHeight/2 + topBorder))
        
        //bottom line
        linePath.move(to: CGPoint(x:margin,
                                  y:height - bottomBorder))
        linePath.addLine(to: CGPoint(x:width - margin,
                                     y:height - bottomBorder))
        let bottomLabel = UILabel(frame: CGRect(x: margin, y: (height - bottomBorder) - 23, width: 75, height: 25))
        bottomLabel.font = UIFont.systemFont(ofSize: 12)
        bottomLabel.text = String(describing: minValue!) + "°"
        self.addSubview(bottomLabel)
        
        let color = UIColor(white: 1.0, alpha: 0.8)
        color.setStroke()
        
        linePath.lineWidth = 1.0
        linePath.stroke()
        
        let startDateLabel = UILabel(frame: CGRect(x: 10, y: self.frame.height - 35, width: 75, height: 30))
        startDateLabel.numberOfLines = 0
        startDateLabel.font = UIFont.systemFont(ofSize: 12)
        startDateLabel.text = startDate!
        self.addSubview(startDateLabel)
        
        let endDateLabel = UILabel(frame: CGRect(x: self.frame.width - 65, y: self.frame.height - 35, width: 65, height: 30))
        endDateLabel.numberOfLines = 0
        endDateLabel.font = UIFont.systemFont(ofSize: 12)
        endDateLabel.text = endDate!
        self.addSubview(endDateLabel)
        }
    }
}
