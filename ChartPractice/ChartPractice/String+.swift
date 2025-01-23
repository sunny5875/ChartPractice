//
//  String+.swift
//  ChartPractice
//
//  Created by 현수빈 on 1/23/25.
//

import Foundation

extension String {
    
    var toTimeInterval: TimeInterval {
        Double(self) ?? .init(0)
    }
    
    var toTimeFormatted: String {
        let date = Date.init(timeIntervalSince1970: self.toTimeInterval)
        let dateFormatt = DateFormatter()
        dateFormatt.dateFormat = "HH:mm"
        
        return dateFormatt.string(from: date)
    }
}
