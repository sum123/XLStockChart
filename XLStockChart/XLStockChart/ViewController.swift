//
//  ViewController.swift
//  XLStockChart
//
//  Created by 夏磊 on 2018/11/16.
//  Copyright © 2018 夏磊. All rights reserved.
//

import UIKit

let iPhoneX: Bool = UIApplication.shared.statusBarFrame.size.height > 20
let XLStatusBarHeight: CGFloat = iPhoneX ? 44.0 : 20.0
let XLNavBarHeight: CGFloat = 44.0
let XLTopHeight: CGFloat = XLStatusBarHeight + XLNavBarHeight
let XLBottomHeight: CGFloat = iPhoneX ? 34.0 : 0.0
let XLScreenW: CGFloat = UIScreen.main.bounds.width
let XLScreenH: CGFloat = UIScreen.main.bounds.height

let KLINETIMEMinLine = "分时"
let KLINETIME5Min = "5分钟"
let KLINETIME15Min = "15分钟"
let KLINETIME1Hour = "1小时"
let KLINETIME1Day = "日K"
let KLINETIME1Week = "周K"

class ViewController: UIViewController {
    
    /// 日期显示类型 日K以内是MM/DD HH:mm  日K以外是YY/MM/DD
    var dateType: XLKLineDateType = .min
    
    /// K线类型 烛线图/分时图
    var lineType: XLKLineType = .candleLineType
    
    /// 主图显示 默认MA
    var mainString = KLINEMA
    
    /// 副图显示 默认VOL
    var secondString = KLINEVOL
    
    /// 十字线是否在动画
    var isCrossAnimation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(timeView)
        view.addSubview(kLineView)
        view.addSubview(indicatorView)
        view.addSubview(detailView)
        
