//////
//////  WalletAPIService.swift
//////  Trading_Terminal
//////
//////  Created by Sk Jasimuddin on 30/04/26.
//////
////
////////
//////  WalletAPIService.swift
//////  Trading_Terminal
//////
////import Foundation
////import Alamofire
////
////// MARK: - Endpoints
////
////private enum WalletEndpoint {
////    static let base = "https://service.hashcashconsultants.com/billbitcoins-v2"
////
////    static let walletAssets =
////
////    "\(base)/MerchantDashboard/FetchUsdBtcLedgerAmount"
////
////    static let userTransactions =
////    "\(base)/merchant/getUserTransaction"
////
////    static let ledgerBalance =
////
////    "\(base)/MerchantDashboard/FetchUsdBtcLedgerAmount"
////
////    static let withdrawExternal =
////
////    "\(base)/wallet/withdrawToExternalWallet"
////
////    static let withdrawPaybito =
////
////    "\(base)/wallet/transferToPaybito"
////
////    static let withdrawBank =
////
////    "\(base)/wallet/withdrawToBank"
////
////
////}
////
////// MARK: - API Service
////
////final class WalletAPIService {
////
////    static let shared = WalletAPIService()
////    private init() {}
////
////    // MARK: - Headers
////
////    private func headers(token: String, uuid: String) -> HTTPHeaders {
////
////        let secureToken =
////        UserDefaults.standard.string(forKey: "Bsecure_token") ?? ""
////
////        print("========== HEADER DEBUG ==========")
////        print("ACCESS TOKEN => \(token)")
////        print("SECURE TOKEN => \(secureToken)")
////        print("UUID => \(uuid)")
////        print("==================================")
////
////        return [
////
////            "Authorization": "bearer \(token)",
////
////            "UUID": uuid,
////
////            "Content-Type": "application/json",
////
////            "Accept": "application/json, text/plain, */*",
////
////            "origin": "9E5XLQU4+cJS8AbKqd5BbPIS+qu1Iv3Dk6ntcvKvDvtMpwbGTvJb4tAF7Uomk1fc",
////
////            "Referer": "https://trade.paybito.com/",
////
////        ]
////    }
////
////    // MARK: - JSON Decode Helper
////
////    private func decode<T: Decodable>(_ value: Any, to type: T.Type) throws -> T {
////        let data = try JSONSerialization.data(withJSONObject: value)
////        return try JSONDecoder().decode(T.self, from: data)
////    }
////
////    // MARK: - Fetch Wallet Assets
////    // MARK: - Fetch Wallet Assets
////
////    func fetchWalletAssets(
////        merchantId: Int,
////        token: String,
////        uuid: String,
////        completion: @escaping (Swift.Result<[WalletAsset], Error>) -> Void
////    ) {
////
////        let params: Parameters = [
////            "merchant_id": merchantId
////        ]
////
////        Alamofire.request(
////            WalletEndpoint.walletAssets,
////            method: .post,
////            parameters: params,
////            encoding: JSONEncoding.default,
////            headers: headers(token: token, uuid: uuid)
////        )
////        .responseJSON { response in
////
////            print("=========== FETCH WALLET ASSETS API ===========")
////
////            print("STATUS CODE => \(response.response?.statusCode ?? 0)")
////
////            if let data = response.data,
////               let raw = String(data: data, encoding: .utf8) {
////
////                print("RAW API RESPONSE =>")
////                print(raw)
////            }
////
////            print("================================================")
////
////            switch response.result {
////
////            case .success(let value):
////
////                do {
////
////                    // Convert Any -> Data
////                    let jsonData = try JSONSerialization.data(withJSONObject: value)
////
////                    // Decode ROOT ARRAY
////                    let decoded = try JSONDecoder()
////                        .decode([WalletAssetsResponse].self, from: jsonData)
////
////                    // Extract actual wallet list
////                    let assets = decoded.first?.coinBalance ?? []
////
////                    print("=========== DECODE SUCCESS ===========")
////                    print("TOTAL ASSETS => \(assets.count)")
////                    print("======================================")
////
////                    completion(.success(assets))
////
////                } catch {
////
////                    print("=========== DECODE ERROR ===========")
////                    print(error)
////                    print("====================================")
////
////                    completion(.failure(error))
////                }
////
////            case .failure(let error):
////
////                print("=========== REQUEST FAILURE ===========")
////                print(error)
////                print("=======================================")
////
////                completion(.failure(error))
////            }
////        }
////    }
////
////    // MARK: - Fetch Transactions
////
////    func fetchUserTransactions(
////        merchantId: Int,
////        page: Int,
////        pageSize: Int,
////        token: String,
////        uuid: String,
////        completion: @escaping (Swift.Result<UserTransactionsWResponse, Error>) -> Void
////    ) {
////
////        let params: Parameters = [
////            "userId": "\(merchantId)",
////            "pageNo": "\(page)",
////            "noOfItemsPerPage": "\(pageSize)"
////        ]
////
////        Alamofire.request(
////            WalletEndpoint.userTransactions,
////            method: .post,
////            parameters: params,
////            encoding: JSONEncoding.default,
////            headers: headers(token: token, uuid: uuid)
////        )
////        .responseJSON { response in
////
////            print("=========== USER TRANSACTIONS API ===========")
////
////            print("STATUS CODE => \(response.response?.statusCode ?? 0)")
////
////            print("REQUEST URL =>")
////            print(response.request?.url?.absoluteString ?? "nil")
////
////            print("REQUEST HEADERS =>")
////            print(response.request?.allHTTPHeaderFields ?? [:])
////
////            if let body = response.request?.httpBody,
////               let bodyString = String(data: body, encoding: .utf8) {
////
////                print("REQUEST BODY =>")
////                print(bodyString)
////            }
////
////            if let data = response.data,
////               let raw = String(data: data, encoding: .utf8) {
////
////                print("RAW API RESPONSE =>")
////                print(raw)
////            }
////
////            print("================================================")
////
////            guard response.response?.statusCode == 200 else {
////
////                print("TRANSACTION API FAILED")
////
////                let error = NSError(
////                    domain: "TransactionAPI",
////                    code: response.response?.statusCode ?? 0,
////                    userInfo: [
////                        NSLocalizedDescriptionKey:
////                        "Transaction API failed"
////                    ]
////                )
////
////                completion(.failure(error))
////
////                return
////            }
////
////            switch response.result {
////
////            case .success(let value):
////
////                do {
////
////                    let arr = try self.decode(
////                        value,
////                        to: [UserTransactionsWResponse].self
////                    )
////
////                    guard let res = arr.first else {
////                        throw NSError(domain: "EmptyResponse", code: -1)
////                    }
////
////                    print("=========== DECODE SUCCESS ===========")
////
////                    print("TOTAL TRANSACTIONS => \(res.trxnList?.count ?? 0)")
////
////                    print("======================================")
////
////                    completion(.success(res))
////
////                } catch {
////
////                    print("=========== DECODE ERROR ===========")
////                    print(error)
////                    print("====================================")
////
////                    completion(.failure(error))
////                }
////
////            case .failure(let error):
////
////                print("=========== REQUEST FAILURE ===========")
////                print(error)
////                print("=======================================")
////
////                completion(.failure(error))
////            }
////        }
////    }
////
////    // MARK: - Fetch Ledger
////
////    func fetchLedgerBalance(
////        merchantId: Int,
////        token: String,
////        uuid: String,
////        completion: @escaping (Swift.Result<LedgerData, Error>) -> Void
////    ) {
////        let params: Parameters = ["merchant_id": merchantId]
////
////        Alamofire.request(
////            WalletEndpoint.ledgerBalance,
////            method: .post,
////            parameters: params,
////            encoding: JSONEncoding.default,
////            headers: headers(token: token, uuid: uuid)
////        )
////        .responseJSON { response in
////
////            switch response.result {
////
////            case .success(let value):
////                do {
////                    let res: LedgerBalanceResponse = try self.decode(value, to: LedgerBalanceResponse.self)
////
////                    if let data = res.data {
////                        completion(Swift.Result.success(data))
////                    } else {
////                        completion(Swift.Result.failure(NSError(domain: "NoData", code: -1)))
////                    }
////
////                } catch {
////                    completion(Swift.Result.failure(error))
////                }
////
////            case .failure(let error):
////                completion(Swift.Result.failure(error))
////            }
////        }
////    }
////
////    // MARK: - Withdraw APIs (Shared Logic)
////
////    private func withdrawRequest<T: Encodable>(
////        url: String,
////        request: T,
////        token: String,
////        uuid: String,
////        completion: @escaping (Swift.Result<GenericWalletResponse, Error>) -> Void
////    ) {
////        guard let params = request.asDictionary() else {
////            completion(Swift.Result.failure(NSError(domain: "EncodingError", code: -1)))
////            return
////        }
////
////        Alamofire.request(
////            url,
////            method: .post,
////            parameters: params,
////            encoding: JSONEncoding.default,
////            headers: headers(token: token, uuid: uuid)
////        )
////        .responseJSON { response in
////
////            switch response.result {
////
////            case .success(let value):
////                do {
////                    let res: GenericWalletResponse = try self.decode(value, to: GenericWalletResponse.self)
////                    completion(Swift.Result.success(res))
////                } catch {
////                    completion(Swift.Result.failure(error))
////                }
////
////            case .failure(let error):
////                completion(Swift.Result.failure(error))
////            }
////        }
////    }
////
////    // MARK: - Withdraw Types
////
////    func withdrawToExternalWallet(
////        request: ExternalWithdrawRequest,
////        token: String,
////        uuid: String,
////        completion: @escaping (Swift.Result<GenericWalletResponse, Error>) -> Void
////    ) {
////        withdrawRequest(
////            url: WalletEndpoint.withdrawExternal,
////            request: request,
////            token: token,
////            uuid: uuid,
////            completion: completion
////        )
////    }
////
////    func transferToPaybitoWallet(
////        request: PayBitoTransferRequest,
////        token: String,
////        uuid: String,
////        completion: @escaping (Swift.Result<GenericWalletResponse, Error>) -> Void
////    ) {
////        withdrawRequest(
////            url: WalletEndpoint.withdrawPaybito,
////            request: request,
////            token: token,
////            uuid: uuid,
////            completion: completion
////        )
////    }
////
////    func withdrawToBankAccount(
////        request: BankWithdrawRequest,
////        token: String,
////        uuid: String,
////        completion: @escaping (Swift.Result<GenericWalletResponse, Error>) -> Void
////    ) {
////        withdrawRequest(
////            url: WalletEndpoint.withdrawBank,
////            request: request,
////            token: token,
////            uuid: uuid,
////            completion: completion
////        )
////    }
////}
////
//
//
//
//
//
//
//
//
////
////  WalletAPIService.swift
////  Trading_Terminal
////
//
////
////  WalletAPIService.swift
////  Trading_Terminal
////
//
//import Foundation
//import Alamofire
//
//// MARK: - Endpoints
//
//private enum WalletEndpoint {
//    static let base = "https://service.hashcashconsultants.com/billbitcoins-v2"
//
//    static let walletAssets      = "\(base)/MerchantDashboard/FetchUsdBtcLedgerAmount"
//    static let userTransactions  = "\(base)/merchant/getUserTransaction"
//    static let ledgerBalance     = "\(base)/MerchantDashboard/FetchUsdBtcLedgerAmount"
//    static let cryptoAddress     = "\(base)/merchant/getCryptoAddress"
//    static let feesByCurrency    = "\(base)/merchant/getFeesByCurrencyId"
//    static let withdrawToPaybito = "\(base)/merchant/withdrawToPaybito"
//    static let withdrawExternal  = "\(base)/wallet/withdrawToExternalWallet"
//    static let withdrawBank      = "\(base)/wallet/withdrawToBank"
//}
//
//// MARK: - API Service
//
//final class WalletAPIService {
//
//    static let shared = WalletAPIService()
//    private init() {}
//
//    // MARK: - Headers
//
//    private func headers(token: String, uuid: String) -> HTTPHeaders {
//        let secureToken = UserDefaults.standard.string(forKey: "Bsecure_token") ?? ""
//        print("========== HEADER DEBUG ==========")
//        print("ACCESS TOKEN => \(token)")
//        print("SECURE TOKEN => \(secureToken)")
//        print("UUID         => \(uuid)")
//        print("==================================")
//        return [
//            "Authorization": "bearer \(token)",
//            "UUID":           uuid,
//            "Content-Type":   "application/json",
//            "Accept":         "application/json, text/plain, */*",
//            "origin":         "9E5XLQU4+cJS8AbKqd5BbPIS+qu1Iv3Dk6ntcvKvDvtMpwbGTvJb4tAF7Uomk1fc",
//            "Referer":        "https://trade.paybito.com/",
//        ]
//    }
//
//    private func decode<T: Decodable>(_ value: Any, to type: T.Type) throws -> T {
//        let data = try JSONSerialization.data(withJSONObject: value)
//        return try JSONDecoder().decode(T.self, from: data)
//    }
//
//    private func logRaw(_ response: DataResponse<Any>) {
//        print("STATUS => \(response.response?.statusCode ?? 0)")
//        if let data = response.data, let raw = String(data: data, encoding: .utf8) {
//            print("RAW => \(raw)")
//        }
//    }
//
//    // MARK: - Fetch Wallet Assets
//
//    func fetchWalletAssets(
//        merchantId: Int,
//        token: String,
//        uuid: String,
//        completion: @escaping (Swift.Result<[WalletAsset], Error>) -> Void
//    ) {
//        Alamofire.request(
//            WalletEndpoint.walletAssets,
//            method: .post,
//            parameters: ["merchant_id": merchantId] as Parameters,
//            encoding: JSONEncoding.default,
//            headers: headers(token: token, uuid: uuid)
//        ).responseJSON { [weak self] response in
//            guard let self = self else { return }
//            self.logRaw(response)
//            switch response.result {
//            case .success(let value):
//                do {
//                    let jsonData = try JSONSerialization.data(withJSONObject: value)
//                    let decoded  = try JSONDecoder().decode([WalletAssetsResponse].self, from: jsonData)
//                    completion(.success(decoded.first?.coinBalance ?? []))
//                } catch { completion(.failure(error)) }
//            case .failure(let error): completion(.failure(error))
//            }
//        }
//    }
//
//    // MARK: - Fetch User Transactions
//
//    func fetchUserTransactions(
//        merchantId: Int,
//        page: Int,
//        pageSize: Int,
//        token: String,
//        uuid: String,
//        completion: @escaping (Swift.Result<UserTransactionsWResponse, Error>) -> Void
//    ) {
//        let params: Parameters = [
//            "userId":           "\(merchantId)",
//            "pageNo":           "\(page)",
//            "noOfItemsPerPage": "\(pageSize)"
//        ]
//        Alamofire.request(
//            WalletEndpoint.userTransactions,
//            method: .post,
//            parameters: params,
//            encoding: JSONEncoding.default,
//            headers: headers(token: token, uuid: uuid)
//        ).responseJSON { [weak self] response in
//            guard let self = self else { return }
//            self.logRaw(response)
//            guard response.response?.statusCode == 200 else {
//                completion(.failure(NSError(
//                    domain: "TransactionAPI",
//                    code: response.response?.statusCode ?? 0,
//                    userInfo: [NSLocalizedDescriptionKey: "Transaction API failed"]
//                )))
//                return
//            }
//            switch response.result {
//            case .success(let value):
//                do {
//                    let arr = try self.decode(value, to: [UserTransactionsWResponse].self)
//                    guard let res = arr.first else { throw NSError(domain: "EmptyResponse", code: -1) }
//                    completion(.success(res))
//                } catch { completion(.failure(error)) }
//            case .failure(let error): completion(.failure(error))
//            }
//        }
//    }
//
//    // MARK: - Fetch Ledger
//
//    func fetchLedgerBalance(
//        merchantId: Int,
//        token: String,
//        uuid: String,
//        completion: @escaping (Swift.Result<LedgerData, Error>) -> Void
//    ) {
//        Alamofire.request(
//            WalletEndpoint.ledgerBalance,
//            method: .post,
//            parameters: ["merchant_id": merchantId] as Parameters,
//            encoding: JSONEncoding.default,
//            headers: headers(token: token, uuid: uuid)
//        ).responseJSON { [weak self] response in
//            guard let self = self else { return }
//            switch response.result {
//            case .success(let value):
//                do {
//                    let res = try self.decode(value, to: LedgerBalanceResponse.self)
//                    if let data = res.data { completion(.success(data)) }
//                    else { completion(.failure(NSError(domain: "NoData", code: -1))) }
//                } catch { completion(.failure(error)) }
//            case .failure(let error): completion(.failure(error))
//            }
//        }
//    }
//
//    // MARK: - Get Crypto Address
//
//    func getCryptoAddress(
//        currencyId: String,
//        merchantId: Int,
//        token: String,
//        uuid: String,
//        completion: @escaping (Swift.Result<CryptoAddressResponse, Error>) -> Void
//    ) {
//        let params: Parameters = [
//            "currency_id": currencyId,
//            "merchant_id": "\(merchantId)"
//        ]
//        print("===== getCryptoAddress REQUEST =====")
//        print("PARAMS => \(params)")
//
//        Alamofire.request(
//            WalletEndpoint.cryptoAddress,
//            method: .post,
//            parameters: params,
//            encoding: JSONEncoding.default,
//            headers: headers(token: token, uuid: uuid)
//        ).responseJSON { [weak self] response in
//            guard let self = self else { return }
//            self.logRaw(response)
//            switch response.result {
//            case .success(let value):
//                do {
//                    let jsonData = try JSONSerialization.data(withJSONObject: value)
//                    let arr = try JSONDecoder().decode([CryptoAddressResponse].self, from: jsonData)
//                    guard let first = arr.first else {
//                        throw NSError(domain: "CryptoAddress", code: -1,
//                                      userInfo: [NSLocalizedDescriptionKey: "Empty response"])
//                    }
//                    completion(.success(first))
//                } catch { completion(.failure(error)) }
//            case .failure(let error): completion(.failure(error))
//            }
//        }
//    }
//
//    // MARK: - Get Fees By Currency
//    //
//    // Sends merchant_id as Int (matches web payload).
//    // Passes network_type from getCryptoAddress response.
//    // Checks error:"1" in response and surfaces it as a real Error.
//
//    func getFeesByCurrency(
//        currencyId: String,
//        merchantId: Int,
//        networkType: String?,
//        token: String,
//        uuid: String,
//        completion: @escaping (Swift.Result<FeesByCurrencyResponse, Error>) -> Void
//    ) {
//        // Match browser payload EXACTLY
//        let params: Parameters = [
//            "currencyId": currencyId,
//            "merchant_id": "\(merchantId)"
//        ]
//
//        print("===== getFeesByCurrencyId REQUEST =====")
//        print("PARAMS => \(params)")
//
//        Alamofire.request(
//            WalletEndpoint.feesByCurrency,
//            method: .post,
//            parameters: params,
//            encoding: JSONEncoding.default,
//            headers: headers(token: token, uuid: uuid)
//        ).responseJSON { [weak self] response in
//            guard let self = self else { return }
//
//            self.logRaw(response)
//
//            switch response.result {
//
//            case .success(let value):
//                do {
//                    let jsonData = try JSONSerialization.data(withJSONObject: value)
//
//                    let fees: FeesByCurrencyResponse
//
//                    if let single = try? JSONDecoder().decode(
//                        FeesByCurrencyResponse.self,
//                        from: jsonData
//                    ) {
//                        fees = single
//
//                    } else if let arr = try? JSONDecoder().decode(
//                        [FeesByCurrencyResponse].self,
//                        from: jsonData
//                    ), let first = arr.first {
//                        fees = first
//
//                    } else {
//                        throw NSError(
//                            domain: "FeesAPI",
//                            code: -1,
//                            userInfo: [
//                                NSLocalizedDescriptionKey:
//                                "Unexpected fees response format"
//                            ]
//                        )
//                    }
//
//                    if fees.error == "1" {
//                        let msg =
//                            fees.errorMsg?
//                            .trimmingCharacters(in: .whitespaces)
//                            ?? "Failed to fetch transfer fees"
//
//                        throw NSError(
//                            domain: "FeesAPI",
//                            code: 1,
//                            userInfo: [
//                                NSLocalizedDescriptionKey:
//                                msg.isEmpty
//                                ? "Failed to fetch transfer fees"
//                                : msg
//                            ]
//                        )
//                    }
//
//                    completion(.success(fees))
//
//                } catch {
//                    completion(.failure(error))
//                }
//
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//
//    // MARK: - Withdraw to PayBito
//
//    func withdrawToPaybito(
//        request: PayBitoTransferRequest,
//        token: String,
//        uuid: String,
//        completion: @escaping (Swift.Result<GenericWalletResponse, Error>) -> Void
//    ) {
//        guard let params = request.asDictionary() else {
//            completion(.failure(NSError(domain: "EncodingError", code: -1)))
//            return
//        }
//        print("===== withdrawToPaybito REQUEST =====")
//        print(params)
//        Alamofire.request(
//            WalletEndpoint.withdrawToPaybito,
//            method: .post,
//            parameters: params,
//            encoding: JSONEncoding.default,
//            headers: headers(token: token, uuid: uuid)
//        ).responseJSON { [weak self] response in
//            guard let self = self else { return }
//            self.logRaw(response)
//            switch response.result {
//            case .success(let value):
//                do {
//                    let res = try self.decode(value, to: GenericWalletResponse.self)
//                    completion(.success(res))
//                } catch { completion(.failure(error)) }
//            case .failure(let error): completion(.failure(error))
//            }
//        }
//    }
//
//    // MARK: - Withdraw to External Wallet
//
//    func withdrawToExternalWallet(
//        request: ExternalWithdrawRequest,
//        token: String,
//        uuid: String,
//        completion: @escaping (Swift.Result<GenericWalletResponse, Error>) -> Void
//    ) {
//        guard let params = request.asDictionary() else {
//            completion(.failure(NSError(domain: "EncodingError", code: -1)))
//            return
//        }
//        Alamofire.request(
//            WalletEndpoint.withdrawExternal,
//            method: .post,
//            parameters: params,
//            encoding: JSONEncoding.default,
//            headers: headers(token: token, uuid: uuid)
//        ).responseJSON { [weak self] response in
//            guard let self = self else { return }
//            self.logRaw(response)
//            switch response.result {
//            case .success(let value):
//                do {
//                    let res = try self.decode(value, to: GenericWalletResponse.self)
//                    completion(.success(res))
//                } catch { completion(.failure(error)) }
//            case .failure(let error): completion(.failure(error))
//            }
//        }
//    }
//
//    // MARK: - Withdraw to Bank
//
//    func withdrawToBankAccount(
//        request: BankWithdrawRequest,
//        token: String,
//        uuid: String,
//        completion: @escaping (Swift.Result<GenericWalletResponse, Error>) -> Void
//    ) {
//        guard let params = request.asDictionary() else {
//            completion(.failure(NSError(domain: "EncodingError", code: -1)))
//            return
//        }
//        Alamofire.request(
//            WalletEndpoint.withdrawBank,
//            method: .post,
//            parameters: params,
//            encoding: JSONEncoding.default,
//            headers: headers(token: token, uuid: uuid)
//        ).responseJSON { [weak self] response in
//            guard let self = self else { return }
//            self.logRaw(response)
//            switch response.result {
//            case .success(let value):
//                do {
//                    let res = try self.decode(value, to: GenericWalletResponse.self)
//                    completion(.success(res))
//                } catch { completion(.failure(error)) }
//            case .failure(let error): completion(.failure(error))
//            }
//        }
//    }
//}





