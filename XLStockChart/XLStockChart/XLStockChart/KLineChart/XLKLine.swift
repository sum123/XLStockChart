//
//  XLKLine.swift
//  XLStockChart
//
//  Created by 夏磊 on 2018/8/22.
//  Copyright © 2018年 sum123. All rights reserved.
//

import UIKit

open class XLCAShapeLayer: CAShapeLayer {
    override open func action(forKey event: String) -> CAAction? {
        return nil
    }
}

open class XLCATextLayer: CATextLayer {
    override open func action(forKey event: String) -> CAAction? {
        return nil
    }
}

public class XLKLine: UIView, XLDrawLayerProtocol {
    
    public var theme = XLKLineStyle()
    
    var dataK: [XLKLineModel] = []
    var positionModels: [XLKLineCoordModel] = []
    var klineModels: [XLKLineModel] = []
    
    var contentOffsetX: CGFloat = 0
    
    // 最高价 最低价  用于显示最高最低值
    var highestPrice: CGFloat = 0
    var highestPoint: CGPoint = CGPoint.zero
    var lowestPrice: CGFloat = 0
    var lowestPoint: CGPoint = CGPoint.zero
    
    // 横向分隔线的价格 根据坐标计算得来
    var onePrice: CGFloat = 0
    var twoPrice: CGFloat = 0
    var threePrice: CGFloat = 0
    var fourPrice: CGFloat = 0
    var fivePrice: CGFloat = 0
    
    // 主图
    var priceUnit: CGFloat = 0.01
    
    // 最大值 最小值 用于计算整个区间的范围 有可能需要算入BOLL的值 所以不能等同价格最大最小值
    var mainMaxPrice: CGFloat = 0
    var mainMinPrice: CGFloat = 0
    var mainMaxMA: CGFloat = 0
    var mainMinMA: CGFloat = 0
    var mainMaxBoll: CGFloat = 0
    var mainMinBoll: CGFloat = 0
    
    // 副图
    var bottomChartUnit: CGFloat = 0.01
    
    //VOL
    var maxVolume: CGFloat = 0
    var minVolume: CGFloat = 0
    
    // KDJ
    var maxKDJ: CGFloat = 0
    var minKDJ: CGFloat = 0
    
    // MACD
    var maxMACD: CGFloat = 0
    var minMACD: CGFloat = 0
    
    // RSI
    var maxRSI: CGFloat = 0
    var minRSI: CGFloat = 0
    
    var renderRect: CGRect = CGRect.zero
    var renderWidth: CGFloat = 0
    
    // 时间layer
    lazy var xAxisTimeMarkLayer = XLCAShapeLayer()
    
    // 主图layer
    lazy var minLineChartLayer = XLCAShapeLayer()
    lazy var minLineFillColorLayer = XLCAShapeLayer()
    lazy var ma60LineLayer = XLCAShapeLayer()
    // 蜡烛图
    lazy var candleChartLayer = XLCAShapeLayer()
    // MA
    lazy var ma5LineLayer = XLCAShapeLayer()
    lazy var ma10LineLayer = XLCAShapeLayer()
    lazy var ma30LineLayer = XLCAShapeLayer()
    // BOLL
    lazy var upBollLineLayer = XLCAShapeLayer()
    lazy var midBollLineLayer = XLCAShapeLayer()
    lazy var lowBollLineLayer = XLCAShapeLayer()
    
    // 副图layer
    // VOL
    lazy var volumeLayer = XLCAShapeLayer()
    lazy var volMa5LineLayer = XLCAShapeLayer()
    lazy var volMa10LineLayer = XLCAShapeLayer()
    
    // MACD
    lazy var macd_barLayer = XLCAShapeLayer()
    lazy var macd_diffLayer = XLCAShapeLayer()
    lazy var macd_deaLayer = XLCAShapeLayer()
    
    // KDJ
    lazy var kdj_K_LineLayer = XLCAShapeLayer()
    lazy var kdj_D_LineLayer = XLCAShapeLayer()
    lazy var kdj_J_LineLayer = XLCAShapeLayer()
    
    // RSI
    lazy var rsiLineLayer = XLCAShapeLayer()
    
    // 最高最低
    var highLowLayer: XLHighLowTextLayer!
    
    var mainDrawString: String = KLINEMA
    var secondDrawString: String = KLINEVOL
    
    var dateType: XLKLineDateType = .min
    var lineType: XLKLineType = .candleLineType
    
    var topChartHeight: CGFloat {
        get {
            return self.frame.maxY - theme.topTextHeight - theme.midTextHeight - theme.bottomChartHeight - theme.timeTextHeight
        }
    }
    
    var topChartTop: CGFloat {
        get {
            return theme.topTextHeight
        }
    }
    
    var midTextTop: CGFloat {
        get {
            return theme.topTextHeight + topChartHeight
        }
    }
    
    var bottomChartTop: CGFloat {
        get {
            return theme.topTextHeight + topChartHeight + theme.midTextHeight
        }
    }
    
    var timeTextTop: CGFloat {
        get {
            return theme.topTextHeight + topChartHeight + theme.midTextHeight + theme.bottomChartHeight
        }
    }
    
    // 计算处于当前显示区域左边隐藏的蜡烛图的个数，即为当前显示的初始 index
    var startIndex: Int {
        get {
            let scrollViewOffsetX = contentOffsetX < 0 ? 0 : contentOffsetX
            var leftCandleCount = Int(abs(scrollViewOffsetX) / (theme.candleWidth + theme.candleGap))

            if leftCandleCount > dataK.count {
                leftCandleCount = dataK.count - 1
                return leftCandleCount
            } else if leftCandleCount == 0 {
                return leftCandleCount
            } else {
                return leftCandleCount + 1
            }
        }
    }
    
    // 当前显示区域起始横坐标 x
    var startX: CGFloat {
        get {
            let scrollViewOffsetX = contentOffsetX < 0 ? 0 : contentOffsetX
            return scrollViewOffsetX
        }
    }
    
