//
//  XLKLineScrollView.swift
//  behoo
//
//  Created by 夏磊 on 2018/8/23.
//  Copyright © 2018年 behoo. All rights reserved.
//

import UIKit

/// K线ScrollView 用于手势冲突类区分
open class XLKLineScrollView: UIScrollView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
