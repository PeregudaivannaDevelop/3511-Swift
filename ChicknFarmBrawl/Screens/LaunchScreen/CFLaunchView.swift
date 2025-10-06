import SwiftUI
import UserNotifications
import UIKit
import Combine

struct CFLaunchView: View {
    
    @AppStorage("firstOpenApp") var firstOpenApp = true
    @AppStorage("stringURL") var stringURL = ""

    @State private var showPrivacy = false
    @State private var showHome = false

    @State var fillAmount: CGFloat = 0.0
    @State var progress: CGFloat = 0
    @State private var cancellable: AnyCancellable?

    @State private var responded = false
    @State private var minSplashDone = false
    @State private var fired = false
    @State private var minTimer: DispatchWorkItem?
    @State private var pollTimer: Timer?

    private let minSplash: TimeInterval       = 2.0
    private let postConsentDelay: TimeInterval = 2.5

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
                progress = 0
                startProgressAnimation()
                startMinSplash()
                startAuthPolling()
            }
            .onDisappear {
                minTimer?.cancel()
                pollTimer?.invalidate()
            }
        }
    }
    
    private func startMinSplash() {
        minTimer?.cancel()
        let w = DispatchWorkItem {
            minSplashDone = true
            tryProceed()
        }
        minTimer = w
        DispatchQueue.main.asyncAfter(deadline: .now() + minSplash, execute: w)
    }

    private func startAuthPolling() {
        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                let hasResponded = (settings.authorizationStatus != .notDetermined)
                DispatchQueue.main.async {
                    if self.responded != hasResponded {
                        self.responded = hasResponded
                        self.tryProceed()
                    } else {
                        self.tryProceed()
                    }
                }
            }
        }
        RunLoop.main.add(pollTimer!, forMode: .common)
    }

    private func tryProceed() {
        guard !fired else { return }

        if isSimulator {
            guard minSplashDone else { return }
            goNext(after: 0)
            return
        }

        if responded && minSplashDone {
            goNext(after: postConsentDelay)
        }
    }

    private func goNext(after delay: TimeInterval) {
        fired = true
        pollTimer?.invalidate()
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if !stringURL.isEmpty {
                AppDelegate.lock([.portrait, .landscapeLeft, .landscapeRight])
                showPrivacy = true
            } else if firstOpenApp {
                AppDelegate.lock([.portrait, .landscapeLeft, .landscapeRight])
                showPrivacy = true
            } else {
                AppDelegate.lock([.landscapeLeft, .landscapeRight])
                showHome = true
            }
        }
    }

    private func startProgressAnimation() {
        progress = 0.01
        withAnimation(.linear(duration: 3.0)) {
            progress = 1.0
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
            
            HStack {
                Text("LOADING...")
                    .foregroundStyle(.yellow2)
                    .font(.system(size: 16, weight: .bold, design: .default))
                
                Text("\(Int(progress * 100))%")
                    .foregroundStyle(.yellow2)
                    .font(.system(size: 16, weight: .bold, design: .default))
            }
            .padding(.horizontal, 12)
        }
        .frame(width: 280)
    }
}

#Preview {
    CFLaunchView()
}
