//
//  XLMidChartTextLayer.swift
//  behoo
//
//  Created by 夏磊 on 2018/8/23.
//  Copyright © 2018年 behoo. All rights reserved.
//

import UIKit

/// k线视图中部左侧文字layer
class XLMidChartTextLayer: XLCAShapeLayer {
    
    var theme = XLKLineStyle()
    
    fileprivate let textWidth: CGFloat = 90
    fileprivate let textHeight: CGFloat = 12
    fileprivate let textLeftOffset: CGFloat = 4
    
    var topChartHeight: CGFloat {
        get {
            return frame.height - theme.topTextHeight - theme.midTextHeight
        }
    }
    
    // 横向分隔线间距
    var topChartLineMargin: CGFloat {
        get {
            return self.topChartHeight / 4
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        oneText.frame = CGRect(x: textLeftOffset, y: theme.topTextHeight, width: self.textWidth, height: self.textHeight)
        
        twoText.frame = CGRect(x: textLeftOffset, y: self.topChartLineMargin + self.theme.topTextHeight - self.textHeight, width: self.textWidth, height: self.textHeight)
        
        threeText.frame = CGRect(x: textLeftOffset, y: self.topChartLineMargin * 2  + self.theme.topTextHeight - self.textHeight, width: self.textWidth, height: self.textHeight)
        
        fourText.frame = CGRect(x: textLeftOffset, y: self.topChartLineMargin * 3 + self.theme.topTextHeight - self.textHeight, width: self.textWidth, height: self.textHeight)
        
        fiveText.frame = CGRect(x: textLeftOffset, y: self.theme.topTextHeight + self.topChartHeight - self.textHeight, width: self.textWidth, height: self.textHeight)
        
        sixText.frame = CGRect(x: textLeftOffset, y: self.theme.topTextHeight + self.topChartHeight + self.theme.midTextHeight, width: self.textWidth, height: self.textHeight)
    }
    
    lazy var oneText: XLCATextLayer = {
        let oneText = XLCATextLayer()
        oneText.fontSize = 10
        oneText.foregroundColor = self.theme.textColor.cgColor
        oneText.backgroundColor = UIColor.clear.cgColor
        oneText.alignmentMode = .left
        oneText.contentsScale = UIScreen.main.scale
        return oneText
    }()
    
    lazy var twoText: XLCATextLayer = {
        let twoText = XLCATextLayer()
        twoText.fontSize = 10
        twoText.foregroundColor = self.theme.textColor.cgColor
        twoText.backgroundColor = UIColor.clear.cgColor
        twoText.alignmentMode = .left
        twoText.contentsScale = UIScreen.main.scale
        return twoText
    }()
    
    lazy var threeText: XLCATextLayer = {
        let threeText = XLCATextLayer()
        threeText.fontSize = 10
        threeText.foregroundColor = self.theme.textColor.cgColor
        threeText.backgroundColor = UIColor.clear.cgColor
        threeText.alignmentMode = .left
        threeText.contentsScale = UIScreen.main.scale
        return threeText
    }()
    
    lazy var fourText: XLCATextLayer = {
        let fourText = XLCATextLayer()
        fourText.fontSize = 10
        fourText.foregroundColor = self.theme.textColor.cgColor
        fourText.backgroundColor = UIColor.clear.cgColor
        fourText.alignmentMode = .left
        fourText.contentsScale = UIScreen.main.scale
        return fourText
    }()
    
    lazy var fiveText: XLCATextLayer = {
        let fiveText = XLCATextLayer()
        fiveText.fontSize = 10
        fiveText.foregroundColor = self.theme.textColor.cgColor
        fiveText.backgroundColor = UIColor.clear.cgColor
        fiveText.alignmentMode = .left
        fiveText.contentsScale = UIScreen.main.scale
        return fiveText
    }()
    
    lazy var sixText: XLCATextLayer = {
        let sixText = XLCATextLayer()
        sixText.fontSize = 10
        sixText.foregroundColor = self.theme.textColor.cgColor
        sixText.backgroundColor = UIColor.clear.cgColor
        sixText.alignmentMode = .left
        sixText.contentsScale = UIScreen.main.scale
        return sixText
    }()
    
    override init() {
        super.init()
        addSublayer(oneText)
        addSublayer(twoText)
        addSublayer(threeText)
        addSublayer(fourText)
        addSublayer(fiveText)
        addSublayer(sixText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurePriceVolue(one: CGFloat, two: CGFloat, three: CGFloat, four: CGFloat, five: CGFloat, six: CGFloat) {
        
        oneText.string = one.xlChart.kLinePriceNumber()
        twoText.string = two.xlChart.kLinePriceNumber()
        threeText.string = three.xlChart.kLinePriceNumber()
        fourText.string = four.xlChart.kLinePriceNumber()
        fiveText.string = five.xlChart.kLinePriceNumber()
        sixText.string = six.xlChart.kLineVolNumber()
    }
}
