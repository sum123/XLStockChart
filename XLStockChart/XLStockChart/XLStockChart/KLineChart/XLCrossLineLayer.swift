//
//  XLCrossLineLayer.swift
//  behoo
//
//  Created by 夏磊 on 2018/8/24.
//  Copyright © 2018年 behoo. All rights reserved.
//

import UIKit

/// 十字线layer
class XLCrossLineLayer: CAShapeLayer {
    
    var theme = XLKLineStyle()
    
    var topChartHeight: CGFloat {
        get {
            return frame.height - theme.topTextHeight - theme.midTextHeight - theme.bottomChartHeight - theme.timeTextHeight
        }
    }
    
    /// 十字线
    lazy var corssLineLayer: XLCAShapeLayer = {
        let line = XLCAShapeLayer()
        line.lineWidth = self.theme.corssLineWidth
        line.strokeColor = UIColor(red:1, green:1, blue:1, alpha:0.6).cgColor
        line.fillColor = UIColor(red:1, green:1, blue:1, alpha:0.6).cgColor
        return line
    }()
    
    /// Y轴标签
    lazy var yMarkLayer: XLCAShapeLayer = {
        let yMarkLayer = XLCAShapeLayer()
        yMarkLayer.backgroundColor = self.theme.crossBgColor.cgColor
        yMarkLayer.borderColor = self.theme.crossBorderColor
        yMarkLayer.borderWidth = self.theme.frameWidth
        yMarkLayer.cornerRadius = 2
        yMarkLayer.contentsScale = UIScreen.main.scale
        
        yMarkLayer.addSublayer(self.yMarkTextLayer)
        return yMarkLayer
    }()
    
    /// Y轴文字
    lazy var yMarkTextLayer: XLCATextLayer = {
        let yMarkTextLayer = XLCATextLayer()
        yMarkTextLayer.fontSize = 10
        yMarkTextLayer.foregroundColor = UIColor.white.cgColor
        yMarkTextLayer.backgroundColor = UIColor.clear.cgColor
        yMarkTextLayer.alignmentMode = .center
        yMarkTextLayer.contentsScale = UIScreen.main.scale
        return yMarkTextLayer
    }()
    
    /// time标签
    lazy var timeMarkLayer: XLCAShapeLayer = {
        let timeMarkLayer = XLCAShapeLayer()
        timeMarkLayer.backgroundColor = self.theme.crossBgColor.cgColor
        timeMarkLayer.borderColor = self.theme.crossBorderColor
        timeMarkLayer.borderWidth = self.theme.frameWidth
        timeMarkLayer.cornerRadius = 2
        timeMarkLayer.contentsScale = UIScreen.main.scale
        
        timeMarkLayer.addSublayer(self.timeMarkTextLayer)
        return timeMarkLayer
    }()
    
    /// time文字
    lazy var timeMarkTextLayer: XLCATextLayer = {
        let timeMarkTextLayer = XLCATextLayer()
        timeMarkTextLayer.fontSize = 10
        timeMarkTextLayer.foregroundColor = UIColor.white.cgColor
        timeMarkTextLayer.backgroundColor = UIColor.clear.cgColor
        timeMarkTextLayer.alignmentMode = .center
        timeMarkTextLayer.contentsScale = UIScreen.main.scale
        return timeMarkTextLayer
    }()
    
    /// 中心圆点
    lazy var circleBigLayer: XLCAShapeLayer = {
        let circleBigLayer = XLCAShapeLayer()
        circleBigLayer.cornerRadius = self.theme.crossCircleWidth * 0.5
        circleBigLayer.backgroundColor = UIColor.white.cgColor
        return circleBigLayer
    }()
    
    lazy var circleMidLayer: XLCAShapeLayer = {
        let circleMidLayer = XLCAShapeLayer()
        circleMidLayer.cornerRadius = (self.theme.crossCircleWidth - 2) * 0.5
        circleMidLayer.backgroundColor = UIColor.xlChart.color(rgba: "#243245").cgColor
        return circleMidLayer
    }()
    
    lazy var circleSmallLayer: XLCAShapeLayer = {
        let circleSmallLayer = XLCAShapeLayer()
        circleSmallLayer.cornerRadius = (self.theme.crossCircleWidth - 4) * 0.5
        circleSmallLayer.backgroundColor = UIColor.white.cgColor
        return circleSmallLayer
    }()
    
