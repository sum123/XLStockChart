//
//  XLKLineView.swift
//  XLStockChart
//
//  Created by 夏磊 on 2018/8/22.
//  Copyright © 2018年 sum123. All rights reserved.
//

import UIKit

@objc public protocol XLKLineViewProtocol: class {
    func XLKLineViewLoadMore()
    func XLKLineViewLongPress(model: XLKLineModel, preClose: CGFloat)
    func XLKLineViewHideCrossDetail()
}

open class XLKLineView: UIView, XLDrawLayerProtocol {
    
    @objc public weak var kLineViewDelegate: XLKLineViewProtocol? = nil
    public var theme = XLKLineStyle()
    public var allDataK: [XLKLineModel] = []
    
    var dataK: [XLKLineModel] = []
    var enableKVO: Bool = true
    var isLongPressEnd = false
    
    var kLineViewWidth: CGFloat = 0.0
    var preKLineRightOffset: CGFloat = 0
    
    var mainDrawString: String = KLINEMA
    var secondDrawString: String = KLINEVOL
    var dateType: XLKLineDateType = .min
    var lineType: XLKLineType = .candleLineType
    
    var scrollView: XLKLineScrollView!
    var kLine: XLKLine!

    var frameLayer: XLCAShapeLayer!
    var topChartTextLayer: XLTopChartTextLayer!
    var bottomChartTextLayer: XLBottomChartTextLayer!
    var midChartTextLayer: XLMidChartTextLayer!
    var crossLineLayer: XLCrossLineLayer!
    
    /// 上一次渲染的offsetX
    var preRenderOffsetX:CGFloat = 0
    
    // 上一次手指一动的x
    var preOneTouchX: CGFloat = 0
    var preTwoTouchX: CGFloat = 0
    
    // 上一次长按的index 用于震动反馈
    var preHighLightIndex: Int = 0
    
    @available(iOS 10.0, *)
    lazy var generator: UIImpactFeedbackGenerator = {
        let generator = UIImpactFeedbackGenerator.init(style: .light)
        return generator
    }()
    
    
    var topChartHeight: CGFloat {
        get {
            return frame.height - theme.topTextHeight - theme.midTextHeight - theme.bottomChartHeight - theme.timeTextHeight
        }
    }
    
    // 横向分隔线间距
    var topChartLineMargin: CGFloat {
        get {
            return self.topChartHeight / 4
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
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        drawFrameLayer()

        scrollView = XLKLineScrollView(frame: bounds)
        scrollView.backgroundColor = UIColor.clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false

        scrollView.delegate = self
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: nil)
        addSubview(scrollView)

        kLine = XLKLine(frame: bounds)
        scrollView.addSubview(kLine)

        topChartTextLayer = XLTopChartTextLayer()
        topChartTextLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: theme.topTextHeight)
        layer.addSublayer(topChartTextLayer)

        bottomChartTextLayer = XLBottomChartTextLayer()
        bottomChartTextLayer.frame = CGRect(x: 0, y: midTextTop, width: frame.width, height: theme.midTextHeight)
        layer.addSublayer(bottomChartTextLayer)

