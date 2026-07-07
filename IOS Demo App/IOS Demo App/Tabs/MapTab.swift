import SwiftUI
import MapKit

struct MapTab: View {
    @EnvironmentObject private var sessionStore: SessionStore

    @State private var selectedSession: GameSession?
    @State private var cameraPosition: MapCameraPosition = .automatic

    private var sessionsWithLocation: [GameSession] {
        sessionStore.sessions.filter { $0.coordinate != nil }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if sessionsWithLocation.isEmpty {
                    GameBackground(accent: GameTheme.neonGreen, intensity: 0.2)
                    emptyState
                } else {
                    Map(position: $cameraPosition, selection: $selectedSession) {
                        ForEach(sessionsWithLocation) { session in
                            if let coordinate = session.coordinate {
                                Marker(
                                    "\(session.mode.displayName): \(session.score)",
                                    coordinate: coordinate
                                )
                                .tint(colorForMode(session.mode))
                                .tag(session)
                            }
                        }
                    }
                    .mapStyle(.standard(elevation: .realistic))
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear(perform: fitMapToSessions)
            .onChange(of: sessionStore.sessions.count) { _, _ in
                fitMapToSessions()
            }
            .sheet(item: $selectedSession) { session in
                sessionDetail(session)
                    .presentationDetents([.height(220)])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "map.fill")
                .font(.system(size: 56))
                .foregroundStyle(GameTheme.neonGreen)

            Text("NO PINS YET")
                .font(.title3.weight(.black))
                .tracking(1.5)
                .foregroundStyle(.white)

            Text("Complete a game with location enabled to see pins on the map.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private func sessionDetail(_ session: GameSession) -> some View {
        VStack(spacing: 16) {
            Text(session.mode.displayName)
                .font(.title2.weight(.black))
                .foregroundStyle(.white)

            Text("Score: \(session.score)")
                .font(.title.weight(.bold))
                .foregroundStyle(GameTheme.neonGold)

            Text(session.timestamp, format: .dateTime.day().month().year().hour().minute())
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))

            if let lat = session.latitude, let lon = session.longitude {
                Text(String(format: "%.4f, %.4f", lat, lon))
                    .font(.caption.monospaced())
                    .foregroundStyle(.white.opacity(0.45))
            }

            ShareLink(item: session.shareText) {
                Label("Share Score", systemImage: "square.and.arrow.up")
                    .font(.headline)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(GameBackground(accent: colorForMode(session.mode), intensity: 0.3))
    }

    private func fitMapToSessions() {
        let coordinates = sessionsWithLocation.compactMap(\.coordinate)
        guard !coordinates.isEmpty else { return }

        if coordinates.count == 1, let coordinate = coordinates.first {
            cameraPosition = .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
            return
        }

        var minLat = coordinates[0].latitude
        var maxLat = coordinates[0].latitude
        var minLon = coordinates[0].longitude
        var maxLon = coordinates[0].longitude

        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.05, (maxLat - minLat) * 1.4),
            longitudeDelta: max(0.05, (maxLon - minLon) * 1.4)
        )
        cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
    }

    private func colorForMode(_ mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return GameTheme.neonCyan
        case .lightItUp: return GameTheme.neonOrange
        case .quizRush: return GameTheme.neonPurple
        }
    }
}

#if DEBUG
#Preview {
    MapTab()
        .environmentObject(SessionStore())
        .preferredColorScheme(.dark)
}
#endif
