import SwiftUI

struct HomeScreenView: View {
    @AppStorage("tapFrenzyHighScore") private var tapFrenzyHighScore = 0
    @AppStorage("lightItUpHighScore") private var lightItUpHighScore = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // MARK: Title
                    VStack(spacing: 8) {
                        Text("Game Hub")
                            .font(.system(size: 48, weight: .bold))
                        Text("Choose your game")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // MARK: Tap Frenzy Button
                    NavigationLink {
                        TapFrenzyView()
                    } label: {
                        VStack(spacing: 16) {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.white)
                            
                            VStack(spacing: 4) {
                                Text("Tap Frenzy")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                
                                Text("Tap as fast as you can!")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.8))
                                
                                if tapFrenzyHighScore > 0 {
                                    Text("Best: \(tapFrenzyHighScore)")
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue.gradient)
                        )
                    }
                    
                    // MARK: Light It Up Button
                    NavigationLink {
                        LightItUpView()
                    } label: {
                        VStack(spacing: 16) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.white)
                            
                            VStack(spacing: 4) {
                                Text("Light It Up")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                
                                Text("Tap the lit cards!")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.8))
                                
                                if lightItUpHighScore > 0 {
                                    Text("Best: \(lightItUpHighScore)")
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.orange.gradient)
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
}

#Preview {
    HomeScreenView()
}
