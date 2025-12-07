import SwiftUI

struct DashboardBackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.4, green: 0.3, blue: 0.2), // Lighter brown
                Color(red: 0.2, green: 0.15, blue: 0.1)  // Darker brown
            ]),
            startPoint: .top,
            endPoint: .center
        )
        .edgesIgnoringSafeArea(.all)
    }
}

struct DashboardBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardBackgroundView()
    }
}
