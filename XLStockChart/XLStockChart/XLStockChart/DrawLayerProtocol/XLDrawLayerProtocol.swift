//
//  XLDrawLayerProtocol.swift
//  XLStockChart
//
//  Created by 夏磊 on 2018/8/22.
//  Copyright © 2018年 sum123. All rights reserved.
//


import UIKit

public protocol XLDrawLayerProtocol {
    
    var theme: XLKLineStyle { get }
    
    func drawLine(lineWidth: CGFloat, startPoint: CGPoint, endPoint: CGPoint, strokeColor: UIColor, fillColor: UIColor, isDash: Bool, isAnimate: Bool) -> XLCAShapeLayer
    
    func drawTextLayer(frame: CGRect, text: String, foregroundColor: UIColor, backgroundColor: UIColor, fontSize: CGFloat) -> CATextLayer
    
    func getCrossLineLayer(frame: CGRect, pricePoint: CGPoint, volumePoint: CGPoint, model: AnyObject?) -> XLCAShapeLayer
}

extension XLDrawLayerProtocol {
    
    public var theme: XLKLineStyle {
        return XLKLineStyle()
    }
    
    public func drawLine(lineWidth: CGFloat,
                         startPoint: CGPoint,
                         endPoint: CGPoint,
                         strokeColor: UIColor,
                         fillColor: UIColor,
                         isDash: Bool = false,
                         isAnimate: Bool = false) -> XLCAShapeLayer {
        
        let linePath = UIBezierPath()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        
        let lineLayer = XLCAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.lineWidth = lineWidth
        lineLayer.strokeColor = strokeColor.cgColor
        lineLayer.fillColor = fillColor.cgColor
        
        if isDash {
            lineLayer.lineDashPattern = [3, 3]
        }
        
        if isAnimate {
            let path = CABasicAnimation(keyPath: "strokeEnd")
            path.duration = 1.0
            path.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            path.fromValue = 0.0
            path.toValue = 1.0
            lineLayer.add(path, forKey: "strokeEndAnimation")
            lineLayer.strokeEnd = 1.0
        }
        return lineLayer
    }
    
    public func drawTextLayer(frame: CGRect,
                              text: String,
                              foregroundColor: UIColor,
                              backgroundColor: UIColor = UIColor.clear,
                              fontSize: CGFloat = 10) -> CATextLayer {
        
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.string = text
        textLayer.fontSize = fontSize
        textLayer.foregroundColor = foregroundColor.cgColor
        textLayer.backgroundColor = backgroundColor.cgColor
        textLayer.alignmentMode = .center
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }
    
    /// 十字线的文字layer offsetY是绘制text间距
    public func drawCrossTextLayer(frame: CGRect, text: String, foregroundColor: UIColor, offsetY: CGFloat = 0, backgroundColor: UIColor = UIColor.clear, fontSize: CGFloat = 10) -> XLCAShapeLayer {
        
        let bgLayer = XLCAShapeLayer()
        bgLayer.frame = frame
        bgLayer.backgroundColor = backgroundColor.cgColor
        bgLayer.borderColor = theme.crossBorderColor
        bgLayer.borderWidth = 1
        bgLayer.cornerRadius = 2
        bgLayer.contentsScale = UIScreen.main.scale
        
        let textLayer = drawTextLayer(frame: CGRect(x: 6, y: 6 - offsetY, width: frame.width - 12, height: frame.height - 12 + offsetY), text: text, foregroundColor: foregroundColor)
        bgLayer.addSublayer(textLayer)
        
        return bgLayer
    }
    
    
    /// 获取纵轴的标签图层
    func getYAxisMarkLayer(frame: CGRect, text: String, y: CGFloat, isLeft: Bool) -> CATextLayer {
        let textSize = theme.getTextSize(text: text)
        let yAxisLabelEdgeInset: CGFloat = 5
        var labelX: CGFloat = 0
        
        if isLeft {
            labelX = yAxisLabelEdgeInset
        } else {
            labelX = frame.width - textSize.width - yAxisLabelEdgeInset
        }
        
        let labelY: CGFloat = y - textSize.height / 2.0
        
        let yMarkLayer = drawTextLayer(frame: CGRect(x: labelX, y: labelY, width: textSize.width, height: textSize.height), text: text, foregroundColor: theme.textColor)
        
        return yMarkLayer
    }
    
