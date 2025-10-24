import SwiftUI
import UserNotifications
import UIKit
import Combine

struct CFLaunchView: View {
    
    @AppStorage("firstOpenApp") var firstOpenApp = true
    @AppStorage("stringURL") var stringURL = ""
    
    @State private var pushAnswered = false
    @State private var showPrivacy = false
    @State private var showHome = false
    @State private var minSplashDone = false
    @State private var fired = false
    @State private var minTimer: DispatchWorkItem?
    @State private var progress: CGFloat = 0.0
    
    private let minSplash: TimeInterval = 1.5
    private let postConsentDelay: TimeInterval = 2.0
    
#if targetEnvironment(simulator)
    private let isSimulator = true
#else
    private let isSimulator = false
#endif
    

       
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                loader
                
                NavigationLink(destination: PrivacyView(),  isActive: $showPrivacy) { EmptyView() }
                NavigationLink(destination: CFHomeWebView(), isActive: $showHome)   { EmptyView() }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
            .background(
                ZStack {
                    Color.white
                    Image(.loadingBackground)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                }
            )
            .navigationViewStyle(StackNavigationViewStyle())
            .hideNavigationBar()
            .onAppear {
                startMinSplash()
                
                NotificationCenter.default.addObserver(
                    forName: .pushPermissionGranted,
                    object: nil,
                    queue: .main
                ) { _ in
                    pushAnswered = true
                    tryProceed()
                }

                NotificationCenter.default.addObserver(
                    forName: .pushPermissionDenied,
                    object: nil,
                    queue: .main
                ) { _ in
                    pushAnswered = true
                    tryProceed()
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self, name: .pushPermissionGranted, object: nil)
                NotificationCenter.default.removeObserver(self, name: .pushPermissionDenied, object: nil)
            }
        }
    }
    
    private func startMinSplash() {
        progress = 0.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.linear(duration: minSplash)) {
                progress = 0.7
            }
        }

        minTimer?.cancel()
        let w = DispatchWorkItem {
            minSplashDone = true
            tryProceed()
        }
        minTimer = w
        DispatchQueue.main.asyncAfter(deadline: .now() + minSplash, execute: w)
    }

    private func tryProceed() {
        guard !fired else { return }

        if isSimulator {
            guard minSplashDone else { return }
            animateToFullAndProceed()
            return
        }

        guard minSplashDone, pushAnswered else { return }
        animateToFullAndProceed()
    }

    private func animateToFullAndProceed() {
        fired = true
        withAnimation(.easeInOut(duration: postConsentDelay)) {
            progress = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + postConsentDelay) {
            if !stringURL.isEmpty || firstOpenApp {
                AppDelegate.orientationLock = [.portrait, .landscapeLeft, .landscapeRight]
                showPrivacy = true
            } else {
                AppDelegate.lock([.landscapeLeft, .landscapeRight])
                showHome = true
            }
        }
    }
}

// MARK: - Loader

extension CFLaunchView {
    var loader: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .green1,
                                    .green2
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
            
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [
                            .pink1,
                            .pink2
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white,
                                    .white
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .frame(width: progress * 280, height: 35)
                .animation(.linear(duration: 3), value: progress)
        }
        .frame(width: 280)
    }
}

#Preview {
    CFLaunchView()
}
