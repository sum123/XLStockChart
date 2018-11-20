//
//  Extension.swift
//  XLStockChart
//
//  Created by 夏磊 on 2018/8/22.
//  Copyright © 2018年 sum123. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UIColor Extension
extension UIColor: NameSpaceProtocol {}
extension NameSpaceWrapper where T: UIColor {
    
    public static func color(rgba: String) -> UIColor {
        var red: CGFloat   = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat  = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            var hexStr = (rgba as NSString).substring(from: 1) as NSString
            if hexStr.length == 8 {
                let alphaHexStr = hexStr.substring(from: 6)
                hexStr = hexStr.substring(to: 6) as NSString
                var alphaHexValue: UInt32 = 0
                let alphaScanner = Scanner(string: alphaHexStr)
                if alphaScanner.scanHexInt32(&alphaHexValue) {
                    let alphaHex = Int(alphaHexValue)
                    alpha = CGFloat(alphaHex & 0x000000FF) / 255.0
                } else {
                    print("scan alphaHex error")
                }
            }
            
            let rgbScanner = Scanner(string: hexStr as String)
            var hexValue: UInt32 = 0
            if rgbScanner.scanHexInt32(&hexValue) {
                if hexStr.length == 6 {
                    let hex = Int(hexValue)
                    red   = CGFloat((hex & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hex & 0x00FF00) >> 8)  / 255.0
                    blue  = CGFloat(hex & 0x0000FF) / 255.0
                } else {
                    print("invalid rgb string, length should be 6")
                }
            } else {
                print("scan hex error")
            }
            
        } else {
            print("invalid rgb string, missing '#' as prefix")
        }
        
        return UIColor(red:red, green:green, blue:blue, alpha:alpha)
    }
}


// MARK: - CGFloat Extension
extension CGFloat: NameSpaceProtocol {}
extension NameSpaceWrapper where T == CGFloat {
    
    /// 价格显示策略 >1 余2位，>0.01 余4位，>0.001 余6位，其余 余8位
    public func kLinePriceNumber() -> String {
        if wrappedValue == 0 {
            return "0"
        }else {
            let tempValue = abs(wrappedValue)
            if tempValue > 1 {
                return String.init(format: "%.2f", wrappedValue)
            }else if tempValue > 0.01 {
                return String.init(format: "%.4f", wrappedValue)
            }else if tempValue > 0.0001 {
                return String.init(format: "%.6f", wrappedValue)
            }else {
                return String.init(format: "%.8f", wrappedValue)
            }
        }
    }
    
    public func kLineVolNumber() -> String {
        if wrappedValue == 0 {
            return "未知"
        }else {
            let tempValue = abs(wrappedValue)
            if tempValue < 10000 {
                return String.init(format: "%.2f", wrappedValue)
            }else if tempValue < 1000000 {
                return String.init(format: "%.2f万", wrappedValue / 10000.0)
            }else if tempValue < 100000000 {
                return String.init(format: "%zd万", (Int)(wrappedValue / 10000.0))
            }else {
                return String.init(format: "%.2f亿", wrappedValue / 100000000.0)
            }
        }
    }
    
    public func percent() -> String {
        if wrappedValue > 0 {
            return String.init(format: "+%.2f%%", wrappedValue)
        } else {
            return String.init(format: "%.2f%%", wrappedValue)
        }
    }
}

// MARK: - DateFormatter Extension
private var cachedFormatters = [String: DateFormatter]()
extension DateFormatter: NameSpaceProtocol {}
extension NameSpaceWrapper where T: DateFormatter {
    
    public static func cached(withFormat format: String) -> DateFormatter {
        if let cachedFormatter = cachedFormatters[format] { return cachedFormatter }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        cachedFormatters[format] = formatter
        return formatter
    }
}


// MARK: - Date Extension
extension Date: NameSpaceProtocol {}
extension NameSpaceWrapper where T == Date {
    
    public func toString(_ format: String) -> String {
        let dateformatter = DateFormatter.xlChart.cached(withFormat: format)
        dateformatter.timeZone = TimeZone.autoupdatingCurrent
        
        return dateformatter.string(from: wrappedValue)
    }
    
    public static func toDate(_ dateString: String, format: String) -> Date {
        let dateformatter = DateFormatter.xlChart.cached(withFormat: format)
        dateformatter.locale = Locale(identifier: "en_US")
        let date = dateformatter.date(from: dateString) ?? Date()
        
        return date
    }
}


// MARK: - Double Extension
extension Double: NameSpaceProtocol {}
extension NameSpaceWrapper where T == Double {
    
    /// 时间戳转string
    public func toTimeString(_ format: String) -> String {
        let myDate = Date.init(timeIntervalSince1970: wrappedValue)
        let dateformatter = DateFormatter.xlChart.cached(withFormat: format)
        dateformatter.timeZone = TimeZone.autoupdatingCurrent
        return dateformatter.string(from: myDate)
    }
}






