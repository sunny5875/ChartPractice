//
//  ViewModel.swift
//  ChartPractice
//
//  Created by 현수빈 on 6/12/24.
// 9f8c21d8735e4739a05166d02427f71e

import Foundation

final class ViewModel: ObservableObject {
    
    @Published var list: [String: [PriceEntry]] = [:]
    
    let jsconDecoder: JSONDecoder = JSONDecoder()

    
    func requestAPI(queryValue: String) {
        
        
        let query: String  = "https://api.coingecko.com/api/v3/coins/\(queryValue)/market_chart?vs_currency=usd&days=30&interval=daily&precision=3"
        let encodedQuery: String = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let queryURL: URL = URL(string: encodedQuery)!
        
        let apikey = "API_KEY"
       
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
                self.list[queryValue] = searchInfo.prices
            } catch {
            }
        }
        task.resume()
    }
}

// Define a struct for the individual price entries
struct PriceEntry: Codable, Hashable {
    let timestamp: Double
    let price: Double
    
    // Custom initializer to map the array elements to the properties
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

// Define a struct for the main response containing the array of prices
struct PricesResponse: Codable, Hashable {
    let prices: [PriceEntry]
}