//
//  SettlementService.swift
//  SettlementWallet
//
//  Maps every API call in Dashboard.jsx to a Swift async/await method.
//  Base URL and auth headers match the existing WalletAPIService pattern.
//
// MARK: - Async bridges for Alamofire-3 completion-based SettlementService
// Drop these once/if you upgrade to Alamofire 5.
//
//  WalletAPIService.swift
//  PaymentsTerminal
//

//
//  WalletAPIService.swift
//  PaymentsTerminal
//
//
//  SettlementService.swift
//  SettlementWallet
//
//  Maps every API call in Dashboard.jsx to a Swift async/await method.
//  Base URL and auth headers match the existing WalletAPIService pattern.
//

import Foundation
import Alamofire

// MARK: - Endpoints

enum SettlementEndpoint {
    static let base = "https://service.hashcashconsultants.com/billbitcoins-v2"

    // Dashboard data
    static let fetchLedger           = "\(base)/MerchantDashboard/FetchUsdBtcLedgerAmount"
    static let getUserTransaction    = "\(base)/merchant/getUserTransaction"

    // Address / Validation
    static let getCryptoAddress      = "\(base)/merchant/getCryptoAddress"
    static let isCryptoAddrValid     = "\(base)/merchant/addressValidate"

    // Fees
    static let getFeesByCurrencyId   = "\(base)/merchant/getFeesByCurrencyId"
    static let getFees               = "\(base)/merchant/getFees"

