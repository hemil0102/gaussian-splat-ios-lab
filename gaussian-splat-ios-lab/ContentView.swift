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
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
