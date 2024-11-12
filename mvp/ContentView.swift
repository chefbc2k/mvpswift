import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            MarketplaceView()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Marketplace")
                }
                .tag(1)
            
            RecordingView()
                .tabItem {
                    Image(systemName: "mic.circle.fill")
                    Text("Record")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.indigo)
    }
}

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Banner
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome to Speak")
                            .font(.largeTitle)
                            .bold()
                        Text("Monetize your voice, preserve your legacy")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    // Quick Actions
                    HStack(spacing: 20) {
                        QuickActionButton(
                            icon: "mic.fill",
                            title: "Record",
                            color: .blue
                        )
                        QuickActionButton(
                            icon: "dollarsign.circle.fill",
                            title: "Earnings",
                            color: .green
                        )
                        QuickActionButton(
                            icon: "lock.fill",
                            title: "Privacy",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // Featured Opportunities
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Featured Opportunities")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(0..<5) { _ in
                                    OpportunityCard()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Activity")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(0..<3) { _ in
                            ActivityCard()
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Speak")
        }
    }
}

struct MarketplaceView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search opportunities...", text: $searchText)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Categories
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(["All", "Voiceover", "Narration", "Podcast", "Gaming"], id: \.self) { category in
                                Text(category)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Marketplace Items
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        ForEach(0..<6) { _ in
                            MarketplaceItemCard()
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Marketplace")
        }
    }
}

struct RecordingView: View {
    @State private var isRecording = false
    @State private var recordingTime: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Recording Visualization
            Circle()
                .fill(isRecording ? Color.red : Color.blue)
                .frame(width: 200, height: 200)
                .overlay(
                    VStack {
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        if isRecording {
                            Text(String(format: "%.1f s", recordingTime))
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                    }
                )
                .onTapGesture {
                    toggleRecording()
                }
            
            // Recording Controls
            HStack(spacing: 40) {
                ControlButton(icon: "arrow.counterclockwise", action: resetRecording)
                ControlButton(icon: isRecording ? "stop.fill" : "mic.fill", action: toggleRecording)
                ControlButton(icon: "square.and.arrow.up", action: shareRecording)
            }
            
            Spacer()
            
            // Privacy Notice
            Text("Your voice is secured with end-to-end encryption")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom)
        }
        .padding()
    }
    
    private func toggleRecording() {
        isRecording.toggle()
        if isRecording {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingTime += 0.1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func resetRecording() {
        stopTimer()
        isRecording = false
        recordingTime = 0
    }
    
    private func shareRecording() {
        // Implement sharing functionality
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("Your Name")
                            .font(.title)
                            .bold()
                        
                        Text("Voice Artist")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    // Stats
                    HStack(spacing: 30) {
                        StatView(value: "47", title: "Recordings")
                        StatView(value: "$1,234", title: "Earnings")
                        StatView(value: "4.8", title: "Rating")
                    }
                    
                    // Menu Items
                    VStack(spacing: 5) {
                        MenuLink(icon: "gear", title: "Settings")
                        MenuLink(icon: "lock.shield", title: "Privacy")
                        MenuLink(icon: "creditcard", title: "Payments")
                        MenuLink(icon: "bell", title: "Notifications")
                        MenuLink(icon: "questionmark.circle", title: "Help")
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
        }
    }
}

// Supporting Views
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct OpportunityCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Audiobook Narration")
                .font(.headline)
            Text("$500-1000")
                .foregroundColor(.green)
            Text("Fiction • 5-7 hours")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 200)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct ActivityCard: View {
    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "mic.fill")
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading) {
                Text("New Recording")
                    .font(.headline)
                Text("2 minutes ago")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct MarketplaceItemCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            Rectangle()
                .fill(Color.blue.opacity(0.1))
                .frame(height: 100)
                .overlay(
                    Image(systemName: "mic.fill")
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Voice Project")
                    .font(.headline)
                Text("$200-400")
                    .foregroundColor(.green)
                Text("2-3 hours")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct ControlButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.blue)
                .clipShape(Circle())
        }
    }
}

struct StatView: View {
    let value: String
    let title: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct MenuLink: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

#Preview {
    ContentView()
}
