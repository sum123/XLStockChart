//
//  XLStockChartNameSpace.swift
//  XLStockChart
//
//  Created by 夏磊 on 2018/8/22.
//  Copyright © 2018年 sum123. All rights reserved.
//


import Foundation

public protocol NameSpaceProtocol {
    associatedtype WrapperType
    var xlChart: WrapperType { get }
    static var xlChart: WrapperType.Type { get }
}

public extension NameSpaceProtocol {
    var xlChart: NameSpaceWrapper<Self> {
        return NameSpaceWrapper(value: self)
    }
    
    static var xlChart: NameSpaceWrapper<Self>.Type {
        return NameSpaceWrapper.self
    }
}

public struct NameSpaceWrapper<T> {
    public let wrappedValue: T
    public init(value: T) {
        self.wrappedValue = value
    }
}