        clickTimeBtn(timeBtnArray[2])
    }
    
    // MARK: - Action
    @objc func clickDetail() {
        self.kLineView.hideCross()
    }
    
    @objc func clickTimeBtn(_ sender: UIButton) {
        
        indicatorView.startAnimating()
        view.isUserInteractionEnabled = false
        
        for btn in timeBtnArray {
            btn.setTitleColor(UIColor.init(white: 1, alpha: 0.6), for: .normal)
        }
        sender.setTitleColor(UIColor.white, for: .normal)
        
        dateType = .min
        lineType = .candleLineType
        
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
                self.indicatorView.stopAnimating()
                self.view.isUserInteractionEnabled = true
                self.kLineView.configureView(data: dataArray, isNew: true, mainDrawString: self.mainString, secondDrawString: self.secondString, dateType: self.dateType, lineType: self.lineType)
            }
        }
    }
    
    // MARK: - Method
    func getModelArrayFromFile(_ fileName: String) -> [XLKLineModel] {
        let pathForResource = Bundle.main.path(forResource: fileName, ofType: "json")
        let json = try! String(contentsOfFile: pathForResource!, encoding: String.Encoding.utf8)
        let jsonData = json.data(using: String.Encoding.utf8)!
        
        let dict = try! JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! [String : Any]
        
        let klines = (dict["data"] as! [String : Any])["klines"] as! [[String : Any]]
        
        var tempArray = [XLKLineModel]()
        
        for klineDict in klines {
            let model = XLKLineModel()
            if let open = klineDict["open"] as? CGFloat {
                model.open = open
            }
            if let close = klineDict["close"] as? CGFloat {
                model.close = close
            }
            if let high = klineDict["high"] as? CGFloat {
                model.high = high
            }
            if let low = klineDict["low"] as? CGFloat {
                model.low = low
            }
            if let volumefrom = klineDict["volumefrom"] as? CGFloat {
                model.volumefrom = volumefrom
            }
            if let time = klineDict["time"] as? TimeInterval {
                model.time = time
            }
            if let inflow = klineDict["inflow"] as? CGFloat {
                model.inflow = inflow
            }
            if let outflow = klineDict["outflow"] as? CGFloat {
                model.outflow = outflow
            }
            if let boll_mb = klineDict["boll_mb"] as? CGFloat {
                model.boll_mb = boll_mb
            }
            if let boll_up = klineDict["boll_up"] as? CGFloat {
                model.boll_up = boll_up
            }
            if let boll_dn = klineDict["boll_dn"] as? CGFloat {
                model.boll_dn = boll_dn
            }
            if let ma5 = klineDict["ma5"] as? CGFloat {
                model.ma5 = ma5
            }
            if let ma10 = klineDict["ma10"] as? CGFloat {
                model.ma10 = ma10
            }
            if let ma30 = klineDict["ma30"] as? CGFloat {
                model.ma30 = ma30
            }
            if let ma60 = klineDict["ma30"] as? CGFloat {
                model.ma60 = ma60
            }
            if let macd_diff = klineDict["macd_diff"] as? CGFloat {
                model.macd_diff = macd_diff
            }
            if let macd_dea = klineDict["macd_dea"] as? CGFloat {
                model.macd_dea = macd_dea
            }
            if let macd_bar = klineDict["macd_bar"] as? CGFloat {
                model.macd_bar = macd_bar
            }
            if let boll_dn = klineDict["boll_dn"] as? CGFloat {
                model.boll_dn = boll_dn
            }
            if let kdj_k = klineDict["kdj_k"] as? CGFloat {
                model.kdj_k = kdj_k
            }
            if let kdj_d = klineDict["kdj_d"] as? CGFloat {
                model.kdj_d = kdj_d
            }
            if let kdj_j = klineDict["kdj_j"] as? CGFloat {
                model.kdj_j = kdj_j
            }
            if let rsi = klineDict["rsi"] as? CGFloat {
                model.rsi = rsi
            }
            tempArray.append(model)
        }
        return tempArray
    }
    
    func setupCrossDetailHide(hide: Bool) {
        if isCrossAnimation {
            return
        }
        
        isCrossAnimation = true
        if hide {
            UIView.animate(withDuration: 0.25, animations: {
                self.detailView.alpha = 0
            }) { (_) in
                self.isCrossAnimation = false
            }
        }else {
            UIView.animate(withDuration: 0.25, animations: {
                self.detailView.alpha = 1
            }) { (_) in
                self.isCrossAnimation = false
            }
        }
    }
    
    // MARK: - Lazy
    lazy var kLineView: XLKLineView = {
        let kLineView = XLKLineView(frame: CGRect(x: 0, y: self.timeView.frame.maxY, width: XLScreenW, height: 500))
        kLineView.backgroundColor = UIColor.xlChart.color(rgba: "#243245")
        kLineView.kLineViewDelegate = self
        return kLineView
    }()
    
    lazy var timeView: UIView = {
        let timeView = UIView.init(frame: CGRect(x: 0, y: XLStatusBarHeight + 70 - XLNavBarHeight, width: XLScreenW, height: XLNavBarHeight))
        timeView.backgroundColor = UIColor.xlChart.color(rgba: "#243245")
        
        let times = [KLINETIMEMinLine, KLINETIME5Min, KLINETIME15Min, KLINETIME1Hour, KLINETIME1Day, KLINETIME1Week]
        let btnW: CGFloat = XLScreenW / CGFloat(times.count)
        var idx: Int = 0
        
        for str in times {
            let btn = UIButton()
            btn.setTitle(str, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            btn.setTitleColor(UIColor.init(white: 1, alpha: 0.6), for: .normal)
            btn.frame = CGRect(x: CGFloat(idx) * btnW, y: 0, width: btnW, height: timeView.bounds.size.height)
            btn.addTarget(self, action: #selector(clickTimeBtn(_:)), for: .touchUpInside)
            btn.tag = idx
            timeView.addSubview(btn)
            self.timeBtnArray.append(btn)
            idx += 1
        }
        return timeView
    }()
    
    lazy var indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .white)
        indicatorView.center = CGPoint(x: self.kLineView.bounds.width*0.5, y: self.timeView.frame.maxY + (self.kLineView.bounds.height - 54 - 24)*0.5)
        return indicatorView
    }()
    
    lazy var detailView: XLCrossDetailView = {
        let detailView = XLCrossDetailView(frame: CGRect(x: 0, y: XLStatusBarHeight, width: XLScreenW, height: 70))
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickDetail))
        detailView.addGestureRecognizer(tap)
        detailView.alpha = 0
        return detailView
    }()
    
    lazy var timeBtnArray = [UIButton]()
}

extension ViewController: XLKLineViewProtocol {
    func XLKLineViewLoadMore() {
        print("加载更多....")
    }
    
    func XLKLineViewHideCrossDetail() {
        print("隐藏十字线")
        self.setupCrossDetailHide(hide: true)
    }
    
    func XLKLineViewLongPress(model: XLKLineModel, preClose: CGFloat) {
        print("长按显示")
        self.detailView.bind(model: model, preClose: preClose)
        self.setupCrossDetailHide(hide: false)
    }
}

