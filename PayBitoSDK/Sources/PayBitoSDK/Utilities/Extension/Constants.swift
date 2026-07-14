//
//  Constants.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 19/05/26.
//

//
//  AppDelegate.swift
//  Smartler
//
//  Created by Shatadru Datta on 16/04/19.
//  Copyright © 2019 Msrit. All rights reserved.
//


import Foundation
import UIKit

let SYSTEM_VERSION = UIDevice.current.systemVersion

let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height
let MAIN_WINDOW = UIApplication.shared.windows.first
let BROKERID = ""
let CAPTCHA_SECRET = "Rtz2IQzefccFwmiurXq)8IjzUm?v3o"

func IS_OF_4_INCH() -> Bool {
    switch UIDevice.current.modelName {
    case .iPhone5, .iPhone5S, .iPhone5C, .iPhoneSE:
        return true
    default:
        return false
    }
}

//MARK: Google Constants
struct GoogleConstants {
    static let client_id = "745537630536-r5vq6d3k7tsl9tqc2bnnt3g7cnno827d.apps.googleusercontent.com"
}
let paybitoOrigin = "9E5XLQU4+cJS8AbKqd5BbPIS+qu1Iv3Dk6ntcvKvDvtMpwbGTvJb4tAF7Uomk1fc"
//MARK: Linkedin Constants
struct LinkedInConstants {
    
    static let CLIENT_ID = "86n39gg96l3mq3"
    static let CLIENT_SECRET = "LaMhjR4SJckFyg1M"
    static let REDIRECT_URI = "https://trade.paybito.com/"
    static let SCOPE = "r_liteprofile%20r_emailaddress" //Get lite profile info and e-mail address
    
    static let AUTHURL = "https://www.linkedin.com/oauth/v2/authorization"
    static let TOKENURL = "https://www.linkedin.com/oauth/v2/accessToken"
}


func SET_OBJ_FOR_DATA(obj: Data, key: String) {
    UserDefaults.standard.set(obj, forKey: key)
}

func SET_OBJ_FOR_KEY(obj: String, key: String) {
    UserDefaults.standard.set(obj, forKey: key)
}

func OBJ_FOR_KEY(key: String) -> String? {
    if let value = UserDefaults.standard.object(forKey: key) as? String {
        return value
    }
    return ""
}


//MARK: Paybito SiteKey For reCapcha
let siteKey = "6LdfSlghAAAAANIC9W1e7t5IqkUiD8H5LalKRJYc"

//MARK: Paybito Site URL
let paybitoSiteURL = URL(string: "https://trade.paybito.com")!

//MARK: AppName
let appName = OBJ_FOR_KEY(key: "companyName") ?? ""

// MARK: BASEURL
let baseurlLive = "https://accounts.paybito.com/api/"//"https://accounts.paybito.com:8443/api/"//https://accounts.paybito.com/api/

//MARK: Paybito stream API

let streamBaseURL = "https://stream.paybito.com/StreamingApi/rest/"
//MARK: Paybito URL
let paybitoURL = OBJ_FOR_KEY(key: "paybitoURL")! //"https://www.paybito.com/"

let baseurlFutureLive = "https://futures-stream.paybito.com/fSocketStream/api/"

let optionStreamBaseURl = "https://options-socket.paybito.com/oSocketStream/api/"

//MARK: socketStreamBase
let socketStreamBASE = "https://stream.paybito.com/SocketStream/api/"
//MARK: NFT image load base url
let nft_ImgBaseURl = "https://paybito-nft-marketplace.s3.us-west-1.amazonaws.com/collections_data/"
let nft_serch_image_url = "https://paybito-nft-marketplace.s3.us-west-1.amazonaws.com/nfts_data/"
//MARK: SPOT socket
//MARK: chart
let chartSocketBaseURL = "https://stream.paybito.com/ChartStream/ws"

//MARK: order book
let orderBookSocketBaseURL = "https://stream.paybito.com/SocketStream/ws"

