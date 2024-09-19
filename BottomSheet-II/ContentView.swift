//
//  ContentView.swift
//  BottomSheet-II
//
//  Created by Jamoliddinov Abduraxmon on 18/09/24.
//

import SwiftUI

struct ContentView: View {
    @State var shouldDismiss = false
    
    var body: some View {
        SWABottomSheet(shouldDismiss: $shouldDismiss, { button }, { bottomSheet })
    }
    
    var button: some View {
        SWAText(title: "Open bottom sheet")
            .padding()
    }
    
    var bottomSheet: some View {
        
        VStack(spacing: 16) {
            Text("Fruits")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(spacing: 8), GridItem(spacing: 8)], spacing: 8) {
                SWAText(title: "🍏 Apple")
                SWAText(title: "🍊 Orange")
                SWAText(title: "🍌 Banana")
                SWAText(title: "🍓 Strawberry")
            }
            
            SWAText(title: "Close", background: Color.red)
                .padding(.bottom, 16)
                .onTapGesture {
                    shouldDismiss = true
                }
        }
        .padding()
        .background(Color.white)
    }
}

struct SWAText: View {
    var title: String
    var background: Color = .blue
    
    var body: some View {
        Text(title)
            .padding()
            .frame(maxWidth: .infinity)
            .background(background)
            .cornerRadius(16)
            .foregroundColor(Color.white)
    }
}

#Preview {
    ContentView()
}