    override init() {
        super.init()
        
        isHidden = true
        addSublayer(corssLineLayer)
        addSublayer(circleBigLayer)
        addSublayer(circleMidLayer)
        addSublayer(circleSmallLayer)
        addSublayer(yMarkLayer)
        addSublayer(timeMarkLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func moveCrossLineLayer(touchNum: CGFloat?, touchPoint: CGPoint, pricePoint: CGPoint, volumePoint: CGPoint, model: XLKLineModel?, secondString: String?, dateType: XLKLineDateType) {
        
        guard let model = model else { return }
        
        let linePath = UIBezierPath()
        
        // 竖线
        linePath.move(to: CGPoint(x: pricePoint.x, y: theme.topTextHeight))
        linePath.addLine(to: CGPoint(x: pricePoint.x, y: theme.topTextHeight + topChartHeight))
        
        linePath.move(to: CGPoint(x: pricePoint.x, y: theme.topTextHeight + topChartHeight + theme.midTextHeight))
        linePath.addLine(to: CGPoint(x: pricePoint.x, y: frame.height - theme.timeTextHeight))
        
        let xlineTop = touchPoint.y
        
        // 横线
        if touchNum != nil {
            linePath.move(to: CGPoint(x: 0, y: xlineTop))
            linePath.addLine(to: CGPoint(x: frame.width, y: xlineTop))
            
            // 圆
            var circleWidth: CGFloat = theme.crossCircleWidth
            circleBigLayer.frame = CGRect(x: pricePoint.x - circleWidth*0.5, y: xlineTop - circleWidth*0.5, width: circleWidth, height: circleWidth)
            
            circleWidth = circleWidth - 2
            circleMidLayer.frame = CGRect(x: pricePoint.x - circleWidth*0.5, y: xlineTop - circleWidth*0.5, width: circleWidth, height: circleWidth)
            
            circleWidth = circleWidth - 2
            circleSmallLayer.frame = CGRect(x: pricePoint.x - circleWidth*0.5, y: xlineTop - circleWidth*0.5, width: circleWidth, height: circleWidth)
            
            circleBigLayer.isHidden = false
            circleMidLayer.isHidden = false
            circleSmallLayer.isHidden = false
        }else {
            circleBigLayer.isHidden = true
            circleMidLayer.isHidden = true
            circleSmallLayer.isHidden = true
        }
        
        corssLineLayer.path = linePath.cgPath
        
        // Y轴标签
        var labelX: CGFloat = 0
        var labelY: CGFloat = 0
        
        if let touchNum = touchNum {
            var yMarkString = ""
            if secondString == KLINEVOL {
                yMarkString = touchNum.xlChart.kLineVolNumber()
            }else {
                yMarkString = touchNum.xlChart.kLinePriceNumber()
            }
            let yMarkStringSize = theme.getCrossTextSize(text: yMarkString)
            labelX = 0 + 2
            labelY = xlineTop - yMarkStringSize.height * 0.5
            if labelY <= theme.topTextHeight {
                labelY = theme.topTextHeight
            }
            let maxY = frame.height - theme.timeTextHeight - yMarkStringSize.height
            
            if labelY >= maxY {
                labelY = maxY
            }
            yMarkTextLayer.string = yMarkString
            yMarkTextLayer.frame = CGRect(x: 6, y: 6, width: yMarkStringSize.width - 12, height: yMarkStringSize.height - 12)
            yMarkLayer.frame = CGRect(x: labelX, y: labelY, width: yMarkStringSize.width, height: yMarkStringSize.height)
            yMarkLayer.isHidden = false
        }else {
            yMarkLayer.isHidden = true
        }
        
        // time标签
        var timeMarkString = ""
        if dateType == .min {
            timeMarkString = model.time.xlChart.toTimeString("MM/dd HH:mm")
        }else {
            timeMarkString = model.time.xlChart.toTimeString("YY/MM/dd")
        }
        let timeMarkStringSize = theme.getCrossTextSize(text: timeMarkString)
        
        let maxX = UIScreen.main.bounds.width - timeMarkStringSize.width
        labelX = pricePoint.x - timeMarkStringSize.width * 0.5
        labelY = frame.height - theme.timeTextHeight
        if labelX > maxX {
            labelX = maxX
        } else if labelX < 0 {
            labelX = 0
        }
        timeMarkTextLayer.string = timeMarkString
        timeMarkTextLayer.frame = CGRect(x: 6, y: 5.5, width: timeMarkStringSize.width - 12, height: timeMarkStringSize.height - 12)
        timeMarkLayer.frame = CGRect(x: labelX, y: labelY, width: timeMarkStringSize.width, height: timeMarkStringSize.height)
        
        isHidden = false
    }
}
