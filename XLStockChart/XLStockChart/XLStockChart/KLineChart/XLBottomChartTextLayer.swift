//
//  XLBottomChartTextLayer.swift
//  XLStockChart
//
//  Created by 夏磊 on 2018/8/23.
//  Copyright © 2018年 sum123. All rights reserved.
//

import UIKit

/// K线底部 例：成交量 VOL5 VOL10 文字layer
class XLBottomChartTextLayer: XLCAShapeLayer, XLDrawLayerProtocol {
    
    var theme = XLKLineStyle()
    
    fileprivate let textHeight: CGFloat = 12
    fileprivate let textTop: CGFloat = 1
    
    override init() {
        super.init()
        addSublayer(oneText)
        addSublayer(twoText)
        addSublayer(threeText)
        addSublayer(fourText)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureBottomValue(secondDrawString: String, one: CGFloat, two: CGFloat, three: CGFloat) {
        
        if secondDrawString == KLINEVOL {
            // VOL
            let oneString = "成交量: " + (one > 0 ? one.xlChart.kLineVolNumber() : "--")
            let twoString = "MA5: " + (two > 0 ? two.xlChart.kLineVolNumber() : "--")
            let threeString = "MA10: " + (three > 0 ? three.xlChart.kLineVolNumber() : "--")
    
            let oneSize = getTextSize(text: oneString)
            let twoSize = getTextSize(text: twoString)
            let threeSize = getTextSize(text: threeString)
    
            oneText.string = oneString
            twoText.string = twoString
            threeText.string = threeString
            
            oneText.frame = CGRect(x: 4, y: 0, width: oneSize.width, height: self.theme.midTextHeight)
            
            var twoHeight: CGFloat = 0
            var twoTop: CGFloat = 0
            if two > 10000 {
                twoHeight = self.theme.midTextHeight
                twoTop = 0
            }else {
                twoHeight = self.theme.midTextHeight - 1
                twoTop = textTop
            }
            twoText.frame = CGRect(x: self.oneText.frame.maxX, y: twoTop, width: twoSize.width, height: twoHeight)
            
            var threeHeight: CGFloat = 0
            var threeTop: CGFloat = 0
            if three > 10000 {
                threeHeight = self.theme.midTextHeight
                threeTop = 0
            }else {
                threeHeight = self.theme.midTextHeight - 1
                threeTop = textTop
            }
            threeText.frame = CGRect(x: self.twoText.frame.maxX, y: threeTop, width: threeSize.width, height: threeHeight)
            
            oneText.isHidden = false
            twoText.isHidden = false
            threeText.isHidden = false
            fourText.isHidden = true
        }else if secondDrawString == KLINEMACD {
            // MACD
            let oneString = "MACD(12,26,9) "
            let twoString = "MACD: " + one.xlChart.kLineVolNumber()
            let threeString = "DIF: " + two.xlChart.kLineVolNumber()
            let fourString = "DEA: " + three.xlChart.kLineVolNumber()
            
            let oneWidth = getTextSize(text: oneString).width
            let twoWidth = getTextSize(text: twoString).width
            let threeWidth = getTextSize(text: threeString).width
            let fourWidth = getTextSize(text: fourString).width
            
            oneText.string = oneString
            twoText.string = twoString
            threeText.string = threeString
            fourText.string = fourString
            
            oneText.frame = CGRect(x: 4, y: textTop, width: oneWidth, height: self.theme.midTextHeight - textTop)
            twoText.frame = CGRect(x: self.oneText.frame.maxX, y: textTop, width: twoWidth, height: self.theme.midTextHeight - textTop)
            threeText.frame = CGRect(x: self.twoText.frame.maxX, y: textTop, width: threeWidth, height: self.theme.midTextHeight - textTop)
            fourText.frame = CGRect(x: self.threeText.frame.maxX, y: textTop, width: fourWidth, height: self.theme.midTextHeight - textTop)
            
            oneText.isHidden = false
            twoText.isHidden = false
            threeText.isHidden = false
            fourText.isHidden = false
        }else if secondDrawString == KLINEKDJ {
            // KDJ
            let oneString = "KDJ(14,1,3) "
            let twoString = "K: " + one.xlChart.kLineVolNumber()
            let threeString = "D: " + two.xlChart.kLineVolNumber()
            let fourString = "J: " + three.xlChart.kLineVolNumber()
            
            let oneWidth = getTextSize(text: oneString).width
            let twoWidth = getTextSize(text: twoString).width
            let threeWidth = getTextSize(text: threeString).width
            let fourWidth = getTextSize(text: fourString).width
            
            oneText.string = oneString
            twoText.string = twoString
            threeText.string = threeString
            fourText.string = fourString
            
            oneText.frame = CGRect(x: 4, y: textTop, width: oneWidth, height: self.theme.midTextHeight - textTop)
            twoText.frame = CGRect(x: self.oneText.frame.maxX, y: textTop, width: twoWidth, height: self.theme.midTextHeight - textTop)
            threeText.frame = CGRect(x: self.twoText.frame.maxX, y: textTop, width: threeWidth, height: self.theme.midTextHeight - textTop)
            fourText.frame = CGRect(x: self.threeText.frame.maxX, y: textTop, width: fourWidth, height: self.theme.midTextHeight - textTop)
            
            oneText.isHidden = false
            twoText.isHidden = false
            threeText.isHidden = false
            fourText.isHidden = false
            
        }else if secondDrawString == KLINERSI {
            // RSI
            let twoString = "RSI(14): " + one.xlChart.kLineVolNumber()
            let twoWidth = getTextSize(text: twoString).width
            twoText.string = twoString
            
            twoText.frame = CGRect(x: 4, y: textTop, width: twoWidth, height: self.theme.midTextHeight - textTop)
            twoText.isHidden = false
            
            oneText.isHidden = true
            threeText.isHidden = true
            fourText.isHidden = true
        }
    }
    
    // MARK: - Lazy
    lazy var oneText: XLCATextLayer = {
        let oneText = XLCATextLayer()
        oneText.fontSize = 10
        oneText.foregroundColor = self.theme.bottomTextOneColor.cgColor
        oneText.backgroundColor = UIColor.clear.cgColor
        oneText.alignmentMode = CATextLayerAlignmentMode.left
        oneText.contentsScale = UIScreen.main.scale
        return oneText
    }()
    
    lazy var twoText: XLCATextLayer = {
        let twoText = XLCATextLayer()
        twoText.fontSize = 10
        twoText.foregroundColor = self.theme.bottomTextTwoColor.cgColor
        twoText.backgroundColor = UIColor.clear.cgColor
        twoText.alignmentMode = CATextLayerAlignmentMode.left
        twoText.contentsScale = UIScreen.main.scale
        return twoText
    }()
    
    lazy var threeText: XLCATextLayer = {
        let threeText = XLCATextLayer()
        threeText.fontSize = 10
        threeText.foregroundColor = self.theme.bottomTextThreeColor.cgColor
        threeText.backgroundColor = UIColor.clear.cgColor
        threeText.alignmentMode = CATextLayerAlignmentMode.left
        threeText.contentsScale = UIScreen.main.scale
        return threeText
    }()
    
    lazy var fourText: XLCATextLayer = {
        let fourText = XLCATextLayer()
        fourText.fontSize = 10
        fourText.foregroundColor = self.theme.bottomTextFourColor.cgColor
        fourText.backgroundColor = UIColor.clear.cgColor
        fourText.alignmentMode = CATextLayerAlignmentMode.left
        fourText.contentsScale = UIScreen.main.scale
        return fourText
    }()
}






