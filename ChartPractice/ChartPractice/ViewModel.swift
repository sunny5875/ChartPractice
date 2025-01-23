//
//  ViewModel.swift
//  ChartPractice
//
//  Created by 현수빈 on 6/12/24.
// 9f8c21d8735e4739a05166d02427f71e

import Foundation

final class ViewModel: ObservableObject {
    
    @Published var list: [Symbol: [PriceEntry]] = [:]
    @Published var selected: PriceEntry? = nil
    
    let jsconDecoder: JSONDecoder = JSONDecoder()

    
    func requestAPI(queryValue: Symbol) {
        
        let query: String  = "https://api.coingecko.com/api/v3/coins/\(queryValue.rawValue)/market_chart?vs_currency=usd&days=30&interval=daily&precision=3"
        let encodedQuery: String = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let queryURL: URL = URL(string: encodedQuery)!
        
        let apikey = "CG-Ba2fh8afp4jtTWrDtzdqpoPp"
       
        var requestURL = URLRequest(url: queryURL)
        requestURL.addValue(apikey, forHTTPHeaderField: "x_cg_pro_api_key")
        
        let task = URLSession.shared.dataTask(with: requestURL) { data, response, error in
            guard error == nil,
                  let data = data
            else { return }
            
            do {
                let searchInfo = try self.jsconDecoder.decode(PricesResponse.self, from: data)
                print("===== \(queryValue)의 결과 ===== ")
                print(searchInfo)
                let firstTimestamp = Double(searchInfo.prices.first?.timestamp ?? Date.timeIntervalSinceReferenceDate)
                DispatchQueue.main.async {
                    self.list[queryValue] = searchInfo.prices.map { item in
                        let newItem = PriceEntry(timestamp: item.timestamp - firstTimestamp, price: item.price * 1300)
                        return newItem
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}

struct PriceEntry: Codable, Hashable, Comparable {
    static func < (lhs: PriceEntry, rhs: PriceEntry) -> Bool {
        lhs.price < rhs.price
    }
    
    var timestamp: Double
    let price: Double
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        timestamp = try container.decode(Double.self)
        price = try container.decode(Double.self)
    }
    
    init(timestamp: Double, price: Double) {
        self.timestamp = timestamp
        self.price = price
    }
}

struct PricesResponse: Codable, Hashable {
    let prices: [PriceEntry]
}

enum Symbol: String, CaseIterable {
    case bitcoin
    case ethereum
    case solana
    
    var symbol: String {
        switch self {
        case .bitcoin:
            return "BTC"
        case .ethereum:
            return "ETH"
        case .solana:
            return "SOL"
        }
    }
}
