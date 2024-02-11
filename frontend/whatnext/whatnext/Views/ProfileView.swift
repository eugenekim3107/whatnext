
//Created By Wenzhou Lyu
import SwiftUI

struct ProfileView: View {
    // Example data
    private let friendsCount = 10
    private let favoritesCount = 5
    private let visitedCount = 8
    var body: some View {
        NavigationView {
            VStack {
                // Profile header
                HStack {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .padding(.trailing,0)
                    VStack(alignment: .center) {
                        Text("Eugene Kim")
                            .font(.title)
                        HStack {
                            StatView(count: friendsCount, label: "Friends", iconName: "person.2.fill", iconColor: .purple)
                            StatView(count: favoritesCount, label: "Favorites", iconName: "star.fill", iconColor: .red)
                            StatView(count: visitedCount, label: "Visited", iconName: "mappin.and.ellipse", iconColor: .green)
                        }
                        .font(.caption)
                    }
                }
                .padding(.vertical, 40)

                // Friends row
                ProfileRowView(title: "Friends", titleIconName: "person.2.fill", titleIconColor: .purple, iconName: "person.crop.circle.fill", itemCount: friendsCount, isCircle: true)
                    .padding(.bottom,40)

                ProfileRowView(title: "Favorites", titleIconName: "star.fill", titleIconColor: .red,
                               iconName: "star.fill", itemCount: favoritesCount, isCircle: false)
                    .padding(.bottom,40)

                ProfileRowView(title: "Visited", titleIconName: "mappin.and.ellipse", titleIconColor: .green,
                    iconName: "mappin.and.ellipse", itemCount: visitedCount, isCircle: false)
                    .padding(.bottom)

                Spacer()

            }
        }
    }
}


struct StatView: View {
    let count: Int
    let label: String
    let iconName: String
    let iconColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
                .foregroundColor(iconColor)
            Text("\(count) \(label)")
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