//MARK: Future Socket
//MARK: chart
let chartFutureSocketBaseURL = "https://futures-stream.paybito.com:5443/FutureChartStream/ws"

//MARK: order b0ok
let orderBookFutureSocketBaseURL = "https://futures-stream.paybito.com:6443/fSocketStream/ws"

//MARK: Option Socket
//MARK: chart
let chartOptionsSocketBaseURL = "https://options-socket.paybito.com/OptionChartStream/ws"

//MARK: order book
let orderBookOptionsSocketBaseURL = "https://options-socket.paybito.com/oSocketStream/ws"


// MARK: URL
let baseurlLiveWithoutPart = "https://api.paybito.com/api/"//"http://13.52.204.253:7080/api/"//"https://api.paybito.com:8443/"//"https://api.paybito.com/"

//MARK: imgLoad Base URL
let imgLoadBaseURL = "https://brokersexchange.s3.us-west-1.amazonaws.com/currency_logo/"

//MARK: Login
let login = "user/LoginWithUsernamePassword"

//MARK: ForgetPassword
let ForgetPassword = "user/SendOtp"

//MARK: ResetPassword
let ResetPassword = "user/ResetPassword"

//MARK: ResendOTP
let ResendOTP = "user/ResendOTP"

// MARK: loan
let Loan = "crypto/banking/loan/getLoanMarketDetails"

//MARK: CheckOTP
let CheckOTP = "user/CheckOTP"

//MARK: Email
let CheckEmail = "user/CheckEmail"

//MARK: Phone
let CheckPhone = "user/CheckPhone"

//MARK: AddUserDetails
let addUserDetails = "user/AddUserDetails"

//MARK: Buy
let BUY_SELL = "userTrade/TradeCreateOffer"

//MARK: StopLoss
let STOP_LOSS = "userTrade/StopLossBuySellTrade"

//MARK: future Stop-Loss
let futureStop_loss = "fTrade/StopLossBuySellTrade"

//MARK: option stop-loss
let optionStop_loss = "optionsTrade/StopLossBuySellTrade"
//MARK: Token
let OauthToken = "oauth/token"

//MARK: UserTransactionTrade
let UserTransactionBalance = "transaction/getUserBalance"

//MARK: UserAllTransaction
let UserAllTransaction = "transaction/getUserAllTransaction"

//MARK: ReceiveTransaction
let ReceiveBTC = "transaction/getCryptoAddress"//"userTransaction/ReceiveBTC"

//MARK: GetUserDetails
let GetUserDetails = "user/GetUserDetails"

//MARK: GetAdminBankDetails
let BankDetails = "user/GetAdminBankDetails"

//MARK: GetUserBankDetails
let UserBankDetails = "user/GetUserBankDetails"

//MARK: UpdateBankDetails
let UpdateBankDetails = "user/UpdateUserBankDetails"

//MARK: InvoiceList
let InvoiceList = "transaction/getInvoicesList"

//MARK: PaymentOrder
let PaymentOrder = "transaction/createPaymentOrder"

//MARK: FundWithdrawal
let FundWithdrawal = "transaction/createWithdrawalOrder"

//MARK: ChangePassword
let ChangePassword = "user/ChangePassword"

//MARK: Support
let Support = "user/SendMailToUser"

//MARK: UpdateDocs
let UpdateDocs = "user/updateUserDocsForMobile"

// MARK: Storyboard
let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
let p2p: UIStoryboard = UIStoryboard(name: "P2PVC", bundle: nil)
// MARK: BILBITCOINSTORYBOARD
let bStory: UIStoryboard = UIStoryboard(name: "BMain", bundle: nil)

// MARK: BILBITCOIN API URL
let bbaseurlLive = "https://service.hashcashconsultants.com/billbitcoins-v2/merchant/"
let bbaseurl = "https://service.hashcashconsultants.com/billbitcoins-v2/MerchantDashboard/"
let baseurlLivePaybito = "https://accounts.paybito.com/api/"
// MARK:- Font
let FONT_NAME = "Roboto-Regular"
let kTableViewBackgroundImage = "BackgroundImage"

