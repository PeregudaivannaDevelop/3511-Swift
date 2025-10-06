import SwiftUI

struct AppEntryPoint: View {
    @AppStorage("stringURL") var stringURL = ""
    @AppStorage("firstOpenApp") var firstOpenApp = true

    @State private var selectedRoute: Route?

    enum Route {
        case launch, privacy
    }

    var body: some View {
        ZStack {
            Group {
                switch selectedRoute {
                case .privacy:
                    PrivacyView()
                case .launch:
                    CFLaunchView()
                case .none:
                    Color.clear
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: selectedRoute)
        }
        .onAppear {
            if !stringURL.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    AppDelegate.lock([.portrait, .landscapeLeft, .landscapeRight])
                }
                selectedRoute = .privacy
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    AppDelegate.lock([.landscapeLeft, .landscapeRight])
                }
                selectedRoute = .launch
            }
        }
    }
}
