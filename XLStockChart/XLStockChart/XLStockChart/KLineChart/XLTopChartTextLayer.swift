//
//  XLTopChartTextLayer.swift
//  XLStockChart
//
//  Created by 夏磊 on 2018/8/23.
//  Copyright © 2018年 sum123. All rights reserved.
//

import UIKit

/// K线顶部 例：MA5 MA10 MA30 文字layer
class XLTopChartTextLayer: XLCAShapeLayer, XLDrawLayerProtocol {
    
    var theme = XLKLineStyle()
    
    fileprivate let textHeight: CGFloat = 12
    fileprivate let textTop: CGFloat = 1
    
    // MARK: - Life Cycle
    override init() {
        super.init()
        addSublayer(titleText)
        addSublayer(oneText)
        addSublayer(twoText)
        addSublayer(threeText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Method
    func configureTopValue(lineType: XLKLineType, mainDrawString: String, one: CGFloat, two: CGFloat, three: CGFloat) {
        
        var oneWidth: CGFloat = 0
        var twoWidth: CGFloat = 0
        var threeWidth: CGFloat = 0
        var textMargin: CGFloat = 0
        
        var titleString = ""
        var oneString = ""
        var twoString = ""
        var threeString = ""
        
        switch lineType {
        case .minLineType:
            print("分时")
            if mainDrawString == KLINEMA {
                // MA
                titleText.string = "均线 "
                titleText.frame = CGRect(x: 4, y: 0, width: 30, height: self.theme.topTextHeight)
                
                let oneString = "MA60: " + one.xlChart.kLinePriceNumber()
                let oneWidth = getTextSize(text: oneString, addOnWith: 5).width
                oneText.string = oneString
                oneText.frame = CGRect(x: titleText.frame.maxX, y: textTop, width: oneWidth, height: textHeight)
                
                titleText.isHidden = false
                oneText.isHidden = false
                twoText.isHidden = true
                threeText.isHidden = true
                
            }else if mainDrawString == KLINEBOLL {
                // BOLL
                titleText.string = "BOLL "
                titleText.frame = CGRect(x: 4, y: textTop, width: 30, height: self.textHeight)
                
                let oneString = "MID: " + two.xlChart.kLinePriceNumber()
                let oneWidth = getTextSize(text: oneString, addOnWith: 5).width
                oneText.string = oneString
                oneText.frame = CGRect(x: titleText.frame.maxX, y: textTop, width: oneWidth, height: textHeight)
                
                titleText.isHidden = false
                oneText.isHidden = false
                twoText.isHidden = true
                threeText.isHidden = true
            }else {
                titleText.isHidden = true
                oneText.isHidden = true
                twoText.isHidden = true
                threeText.isHidden = true
            }
            
            
        case .candleLineType:
            // K线
            if mainDrawString == KLINEMA {
                // MA
                titleString = "均线 "
                titleText.frame = CGRect(x: 4, y: 0, width: 30, height: self.theme.topTextHeight)
                textMargin = 5
                
                oneString = "MA5: " + one.xlChart.kLinePriceNumber()
                twoString = "MA10: " + two.xlChart.kLinePriceNumber()
                threeString = "MA30: " + three.xlChart.kLinePriceNumber()
                
                titleText.string = titleString
                oneText.string = oneString
                twoText.string = twoString
                threeText.string = threeString
                
                oneWidth = getTextSize(text: oneString, addOnWith: textMargin).width
                twoWidth = getTextSize(text: twoString, addOnWith: textMargin).width
                threeWidth = getTextSize(text: threeString, addOnWith: textMargin).width
                
                oneText.frame = CGRect(x: titleText.frame.maxX, y: textTop, width: oneWidth, height: textHeight)
                twoText.frame = CGRect(x: oneText.frame.maxX, y: textTop, width: twoWidth, height: textHeight)
                threeText.frame = CGRect(x: twoText.frame.maxX, y: textTop, width: threeWidth, height: textHeight)
                
                titleText.isHidden = false
                oneText.isHidden = false
                twoText.isHidden = false
                threeText.isHidden = false
                
            }else if mainDrawString == KLINEBOLL {
                // BOLL
                titleString = "BOLL "
                titleText.frame = CGRect(x: 4, y: textTop, width: 30, height: self.textHeight)
                textMargin = 5
                
                oneString = "UP: " + one.xlChart.kLinePriceNumber()
                twoString = "MID: " + two.xlChart.kLinePriceNumber()
                threeString = "LOW: " + three.xlChart.kLinePriceNumber()
                
                titleText.string = titleString
                oneText.string = oneString
                twoText.string = twoString
                threeText.string = threeString
                
                oneWidth = getTextSize(text: oneString, addOnWith: textMargin).width
                twoWidth = getTextSize(text: twoString, addOnWith: textMargin).width
                threeWidth = getTextSize(text: threeString, addOnWith: textMargin).width
                
                oneText.frame = CGRect(x: titleText.frame.maxX, y: textTop, width: oneWidth, height: textHeight)
                twoText.frame = CGRect(x: oneText.frame.maxX, y: textTop, width: twoWidth, height: textHeight)
                threeText.frame = CGRect(x: twoText.frame.maxX, y: textTop, width: threeWidth, height: textHeight)
                
                titleText.isHidden = false
                oneText.isHidden = false
                twoText.isHidden = false
                threeText.isHidden = false
            }else {
                titleText.isHidden = true
                oneText.isHidden = true
                twoText.isHidden = true
                threeText.isHidden = true
            }
   
        }
    }
    
    // MARK: - Lazy
    lazy var titleText: XLCATextLayer = {
        let titleText = XLCATextLayer()
        titleText.fontSize = 10
        titleText.foregroundColor = self.theme.bottomTextOneColor.cgColor
        titleText.backgroundColor = UIColor.clear.cgColor
        titleText.alignmentMode = CATextLayerAlignmentMode.left
        titleText.contentsScale = UIScreen.main.scale
        return titleText
    }()
    
    lazy var oneText: XLCATextLayer = {
        let oneText = XLCATextLayer()
        oneText.fontSize = 10
        oneText.foregroundColor = self.theme.topTextOneColor.cgColor
        oneText.backgroundColor = UIColor.clear.cgColor
        oneText.alignmentMode = CATextLayerAlignmentMode.left
        oneText.contentsScale = UIScreen.main.scale
        return oneText
    }()
    
    lazy var twoText: XLCATextLayer = {
        let twoText = XLCATextLayer()
        twoText.fontSize = 10
        twoText.foregroundColor = self.theme.topTextTwoColor.cgColor
        twoText.backgroundColor = UIColor.clear.cgColor
        twoText.alignmentMode = CATextLayerAlignmentMode.left
        twoText.contentsScale = UIScreen.main.scale
        return twoText
    }()
    
    lazy var threeText: XLCATextLayer = {
        let threeText = XLCATextLayer()
        threeText.fontSize = 10
        threeText.foregroundColor = self.theme.topTextThreeColor.cgColor
        threeText.backgroundColor = UIColor.clear.cgColor
        threeText.alignmentMode = CATextLayerAlignmentMode.left
        threeText.contentsScale = UIScreen.main.scale
        return threeText
    }()
}




