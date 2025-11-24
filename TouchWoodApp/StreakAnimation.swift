import SwiftUI

struct StreakAnimationView: View {
    let currentStreak: Int
    let previousStreak: Int
    @State private var showConfetti = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var fireworkOffset: CGFloat = 0
    
    var isMilestone: Bool {
        currentStreak > previousStreak && (currentStreak % 7 == 0 || currentStreak % 30 == 0 || currentStreak % 100 == 0)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Main streak display
                VStack(spacing: 8) {
                    Text("\(currentStreak)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .scaleEffect(pulseScale)
                        .animation(.easeInOut(duration: 0.6), value: pulseScale)
                    
                    Text(currentStreak == 1 ? "Day Streak" : "Day Streak")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                // Confetti overlay for milestones
                if showConfetti {
                    ConfettiView()
                        .allowsHitTesting(false)
                }
            }
            
            // Milestone message
            if isMilestone {
                Text(milestoneMessage)
                    .font(.headline)
                    .foregroundColor(.orange)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(20)
                    .scaleEffect(showConfetti ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showConfetti)
            }
        }
        .onChange(of: currentStreak) { newValue in
            if newValue > previousStreak {
                triggerStreakAnimation()
            }
        }
    }
    
    private var milestoneMessage: String {
        switch currentStreak {
        case 7: return "🔥 One Week Strong!"
        case 14: return "💪 Two Weeks!"
        case 30: return "🎉 One Month!"
        case 60: return "🌟 Two Months!"
        case 90: return "🏆 Three Months!"
        case 100: return "💯 Century!"
        case 365: return "🎊 One Year!"
        default:
            if currentStreak % 7 == 0 {
                return "🔥 \(currentStreak / 7) Week\(currentStreak / 7 > 1 ? "s" : "")!"
            } else if currentStreak % 30 == 0 {
                return "🎉 \(currentStreak / 30) Month\(currentStreak / 30 > 1 ? "s" : "")!"
            }
            return ""
        }
    }
    
    private func triggerStreakAnimation() {
        // Pulse animation
        withAnimation(.easeInOut(duration: 0.3).repeatCount(2, autoreverses: true)) {
            pulseScale = 1.2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            pulseScale = 1.0
        }
        
        // Confetti for milestones
        if isMilestone {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                showConfetti = false
            }
        }
    }
}

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
            }
        }
        .onAppear {
            generateConfetti()
        }
    }
    
    private func generateConfetti() {
        let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]
        
        particles = (0..<50).map { i in
            let angle = Double(i) * (360.0 / 50.0) * (.pi / 180.0)
            let distance = Double.random(in: 50...200)
            
            return ConfettiParticle(
                id: i,
                x: cos(angle) * distance,
                y: sin(angle) * distance - 100,
                color: colors.randomElement() ?? .blue,
                size: Double.random(in: 4...12),
                opacity: 1.0,
                scale: 1.0
            )
        }
        
        // Animate particles
        withAnimation(.easeOut(duration: 2.0)) {
            for i in particles.indices {
                particles[i].y += 300
                particles[i].opacity = 0.0
                particles[i].scale = 0.3
            }
        }
    }
}

struct ConfettiParticle {
    let id: Int
    var x: CGFloat
    var y: CGFloat
    let color: Color
    let size: CGFloat
    var opacity: Double
    var scale: CGFloat
}

// Streak Badge Component
struct StreakBadge: View {
    let streak: Int
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundColor(.orange)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
            
            Text("\(streak)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(4)
                .background(Color.orange)
                .clipShape(Circle())
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// Streak Progress Ring
struct StreakProgressRing: View {
    let current: Int
    let goal: Int
    
    var progress: Double {
        min(Double(current) / Double(goal), 1.0)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                .frame(width: 120, height: 120)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            VStack {
                Text("\(current)")
                    .font(.title)
                    .fontWeight(.bold)
                Text("/ \(goal)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
