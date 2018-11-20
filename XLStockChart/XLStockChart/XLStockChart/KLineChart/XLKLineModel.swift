//
//  XLKLineModel.swift
//  XLStockChart
//
//  Created by 夏磊 on 2018/8/22.
//  Copyright © 2018年 sum123. All rights reserved.
//

import UIKit

/// K线数据Model
public class XLKLineModel: NSObject {
    
    /// 开盘
    public var open: CGFloat = 0
    
    /// 收盘
    public var close: CGFloat = 0
    
    /// 最高
    public var high: CGFloat = 0
    
    /// 最低
    public var low: CGFloat = 0
    
    /// 成交量
    public var volumefrom: CGFloat = 0
    
    /// 成交额
    public var volumeto: CGFloat = 0
    
    /// 时间
    public var time: TimeInterval = 0
    
    /// 流入
    public var inflow: CGFloat = 0
    
    /// 流出
    public var outflow: CGFloat = 0
    
    /// boll中线
    public var boll_mb: CGFloat = 0
    
    /// boll上线
    public var boll_up: CGFloat = 0
    
    /// boll下线
    public var boll_dn: CGFloat = 0
    
    /// ma5值
    public var ma5: CGFloat = 0
    
    /// ma10值
    public var ma10: CGFloat = 0
    
    /// ma30值
    public var ma30: CGFloat = 0
    
    /// ma60值
    public var ma60: CGFloat = 0
    
    /// volMa5值
    public var volMa5: CGFloat = 0
    
    /// volMa10值
    public var volMa10: CGFloat = 0
    
    /// macd diff线
    public var macd_diff: CGFloat = 0
    
    /// macd dea线
    public var macd_dea: CGFloat = 0
    
    /// macd 柱状图
    public var macd_bar: CGFloat = 0
    
    /// kdj k线
    public var kdj_k: CGFloat = 0
    
    /// kdj d线
    public var kdj_d: CGFloat = 0
    
    /// kdj j线
    public var kdj_j: CGFloat = 0
    
    /// rsi
    public var rsi: CGFloat = 0
}







