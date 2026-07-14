//
//  URLExtension.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 11/05/26.
//


import Foundation

extension URL: Identifiable {
    public var id: String {
        absoluteString
    }
}