        midChartTextLayer = XLMidChartTextLayer()
        midChartTextLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height - theme.timeTextHeight - theme.bottomChartHeight)
        layer.addSublayer(midChartTextLayer)

        crossLineLayer = XLCrossLineLayer()
        crossLineLayer.frame = bounds
        layer.addSublayer(crossLineLayer)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureAction(_:)))
        kLine.addGestureRecognizer(longPressGesture)

        let pinGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinGestureAction(_:)))
        kLine.addGestureRecognizer(pinGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureAction(_:)))
        kLine.addGestureRecognizer(tapGesture)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let scrollView = scrollView {
            scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
        }
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(UIScrollView.contentOffset) && enableKVO {
//            print("in klineview scrollView?.contentOffset.x " + "\(scrollView.contentOffset.x)")
            
            // 当滚动间隙大于1个K线柱的时候 才刷新视图
            if abs(preRenderOffsetX - scrollView.contentOffset.x) < (theme.candleWidth+theme.candleGap), scrollView.contentSize.width > scrollView.bounds.size.width {
                return
            }
            // 拖动 ScrollView 时重绘当前显示的 klineview
            kLine.contentOffsetX = scrollView.contentOffset.x
            kLine.renderWidth = scrollView.frame.width
            kLine.drawKLineView(mainDrawString: mainDrawString, secondDrawString: secondDrawString, lineType: lineType)
            frameLayer.isHidden = false
            
            var sixNum: CGFloat = 0
            if secondDrawString == KLINEVOL {
                sixNum = kLine.maxVolume
            }else if secondDrawString == KLINEMACD {
                sixNum = kLine.maxMACD
            }else if secondDrawString == KLINEKDJ {
                sixNum = kLine.maxKDJ
            }else if secondDrawString == KLINERSI {
                sixNum = kLine.maxRSI
            }
            
            midChartTextLayer.configurePriceVolue(one: kLine.onePrice, two: kLine.twoPrice, three: kLine.threePrice, four: kLine.fourPrice, five: kLine.fivePrice, six: sixNum)
            preRenderOffsetX = scrollView.contentOffset.x
        }
    }
    
    /// 首次加载需要计算MA VOL的值
    func configureMidText() {
        
        // 主图
        var one: CGFloat = 0
        var two: CGFloat = 0
        var three: CGFloat = 0
        
        if self.mainDrawString == KLINEMA {
            if lineType == .minLineType {
                // 分时 用MA60
                one = dataK.last?.ma60 ?? 0
            }else {
                // K线 用MA5的数据
                one = dataK.last?.ma5 ?? 0
            }
            two = dataK.last?.ma10 ?? 0
            three =  dataK.last?.ma30 ?? 0
        }else if self.mainDrawString == KLINEBOLL {
            one = dataK.last?.boll_up ?? 0
            two = dataK.last?.boll_mb ?? 0
            three =  dataK.last?.boll_dn ?? 0
        }
        topChartTextLayer.configureTopValue(lineType: lineType, mainDrawString: mainDrawString, one: one, two: two, three: three)
        
        // 副图
        if self.secondDrawString == KLINEVOL {
            one = dataK.last?.volumefrom ?? 0
            two = calcVolMa(num: 5, targetIndex: dataK.count - 1, isMustHasNum: true, dataK: dataK) ?? 0
            three = calcVolMa(num: 10, targetIndex: dataK.count - 1, isMustHasNum: true, dataK: dataK) ?? 0
        }else if self.secondDrawString == KLINEMACD {
            one = dataK.last?.macd_bar ?? 0
            two = dataK.last?.macd_diff ?? 0
            three = dataK.last?.macd_dea ?? 0
        }else if self.secondDrawString == KLINEKDJ {
            one = dataK.last?.kdj_k ?? 0
            two = dataK.last?.kdj_d ?? 0
            three = dataK.last?.kdj_j ?? 0
        }else if self.secondDrawString == KLINERSI {
            one = dataK.last?.rsi ?? 0
        }
        bottomChartTextLayer.configureBottomValue(secondDrawString: secondDrawString, one: one, two: two, three: three)
    }
    
    /// 加载k线数据的方法 mainDrawString：主图绘制字符串，secondDrawString：副图绘制字符串，dateType：日期显示类型，lineType：K线显示类型
    public func configureView(data: [XLKLineModel], isNew: Bool, mainDrawString: String, secondDrawString: String, dateType: XLKLineDateType, lineType: XLKLineType) {
        
        hideCross()
        self.mainDrawString = mainDrawString
        self.secondDrawString = secondDrawString
        self.dateType = dateType
        self.lineType = lineType
        preRenderOffsetX = 0
        
        if isNew {
            self.dataK = data
        }else {
            self.dataK = data + self.dataK
        }
        self.kLine.dataK = self.dataK
        self.kLine.dateType = dateType
        self.kLine.lineType = lineType
        
        let count: CGFloat = CGFloat(dataK.count)

        // 总长度
        kLineViewWidth = count * theme.candleWidth + (count + 1) * theme.candleGap
        if kLineViewWidth < self.frame.width {
            kLineViewWidth = self.frame.width
        }

        // 更新view长度
//        print("currentWidth " + "\(kLineViewWidth)")
        kLine.frame = CGRect(x: 0, y: 0, width: kLineViewWidth, height: scrollView.frame.height)

        var contentOffsetX: CGFloat = 0

        if isNew {
            // 首次加载，将 kLine 的右边和scrollview的右边对齐
            contentOffsetX = kLine.frame.width - scrollView.frame.width
            
            // 首次加载需要计算MA VOL的值
            configureMidText()
            
        }else {
            if scrollView.contentSize.width > 0 {
                contentOffsetX = kLineViewWidth - preKLineRightOffset
            } else {
                // 首次加载，将 kLine 的右边和scrollview的右边对齐
                contentOffsetX = kLine.frame.width - scrollView.frame.width
                
                // 首次加载需要计算MA VOL的值
                configureMidText()
            }
        }
        
        scrollView.contentSize = CGSize(width: kLineViewWidth, height: self.frame.height)
        scrollView.contentOffset = CGPoint(x: contentOffsetX, y: 0)
        kLine.contentOffsetX = scrollView.contentOffset.x
        //        print("ScrollKLine contentOffsetX " + "\(contentOffsetX)")
    }
    
    func updateKlineViewWidth() {
        let count: CGFloat = CGFloat(kLine.dataK.count)
        // 总长度
        kLineViewWidth = count * theme.candleWidth + (count + 1) * theme.candleGap
        if kLineViewWidth < self.frame.width {
            kLineViewWidth = self.frame.width
        }
        
        // 更新view长度
//        print("currentWidth " + "\(kLineViewWidth)")
        kLine.frame = CGRect(x: 0, y: 0, width: kLineViewWidth, height: scrollView.frame.height)
        scrollView.contentSize = CGSize(width: kLineViewWidth, height: self.frame.height)
    }
    
    // 画边框
    func drawFrameLayer() {

        let linePath = UIBezierPath()

        // 横向分隔线
        linePath.move(to: CGPoint(x: -50, y: 0))
        linePath.addLine(to: CGPoint(x: frame.maxX + 50,  y: 0))
        
        linePath.move(to: CGPoint(x: 0, y: theme.topTextHeight))
        linePath.addLine(to: CGPoint(x: frame.width,  y: theme.topTextHeight))
        
        linePath.move(to: CGPoint(x: 0, y: midTextTop))
        linePath.addLine(to: CGPoint(x: frame.width,  y: midTextTop))
        
        linePath.move(to: CGPoint(x: 0, y: bottomChartTop))
        linePath.addLine(to: CGPoint(x: frame.width,  y: bottomChartTop))
        
        linePath.move(to: CGPoint(x: 0, y: bottomChartTop + theme.bottomChartHeight * 0.5))
        linePath.addLine(to: CGPoint(x: frame.width,  y: bottomChartTop + theme.bottomChartHeight * 0.5))
        
        linePath.move(to: CGPoint(x: -50, y: timeTextTop))
        linePath.addLine(to: CGPoint(x: frame.maxX + 50,  y: timeTextTop))
        
        linePath.move(to: CGPoint(x: -50, y: frame.height))
        linePath.addLine(to: CGPoint(x: frame.maxX + 50,  y: frame.height))

        // topChart分隔线
        linePath.move(to: CGPoint(x: 0, y: topChartLineMargin + topChartTop))
        linePath.addLine(to: CGPoint(x: frame.width,  y: topChartLineMargin + topChartTop))

        linePath.move(to: CGPoint(x: 0, y: topChartLineMargin * 2 + topChartTop))
        linePath.addLine(to: CGPoint(x: frame.width,  y: topChartLineMargin * 2 + topChartTop))

        linePath.move(to: CGPoint(x: 0, y: topChartLineMargin * 3 + topChartTop))
        linePath.addLine(to: CGPoint(x: frame.width,  y: topChartLineMargin * 3 + topChartTop))

        frameLayer = XLCAShapeLayer()
        frameLayer.path = linePath.cgPath
        frameLayer.lineWidth = theme.frameWidth
        frameLayer.strokeColor = theme.lineBorderColor.cgColor
        frameLayer.isHidden = true

        self.layer.addSublayer(frameLayer)
    }
    
    func beginShowCross(_ recognizer: UIGestureRecognizer) {
        let point = recognizer.location(in: kLine)
        var highLightIndex = Int(point.x / (theme.candleWidth + theme.candleGap))
        var positionModelIndex = highLightIndex - kLine.startIndex
        highLightIndex = highLightIndex <= 0 ? 0 : highLightIndex
        positionModelIndex = positionModelIndex <= 0 ? 0 : positionModelIndex
        
        if highLightIndex < kLine.dataK.count && positionModelIndex < kLine.positionModels.count {
            
            // 震动反馈
            if preHighLightIndex != highLightIndex {
                if #available(iOS 10.0, *) {
                    generator.prepare()
                    generator.impactOccurred()
                }
            }
            preHighLightIndex = highLightIndex
            
            let entity = kLine.dataK[highLightIndex]
            let left = kLine.startX + CGFloat(highLightIndex - kLine.startIndex) * (self.theme.candleWidth + theme.candleGap) - scrollView.contentOffset.x
            let centerX = left + theme.candleWidth / 2.0
            let highLightVolume = kLine.positionModels[positionModelIndex].volumeStartPoint.y
            let highLightClose = kLine.positionModels[positionModelIndex].closeY
            let preIndex = (highLightIndex - 1 >= 0) ? (highLightIndex - 1) : highLightIndex
            let preData = kLine.dataK[preIndex]
            
            // 顶部数据
            var one: CGFloat = 0
            var two: CGFloat = 0
            var three: CGFloat = 0
            
            if self.mainDrawString == KLINEMA {
                if lineType == .minLineType {
                    // 分时 用MA60
                    one = entity.ma60
                }else {
                    // K线 用MA5的数据
                    one = entity.ma5
                }
                two = entity.ma10
                three =  entity.ma30
            }else if self.mainDrawString == KLINEBOLL {
                one = entity.boll_up
                two = entity.boll_mb
                three =  entity.boll_dn
            }
            topChartTextLayer.configureTopValue(lineType: lineType, mainDrawString: mainDrawString, one: one, two: two, three: three)
            
            // 底部数据
            if self.secondDrawString == KLINEVOL {
                one = entity.volumefrom
                two = calcVolMa(num: 5, targetIndex: highLightIndex, isMustHasNum: true, dataK: dataK) ?? 0
                three = calcVolMa(num: 10, targetIndex: highLightIndex, isMustHasNum: true, dataK: dataK) ?? 0
            }else if self.secondDrawString == KLINEMACD {
                one = entity.macd_bar
                two = entity.macd_diff
                three = entity.macd_dea
            }else if self.secondDrawString == KLINEKDJ {
                one = entity.kdj_k
                two = entity.kdj_d
                three = entity.kdj_j
            }else if self.secondDrawString == KLINERSI {
                one = entity.rsi
            }
            bottomChartTextLayer.configureBottomValue(secondDrawString: secondDrawString, one: one, two: two, three: three)

            // 长按数据
            let touchY = point.y
            if touchY >= topChartTop && touchY <= midTextTop {
                // k线数据
                let currentPrice: CGFloat = kLine.mainMinPrice + (midTextTop - touchY - theme.topChartMinYGap) / kLine.priceUnit
                
                crossLineLayer.moveCrossLineLayer(touchNum: currentPrice, touchPoint: point, pricePoint: CGPoint(x: centerX, y: highLightClose), volumePoint: CGPoint(x: centerX, y: highLightVolume), model: entity, secondString: nil, dateType: dateType)
                
                if let kLineViewDelegate = self.kLineViewDelegate {
                    kLineViewDelegate.XLKLineViewLongPress(model: entity, preClose: preData.close)
                }
                
            }else if touchY > midTextTop && touchY < bottomChartTop {
                crossLineLayer.moveCrossLineLayer(touchNum: nil, touchPoint: point, pricePoint: CGPoint(x: centerX, y: highLightClose), volumePoint: CGPoint(x: centerX, y: highLightVolume), model: entity, secondString: nil, dateType: dateType)
                
            }else if touchY >= bottomChartTop && touchY <= timeTextTop {
                var currentNum: CGFloat = 0
                
                // 成交量数据
                if secondDrawString == KLINEVOL {
                    if touchY >= bottomChartTop + theme.volumeGap {
                        currentNum = kLine.minVolume + (timeTextTop - touchY) / kLine.bottomChartUnit
                        
                        if currentNum >= kLine.maxVolume {
                            currentNum = kLine.maxVolume
                        }
                        if currentNum <= kLine.minVolume {
                            currentNum = kLine.minVolume
                        }
                        crossLineLayer.moveCrossLineLayer(touchNum: currentNum, touchPoint: point, pricePoint: CGPoint(x: centerX, y: highLightClose), volumePoint: CGPoint(x: centerX, y: highLightVolume), model: entity, secondString: KLINEVOL, dateType: dateType)
                    }else {
                        // 超出最高不显示
                        crossLineLayer.moveCrossLineLayer(touchNum: nil, touchPoint: point, pricePoint: CGPoint(x: centerX, y: highLightClose), volumePoint: CGPoint(x: centerX, y: highLightVolume), model: entity, secondString: KLINEVOL, dateType: dateType)
                    }
                }else if secondDrawString == KLINEMACD {
                     // MACD
                    if touchY >= bottomChartTop + theme.volumeGap {
                        currentNum = kLine.minMACD + (timeTextTop - touchY - theme.volumeGap) / kLine.bottomChartUnit
                        
                        if currentNum >= kLine.maxMACD {
                            currentNum = kLine.maxMACD
                        }

                        crossLineLayer.moveCrossLineLayer(touchNum: currentNum, touchPoint: point, pricePoint: CGPoint(x: centerX, y: highLightClose), volumePoint: CGPoint(x: centerX, y: highLightVolume), model: entity, secondString: KLINEMACD, dateType: dateType)
                    }else {
                        // 超出最高不显示
                        crossLineLayer.moveCrossLineLayer(touchNum: nil, touchPoint: point, pricePoint: CGPoint(x: centerX, y: highLightClose), volumePoint: CGPoint(x: centerX, y: highLightVolume), model: entity, secondString: KLINEMACD, dateType: dateType)
                    }
                }else if secondDrawString == KLINEKDJ {
                    // DKJ
                    if touchY >= bottomChartTop + theme.volumeGap {
                        currentNum = kLine.minKDJ + (timeTextTop - touchY - theme.volumeGap) / kLine.bottomChartUnit
                        
                        if currentNum >= kLine.maxKDJ {
                            currentNum = kLine.maxKDJ
                        }

                        crossLineLayer.moveCrossLineLayer(touchNum: currentNum, touchPoint: point, pricePoint: CGPoint(x: centerX, y: highLightClose), volumePoint: CGPoint(x: centerX, y: highLightVolume), model: entity, secondString: KLINEKDJ, dateType: dateType)
                    }else {
                        // 超出最高不显示
                        crossLineLayer.moveCrossLineLayer(touchNum: nil, touchPoint: point, pricePoint: CGPoint(x: centerX, y: highLightClose), volumePoint: CGPoint(x: centerX, y: highLightVolume), model: entity, secondString: KLINEKDJ, dateType: dateType)
                    }
                }else if secondDrawString == KLINERSI {
                    // RSI
                    if touchY >= bottomChartTop + theme.volumeGap {
                        currentNum = kLine.minRSI + (timeTextTop - touchY - theme.volumeGap) / kLine.bottomChartUnit
                        
                        if currentNum >= kLine.maxRSI {
                            currentNum = kLine.maxRSI
                        }

                        crossLineLayer.moveCrossLineLayer(touchNum: currentNum, touchPoint: point, pricePoint: CGPoint(x: centerX, y: highLightClose), volumePoint: CGPoint(x: centerX, y: highLightVolume), model: entity, secondString: KLINERSI, dateType: dateType)
                    }else {
                        // 超出最高不显示
                        crossLineLayer.moveCrossLineLayer(touchNum: nil, touchPoint: point, pricePoint: CGPoint(x: centerX, y: highLightClose), volumePoint: CGPoint(x: centerX, y: highLightVolume), model: entity, secondString: KLINEKDJ, dateType: dateType)
                    }
                }
                
                if let kLineViewDelegate = self.kLineViewDelegate {
                    kLineViewDelegate.XLKLineViewLongPress(model: entity, preClose: preData.close)
                }
            }
        }
    }
    
    /// 处理点击事件
    @objc func handleTapGestureAction(_ recognizer: UITapGestureRecognizer) {
        if isLongPressEnd {
            hideCross()
        }else {
           beginShowCross(recognizer)
        }
    }
    
    // 长按操作
    @objc func handleLongPressGestureAction(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            beginShowCross(recognizer)
        }
        
        if recognizer.state == .ended {
            isLongPressEnd = true
        }
    }

     @objc open func hideCross() {
        crossLineLayer.isHidden = true
        if let kLineViewDelegate = self.kLineViewDelegate {
            kLineViewDelegate.XLKLineViewHideCrossDetail()
        }
        isLongPressEnd = false
    }
    
    // 捏合缩放扩大操作
    @objc func handlePinGestureAction(_ recognizer: UIPinchGestureRecognizer) {
        
        guard recognizer.numberOfTouches == 2 else { return }

        switch recognizer.state {
        case .began:
            enableKVO = false
            scrollView.isScrollEnabled = false
        default:
            enableKVO = true
            scrollView.isScrollEnabled = true
        }
        
        let scale = recognizer.scale
        let originScale: CGFloat = 1.0
        let kLineScaleFactor: CGFloat = 0.1
        let kLineScaleBound: CGFloat = 0.03
        let diffScale = scale - originScale // 获取缩放倍数

        if abs(diffScale) > kLineScaleBound {
            let point1 = recognizer.location(ofTouch: 0, in: self)
            let point2 = recognizer.location(ofTouch: 1, in: self)

            if abs(point1.x - preOneTouchX) < 5, abs(point2.x - preTwoTouchX) < 5 {
                return
            }
            preOneTouchX = point1.x
            preTwoTouchX = point2.x

            let pinCenterX = (point1.x + point2.x) / 2
            let scrollViewPinCenterX = pinCenterX + scrollView.contentOffset.x

            // 中心点数据index
            let pinCenterLeftCount = scrollViewPinCenterX / (theme.candleWidth + theme.candleGap)

            // 缩放后的candle宽度
            let newCandleWidth = theme.candleWidth * (recognizer.velocity > 0 ? (1 + kLineScaleFactor) :  (1 - kLineScaleFactor))

            if newCandleWidth > theme.candleMaxWidth {
                self.theme.candleWidth = theme.candleMaxWidth
                kLine.theme.candleWidth = theme.candleMaxWidth

            } else if newCandleWidth < theme.candleMinWidth {
                self.theme.candleWidth = theme.candleMinWidth
                kLine.theme.candleWidth = theme.candleMinWidth

            } else {
                self.theme.candleWidth = newCandleWidth
                kLine.theme.candleWidth = newCandleWidth
            }

            // 更新容纳的总长度
            self.updateKlineViewWidth()

            let newPinCenterX = pinCenterLeftCount * theme.candleWidth + (pinCenterLeftCount - 1) * theme.candleGap
            let newOffsetX = newPinCenterX - pinCenterX
            self.scrollView.contentOffset = CGPoint(x: newOffsetX > 0 ? newOffsetX : 0 , y: self.scrollView.contentOffset.y)

            kLine.contentOffsetX = scrollView.contentOffset.x
            kLine.drawKLineView(mainDrawString: mainDrawString, secondDrawString: secondDrawString, lineType: lineType)
        }
        
    }
}

extension XLKLineView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideCross()
        // 用于滑动加载更多 KLine 数据
        if (scrollView.contentOffset.x == 0) {
            preKLineRightOffset = kLineViewWidth + theme.candleWidth
            if let kLineViewDelegate = self.kLineViewDelegate {
                kLineViewDelegate.XLKLineViewLoadMore()
            }
        }
    }
}