    // External wallet send
    static let coinSendToOther       = "\(base)/merchant/SendOtp/coinsendtoother"   // email OTP
    static let sendToOther           = "\(base)/merchant/sendToOther"

    // PayBito / Exchange transfer
    static let autoLoginExchange     = "\(base)/merchant/auto-login/exchange"
    static let fetchUserSettings     = "\(base)/MerchantDashboard/FetchUserSettings"
    static let userAccountStatus = "https://accounts.paybito.com/api/user/userAccountStatus"
    static let transferToPaybito     = "\(base)/merchant/TransferToPaybito"

    // Bank withdrawal
    static let getUserDetails        = "\(base)/kyc/GetUserDetails"
    static let getUserBankDetails    = "\(base)/merchant/getUserBankDetails"
    static let convertPrice          = "\(base)/merchant/ConvertPrice"
    static let getTxnLimitByTier     = "\(base)/merchant/GetTransactionLimitByTier"
    static let createWithdrawalReq   = "\(base)/merchant/CreateWithdrawalRequest"
}

// MARK: - SettlementService

final class SettlementService {
    
    static let shared = SettlementService()
    private init() {}
    
    // MARK: - Auth headers
    
    private func headers() -> HTTPHeaders {
        let token       = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
        let uuid        = UserDefaults.standard.string(forKey: "Buuid") ?? ""
        let secureToken = UserDefaults.standard.string(forKey: "Bsecure_token") ?? ""
        _ = secureToken   // reserved for future use
        return [
            "Authorization": "bearer \(token)",
            "UUID":           uuid,
            "Content-Type":   "application/json",
            "Accept":         "application/json, text/plain, */*",
            "origin":         "9E5XLQU4+cJS8AbKqd5BbPIS+qu1Iv3Dk6ntcvKvDvtMpwbGTvJb4tAF7Uomk1fc",
            "Referer":        "https://trade.paybito.com/",
        ]
    }
    
