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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                rateView()
                ForEach(Array(viewModel.list.keys), id: \.self) { index in
                    HStack {
                        Text(index)
                            .font(.headline)
                            .padding(20)
                        Spacer()
                    }
                    .background(Color.white)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                }
                Spacer()
            }
            .padding()
            .navigationTitle("크립토 환율")
            .background(Color.black.opacity(0.03))
        }
        .task {
            viewModel.requestAPI(queryValue: "bitcoin")
            viewModel.requestAPI(queryValue: "ethereum")
            viewModel.requestAPI(queryValue: "solana")
        }
    }
    
    
    @ViewBuilder
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
    
    @ViewBuilder
    func cell(_ key: String, list: [PriceEntry] ) -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                Image(systemName: "wonsign.circle")
                
                Text(key)
                    .font(.callout)
                Spacer()
            }
            .foregroundStyle(Color.white)
            
            HStack {
                Spacer()
                Chart {
                    ForEach(list, id: \.self) { point in
                        if #available(iOS 16.4, *) {
                            LineMark(
                                x: .value("sec", point.timestamp - 1715731200000),
                                y: .value("amount", point.price * 1000 * 1300 )
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(Color.red)
                            .lineStyle(.init(lineWidth: 2.0))
                            .shadow(color: .red, radius: 4)
                            
                        }
                    }
                }
//                .chartYScale(type: .log)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(width: 90, height: 64)
            }
            
            Text("₩ 101,435,000")
                .foregroundStyle(Color.white)
                .font(.headline)
            
            Text("3.2")
                .foregroundStyle(Color.red)
                .font(.callout)
        }
        .padding()
        .frame(width: 234, height: 210)
        .background(Color.black.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}
    
    #Preview {
        ContentView()
    }
