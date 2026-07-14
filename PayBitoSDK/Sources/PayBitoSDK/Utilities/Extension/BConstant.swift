//
//  BConstant.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 19/05/26.
//

import Foundation


class BConstant {
    
    public static var shared = BConstant()
    
    let baseurlLive = "https://service.hashcashconsultants.com/billbitcoins-v2/merchant/"
    let baseurl = "https://service.hashcashconsultants.com/billbitcoins-v2/MerchantDashboard/"
    
    
    var appTitle : String = OBJ_FOR_KEY(key: "companyName") ?? ""
    
    
    var appImage : String =  OBJ_FOR_KEY(key: "loader_icon") ?? ""
    
 
    
 
    
    
}
