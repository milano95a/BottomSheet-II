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
        SFBottomSheet(shouldDismiss: $shouldDismiss, { button }, { bottomSheet })
    }
    
    var button: some View {
        Text("open bottom sheet")
    }
    
    var bottomSheet: some View {
        VStack {
            Text("Title")
                .padding(16)
            LazyVGrid(columns: [GridItem(spacing: 8), GridItem(spacing: 8)], spacing: 8) {
                bottomSheetButton(text: "Apple")
                bottomSheetButton(text: "Orange")
                bottomSheetButton(text: "Banana")
                bottomSheetButton(text: "Pineapple")
            }
            .padding(16)
            Button("Закрыть", action: {
                shouldDismiss = true
            })
            .padding(16)
            .padding(.bottom, 16)
        }
        .background(Color.white)
    }
    
    func bottomSheetButton(text: String) -> some View {
        VStack {
            Image(systemName: "chart.pie.fill")
            Text(text)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray)
    }
}

#Preview {
    ContentView()
}




struct SFBottomSheet<ButtonContent: View, BottomSheetContent: View>: View {
    @Binding var shouldDismiss: Bool
    var button: () -> ButtonContent
    var bottomSheet: () -> BottomSheetContent
    
    init(shouldDismiss: Binding<Bool>, _ button: @escaping () -> ButtonContent, _ bottomSheet: @escaping () -> BottomSheetContent) {
        self._shouldDismiss = shouldDismiss
        self.button = button
        self.bottomSheet = bottomSheet
    }
    
    @State private var isPresented = false
    @State private var offset: CGFloat = UIScreen.main.bounds.height
    @State private var contentSize: CGSize = .zero

    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.location.y > 0 {
                    self.offset = value.location.y
                }
            }
            .onEnded { value in
                if contentSize.height / 2 < value.location.y {
                    withAnimation {
                        self.offset = contentSize.height
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        isPresented = false
                    }
                } else {
                    withAnimation {
                        self.offset = .zero
                    }
                }
            }
    }
    
    var body: some View {
        button()
            .onTapGesture {
                isPresented = true
            }
            .fullScreenCover(isPresented: $isPresented) {
                ZStack {
                    ZStack {
                        Color.black.opacity(0.5)
                            .onTapGesture {
                                close()
                            }
                        VStack {
                            Color.clear
                                .layoutPriority(1)
                            
                            ChildSizeReader(size: $contentSize, content: {
                                bottomSheet()
                            })
                            .offset(y: offset)
                            .transition(.slide)
                            .onAppear {
                                withAnimation {
                                    offset = .zero
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    shouldDismiss = false
                                }
                            }
                            .gesture(simpleDrag)
                        }
                    }
                }
                .onChange(of: shouldDismiss) { oldValue, newValue in
                    if shouldDismiss {
                        close()
                    }
                }
                .ignoresSafeArea()
                .background(SFFullScreenCoverBackgroundRemovalView())
            }
            .removeFullScreenCoverAppearAnimation()
    }
    
    func close() {
        withAnimation {
            self.offset = contentSize.height
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            isPresented = false
        }
    }
}

// Sourcecode: https://stackoverflow.com/questions/56573373/swiftui-get-size-of-child
struct ChildSizeReader<Content: View>: View {
    @Binding var size: CGSize
    let content: () -> Content
    var body: some View {
        ZStack {
            content()
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: SizePreferenceKey.self, value: proxy.size)
                    }
                )
        }
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            self.size = preferences
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: Value = .zero

    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}

///https://stackoverflow.com/questions/64301041/swiftui-translucent-background-for-fullscreencover
struct SFFullScreenCoverBackgroundRemovalView: UIViewRepresentable {
    
    private class BackgroundRemovalView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            
            superview?.superview?.backgroundColor = .clear
        }
    }
    
    func makeUIView(context: Context) -> UIView {
        return BackgroundRemovalView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

/// Remove view transition animation
extension View {
    func removeFullScreenCoverAppearAnimation() -> some View {
        self
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
    }
}