    // MARK: - JSON decode helper (wraps Alamofire responseJSON)
    
    private func post<T: Decodable>(
        
        url: String,
        
        params: Parameters,
        
        as type: T.Type
        
    ) async throws -> T {
        
        print("➡️ API URL:", url)
        
        print("➡️ PARAMS:", params)
        
        return try await withCheckedThrowingContinuation { continuation in
            
            Alamofire.request(
                
                url,
                
                method: .post,
                
                parameters: params,
                
                encoding: JSONEncoding.default,
                
                headers: headers()
                
            )
            
            .validate()
            
            .responseData { response in
                
                print("⬅️ RESPONSE URL:", url)
                
                print("⬅️ STATUS:", response.response?.statusCode ?? -1)
                
                switch response.result {
                    
                case .success(let data):
                    
                    do {
                        let decoded = try JSONDecoder().decode(T.self, from: data)
                        continuation.resume(returning: decoded)
                        
                    } catch {
                        
                        do {
                            let arr = try JSONDecoder().decode([T].self, from: data)
                            
                            if let first = arr.first {
                                continuation.resume(returning: first)
                            } else {
                                continuation.resume(
                                    throwing: ServiceError.emptyResponse
                                )
                            }
                            
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: ──────────────────────────────────────────────
    // MARK: 1. Settlement Dashboard
    // MARK: ──────────────────────────────────────────────

    /// FetchUsdBtcLedgerAmount — returns coin balances
    func fetchLedgerAmount(merchantId: String) async throws -> LedgerAmountResponse {
        return try await post(
            url: SettlementEndpoint.fetchLedger,
            params: ["merchant_id": merchantId],
            as: LedgerAmountResponse.self
        )
    }

    /// GetUserTransaction — paginated list
    func getUserTransactions(
        userId: String,
        pageNo: Int,
        pageSize: Int
    ) async throws -> UserTransactionResponse {
        return try await post(
            url: SettlementEndpoint.getUserTransaction,
            params: [
                "userId":           userId,
                "pageNo":           "\(pageNo)",
                "noOfItemsPerPage": "\(pageSize)",
            ],
            as: UserTransactionResponse.self
        )
    }

    // MARK: ──────────────────────────────────────────────
    // MARK: 2. Saved Crypto Addresses
    // MARK: ──────────────────────────────────────────────

    /// getCryptoAddress — saved addresses for a currency
    func getCryptoAddresses(
        currencyId: String,
        merchantId: String
    ) async throws -> [SavedCryptoAddress] {

        return try await withCheckedThrowingContinuation { continuation in

            Alamofire.request(
                SettlementEndpoint.getCryptoAddress,
                method: .post,
                parameters: [
                    "currency_id": currencyId,
                    "merchant_id": merchantId
                ],
                encoding: JSONEncoding.default,
                headers: headers()
            )
            .validate()
            .responseData { response in

                switch response.result {

                case .success(let data):

                    print("===== GET CRYPTO ADDRESS RAW RESPONSE =====")

                    if let json = String(data: data, encoding: .utf8) {
                        print(json)
                    }

                    let decoded =
                        (try? JSONDecoder().decode(
                            [SavedCryptoAddress].self,
                            from: data
                        )) ?? []

                    print("===== DECODED ADDRESSES =====")
                    print(decoded)

                    continuation.resume(returning: decoded)

                case .failure:

                    // matches React catch
                    continuation.resume(returning: [])
                }
            }
        }
    }

    // MARK: ──────────────────────────────────────────────
    // MARK: 3. Address Validation
    // MARK: ──────────────────────────────────────────────

    /// isCryptoAddrValid — mirrors React validateExternalAddress()
    func validateAddress(
        currencyId: String,
        address: String,
        merchantId: String,
        tokenType: String?
    ) async throws -> CryptoAddrValidResponse {

        var params: Parameters = [
            "currencyId": currencyId,
            "address": address,
            "merchant_id": merchantId
        ]

        if let t = tokenType, currencyId == "16" {
            params["tokenType"] = t
        }

        let response = try await post(
            url: SettlementEndpoint.isCryptoAddrValid,
            params: params,
            as: [CryptoAddrValidResponse].self
        )

        guard let first = response.first else {
            throw ServiceError.apiError("Empty response")
        }

        return first
    }

    // MARK: ──────────────────────────────────────────────
    // MARK: 4. Fee Estimation
    // MARK: ──────────────────────────────────────────────

    /// getFeesByCurrencyId — min/max limits for a currency
    /// Mirrors React: balenceTranfertoPaybitoModal + getHcxXrpOtherWalletValue
    func getFeesByCurrency(
        currencyId: String,
        merchantId: String,
        tokenType: String?
    ) async throws -> CurrencyFeesResponse {
        var params: Parameters = [
            "currencyId":  currencyId,
            "merchant_id": merchantId,
        ]
        if let t = tokenType {
            params["tokenType"] = t
        }
        return try await post(
            url: SettlementEndpoint.getFeesByCurrencyId,
            params: params,
            as: CurrencyFeesResponse.self
        )
    }

    /// getFees — estimated network fee for a specific send amount
    /// Mirrors React: rate() + maxSendAmount()
    func getNetworkFee(
        sendAmount: String,
        currency: String,
        merchantId: String
    ) async throws -> GetFeesResponse {
        return try await post(
            url: SettlementEndpoint.getFees,
            params: [
                "sendAmount":  sendAmount,
                "currency":    currency,
                "merchant_id": merchantId,
            ],
            as: GetFeesResponse.self
        )
    }

    // MARK: ──────────────────────────────────────────────
    // MARK: 5. External Wallet Send
    // MARK: ──────────────────────────────────────────────

    /// coinSendToOther — triggers email OTP for external wallet transfer
    /// Mirrors React: sendMailForExternalWallet()
    func requestEmailOTPForExternalTransfer(
        email: String,
        merchantId: String
    ) async throws -> CoinSendToOtherResponse {
        return try await post(
            url: SettlementEndpoint.coinSendToOther,
            params: [
                "email":       email,
                "merchant_id": merchantId,
            ],
            as: CoinSendToOtherResponse.self
        )
    }

    /// SendToOther — final external wallet transfer call
    /// Mirrors React: transferToExternal()
    func sendToExternalWallet(request: SendToOtherRequest) async throws -> SendToOtherResponse {
        guard let params = request.asDictionary() else {
            throw ServiceError.encodingFailed
        }
        return try await post(
            url: SettlementEndpoint.sendToOther,
            params: params,
            as: SendToOtherResponse.self
        )
    }

    // MARK: ──────────────────────────────────────────────
    // MARK: 6. PayBito / Exchange Transfer
    // MARK: ──────────────────────────────────────────────

    /// /merchant/auto-login/exchange — Step 1 of PayBito transfer
    /// Mirrors React: handleExchangeUserDetails()
    func autoLoginExchange(
        merchantId: String,
        brokerId: String,
        uuid: String,
        authToken: String
    ) async throws -> ExchangeAutoLoginResponse {

        return try await withCheckedThrowingContinuation { cont in

            var hdrs = headers()
            hdrs["Authorization"] = "Bearer \(authToken)"
            
            
            print("\n===== AUTO LOGIN REQUEST =====")
            print("URL =", SettlementEndpoint.autoLoginExchange)
            print("merchantId =", merchantId)
            print("brokerId =", brokerId)
            print("uuid =", uuid)
            print("authToken =", authToken)
            print("headers =", hdrs)

            Alamofire.request(
                SettlementEndpoint.autoLoginExchange,
                method: .post,
                parameters: [
                    "merchantId": merchantId,
                    "brokerId": brokerId,
                    "uuid": uuid
                ],
                encoding: JSONEncoding.default,
                headers: hdrs
            )
            .validate()
            .responseData { response in

                print("\n===== AUTO LOGIN RESPONSE =====")
                print("statusCode =", response.response?.statusCode ?? -1)

                if let data = response.data {
                    print(String(data: data, encoding: .utf8) ?? "")
                }

                switch response.result {

                case .success(let data):
                    do {
                        let decoded = try JSONDecoder()
                            .decode(ExchangeAutoLoginResponse.self, from: data)

                        cont.resume(returning: decoded)

                    } catch {
                        print("DECODING ERROR:", error)
                        cont.resume(throwing: error)
                    }

                case .failure(let error):
                    print("REQUEST ERROR:", error)
                    cont.resume(throwing: error)
                }
            }
        }
    }
    
    func userAccountStatus(
        token: String,
        uuid: String,
        userId: Int
    ) async throws -> UserAccountStatusResponse {

        return try await withCheckedThrowingContinuation { cont in

            let headers: HTTPHeaders = [

                "Authorization": "BEARER \(token)",

                "Content-Type": "application/json",

                "Accept": "*/*",

                "Origin": "https://trade.paybito.com",

                "Referer": "https://trade.paybito.com/"

            ]

            let params: Parameters = [
                "uuid": uuid,
                "userId": userId
            ]

            print("===== USER ACCOUNT STATUS =====")
            print("URL:", SettlementEndpoint.userAccountStatus)
            print("userId (Int):", userId)     // confirms it's not empty string
              print("uuid:", uuid)
          

            Alamofire.request(
                SettlementEndpoint.userAccountStatus,
                method: .post,
                parameters: params,
                encoding: JSONEncoding.default,
                headers: headers
            )
            .responseData { response in

                print("\n===== USER ACCOUNT STATUS RESPONSE =====")

                print("statusCode =", response.response?.statusCode ?? -1)

                if let data = response.data {

                    print("responseBody =", String(data: data, encoding: .utf8) ?? "")

                }
                switch response.result {

                case .success(let data):

                    do {
                        let decoded = try JSONDecoder()
                            .decode(UserAccountStatusResponse.self, from: data)

                        cont.resume(returning: decoded)

                    } catch {
                        cont.resume(throwing: error)
                    }

                case .failure(let error):
                    cont.resume(throwing: error)
                }
            }
        }
    }

    /// FetchUserSettings — checks google_auth_enabled flag
    /// Mirrors React: FetchUserSettings() inside balanceTransfertoPaybito()
    func fetchUserSettings(merchantId: String) async throws -> UserSettingsResponse {
        return try await post(
            url: SettlementEndpoint.fetchUserSettings,
            params: ["merchant_id": merchantId],
            as: UserSettingsResponse.self
        )
    }

    /// transferBalencetoPaybito — final PayBito transfer call
    /// Mirrors React: transferToPaybitoWallet()
    func transferToPaybito(
        request: TransferToPaybitoRequest
    ) async throws -> TransferToPaybitoResponse {

        guard let params = request.asDictionary() else {
            throw ServiceError.encodingFailed
        }
        print("===== FINAL PARAMS =====")

        dump(params)

        if let data = try? JSONSerialization.data(withJSONObject: params),

           let json = String(data: data, encoding: .utf8) {

            print("===== JSON BODY =====")

            print(json)

        }

        return try await post(
            url: SettlementEndpoint.transferToPaybito,
            params: params,
            as: TransferToPaybitoResponse.self
        )
    }

    // MARK: ──────────────────────────────────────────────
    // MARK: 7. Bank Withdrawal
    // MARK: ──────────────────────────────────────────────

    /// GetUserDetails — KYC / bankDetailsStatus check
    /// Mirrors React: handleInitiateWithdrawToBankAccount()
    func getUserDetails() async throws -> UserrDetailsResponse {

        let exchangeUuid =
            UserDefaults.standard.string(forKey: "Bexchange_uuid") ?? ""

        return try await withCheckedThrowingContinuation { cont in

            Alamofire.request(
                SettlementEndpoint.getUserDetails,
                method: .post,
                parameters: [
                    "uuid": exchangeUuid
                ],
                encoding: JSONEncoding.default,
                headers: headers()
            )
            .validate()
            .responseData { response in

                switch response.result {

                case .success(let data):

                    print(String(data: data, encoding: .utf8) ?? "")

                    do {
                        let decoded = try JSONDecoder().decode(
                            UserrDetailsResponse.self,
                            from: data
                        )

                        cont.resume(returning: decoded)

                    } catch {
                        cont.resume(throwing: error)
                    }

                case .failure(let error):
                    cont.resume(throwing: error)
                }
            }
        }
    }
    /// GetUserBankDetails
    func getUserBankDetails() async throws -> GetUserBankDetailsResponse {
        
        
        print("🚀 CALLING:", SettlementEndpoint.getUserBankDetails)

        return try await withCheckedThrowingContinuation { cont in

            Alamofire.request(
                SettlementEndpoint.getUserBankDetails,
                method: .post,
                parameters: Parameters(),
                encoding: JSONEncoding.default,
                headers: headers()
            )
            .validate()
            .responseJSON { response in

                switch response.result {

                case .success(let value):

                    do {
                        let data = try JSONSerialization.data(
                            withJSONObject: value
                        )

                        let decoded = try JSONDecoder()
                            .decode(GetUserBankDetailsResponse.self, from: data)

                        cont.resume(returning: decoded)

                    } catch {
                        cont.resume(throwing: error)
                    }

                case .failure(let error):
                    cont.resume(throwing: error)
                }
            }
        }
    }

    /// ConvertPrice — fiat market price for a crypto asset
    /// Mirrors React: ConvertPrice(assetCode, homeCurrency)
    func convertPrice(
        fromCurrency: String,
        toCurrency: String
    ) async throws -> ConvertPriceResponse {
        print("🚀 CALLING:", SettlementEndpoint.convertPrice)
        return try await post(
            url: SettlementEndpoint.convertPrice,
            params: [
                "from": fromCurrency,
                "to":   toCurrency,
            ],
            as: ConvertPriceResponse.self
        )
    }

    /// GetTransactionLimitByTier
    func getTransactionLimit(
        currency: String,
        tierType: String?
    ) async throws -> TransactionLimitResponse {
        print("🚀 CALLING:", SettlementEndpoint.getTxnLimitByTier)
        var params: Parameters = ["currency": currency]
        if let t = tierType { params["userTierType"] = t }
        return try await post(
            url: SettlementEndpoint.getTxnLimitByTier,
            params: params,
            as: TransactionLimitResponse.self
        )
    }

    /// CreateWithdrawalRequest — final bank withdrawal call
    func createWithdrawalRequest(body: CreateWithdrawalRequestBody) async throws -> CreateWithdrawalResponse {
        guard let params = body.asDictionary() else {
            throw ServiceError.encodingFailed
        }
        return try await post(
            url: SettlementEndpoint.createWithdrawalReq,
            params: params,
            as: CreateWithdrawalResponse.self
        )
    }
}



