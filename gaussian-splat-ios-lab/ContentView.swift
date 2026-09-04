//
//  ContentView.swift
//  gaussian-splat-ios-lab
//
//  Created by harryho on 9/3/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("숫자와 친해지기") {
                    NavigationLink("기준선") {
                       Step00_Baseline()
                    }
                    NavigationLink("스플랫 하나를 «숫자로»") {
                       Step01_SplatAsNumbers()
                    }
                    NavigationLink("버퍼에 넣고 다시 꺼내기") {
                       Step02_BufferRoundTrip()
                    }
                }
                
                Section("첫 타원체") {
                    NavigationLink("첫 스플랫을 그린다") {
                        Step03_FirstSplat()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
