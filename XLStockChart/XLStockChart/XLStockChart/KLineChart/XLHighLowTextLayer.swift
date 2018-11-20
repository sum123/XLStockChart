//
//  XLHighLowTextLayer.swift
//  behoo
//
//  Created by 夏磊 on 2018/9/3.
//  Copyright © 2018年 behoo. All rights reserved.
//

import UIKit

/// 最高最低文字layer
class XLHighLowTextLayer: CAShapeLayer {
    
    var theme = XLKLineStyle()
    
    let lineLayerWidth: CGFloat = 15
    
    // 最高最低值靠近左侧屏幕最大偏移值
    let maxOffsetWidth: CGFloat = 60
    
    override init() {
        super.init()
        addSublayer(highTextLayer)
        addSublayer(highLineLayer)
        addSublayer(lowTextLayer)
        addSublayer(lowLineLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func moveHighLowLayer(highPoint: CGPoint, highPrice: CGFloat, lowPoint: CGPoint, lowPrice: CGFloat, startX: CGFloat) {
        
        var labelX: CGFloat = 0
        var labelY: CGFloat = 0
        
        if highPoint == CGPoint.zero {
            highTextLayer.isHidden = true
            highLineLayer.isHidden = true
        }else {
            let linePath = UIBezierPath()
            linePath.move(to: highPoint)
            
            let highMarkString = highPrice.xlChart.kLinePriceNumber()
            let highMarkStringSize = theme.getTextSize(text: highMarkString)
            
            if highPoint.x - startX > frame.width * 0.5 {
                // label在左侧
                linePath.addLine(to: CGPoint(x: highPoint.x - lineLayerWidth, y: highPoint.y))
                labelX = highPoint.x - highMarkStringSize.width - lineLayerWidth
                
            } else {
                // label在右侧
                // 如果是在左侧屏幕边缘 往右边拉长
                var offset:CGFloat = 0
                if highPoint.x - startX < maxOffsetWidth {
                    offset = maxOffsetWidth - (highPoint.x - startX)
                }
                
                linePath.addLine(to: CGPoint(x: highPoint.x + lineLayerWidth + offset, y: highPoint.y))
                labelX = highPoint.x + lineLayerWidth + offset
            }
            labelY = highPoint.y - highMarkStringSize.height * 0.5
            highTextLayer.string = highMarkString
            highTextLayer.frame = CGRect(x: labelX, y: labelY, width: highMarkStringSize.width, height: highMarkStringSize.height)
            highTextLayer.isHidden = false
            
            highLineLayer.path = linePath.cgPath
            highLineLayer.isHidden = false
        }
        
        if lowPoint == CGPoint.zero {
            lowTextLayer.isHidden = true
            lowLineLayer.isHidden = true
        }else {
            let linePath = UIBezierPath()
            linePath.move(to: lowPoint)
            
            let lowMarkString = lowPrice.xlChart.kLinePriceNumber()
            let lowMarkStringSize = theme.getTextSize(text: lowMarkString)
            
            if lowPoint.x - startX > frame.width * 0.5 {
                // label在左侧
                labelX = lowPoint.x - lowMarkStringSize.width - lineLayerWidth
                
                linePath.addLine(to: CGPoint(x: lowPoint.x - lineLayerWidth, y: lowPoint.y))
            } else {
                // label在右侧
                // 如果是在左侧屏幕边缘 往右边拉长
                var offset:CGFloat = 0
                if lowPoint.x - startX < maxOffsetWidth {
                    offset = maxOffsetWidth - (lowPoint.x - startX)
                }
                
                linePath.addLine(to: CGPoint(x: lowPoint.x + lineLayerWidth + offset, y: lowPoint.y))
                labelX = lowPoint.x + lineLayerWidth + offset
            }
            labelY = lowPoint.y - lowMarkStringSize.height * 0.5
            lowTextLayer.string = lowMarkString
            lowTextLayer.frame = CGRect(x: labelX, y: labelY, width: lowMarkStringSize.width, height: lowMarkStringSize.height)
            lowTextLayer.isHidden = false
            
            lowLineLayer.path = linePath.cgPath
            lowLineLayer.isHidden = false
        }
    }
    
    // MARK: - Lazy
    /// 最高
    lazy var highTextLayer: XLCATextLayer = {
        let highTextLayer = XLCATextLayer()
        highTextLayer.fontSize = 10
        highTextLayer.foregroundColor = UIColor(red:1, green:1, blue:1, alpha:0.8).cgColor
        highTextLayer.backgroundColor = self.theme.highLowBgColor.cgColor
        highTextLayer.alignmentMode = .center
        highTextLayer.contentsScale = UIScreen.main.scale
        highTextLayer.isHidden = true
        return highTextLayer
    }()
    
    /// 最高line
    lazy var highLineLayer: CAShapeLayer = {
        let line = CAShapeLayer()
        line.lineWidth = self.theme.highLowLineWidth
        line.strokeColor = UIColor.white.cgColor
        line.fillColor = UIColor.white.cgColor
        line.isHidden = true
        return line
    }()
    
    /// 最低
    lazy var lowTextLayer: XLCATextLayer = {
        let lowTextLayer = XLCATextLayer()
        lowTextLayer.fontSize = 10
        lowTextLayer.foregroundColor = UIColor(red:1, green:1, blue:1, alpha:0.8).cgColor
        lowTextLayer.backgroundColor = self.theme.highLowBgColor.cgColor
        lowTextLayer.alignmentMode = .center
        lowTextLayer.contentsScale = UIScreen.main.scale
        lowTextLayer.isHidden = true
        return lowTextLayer
    }()
    
    /// 最低line
    lazy var lowLineLayer: CAShapeLayer = {
        let line = CAShapeLayer()
        line.lineWidth = self.theme.highLowLineWidth
        line.strokeColor = UIColor.white.cgColor
        line.fillColor = UIColor.white.cgColor
        line.isHidden = true
        return line
    }()
}
