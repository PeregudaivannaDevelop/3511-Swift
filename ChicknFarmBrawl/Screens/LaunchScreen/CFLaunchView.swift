import SwiftUI

struct CFLaunchView: View {
    
    @State private var progress: CGFloat = 0.0
    @State private var isActive = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                loader
                
                NavigationLink(
                    destination: CFHomeWebView(),
                    isActive: $isActive
                ) {
                    EmptyView()
                }
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
            .onAppear {
                progress = 0
                Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
                    if progress < 1 {
                        progress += 0.01
                    } else {
                        timer.invalidate()
                        isActive = true
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .hideNavigationBar()
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
