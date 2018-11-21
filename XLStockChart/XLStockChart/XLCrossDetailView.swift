//
//  XLCrossDetailView.swift
//  XLStockChart
//
//  Created by 夏磊 on 2018/11/20.
//  Copyright © 2018 夏磊. All rights reserved.
//

import UIKit

/// 长按详情视图 可自定义
class XLCrossDetailView: UIView {
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.frame.size = CGSize(width: XLScreenW, height: 70)
        self.backgroundColor = UIColor.xlChart.color(rgba: "#1F2D3F")
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Method
    func bind(model: XLKLineModel, preClose: CGFloat) {
        // 时间
        oneLabArray[0].text = String.init(format: "%@: %@", KLINETIME, model.time.xlChart.toTimeString("MM/dd HH:mm"))
        
        // 成交量
        oneLabArray[1].text = String.init(format: "%@: %@", KLINEVOL, model.volumefrom.xlChart.kLineVolNumber())
        
        // 涨跌额
        let changePrice = calaRiseAndFallPrice(model: model, preClose: preClose)
        twoLabArray[0].text = String.init(format: "%@: %@", KLINERISEANDFALLVOL, changePrice == 0 ? "--" : changePrice.xlChart.percent())
        
        // 开盘
        twoLabArray[1].text = String.init(format: "%@: %@", KLINEOPEN, model.open.xlChart.kLinePriceNumber())
        
        // 最高
        twoLabArray[2].text = String.init(format: "%@: %@", KLINEHIGH, model.high.xlChart.kLinePriceNumber())
        
        // 涨跌幅
        let changeVol = calaRiseAndFallVol(model: model, preClose: preClose)
        threeLabArray[0].text = String.init(format: "%@: %@", KLINERISEANDFALLPERCENT, changeVol == 0 ? "--" : changeVol.xlChart.kLineVolNumber())
        
        /// 收盘
        threeLabArray[1].text = String.init(format: "%@: %@", KLINECLOSE, model.close.xlChart.kLinePriceNumber())
        
        // 最低
        threeLabArray[2].text =  String.init(format: "%@: %@", KLINELOW, model.low.xlChart.kLinePriceNumber())
    }
    
    
    func calaRiseAndFallVol(model: XLKLineModel, preClose: CGFloat) -> CGFloat {
        return model.close - preClose
    }
    
    func calaRiseAndFallPrice(model: XLKLineModel, preClose: CGFloat) -> CGFloat {
        if preClose == 0 {
            return 0
        }
        
        return (model.close - preClose) / preClose * 100
    }
    
    func setupViews() {
        let offset: CGFloat = 15
        var maxX: CGFloat = offset
        let topMargin: CGFloat = 10
        let space: CGFloat = 6
        let btnH: CGFloat = (self.bounds.size.height - 2*topMargin - space*2) / 3
        let margin: CGFloat = 0
        let btnW: CGFloat = (XLScreenW - offset*2 - margin*2) / 3
        
        for i in 0..<3 {
            maxX = offset
            
            let oneLab = UILabel()
            oneLab.adjustsFontSizeToFitWidth = true
            oneLab.frame = CGRect(x: maxX, y: topMargin + CGFloat(i) * (btnH+space), width: btnW, height: btnH)
            oneLab.textColor = UIColor.white
            oneLab.font = UIFont.systemFont(ofSize: 12)
            self.addSubview(oneLab)
            if i == 0 {
                oneLabArray.append(oneLab)
            }else if i == 1 {
                twoLabArray.append(oneLab)
            }else if i == 2 {
                threeLabArray.append(oneLab)
            }
            maxX = oneLab.frame.maxX
            
            
            let twoLab = UILabel()
            twoLab.adjustsFontSizeToFitWidth = true
            twoLab.frame = CGRect(x: maxX + margin + 10, y: topMargin + CGFloat(i) * (btnH+space), width: btnW, height: btnH)
            twoLab.textColor = UIColor.white
            twoLab.font = UIFont.systemFont(ofSize: 12)
            self.addSubview(twoLab)
            if i == 0 {
                oneLabArray.append(twoLab)
            }else if i == 1 {
                twoLabArray.append(twoLab)
            }else if i == 2 {
                threeLabArray.append(twoLab)
            }
            maxX = twoLab.frame.maxX
            
            
            if i == 1 || i == 2 {
                let threeLab = UILabel()
                threeLab.adjustsFontSizeToFitWidth = true
                threeLab.frame = CGRect(x: maxX + margin, y: topMargin + CGFloat(i) * (btnH+space), width: btnW, height: btnH)
                threeLab.textColor = UIColor.white
                threeLab.font = UIFont.systemFont(ofSize: 12)
                self.addSubview(threeLab)
                if i == 1 {
                    twoLabArray.append(threeLab)
                }else if i == 2 {
                    threeLabArray.append(threeLab)
                }
            }
        }
    }
  
    
    // MARK: - Lazy
    lazy var oneLineArray = [KLINETIME, KLINEVOL]
    lazy var twoLineArray = [KLINERISEANDFALLVOL, KLINEOPEN, KLINEHIGH]
    lazy var threeLineArray = [KLINERISEANDFALLPERCENT, KLINECLOSE, KLINELOW]
    lazy var oneLabArray = [UILabel]()
    lazy var twoLabArray = [UILabel]()
    lazy var threeLabArray = [UILabel]()
}
