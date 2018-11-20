# XLStockChart
K线图(烛线图，分时图，MA、VOL、MACD、KDJ、RSI)  捏合手势 加载更多等等

![iOS 9.0+](https://img.shields.io/badge/iOS-9.0%2B-blue.svg)
![Swift 4.0+](https://img.shields.io/badge/Swift-4.0%2B-orange.svg)
![MIT](https://img.shields.io/github/license/mashape/apistatus.svg)

XLStockChart是一个用于区块链币价或股票行情显示的库。

## Example
		// 日期显示类型 日K以内是MM/DD HH:mm  日K以外是YY/MM/DD
        dateType = .min
        
        // K线类型 烛线图/分时图
        lineType = .candleLineType
        
        // 主图显示 默认MA
        var mainString = KLINEMA
        
        // 副图显示 默认VOL
        var secondString = KLINEVOL
        
        var dataArray = [XLKLineModel]()
        
        switch sender.currentTitle {
        case KLINETIMEMinLine:
            // 分时
            dataArray = getModelArrayFromFile("minLineData")
            lineType = .minLineType
        case KLINETIME5Min:
            // 5分钟
            dataArray = getModelArrayFromFile("5MinData")
        case KLINETIME15Min:
            // 15分钟
            dataArray = getModelArrayFromFile("15MinData")
        case KLINETIME1Hour:
            // 1小时
            dataArray = getModelArrayFromFile("1HourData")
        case KLINETIME1Day:
            // 日K
            dataArray = getModelArrayFromFile("1dayData")
            dateType = .day
        case KLINETIME1Week:
            // 周K
            dataArray = getModelArrayFromFile("1WeekData")
            dateType = .day
        default:
            break
        }
        
        if dataArray.count > 0 {
            // 模拟网络请求
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.kLineView.configureView(data: dataArray, isNew: true, mainDrawString: mainString, secondDrawString: secondString, dateType: dateType, lineType: lineType)
            }
        }
        
    
## Features
1. 支持`分时图`、`烛线图`、`MA`、`VOL`、`MACD`、`KDJ`、`RSI`、`最高&最低`等数据展示。
2. 支持横屏查看。
3. 手势捏合、长按展示详情、加载更多数据等。
4. K线图利用 `UIScrollView` 达到流畅的滑动查看效果, 减少重绘渲染次数。
5. 使用 `CAShapeLayer` 绘图，内存占用更小，效率更高。

## Requirements

- iOS 9.0+
- Swift 4