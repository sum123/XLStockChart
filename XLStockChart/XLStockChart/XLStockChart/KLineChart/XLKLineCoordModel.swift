//
//  XLKLineCoordModel.swift
//  XLStockChart
//
//  Created by 夏磊 on 2018/8/22.
//  Copyright © 2018年 sum123. All rights reserved.
//

import UIKit

/// K线坐标Model
public class XLKLineCoordModel: NSObject {
    
    var openPoint: CGPoint = .zero
    var closePoint: CGPoint = .zero
    var highPoint: CGPoint = .zero
    var lowPoint: CGPoint = .zero
    
    var ma5Point: CGPoint = .zero
    var ma10Point: CGPoint = .zero
    var ma30Point: CGPoint = .zero
    
    var ma60Point: CGPoint = .zero
    
    var midBollPoint: CGPoint = .zero
    var upBollPoint: CGPoint = .zero
    var lowBollPoint: CGPoint = .zero
    
    var minLinePoint: CGPoint = .zero
    var minLine60MaPoint: CGPoint = .zero
    
    var volumeStartPoint: CGPoint = .zero
    var volumeEndPoint: CGPoint = .zero
    
    var volMa5Point: CGPoint = .zero
    var volMa10Point: CGPoint = .zero
    
    var kdj_K_Point: CGPoint = .zero
    var kdj_D_Point: CGPoint = .zero
    var kdj_J_Point: CGPoint = .zero
    
    var macdStartPoint: CGPoint = .zero
    var macdEndPoint: CGPoint = .zero
    var diffPoint: CGPoint = .zero
    var deaPoint: CGPoint = .zero
    var macdBarColor: UIColor = UIColor.black
    
    var rsiPoint: CGPoint = .zero
    
    var candleFillColor: UIColor = UIColor.black
    var candleRect: CGRect = CGRect.zero
    
    var closeY: CGFloat = 0
    
    var isDrawAxis: Bool = false
}

