//
//  ContentView.swift
//  ChartPractice
//
//  Created by 현수빈 on 6/12/24.
//

import SwiftUI
import Charts

struct ContentView: View {
    
    @StateObject var viewModel: ViewModel = ViewModel()

    let curGradient = LinearGradient(
          gradient: Gradient (
              colors: [
                Color.blue.opacity(0.1),
                  Color.blue.opacity(0.0)
              ]
          ),
          startPoint: .top,
          endPoint: .bottom
      )
    
    let curGradient2 = LinearGradient(
          gradient: Gradient (
              colors: [
                Color.red.opacity(0.1),
                  Color.red.opacity(0.0)
              ]
          ),
          startPoint: .top,
          endPoint: .bottom
      )

    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                rateLargeView()
                rateView()
            }
            .padding()
            .navigationTitle("크립토 환율")
            .background(Color.black.opacity(0.03))
        }
        .task {
            await withTaskGroup(of: Void.self) { group in
                for item in Symbol.allCases {
                    group.addTask {
                        await viewModel.requestAPI(queryValue: item)
                    }
                }
            }
        }
    }
    @ViewBuilder
    func rateLargeView() -> some View {
        if let list = viewModel.list[Symbol.bitcoin] {
            largeCell(Symbol.bitcoin, list: list)
                .padding(.horizontal, 12)
        }
    }
    
    func largeCellHeader(_ key: Symbol, list: [PriceEntry] ) -> some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 4) {
                Image(systemName: "dollarsign.circle.fill")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(Color.orange)
                
                Text(key.rawValue.capitalized)
                    .font(.title2)
                
                Text("(\(key.symbol))")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            HStack {
                Text("₩\(Int(list.last?.price ?? 0.0))")
                    .font(.title2)
                
                Text("77,000 0.05%")
                    .font(.caption)
                    .foregroundStyle(Color.red)
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
    
    func largeCell(_ key: Symbol, list: [PriceEntry] ) -> some View {
        VStack {
            largeCellHeader(key, list: list)
            
            Rectangle()
                .frame(height: 20)
                .foregroundStyle(Color.clear)
            
            Chart {
                ForEach(list, id: \.self) { point in
                    LineMark(
                        x: .value("sec", point.timestamp),
                        y: .value("price", point.price)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(Color.blue)
                    
                    AreaMark(
                        x: .value("sec", point.timestamp),
                        yStart: .value("Baseline", calculateYDomain(list).lowerBound),
                        yEnd: .value("price", point.price)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(curGradient)
                    
                    if let selectedPoint = viewModel.selected {
                        RuleMark(
                            x: .value("sec", selectedPoint.timestamp),
                            yStart: .value("Baseline", calculateYDomain(list).lowerBound),
                            yEnd: .value("price", selectedPoint.price)
                        )
                        .lineStyle(.init(lineWidth: 1.5, dash: [2]))
                        
                        PointMark(
                            x: .value("sec", selectedPoint.timestamp),
                            y: .value("price", selectedPoint.price)
                        )
                        .symbol {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 4)
                                )
                        }
                        .annotation(position: .top, alignment: .center) {
                            HStack(spacing: 2) {
                                Text("\(String(selectedPoint.timestamp).toTimeFormatted)")
                                    .font(.caption2)
                                    .foregroundStyle(Color.black)
                                
                                Text("₩\(Int(selectedPoint.price))")
                                    .font(.caption2)
                                    .foregroundStyle(Color.red)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay {
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                            }
                        }
                    }
                }
            }
            .chartYScale(domain: calculateYDomain(list))
            .chartXAxis(.hidden)
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let location = value.location
                                    if let nearPoint = getNearestPoint(list: list, location: location, proxy: proxy, geo: geo) {
                                        viewModel.selected = nearPoint
                                    }
                                }
                                .onEnded { _ in
                                    viewModel.selected = nil
                                }
                        )
                }
            }
        }
        .padding(.vertical, 24)
        .backgroundStyle(Color.white)
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black.opacity(0.2), lineWidth: 1)
        }
    }
    
    private func calculateYDomain(_ list: [PriceEntry]) -> ClosedRange<Double> {
        guard let minPrice = list.min()?.price,
                let maxPrice = list.max()?.price else {
            return 0...1
        }
        return minPrice...maxPrice
    }
    
    func rateView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8, content: {
                ForEach(Array(viewModel.list.keys), id: \.self) { key in
                    cell(key, list: viewModel.list[key] ?? [])
                }
            })
        }
        .padding(.horizontal, 12)
    }
    
    func cell(_ key: Symbol, list: [PriceEntry] ) -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                Text(key.rawValue.capitalized)
                    .font(.title2)
                
                Text(key.symbol)
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                
                Spacer()
                Image(systemName: "dollarsign.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(Color.orange)
            }
            .foregroundStyle(Color.black)
            
            Text("+0.05%")
                .font(.caption)
                .foregroundStyle(Color.red)
            
            HStack {
                Chart {
                    ForEach(list, id: \.self) { point in
                        LineMark(
                            x: .value("sec", point.timestamp),
                            y: .value("amount", point.price )
                        )
                        .interpolationMethod(.cardinal)
                        .foregroundStyle(Color.red)
                        .lineStyle(.init(lineWidth: 2.0))
                        
                        AreaMark(
                            x: .value("sec", point.timestamp),
                            yStart: .value("Baseline", calculateYDomain(list).lowerBound),
                            yEnd: .value("price", point.price)
                        )
                        .interpolationMethod(.cardinal)
                        .foregroundStyle(curGradient2)
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartYScale(domain: calculateYDomain(list))
                .frame(height: 64)
            }
            
            Text("₩ 101,435,000")
                .foregroundStyle(Color.black)
                .font(.headline)
        }
        .padding(16)
        .frame(width: 234, height: 210)
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black.opacity(0.2), lineWidth: 1)
        }
    }
    
    
    private func getNearestPoint(list: [PriceEntry], location: CGPoint, proxy: ChartProxy, geo: GeometryProxy) -> PriceEntry? {
        let xValue = proxy.value(atX: location.x, as: Double.self)

        guard let x = xValue else { return nil }

        return list.min(by: { abs($0.timestamp - x) < abs($1.timestamp - x) })
    }
}

#Preview {
    ContentView()
}
