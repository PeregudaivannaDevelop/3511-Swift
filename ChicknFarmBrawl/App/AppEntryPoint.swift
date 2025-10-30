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
                AppDelegate.lock([.portrait, .landscapeLeft, .landscapeRight])
                selectedRoute = .privacy
            } else {
                AppDelegate.lock([.portrait], rotateTo: .portrait)
                selectedRoute = .launch
            }
        }
    }
}