    /// 获取长按显示的十字线及其标签图层
    public func getCrossLineLayer(frame: CGRect, pricePoint: CGPoint, volumePoint: CGPoint, model: AnyObject?) -> XLCAShapeLayer {
        let highlightLayer = XLCAShapeLayer()
        
        let corssLineLayer = XLCAShapeLayer()
        var yAxisMarkLayer = XLCAShapeLayer()
        var bottomMarkLayer = XLCAShapeLayer()
        var bottomMarkerString = ""
        var yAxisMarkString = ""
        
        guard let model = model else { return highlightLayer }
        
        if model.isKind(of: XLKLineModel.self) {
            let entity = model as! XLKLineModel
            yAxisMarkString = entity.close.xlChart.kLinePriceNumber()
            bottomMarkerString = "\(entity.time)"
        } else{
            return highlightLayer
        }
        
        let linePath = UIBezierPath()
        
        // 竖线
        linePath.move(to: CGPoint(x: pricePoint.x, y: theme.topTextHeight))
        linePath.addLine(to: CGPoint(x: pricePoint.x, y: frame.height))
        
        // 横线
        linePath.move(to: CGPoint(x: frame.minX, y: pricePoint.y))
        linePath.addLine(to: CGPoint(x: frame.maxX, y: pricePoint.y))
        
        corssLineLayer.lineWidth = theme.corssLineWidth
        corssLineLayer.strokeColor = theme.crossLineColor.cgColor
        corssLineLayer.fillColor = theme.crossLineColor.cgColor
        corssLineLayer.path = linePath.cgPath
        
        // 标记标签大小
        let yAxisMarkSize = theme.getCrossTextSize(text: yAxisMarkString)
        //        let volMarkSize = theme.getTextSize(text: volumeMarkerString)
        let bottomMarkSize = theme.getCrossTextSize(text: bottomMarkerString)
        
        var labelX: CGFloat = 0
        var labelY: CGFloat = 0
        
        // 纵坐标标签
        if pricePoint.x > frame.width / 2 {
            labelX = frame.maxX - yAxisMarkSize.width - 2
        } else {
           labelX = frame.minX + 2
        }
        labelY = pricePoint.y - yAxisMarkSize.height / 2.0
        
        yAxisMarkLayer = drawCrossTextLayer(frame: CGRect(x: labelX, y: labelY, width: yAxisMarkSize.width, height: theme.crossTextLayerHeight), text: yAxisMarkString, foregroundColor: theme.textColor, backgroundColor: theme.crossBgColor)
        
        // 底部时间标签
        let maxX = frame.maxX - bottomMarkSize.width
        labelX = pricePoint.x - bottomMarkSize.width / 2.0
        labelY = frame.height - theme.timeTextHeight + 1
        if labelX > maxX {
            labelX = frame.maxX - bottomMarkSize.width
        } else if labelX < frame.minX {
            labelX = frame.minX
        }
        
        bottomMarkLayer = drawCrossTextLayer(frame: CGRect(x: labelX, y: labelY, width: bottomMarkSize.width, height: theme.crossTextLayerHeight - 1), text: bottomMarkerString, foregroundColor: theme.textColor, offsetY: 1, backgroundColor: theme.crossBgColor)
        
        highlightLayer.addSublayer(corssLineLayer)
        highlightLayer.addSublayer(yAxisMarkLayer)
        highlightLayer.addSublayer(bottomMarkLayer)
        
        return highlightLayer
    }
    
    func getTextSize(text: String?, fontSize: CGFloat = 10, addOnWith: CGFloat = 5, addOnHeight: CGFloat = 0) -> CGSize {
        if let text = text {
            let size = text.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)])
            let width = ceil(size.width) + addOnWith
            let height = ceil(size.height) + addOnHeight
            
            return CGSize(width: width, height: height)
        }else {
            return CGSize.zero
        }
    }
    
    /// 成交量 MA计算  从当前屏幕最后一个数据往前num个数据的vol平均值 isMustHasNum:是否必须够num的个数
    public func calcVolMa(num: Int, targetIndex: Int, isMustHasNum: Bool = false, dataK: [XLKLineModel]) -> CGFloat? {
        if targetIndex <= 0 {
            return nil
        }
        
        if isMustHasNum, targetIndex - (num - 1) < 0 {
            return nil
        }
        
        var tempIndex: Int = targetIndex
        var totailvalue:CGFloat = 0
        
        // 起始位置
        let startIdx = max(targetIndex - (num - 1), 0)
        // 参与计算的值的个数
        var valueNum = 0
        
        while tempIndex >= startIdx {
            if tempIndex < dataK.count {
                let data = dataK[tempIndex]
                totailvalue += data.volumefrom
                tempIndex -= 1
                valueNum += 1
            }
        }
        
        if valueNum > 0 {
            return totailvalue / CGFloat(valueNum)
        }else {
            return nil
        }
    }
}