func IS_IPAD() -> Bool {
    
    switch UIDevice.current.userInterfaceIdiom {
    case .phone: // It's an iPhone
        return false
    case .pad: // It's an iPad
        return true
    case .unspecified: // undefined
        return false
    default:
        return false
    }
}


var brokerID = "PAYB18022021121103"
//"brokerId"
//MARK:  let CountryList
let CountryList = "home/getExchangeCountries/\(OBJ_FOR_KEY(key: "brokerId") ?? "")"


func SET_INTEGER_FOR_KEY(integer: Int, key: String) {
    UserDefaults.standard.set(integer, forKey: key)
}

func INTEGER_FOR_KEY(key: String) -> Int? {
    return UserDefaults.standard.integer(forKey: key)
}

func SET_FLOAT_FOR_KEY(float: Float, key: String) {
    UserDefaults.standard.set(float, forKey: key)
}

func FLOAT_FOR_KEY(key: String) -> Float? {
    return UserDefaults.standard.float(forKey: key)
}

func SET_BOOL_FOR_KEY(bool: Bool, key: String) {
    UserDefaults.standard.set(bool, forKey: key)
}

func BOOL_FOR_KEY(key: String) -> Bool? {
    return UserDefaults.standard.bool(forKey: key)
}

func REMOVE_OBJ_FOR_KEY(key: String) {
    UserDefaults.standard.removeObject(forKey: key)
}

