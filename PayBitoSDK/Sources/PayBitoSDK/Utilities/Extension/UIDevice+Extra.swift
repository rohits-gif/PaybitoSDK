//
//  UIDevice+Extra.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 19/05/26.
//
//
//

import Foundation
import UIKit

public enum Model {
    
    case simulator
    case iPod1
    case iPod2
    case iPod3
    case iPod4
    case iPod5
    case iPod6
    
    case iPhone4
    case iPhone4S
    case iPhone5
    case iPhone5C
    case iPhone5S
    case iPhoneSE
    case iPhone6
    case iPhone6Plus
    case iPhone6S
    case iPhone6SPlus
    
    case iPad2
    case iPad3
    case iPad4
    case iPadAir1
    case iPadAir2
    case iPadMini1
    case iPadMini2
    case iPadMini3
    case iPadMini4
    case iPadPro
    
    case AppleTV
    case Other
}

public extension UIDevice {
    
    public var modelName: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
            case "iPod5,1":                                 return .iPod5
            case "iPod7,1":                                 return .iPod6
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return .iPhone4
            case "iPhone4,1":                               return .iPhone4S
            case "iPhone5,1", "iPhone5,2":                  return .iPhone5
            case "iPhone5,3", "iPhone5,4":                  return .iPhone5C
            case "iPhone6,1", "iPhone6,2":                  return .iPhone5S
            case "iPhone7,2":                               return .iPhone6
            case "iPhone7,1":                               return .iPhone6Plus
            case "iPhone8,1":                               return .iPhone6S
            case "iPhone8,2":                               return .iPhone6SPlus
            case "iPhone8,4":                               return .iPhoneSE
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return .iPad2
            case "iPad3,1", "iPad3,2", "iPad3,3":           return .iPad3
            case "iPad3,4", "iPad3,5", "iPad3,6":           return .iPad4
            case "iPad4,1", "iPad4,2", "iPad4,3":           return .iPadAir1
            case "iPad5,3", "iPad5,4":                      return .iPadAir2
            case "iPad2,5", "iPad2,6", "iPad2,7":           return .iPadMini1
            case "iPad4,4", "iPad4,5", "iPad4,6":           return .iPadMini2
            case "iPad4,7", "iPad4,8", "iPad4,9":           return .iPadMini3
            case "iPad5,1", "iPad5,2":                      return .iPadMini4
            case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return .iPadPro
            case "AppleTV5,3":                              return .AppleTV
            case "i386", "x86_64":                          return .iPhone5S
            default:                                        return .Other
        }
    }
    
}