    // 当前显示区域最多显示的蜡烛图个数
    var countOfshowCandle: Int {
        get {
//            return Int((renderWidth - theme.candleWidth) / ( theme.candleWidth + theme.candleGap))
            return Int(renderWidth / ( theme.candleWidth + theme.candleGap))
        }
    }
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        highLowLayer = XLHighLowTextLayer()
        highLowLayer.frame = bounds
        self.layer.addSublayer(highLowLayer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Drawing Function
    func drawKLineView(mainDrawString: String, secondDrawString: String, lineType: XLKLineType) {
        self.mainDrawString = mainDrawString
        self.secondDrawString = secondDrawString
        self.lineType = lineType
        
        calcMaxAndMinData()
        convertToPositionModel(data: dataK)
        
        clearLayer()
        drawxAxisTimeMarkLayer()
        
        
        // 主图
        if lineType == .minLineType {
            // 分时
            drawMinLineChartLayer(array: positionModels)
            highLowLayer.isHidden = true
            
            if mainDrawString == KLINEMA {
                drawMinLineMALayer(array: positionModels)
            }else if mainDrawString == KLINEBOLL {
                drawMinLineBOLLLayer(array: positionModels)
            }else if mainDrawString == KLINEHIDE {
                print("隐藏")
            }
        }else {
            // K线
            drawCandleChartLayer(array: positionModels)
            if mainDrawString == KLINEMA {
                drawMainMALayer(array: positionModels)
            }else if mainDrawString == KLINEBOLL {
                drawBOLLLayer(array: positionModels)
            }else if mainDrawString == KLINEHIDE {
                print("隐藏")
            }
            
            // 最高最低
            drawHighLowLayer()
            highLowLayer.isHidden = false
        }
        
        // 副图
        if secondDrawString == KLINEVOL {
            drawVolumeLayer(array: positionModels)
            drawVolMALayer(array: positionModels)
        }else if secondDrawString == KLINEMACD {
            drawMACD_BAR_Layer(array: positionModels)
            drawMACD_DIF_DEA_Layer(array: positionModels)
        }else if secondDrawString == KLINEKDJ {
            drawKDJLayer(array: positionModels)
        }else if secondDrawString == KLINERSI {
            drawRsiLayer(array: positionModels)
        }
    }
    
    /// 计算当前显示区域的最大最小值
    fileprivate func calcMaxAndMinData() {
        if dataK.count > 0 {
            
            self.mainMaxPrice = CGFloat.leastNormalMagnitude
            self.mainMinPrice = CGFloat.greatestFiniteMagnitude
            self.mainMaxMA = CGFloat.leastNormalMagnitude
            self.mainMinMA = CGFloat.greatestFiniteMagnitude
            self.mainMaxBoll = CGFloat.leastNormalMagnitude
            self.mainMinBoll = CGFloat.greatestFiniteMagnitude
            
            self.maxVolume = CGFloat.leastNormalMagnitude
            self.minVolume = CGFloat.greatestFiniteMagnitude
            self.maxKDJ = -CGFloat.greatestFiniteMagnitude
            self.minKDJ = CGFloat.greatestFiniteMagnitude
            self.maxMACD = -CGFloat.greatestFiniteMagnitude
            self.minMACD = CGFloat.greatestFiniteMagnitude
            self.maxRSI = -CGFloat.greatestFiniteMagnitude
            self.minRSI = CGFloat.greatestFiniteMagnitude
            
            let startIndex = self.startIndex
            // 比计算出来的多加一个，是为了避免计算结果的取整导致少画
            let count = (startIndex + countOfshowCandle + 1) > dataK.count ? dataK.count : (startIndex + countOfshowCandle + 1)
            
            if startIndex < count {
                for i in startIndex ..< count {
                    let entity = dataK[i]
                    
                    // 主图
                    if self.lineType == .minLineType {
                        // 分时
                        self.mainMaxPrice = self.mainMaxPrice > entity.close ? self.mainMaxPrice : entity.close
                        self.mainMinPrice = self.mainMinPrice < entity.close ? self.mainMinPrice : entity.close
                        
                        if self.mainDrawString == KLINEMA {
                            // MA
                            self.mainMaxMA = self.mainMaxMA > entity.ma60 ? self.mainMaxMA : entity.ma60

                            // 过滤负数
                            if entity.ma60 > 0 {
                                self.mainMinMA = self.mainMinMA < entity.ma60 ? self.mainMinMA : entity.ma60
                            }
                            
                        }else if self.mainDrawString == KLINEBOLL {
                            // BOLL
                            self.mainMaxBoll = self.mainMaxBoll > entity.boll_mb ? self.mainMaxBoll : entity.boll_mb
                            self.mainMinBoll = self.mainMinBoll < entity.boll_mb ? self.mainMinBoll : entity.boll_mb
                        }
                        
                    }else {
                        // K线
                        self.mainMaxPrice = self.mainMaxPrice > entity.high ? self.mainMaxPrice : entity.high
                        self.mainMinPrice = self.mainMinPrice < entity.low ? self.mainMinPrice : entity.low
                        
                        if self.mainDrawString == KLINEMA {
                            // MA
                            let tempMAMax = max(entity.ma5, entity.ma10, entity.ma30)
                            self.mainMaxMA = self.mainMaxMA > tempMAMax ? self.mainMaxMA : tempMAMax
                            
                            // 过滤负数
                            if entity.ma5 > 0, entity.ma10 > 10, entity.ma30 > 0 {
                                let tempMAMin = min(entity.ma5, entity.ma10, entity.ma30)
                                self.mainMinMA = self.mainMinMA < tempMAMin ? self.mainMinMA : tempMAMin
                            }
                            
                        }else if self.mainDrawString == KLINEBOLL {
                            // BOLL
                            self.mainMaxBoll = self.mainMaxBoll > entity.boll_up ? self.mainMaxBoll : entity.boll_up
                            self.mainMinBoll = self.mainMinBoll < entity.boll_dn ? self.mainMinBoll : entity.boll_dn
                        }
                    }
                    
                    // 副图
                    if self.secondDrawString == KLINEVOL {
                        // VOL
                        self.maxVolume = self.maxVolume > entity.volumefrom ? self.maxVolume : entity.volumefrom
                        self.minVolume = self.minVolume < entity.volumefrom ? self.minVolume : entity.volumefrom

                        
                        // 计算VOL的MA5 MA10
                        entity.volMa5 = calcVolMa(num: 5, targetIndex: i, isMustHasNum: true, dataK: dataK) ?? 0
                        entity.volMa10 = calcVolMa(num: 10, targetIndex: i, isMustHasNum: true, dataK: dataK) ?? 0
                        dataK[i] = entity
                        
                        self.maxVolume = max(entity.volMa5, entity.volMa10, self.maxVolume)
                        
                        if entity.volMa5 > 0, entity.volMa10 > 0 {
                            self.minVolume = min(entity.volMa5, entity.volMa10, self.minVolume)
                        }
                        
                    }else if self.secondDrawString == KLINEMACD {
                        // MACD
                        let tempMACDMax = max(entity.macd_bar, entity.macd_dea, entity.macd_diff)
                        self.maxMACD = self.maxMACD > tempMACDMax ? self.maxMACD : tempMACDMax
                        
                        let tempMACDMin = min(entity.macd_bar, entity.macd_dea, entity.macd_diff)
                        self.minMACD = self.minMACD < tempMACDMin ? self.minMACD : tempMACDMin
                        
                        
                    }else if self.secondDrawString == KLINEKDJ {
                        // KDJ
                        let tempKDJMax = max(entity.kdj_k, entity.kdj_d, entity.kdj_j)
                        self.maxKDJ = self.maxKDJ > tempKDJMax ? self.maxKDJ : tempKDJMax
                        
                        let tempKDJMin = min(entity.kdj_k, entity.kdj_d, entity.kdj_j)
                        self.minKDJ = self.minKDJ < tempKDJMin ? self.minKDJ : tempKDJMin
                        
                    }else if self.secondDrawString == KLINERSI {
                        // RSI
                        self.maxRSI = self.maxRSI > entity.rsi ? self.maxRSI : entity.rsi
                        
                        self.minRSI = self.minRSI < entity.rsi ? self.minRSI : entity.rsi
                    }
                }
            }
            
            // 算出需要绘制的最大最小值
            // 主图
            if self.mainDrawString == KLINEMA {
                // MA
                self.mainMaxPrice = self.mainMaxPrice > self.mainMaxMA ? self.mainMaxPrice : self.mainMaxMA
                self.mainMinPrice = self.mainMinPrice < self.mainMinMA ? self.mainMinPrice : self.mainMinMA
            }else if self.mainDrawString == KLINEBOLL {
                // BOLL
                self.mainMaxPrice = self.mainMaxPrice > self.mainMaxBoll ? self.mainMaxPrice : self.mainMaxBoll
                self.mainMinPrice = self.mainMinPrice < self.mainMinBoll ? self.mainMinPrice : self.mainMinBoll
            }
            
            // 副图
            if self.secondDrawString == KLINEVOL {
                // VOL
            }else if self.secondDrawString == KLINEMACD {
                // MACD
            }else if self.secondDrawString == KLINEKDJ {
                // KDJ
            }else if self.secondDrawString == KLINERSI {
                // RSI
            }
        }
    }
    
    /// 转换为坐标 model
    fileprivate func convertToPositionModel(data: [XLKLineModel]) {
        
        if data.count < 1 {
            return
        }
        
        self.positionModels.removeAll()
        self.klineModels.removeAll()
        
        let axisGap = countOfshowCandle / 4
        let gap = theme.topChartMinYGap
        let minY = gap
        
        let maxDiffPrice = self.mainMaxPrice - self.mainMinPrice
        if maxDiffPrice > 0 {
            priceUnit = (topChartHeight - 2 * minY) / maxDiffPrice
        }
        
        var maxDiffVolume: CGFloat = 0
        if self.secondDrawString == KLINEVOL {
            maxDiffVolume = self.maxVolume - self.minVolume
            bottomChartUnit = (theme.bottomChartHeight - theme.volumeGap) / maxDiffVolume
        }else if self.secondDrawString == KLINEMACD {
            maxDiffVolume = self.maxMACD - self.minMACD
            bottomChartUnit = (theme.bottomChartHeight - 2 * theme.volumeGap) / maxDiffVolume
        }else if self.secondDrawString == KLINEKDJ {
            maxDiffVolume = self.maxKDJ - self.minKDJ
            bottomChartUnit = (theme.bottomChartHeight - 2 * theme.volumeGap) / maxDiffVolume
        }else if self.secondDrawString == KLINERSI {
            maxDiffVolume = self.maxRSI - self.minRSI
            bottomChartUnit = (theme.bottomChartHeight - 2 * theme.volumeGap) / maxDiffVolume
        }
        
        let count = (startIndex + countOfshowCandle + 1) > data.count ? data.count : (startIndex + countOfshowCandle + 1)
        
        // 绘制顶部chart视图top顶部起始位置
        let topChartPostionTop = minY + topChartTop
        
        // 绘制底部chart视图top顶部起始位置
        let bottomChartPostionTop = bottomChartTop + theme.volumeGap
        
        // macdBar中线起始位置
        let startMacdBarY = abs(self.maxMACD) * bottomChartUnit + bottomChartPostionTop
        
        self.highestPrice = CGFloat.leastNormalMagnitude
        self.lowestPrice = CGFloat.greatestFiniteMagnitude
        
        // 计算几条横隔线的y值price
        let gapPrice: CGFloat = theme.topChartMinYGap / priceUnit
        self.onePrice = self.mainMaxPrice + gapPrice
        self.fivePrice = self.mainMinPrice - gapPrice
        let marginPrice = (self.onePrice - self.fivePrice) / 4.0
        self.fourPrice = self.fivePrice + marginPrice
        self.threePrice = self.fivePrice + marginPrice * 2
        self.twoPrice = self.fivePrice + marginPrice * 3
        
        if startIndex < count {
            for index in startIndex ..< count {
                let model = data[index]
                
                // 临时数据
                var highPoint: CGPoint = CGPoint.zero
                var lowPoint: CGPoint = CGPoint.zero
                var openPointY: CGFloat = 0
                var closePointY: CGFloat = 0
                var fillCandleColor = UIColor.black
                var candleRect = CGRect.zero
                
                var ma5Point: CGPoint = CGPoint.zero
                var ma10Point: CGPoint = CGPoint.zero
                var ma30Point: CGPoint = CGPoint.zero
                
                var ma60Point: CGPoint = CGPoint.zero
                
                var upBollPoint: CGPoint = CGPoint.zero
                var midBollPoint: CGPoint = CGPoint.zero
                var lowBollPoint: CGPoint = CGPoint.zero
                
                var minLinePoint: CGPoint = CGPoint.zero
                var minLine60MaPoint: CGPoint = CGPoint.zero
                
                var volumeStartPoint: CGPoint = CGPoint.zero
                var volumeEndPoint: CGPoint = CGPoint.zero
                var volMa5Point: CGPoint = CGPoint.zero
                var volMa10Point: CGPoint = CGPoint.zero
                
                var kdj_K_Point: CGPoint = CGPoint.zero
                var kdj_D_Point: CGPoint = CGPoint.zero
                var kdj_J_Point: CGPoint = CGPoint.zero
                
                var rsiPoint: CGPoint = CGPoint.zero
                
                var macdStartPoint: CGPoint = CGPoint.zero
                var macdEndPoint: CGPoint = CGPoint.zero
                var diffPoint: CGPoint = CGPoint.zero
                var deaPoint: CGPoint = CGPoint.zero
                var macdBarColor = UIColor.black
                
                // 公共数据
                let leftPosition = startX + CGFloat(index - startIndex) * (theme.candleWidth + theme.candleGap)
                let xPosition = leftPosition + theme.candleWidth * 0.5
                
                highPoint = CGPoint(x: xPosition, y: (mainMaxPrice - model.high) * priceUnit + topChartPostionTop)
                lowPoint = CGPoint(x: xPosition, y: (mainMaxPrice - model.low) * priceUnit + topChartPostionTop)
                openPointY = (mainMaxPrice - model.open) * priceUnit + topChartPostionTop
                closePointY = (mainMaxPrice - model.close) * priceUnit + topChartPostionTop
                
                // 蜡烛rect和颜色
                if(openPointY > closePointY) {
                    fillCandleColor = theme.riseColor
                    candleRect = CGRect(x: leftPosition, y: closePointY, width: theme.candleWidth, height: openPointY - closePointY)
                    
                } else if(openPointY < closePointY) {
                    fillCandleColor = theme.fallColor
                    candleRect = CGRect(x: leftPosition, y: openPointY, width: theme.candleWidth, height: closePointY - openPointY)
                    
                } else {
                    candleRect = CGRect(x: leftPosition, y: closePointY, width: theme.candleWidth, height: theme.candleMinHeight)
                    if(index > 0) {
                        let preKLineModel = data[index - 1]
                        if(model.open > preKLineModel.close) {
                            fillCandleColor = theme.riseColor
                        } else {
                            fillCandleColor = theme.fallColor
                        }
                    }
                }
                
                // 主图
                if self.lineType == .minLineType {
                    // 分时
                    minLinePoint = CGPoint(x: xPosition, y: (mainMaxPrice - model.close) * priceUnit + topChartPostionTop)
                    minLine60MaPoint = CGPoint(x: xPosition, y: (mainMaxPrice - model.close) * priceUnit + topChartPostionTop)
                    
                    if self.mainDrawString == KLINEMA {
                        // MA
                        if model.ma60 > 0 {
                            ma60Point = CGPoint(x: xPosition, y: (mainMaxPrice - model.ma60) * priceUnit + topChartPostionTop)
                        }
                        if ma60Point.y < topChartTop || ma60Point.y > midTextTop {
                            ma60Point = .zero
                        }
                    }else if self.mainDrawString == KLINEBOLL {
                        // BOLL
                        midBollPoint = CGPoint(x: xPosition, y: (mainMaxPrice - model.boll_mb) * priceUnit + topChartPostionTop)
                    }
                }else {
                    // K线
                    // 最高价
                    if self.highestPrice < model.high {
                        self.highestPrice = model.high
                        self.highestPoint = highPoint
                    }
                    
                    // 最低价
                    if self.lowestPrice > model.low {
                        self.lowestPrice = model.low
                        self.lowestPoint = lowPoint
                    }
                    if self.mainDrawString == KLINEMA {
                        // MA
                        if model.ma5 > 0 {
                            ma5Point = CGPoint(x: xPosition, y: (mainMaxPrice - model.ma5) * priceUnit + topChartPostionTop)
                        }
                        if ma5Point.y < topChartTop || ma5Point.y > midTextTop {
                            ma5Point = .zero
                        }
                        
                        if model.ma10 > 0 {
                            ma10Point = CGPoint(x: xPosition, y: (mainMaxPrice - model.ma10) * priceUnit + topChartPostionTop)
                        }
                        
                        if ma10Point.y < topChartTop || ma10Point.y > midTextTop {
                            ma10Point = .zero
                        }
                        
                        if model.ma30 > 0 {
                            ma30Point = CGPoint(x: xPosition, y: (mainMaxPrice - model.ma30) * priceUnit + topChartPostionTop)
                        }
                        
                        if ma30Point.y < topChartTop || ma30Point.y > midTextTop {
                            ma30Point = .zero
                        }
                        
                    }else if self.mainDrawString == KLINEBOLL {
                        // BOLL
                        upBollPoint = CGPoint(x: xPosition, y: (mainMaxPrice - model.boll_up) * priceUnit + topChartPostionTop)
                        midBollPoint = CGPoint(x: xPosition, y: (mainMaxPrice - model.boll_mb) * priceUnit + topChartPostionTop)
                        lowBollPoint = CGPoint(x: xPosition, y: (mainMaxPrice - model.boll_dn) * priceUnit + topChartPostionTop)
                    }
                }
                
                // 副图
                if self.secondDrawString == KLINEVOL {
                    // VOL
                    var volume = (model.volumefrom - self.minVolume) * bottomChartUnit
                    // 小于1 默认给1的高度
                    if volume < theme.minVolHeight {
                        volume = theme.minVolHeight
                    }
                    volumeStartPoint = CGPoint(x: xPosition, y: timeTextTop - volume)
                    volumeEndPoint = CGPoint(x: xPosition, y: timeTextTop)
                    
                    let volMa5Y = (self.maxVolume - model.volMa5) * bottomChartUnit + bottomChartPostionTop
                    if model.volMa5 > 0, volMa5Y > 0, volMa5Y <= timeTextTop {
                        volMa5Point = CGPoint(x: xPosition, y: volMa5Y)
                    }
                    
                    let volMa10Y = (self.maxVolume - model.volMa10) * bottomChartUnit + bottomChartPostionTop
                    if model.volMa10 > 0, volMa10Y > 0, volMa10Y <= timeTextTop {
                        volMa10Point = CGPoint(x: xPosition, y: volMa10Y)
                    }
                }else if self.secondDrawString == KLINEMACD {
                    // MACD
                    let macd_bar = abs(model.macd_bar) * bottomChartUnit
                    macdStartPoint = CGPoint(x: xPosition, y: startMacdBarY)
                    if model.macd_bar > 0 {
                        macdEndPoint = CGPoint(x: xPosition, y: startMacdBarY - macd_bar)
                        macdBarColor = theme.riseColor
                    }else if model.macd_bar < 0 {
                        macdEndPoint = CGPoint(x: xPosition, y: startMacdBarY + macd_bar)
                        macdBarColor = theme.fallColor
                    }else {
                        macdBarColor = UIColor.clear
                    }

                    let diffY = (self.maxMACD - model.macd_diff) * bottomChartUnit + bottomChartPostionTop
                    diffPoint = CGPoint(x: xPosition, y: diffY)

                    let deaY = (self.maxMACD - model.macd_dea) * bottomChartUnit + bottomChartPostionTop
                    deaPoint = CGPoint(x: xPosition, y: deaY)

                }else if self.secondDrawString == KLINEKDJ {
                    // KDJ
                    let kdj_K_Y = (self.maxKDJ - model.kdj_k) * bottomChartUnit + bottomChartPostionTop
                    kdj_K_Point = CGPoint(x: xPosition, y: kdj_K_Y)
                    
                    let kdj_D_Y = (self.maxKDJ - model.kdj_d) * bottomChartUnit + bottomChartPostionTop
                    kdj_D_Point = CGPoint(x: xPosition, y: kdj_D_Y)
                    
                    let kdj_J_Y = (self.maxKDJ - model.kdj_j) * bottomChartUnit + bottomChartPostionTop
                    kdj_J_Point = CGPoint(x: xPosition, y: kdj_J_Y)

                }else if self.secondDrawString == KLINERSI {
                    // RSI
                    let rsiY = (self.maxRSI - model.rsi) * bottomChartUnit + bottomChartPostionTop
                    rsiPoint = CGPoint(x: xPosition, y: rsiY)
                }

                let positionModel = XLKLineCoordModel()
                positionModel.highPoint = highPoint
                positionModel.lowPoint = lowPoint
                positionModel.openPoint = CGPoint(x: xPosition, y: openPointY)
                positionModel.closePoint = CGPoint(x: xPosition, y: closePointY)
                positionModel.closeY = closePointY
                positionModel.ma5Point = ma5Point
                positionModel.ma10Point = ma10Point
                positionModel.ma30Point = ma30Point
                positionModel.ma60Point = ma60Point
                positionModel.upBollPoint = upBollPoint
                positionModel.midBollPoint = midBollPoint
                positionModel.lowBollPoint = lowBollPoint
                positionModel.minLinePoint = minLinePoint
                positionModel.minLine60MaPoint = minLine60MaPoint
                positionModel.volumeStartPoint = volumeStartPoint
                positionModel.volumeEndPoint = volumeEndPoint
                positionModel.volMa5Point = volMa5Point
                positionModel.volMa10Point = volMa10Point
                positionModel.candleFillColor = fillCandleColor
                positionModel.candleRect = candleRect
                positionModel.kdj_K_Point = kdj_K_Point
                positionModel.kdj_D_Point = kdj_D_Point
                positionModel.kdj_J_Point = kdj_J_Point
                positionModel.macdStartPoint = macdStartPoint
                positionModel.macdEndPoint = macdEndPoint
                positionModel.deaPoint = deaPoint
                positionModel.diffPoint = diffPoint
                positionModel.macdBarColor = macdBarColor
                positionModel.rsiPoint = rsiPoint
                if index % axisGap == 0 {
                    positionModel.isDrawAxis = true
                }
                self.positionModels.append(positionModel)
                self.klineModels.append(model)
            }
        }
    }
    
    // MARK: - 主图
    /// 画分时图
    func drawMinLineChartLayer(array: [XLKLineCoordModel]) {
        if array.count < 1 {
            return
        }
        
        let minLinePath = UIBezierPath()
        minLinePath.move(to: array.first!.minLinePoint)
        for index in 1 ..< array.count {
            minLinePath.addLine(to: array[index].minLinePoint)
        }
        
        minLineChartLayer.frame = self.bounds
        minLineChartLayer.path = minLinePath.cgPath
        minLineChartLayer.lineWidth = theme.frameWidth
        minLineChartLayer.strokeColor = theme.minLineColor.cgColor
        minLineChartLayer.fillColor = UIColor.clear.cgColor
    
        // 填充颜色
        minLinePath.addLine(to: CGPoint(x: array.last!.minLinePoint.x, y: midTextTop))
        minLinePath.addLine(to: CGPoint(x: array[0].minLinePoint.x, y: midTextTop))
        minLineFillColorLayer.frame = self.bounds
        minLineFillColorLayer.path = minLinePath.cgPath
        minLineFillColorLayer.fillColor = theme.minLinefillColor.cgColor
        minLineFillColorLayer.strokeColor = UIColor.clear.cgColor
        minLineFillColorLayer.zPosition -= 1 // 将图层置于下一级，让底部的标记线显示出来
        
        self.layer.addSublayer(minLineChartLayer)
        self.layer.addSublayer(minLineFillColorLayer)
    }
    
    /// 画分时均线图
    func drawMinLineMALayer(array: [XLKLineCoordModel]) {
        
        if array.count < 1 {
            return
        }
        
        let ma60LinePath = UIBezierPath()
        for index in 1 ..< array.count {
            let preMa60Point = array[index - 1].ma60Point
            let ma60Point = array[index].ma60Point
            if ma60Point != .zero, preMa60Point != .zero {
                ma60LinePath.move(to: preMa60Point)
                ma60LinePath.addLine(to: ma60Point)
            }
        }
        
        ma60LineLayer.frame = self.bounds
        ma60LineLayer.path = ma60LinePath.cgPath
        ma60LineLayer.strokeColor = theme.topTextOneColor.cgColor
        ma60LineLayer.fillColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(ma60LineLayer)
    }
    
    /// 画分时图的BOLL线图
    func drawMinLineBOLLLayer(array: [XLKLineCoordModel]) {
        
        if array.count < 1 {
            return
        }
        
        let midBollLinePath = UIBezierPath()
        for index in 1 ..< array.count {
            let preMidBollPoint = array[index - 1].midBollPoint
            let midBollPoint = array[index].midBollPoint
            midBollLinePath.move(to: preMidBollPoint)
            midBollLinePath.addLine(to: midBollPoint)
        }
        
        midBollLineLayer.frame = bounds
        midBollLineLayer.path = midBollLinePath.cgPath
        midBollLineLayer.strokeColor = theme.topTextOneColor.cgColor
        midBollLineLayer.fillColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(midBollLineLayer)
    }
    
    /// 画蜡烛图
    func drawCandleChartLayer(array: [XLKLineCoordModel]) {
        candleChartLayer.frame = bounds
        for object in array.enumerated() {
            let candleLayer = getCandleLayer(model: object.element)
            candleChartLayer.addSublayer(candleLayer)
        }
        self.layer.addSublayer(candleChartLayer)
    }
    
    /// 画主均线图
    func drawMainMALayer(array: [XLKLineCoordModel]) {
        
        if array.count < 1 {
            return
        }
        
        let ma5LinePath = UIBezierPath()
        let ma10LinePath = UIBezierPath()
        let ma30LinePath = UIBezierPath()
        for index in 1 ..< array.count {
            let preMa5Point = array[index - 1].ma5Point
            let ma5Point = array[index].ma5Point
            if ma5Point != .zero, preMa5Point != .zero {
                ma5LinePath.move(to: preMa5Point)
                ma5LinePath.addLine(to: ma5Point)
            }
            
            let preMa10Point = array[index - 1].ma10Point
            let ma10Point = array[index].ma10Point
            if ma10Point != .zero, preMa10Point != .zero {
                ma10LinePath.move(to: preMa10Point)
                ma10LinePath.addLine(to: ma10Point)
            }
            
            let preMa30Point = array[index - 1].ma30Point
            let ma30Point = array[index].ma30Point
            if ma30Point != .zero, preMa30Point != .zero {
                ma30LinePath.move(to: preMa30Point)
                ma30LinePath.addLine(to: ma30Point)
            }
        }
        
        ma5LineLayer.frame = self.bounds
        ma5LineLayer.path = ma5LinePath.cgPath
        ma5LineLayer.strokeColor = theme.topTextOneColor.cgColor
        ma5LineLayer.fillColor = UIColor.clear.cgColor
        
        ma10LineLayer.frame = self.bounds
        ma10LineLayer.path = ma10LinePath.cgPath
        ma10LineLayer.strokeColor = theme.topTextTwoColor.cgColor
        ma10LineLayer.fillColor = UIColor.clear.cgColor
        
        ma30LineLayer.frame = self.bounds
        ma30LineLayer.path = ma30LinePath.cgPath
        ma30LineLayer.strokeColor = theme.topTextThreeColor.cgColor
        ma30LineLayer.fillColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(ma5LineLayer)
        self.layer.addSublayer(ma10LineLayer)
        self.layer.addSublayer(ma30LineLayer)
    }
    
    /// 画BOLL线图
    func drawBOLLLayer(array: [XLKLineCoordModel]) {
        
        if array.count < 1 {
            return
        }
        
        let upBollLinePath = UIBezierPath()
        let midBollLinePath = UIBezierPath()
        let lowBollLinePath = UIBezierPath()
        for index in 1 ..< array.count {
            let preUpBollPoint = array[index - 1].upBollPoint
            let upBollPoint = array[index].upBollPoint
            upBollLinePath.move(to: preUpBollPoint)
            upBollLinePath.addLine(to: upBollPoint)
            
            let preMidBollPoint = array[index - 1].midBollPoint
            let midBollPoint = array[index].midBollPoint
            midBollLinePath.move(to: preMidBollPoint)
            midBollLinePath.addLine(to: midBollPoint)
            
            let preLowPoint = array[index - 1].lowBollPoint
            let lowPoint = array[index].lowBollPoint
            lowBollLinePath.move(to: preLowPoint)
            lowBollLinePath.addLine(to: lowPoint)
        }
        
        upBollLineLayer.frame = bounds
        upBollLineLayer.path = upBollLinePath.cgPath
        upBollLineLayer.strokeColor = theme.topTextOneColor.cgColor
        upBollLineLayer.fillColor = UIColor.clear.cgColor
        
        midBollLineLayer.frame = bounds
        midBollLineLayer.path = midBollLinePath.cgPath
        midBollLineLayer.strokeColor = theme.topTextTwoColor.cgColor
        midBollLineLayer.fillColor = UIColor.clear.cgColor
        
        lowBollLineLayer.frame = bounds
        lowBollLineLayer.path = lowBollLinePath.cgPath
        lowBollLineLayer.strokeColor = theme.topTextThreeColor.cgColor
        lowBollLineLayer.fillColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(upBollLineLayer)
        self.layer.addSublayer(midBollLineLayer)
        self.layer.addSublayer(lowBollLineLayer)
    }

    /// 绘制最高最低
    func drawHighLowLayer() { 
        highLowLayer.moveHighLowLayer(highPoint: highestPoint, highPrice: highestPrice, lowPoint: lowestPoint, lowPrice: lowestPrice, startX: startX)
        self.layer.insertSublayer(highLowLayer, above: candleChartLayer)
    }
    
    // MARK: - 成交量
    /// 画成交量图
    func drawVolumeLayer(array: [XLKLineCoordModel]) {
        volumeLayer.frame = bounds
        for object in array.enumerated() {
            let model = object.element
            let volLayer = drawLine(lineWidth: theme.candleWidth + theme.candleGap * 0.5,
                                    startPoint: model.volumeStartPoint,
                                    endPoint: model.volumeEndPoint,
                                    strokeColor: model.candleFillColor,
                                    fillColor: model.candleFillColor)
            volumeLayer.addSublayer(volLayer)
        }
        self.layer.addSublayer(volumeLayer)
    }
    
    
    /// 画VOL均线图
    func drawVolMALayer(array: [XLKLineCoordModel]) {
        
        if array.count < 1 {
            return
        }
        
        let volMa5LinePath = UIBezierPath()
        let volMa10LinePath = UIBezierPath()
        
        for index in 1 ..< array.count {
            let preVolMa5Point = array[index - 1].volMa5Point
            let volMa5Point = array[index].volMa5Point
            if volMa5Point != .zero, preVolMa5Point != .zero {
                volMa5LinePath.move(to: preVolMa5Point)
                volMa5LinePath.addLine(to: volMa5Point)
            }
            
            let preVolMa10Point = array[index - 1].volMa10Point
            let volMa10Point = array[index].volMa10Point
            if volMa10Point != .zero, preVolMa10Point != .zero {
                volMa10LinePath.move(to: preVolMa10Point)
                volMa10LinePath.addLine(to: volMa10Point)
            }
        }
        
        volMa5LineLayer.frame = bounds
        volMa5LineLayer.path = volMa5LinePath.cgPath
        volMa5LineLayer.strokeColor = theme.bottomTextTwoColor.cgColor
        volMa5LineLayer.fillColor = UIColor.clear.cgColor
        
        volMa10LineLayer.frame = bounds
        volMa10LineLayer.path = volMa10LinePath.cgPath
        volMa10LineLayer.strokeColor = theme.bottomTextThreeColor.cgColor
        volMa10LineLayer.fillColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(volMa5LineLayer)
        self.layer.addSublayer(volMa10LineLayer)
    }
    
    // MARK: - KDJ
    /// 画KDJ线图
    func drawKDJLayer(array: [XLKLineCoordModel]) {
        
        if array.count < 1 {
            return
        }
        
        let KDJ_K_LinePath = UIBezierPath()
        let KDJ_D_LinePath = UIBezierPath()
        let KDJ_J_LinePath = UIBezierPath()
        
        for index in 1 ..< array.count {
            let preKPoint = array[index - 1].kdj_K_Point
            let kPoint = array[index].kdj_K_Point
            if kPoint != .zero, preKPoint != .zero {
                KDJ_K_LinePath.move(to: preKPoint)
                KDJ_K_LinePath.addLine(to: kPoint)
            }
            
            let preDPoint = array[index - 1].kdj_D_Point
            let DPoint = array[index].kdj_D_Point
            if DPoint != .zero, preDPoint != .zero {
                KDJ_D_LinePath.move(to: preDPoint)
                KDJ_D_LinePath.addLine(to: DPoint)
            }
            
            let preJPoint = array[index - 1].kdj_J_Point
            let JPoint = array[index].kdj_J_Point
            if JPoint != .zero, preJPoint != .zero {
                KDJ_J_LinePath.move(to: preJPoint)
                KDJ_J_LinePath.addLine(to: JPoint)
            }
        }
        
        kdj_K_LineLayer.frame = bounds
        kdj_K_LineLayer.path = KDJ_K_LinePath.cgPath
        kdj_K_LineLayer.strokeColor = theme.bottomTextTwoColor.cgColor
        kdj_K_LineLayer.fillColor = UIColor.clear.cgColor
        
        kdj_D_LineLayer.frame = bounds
        kdj_D_LineLayer.path = KDJ_D_LinePath.cgPath
        kdj_D_LineLayer.strokeColor = theme.bottomTextThreeColor.cgColor
        kdj_D_LineLayer.fillColor = UIColor.clear.cgColor
        
        kdj_J_LineLayer.frame = bounds
        kdj_J_LineLayer.path = KDJ_J_LinePath.cgPath
        kdj_J_LineLayer.strokeColor = theme.bottomTextFourColor.cgColor
        kdj_J_LineLayer.fillColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(kdj_K_LineLayer)
        self.layer.addSublayer(kdj_D_LineLayer)
        self.layer.addSublayer(kdj_J_LineLayer)
    }
    
    // MARK: - MACD
    /// 画MACD柱状图
    func drawMACD_BAR_Layer(array: [XLKLineCoordModel]) {
        macd_barLayer.frame = bounds
        for object in array.enumerated() {
            let model = object.element
            let volLayer = drawLine(lineWidth: theme.macdBarWidth,
                                    startPoint: model.macdStartPoint,
                                    endPoint: model.macdEndPoint,
                                    strokeColor: model.macdBarColor,
                                    fillColor: model.macdBarColor)
            macd_barLayer.addSublayer(volLayer)
        }
        self.layer.addSublayer(macd_barLayer)
    }
    
    /// 画MACD线图
    func drawMACD_DIF_DEA_Layer(array: [XLKLineCoordModel]) {
        
        if array.count < 1 {
            return
        }
        
        let diffLinePath = UIBezierPath()
        let deaLinePath = UIBezierPath()
        
        for index in 1 ..< array.count {
            let preDiffPoint = array[index - 1].diffPoint
            let diffPoint = array[index].diffPoint
            if diffPoint != .zero, preDiffPoint != .zero {
                diffLinePath.move(to: preDiffPoint)
                diffLinePath.addLine(to: diffPoint)
            }
            
            let preDeaPoint = array[index - 1].deaPoint
            let DeaPoint = array[index].deaPoint
            if DeaPoint != .zero, preDeaPoint != .zero {
                deaLinePath.move(to: preDeaPoint)
                deaLinePath.addLine(to: DeaPoint)
            }
        }
        
        macd_diffLayer.frame = bounds
        macd_diffLayer.path = diffLinePath.cgPath
        macd_diffLayer.strokeColor = theme.bottomTextThreeColor.cgColor
        macd_diffLayer.fillColor = UIColor.clear.cgColor
        
        macd_deaLayer.frame = bounds
        macd_deaLayer.path = deaLinePath.cgPath
        macd_deaLayer.strokeColor = theme.bottomTextFourColor.cgColor
        macd_deaLayer.fillColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(macd_diffLayer)
        self.layer.addSublayer(macd_deaLayer)
    }
    
    // MARK: - RSI
    func drawRsiLayer(array: [XLKLineCoordModel]) {
        
        if array.count < 1 {
            return
        }
        
        let rsiLinePath = UIBezierPath()
        
        for index in 1 ..< array.count {
            let preRsiPoint = array[index - 1].rsiPoint
            let rsiPoint = array[index].rsiPoint
            if rsiPoint != .zero, preRsiPoint != .zero {
                rsiLinePath.move(to: preRsiPoint)
                rsiLinePath.addLine(to: rsiPoint)
            }
        }
        
        rsiLineLayer.frame = bounds
        rsiLineLayer.path = rsiLinePath.cgPath
        rsiLineLayer.strokeColor = theme.bottomTextTwoColor.cgColor
        rsiLineLayer.fillColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(rsiLineLayer)
    }
    
    // MARK: - 时间layer
    func drawxAxisTimeMarkLayer() {
        xAxisTimeMarkLayer.sublayers?.removeAll()
        for (index, position) in positionModels.enumerated() {
            let model = klineModels[index]
            if position.isDrawAxis {
                if dateType == .min {
                    xAxisTimeMarkLayer.addSublayer(drawXaxisTimeMark(xPosition: position.highPoint.x, dateString: model.time.xlChart.toTimeString("MM/dd HH:mm")))
                }else if dateType == .day {
                    xAxisTimeMarkLayer.addSublayer(drawXaxisTimeMark(xPosition: position.highPoint.x, dateString: model.time.xlChart.toTimeString("YY/MM/dd")))
                }
            }
        }
        self.layer.addSublayer(xAxisTimeMarkLayer)
    }

    // MARK: - 清除图层
    func clearLayer() {
        
        // 时间
        xAxisTimeMarkLayer.sublayers?.forEach{ $0.removeFromSuperlayer() }
        
        // 主图
        minLineChartLayer.removeFromSuperlayer()
        minLineFillColorLayer.removeFromSuperlayer()
        ma60LineLayer.removeFromSuperlayer()
        candleChartLayer.sublayers?.forEach{ $0.removeFromSuperlayer() }
        clearMainMaLayer()
        clearMainBollLayer()
        
        // 副图
        // VOL
        volumeLayer.sublayers?.forEach{ $0.removeFromSuperlayer() }
        volMa5LineLayer.removeFromSuperlayer()
        volMa10LineLayer.removeFromSuperlayer()
        
        // KDJ
        kdj_K_LineLayer.removeFromSuperlayer()
        kdj_D_LineLayer.removeFromSuperlayer()
        kdj_J_LineLayer.removeFromSuperlayer()
        
        // MACD
        macd_barLayer.sublayers?.forEach{ $0.removeFromSuperlayer() }
        macd_deaLayer.removeFromSuperlayer()
        macd_diffLayer.removeFromSuperlayer()
        
        // RSI
        rsiLineLayer.removeFromSuperlayer()
    }
    
    func clearMainMaLayer() {
        ma5LineLayer.removeFromSuperlayer()
        ma10LineLayer.removeFromSuperlayer()
        ma30LineLayer.removeFromSuperlayer()
    }
    
    func clearMainBollLayer() {
        midBollLineLayer.removeFromSuperlayer()
        upBollLineLayer.removeFromSuperlayer()
        lowBollLineLayer.removeFromSuperlayer()
    }
    
    // MARK: - 私有
    /// 获取单个蜡烛图的layer
    fileprivate func getCandleLayer(model: XLKLineCoordModel) -> XLCAShapeLayer {
        // K线
        let linePath = UIBezierPath(rect: model.candleRect)
        
        // 影线
        linePath.move(to: model.lowPoint)
        linePath.addLine(to: model.highPoint)
        
        let klayer = XLCAShapeLayer()
        klayer.path = linePath.cgPath
        klayer.strokeColor = model.candleFillColor.cgColor
        klayer.fillColor = model.candleFillColor.cgColor
        
        return klayer
    }
    
    /// 横坐标单个时间标签
    fileprivate func drawXaxisTimeMark(xPosition: CGFloat, dateString: String) -> XLCAShapeLayer {
        
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: xPosition, y: theme.topTextHeight))
        linePath.addLine(to: CGPoint(x: xPosition,  y: midTextTop))

        linePath.move(to: CGPoint(x: xPosition, y: bottomChartTop))
        linePath.addLine(to: CGPoint(x: xPosition, y: timeTextTop))
        
        let lineLayer = XLCAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.lineWidth = theme.frameWidth
        lineLayer.strokeColor = theme.lineBorderColor.cgColor
//        lineLayer.fillColor = UIColor.orange.cgColor
//        lineLayer.backgroundColor = theme.lineBorderColor.cgColor
        
        let textSize = theme.getTextSize(text: dateString)
        
        var labelX: CGFloat = 0
        var labelY: CGFloat = 0
        let maxX = frame.maxX - textSize.width
        labelX = xPosition - textSize.width / 2.0
        labelY = timeTextTop + 6
        if labelX > maxX {
            labelX = maxX
        } else if labelX < frame.minX {
            labelX = frame.minX
        }
        
        let timeLayer = drawTextLayer(frame: CGRect(x: labelX, y: labelY, width: textSize.width, height: textSize.height), text: dateString, foregroundColor: theme.textColor)
        
        let shaperLayer = XLCAShapeLayer()
        shaperLayer.addSublayer(lineLayer)
        shaperLayer.addSublayer(timeLayer)
        
        return shaperLayer
    }
    
}