func UIColorRGB(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor? {
    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
}
func UIBorderColor() -> UIColor {
    return UIColor(red: 212.0 / 255.0, green: 212.0 / 255.0, blue: 212.0 / 255.0, alpha: 1.0)
}

func UIColorRGBA(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor? {
    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
}

func UIColorTabBarUnselected() -> UIColor? {
    return UIColor(red: 128.0 / 255.0, green: 127.0 / 255.0, blue: 123.0 / 255.0, alpha: 1.0)
}

func FIRST_WINDOW() -> AnyObject? {
    return UIApplication.shared.windows.first!
}

//@available(iOS 13.0, *)
//func APP_DELEGATE() -> AppDelegate? {
//    return UIApplication.shared.delegate as? AppDelegate
//}

func SWIFT_CLASS_STRING(className: String) -> String? {
    return "\(Bundle.main.infoDictionary!["CFBundleName"] as! String).\(className)";
}

func PRIMARY_FONT(size: CGFloat) -> UIFont? {
    return UIFont(name: FONT_NAME, size: size)
}

struct GlobalMethods {
    
    /// The method is used to store value in userdefaults
    ///
    /// - Parameters:
    ///   - key: The key name for defaults
    ///   - value: The value of the ket Passed
    static func storeInDefaults (key: String, value: String){
        
        UserDefaults.standard.set(value, forKey:key)
        UserDefaults.standard.synchronize()
    }
    
    /// The method is used ato retrieve value of the saved keys in Userdefaults and if not found it returns a blank string
    ///
    /// - Parameter keyName: The key saved in the defaults
    /// - Returns: The value is returned for the key
    static func getFromDefaultsFor(keyName: String) ->String{
        let returnValue:String! = UserDefaults.standard.object(forKey: keyName) != nil ? UserDefaults.standard.object(forKey: keyName) as? String : ""
        return returnValue
    }
    
    /// The method returns the comapny access token and comapny cid
    static var getCompanyCidAndCompanyAccesstoken = {(comapnyAccessToken: String) -> (accessToken: String, cid: String) in
        let base64UserStr = NSString(format: "%@%@", comapnyAccessToken,"==") as String
        let decodedData = NSData(base64Encoded: base64UserStr, options: NSData.Base64DecodingOptions.init(rawValue: 0))
        let decodedString = NSString(data: decodedData! as Data, encoding: String.Encoding.utf8.rawValue)
        let  base64String = decodedString?.components(separatedBy: "-")
        let  companyAccessToken = base64String?[1]
        let companyCid = base64String?[2]
        return (comapnyAccessToken,companyCid!)
    }
}



func commandFrom(dict:Dictionary<String,Any>) -> String
{
    let jsonData: Data? = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
    let error: Error? = nil
    
    if jsonData != nil && error == nil
    {
        var strTempCommand = ""
        if let aData = jsonData
        {
            strTempCommand = String(data: aData, encoding: .utf8)!
            return strTempCommand
        }
    }
    
    return ""
}

//var strIPGlobal : String
//{
//    return UserDefaults.getString(forKey: kIP)
//}
//
//var strPortGlobal : String
//{
//    return UserDefaults.getString(forKey: kPORT)
//}


struct Platform
{
    static var isSimulator: Bool
    {
        //return TARGET_OS_SIMULATOR != 0
        return false
    }
    
}

var strDeviceID : String
{
    if Platform.isSimulator
    {
        return "901D98FC-74E1-4862-860E-BD996B1CA31C"
    }
    else
    {
        return UIDevice.current.identifierForVendor!.uuidString
    }
}

func getSupportURL(from urlString: String) -> String? {
    guard let url = URL(string: urlString),
          var host = url.host else {
        return nil
    }

    // Split the domain components
    let hostComponents = host.components(separatedBy: ".")

    // Replace the first component (subdomain) with "support"
    if hostComponents.count >= 3 {
        // E.g. trade.paybito.com => support.paybito.com
        let newHost = ["support"] + hostComponents.dropFirst()
        host = newHost.joined(separator: ".")
    } else if hostComponents.count == 2 {
        // E.g. paybito.com => support.paybito.com
        host = "user-support@" + host
    }

    return "https://\(host)"
}



//func SECONDARY_FONT(size: CGFloat) -> UIFont? {
// return UIFont(name: "Roboto-Regular", size: size)!
//}

/*
 if #available(iOS 9.0, *)
 {
 //System version is more than 9.0
 }
 else
 {
 
 }
 */

//class requestHeader {
//    class func headerWithAuthToken() -> HTTPHeaders{
//        let headers = [
//            "Content-Type": "application/json",
//            "Authorization": "Bearer \(OBJ_FOR_KEY(key: "ACCESS_TOKEN") ?? "")",
//            "origin": "9E5XLQU4+cJS8AbKqd5BbPIS+qu1Iv3Dk6ntcvKvDvtMpwbGTvJb4tAF7Uomk1fc"
//                    ]
////        "origin": "9E5XLQU4+cJS8AbKqd5BbPIS+qu1Iv3Dk6ntcvKvDvtMpwbGTvJb4tAF7Uomk1fc"
//        return headers
//    }
//    class func headerWithoutAuthToken() -> HTTPHeaders{
//        let headers = [
//            "Content-Type": "application/json",
//            "origin": "9E5XLQU4+cJS8AbKqd5BbPIS+qu1Iv3Dk6ntcvKvDvtMpwbGTvJb4tAF7Uomk1fc"
//           // "Authorization": "Bearer \(OBJ_FOR_KEY(key: "ACCESS_TOKEN")!)"
//                    ]
//        return headers
//    }
//    class func headerWithAuthTokenForMultipart() -> HTTPHeaders{
//        let headers = [
//            "Content-Type": "multipart/form-data",
//            "authorization": "BEARER \(OBJ_FOR_KEY(key: "ACCESS_TOKEN") ?? "")",
//            "origin": "9E5XLQU4+cJS8AbKqd5BbPIS+qu1Iv3Dk6ntcvKvDvtMpwbGTvJb4tAF7Uomk1fc"
//           // "Authorization": "Bearer \(OBJ_FOR_KEY(key: "ACCESS_TOKEN")!)"
//                    ]
//        return headers
//    }
//}
