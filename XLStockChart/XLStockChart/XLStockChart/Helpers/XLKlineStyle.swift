//
//  XLKlineStyle.swift
//  XLStockChart
//
//  Created by 夏磊 on 2018/8/22.
//  Copyright © 2018年 sum123. All rights reserved.
//

import UIKit

/// K线/分时类型
public enum XLKLineType: Int {
    case minLineType        = 0   // 分时类型
    case candleLineType     = 1   // 烛线类型
}

/// K线时间显示格式
public enum XLKLineDateType: Int {
    case min        = 0   // 分钟显示
    case day        = 1   // 日期显示
}

public let KLINEMA      = "均线"
public let KLINEBOLL    = "BOLL"
public let KLINEHIDE    = "隐藏"
public let KLINEVOL     = "成交量"
public let KLINEMACD    = "MACD"
public let KLINEKDJ     = "KDJ"
public let KLINERSI     = "RSI"
public let KLINETIME                   = "时   间"
public let KLINEOPEN                   = "开   盘"
public let KLINEHIGH                   = "最   高"
public let KLINELOW                    = "最   低"
public let KLINECLOSE                  = "收   盘"
public let KLINERISEANDFALLVOL         = "涨跌额"
public let KLINERISEANDFALLPERCENT     = "涨跌幅"

public class XLKLineStyle: NSObject {
    
    let topTextHeight: CGFloat = 14
    let midTextHeight: CGFloat = 14
    let bottomChartHeight: CGFloat = 54
    let timeTextHeight: CGFloat = 24
    
    let corssLineWidth: CGFloat = 0.47
    let highLowLineWidth: CGFloat = 0.47
    let frameWidth: CGFloat = 0.47
    var crossCircleWidth: CGFloat = 8
    
    var candleWidth: CGFloat = 5
    var candleGap: CGFloat = 2
    var candleMinHeight: CGFloat = 0.5
    var candleMaxWidth: CGFloat = 15
    var candleMinWidth: CGFloat = 2
    
    // 成交量最小高度
    var minVolHeight: CGFloat = 0.5
    
    // topChart 上下间距
    let topChartMinYGap: CGFloat = 8
    
    // bottomChart 间距
    let volumeGap: CGFloat = 3
    
    // timeLine 上下间距
    let timeLineMinGap: CGFloat = 10
    
    
    // macdBar的宽度
    let macdBarWidth: CGFloat = 1
    
    let topTextOneColor = UIColor.xlChart.color(rgba: "#EDBB3C")
    let topTextTwoColor = UIColor.xlChart.color(rgba: "#49ADFF")
    let topTextThreeColor = UIColor.xlChart.color(rgba: "#DC66ED")

    let bottomTextOneColor = UIColor.xlChart.color(rgba: "#FFFFFF")
    let bottomTextTwoColor = UIColor.xlChart.color(rgba: "#EDBB3C")
    let bottomTextThreeColor = UIColor.xlChart.color(rgba: "#49ADFF")
    let bottomTextFourColor = UIColor.xlChart.color(rgba: "#DC66ED")

    let lineBorderColor = UIColor(red:1, green:1, blue:1, alpha:0.1)
    let crossLineColor = UIColor(red:1, green:1, blue:1, alpha:0.6)
    let textColor = UIColor(red:1, green:1, blue:1, alpha:0.4)
    
    var riseColor: UIColor {
//        if let REB_GREEN = UserDefaults.standard.value(forKey: "REB_GREEN") as? NSNumber {
//            return REB_GREEN.isEqual(to: NSNumber.init(value: 0)) ? UIColor.xlChart.color(rgba: BHCOLORSTRING_CH_2) : UIColor.xlChart.color(rgba: BHCOLORSTRING_CH_1)
//        }
        return UIColor.xlChart.color(rgba: "#00C087") // 涨 默认green
    }
    
    var fallColor: UIColor {
//        if let REB_GREEN = UserDefaults.standard.value(forKey: "REB_GREEN") as? NSNumber {
//            return REB_GREEN.isEqual(to: NSNumber.init(value: 0)) ? UIColor.xlChart.color(rgba: BHCOLORSTRING_CH_1) : UIColor.xlChart.color(rgba: BHCOLORSTRING_CH_2)
//        }
        return UIColor.xlChart.color(rgba: "#FE6D39") // 跌 默认red
    }

    // 折线颜色
    let minLineColor = UIColor.xlChart.color(rgba: "#2CA0FF")
    let minLineMaColor = UIColor.xlChart.color(rgba: "#ffc004")
    let minLinefillColor = UIColor(red: 0, green: 122.0/255.0, blue: 1, alpha: 0.08)
    
    // Bar柱状图 上下间隙
    let barChartMinYGap: CGFloat = 13
    // Bar柱状图 左右两边间隙
    let barChartMinXGap: CGFloat = 4
    let barWidth: CGFloat = 25
    // Bar柱状图最小高度
    var minBarHeight: CGFloat = 1
    let barLineBorderColor = UIColor(red: 0, green: 71.0/255.0, blue: 148.0/255.0, alpha: 0.1)
    
    
    /// 十字线文字边框颜色
    let crossBorderColor =  UIColor(red: 1, green: 1, blue: 1, alpha: 0.6).cgColor
    
    /// 十字线文字背景颜色
    let crossBgColor = UIColor.xlChart.color(rgba: "#1F2D3F")
    
    let crossTextLayerHeight: CGFloat = 24
    
    let highLowBgColor = UIColor.clear

    let baseFont = UIFont.systemFont(ofSize: 10)
    
    func getTextSize(text: String) -> CGSize {
        
        let size = text.size(withAttributes: [NSAttributedString.Key.font: baseFont])
        let width = ceil(size.width) + 5
        let height = ceil(size.height)
        
        return CGSize(width: width, height: height)
    }
    
    func getCrossTextSize(text: String) -> CGSize {
        
        let size = text.size(withAttributes: [NSAttributedString.Key.font: baseFont])
        let width = ceil(size.width) + 12
        let height = ceil(size.height) + 12
        
        return CGSize(width: width, height: height)
    }
}
