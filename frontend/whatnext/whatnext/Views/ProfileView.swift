
//Created By Wenzhou Lyu
import SwiftUI

struct ProfileView: View {
    // Example data
    private let friendsCount = 10
    private let favoritesCount = 5
    private let visitedCount = 8
    
    let exampleFriends = [
        ProfileItem(imageURL: URL(string: "https://res.cloudinary.com/dzkbufuj8/image/upload/v1708296008/erksybjgjykioifl6wgg.png")!),
        ProfileItem(imageURL: URL(string: "https://res.cloudinary.com/dzkbufuj8/image/upload/v1708296088/l71jxbqjpbxarla0unif.png")!),
        ProfileItem(imageURL: URL(string: "https://res.cloudinary.com/dzkbufuj8/image/upload/v1708296088/myntzdloywgjd3wo732k.png")!),
        ProfileItem(imageURL: URL(string: "https://res.cloudinary.com/dzkbufuj8/image/upload/v1708296088/xvegc8ebnzbnelk5gawk.png")!),
        // Add more as needed
    ]

    let exampleFavorites = [
        ProfileItem(imageURL: URL(string: "https://s3-media1.fl.yelpcdn.com/bphoto/vxSx2j9gnJ-dWu9OFYyhRQ/o.jpg")!),
        ProfileItem(imageURL: URL(string: "https://s3-media1.fl.yelpcdn.com/bphoto/6Z_nkxlxwN5KjSI4o-T1uA/o.jpg")!),
        ProfileItem(imageURL: URL(string: "https://s3-media3.fl.yelpcdn.com/bphoto/GH7ulQACJUkL-GKjke_YgA/o.jpg")!),
        ProfileItem(imageURL: URL(string: "https://s3-media4.fl.yelpcdn.com/bphoto/UTRNj5MtbuC7SC0Owso-bw/o.jpg")!),
        // Add more as needed
    ]

    let exampleVisited = [
        ProfileItem(imageURL: URL(string: "https://s3-media2.fl.yelpcdn.com/bphoto/svRxHx6tJR7I1bUTqp29BA/o.jpg")!),
        ProfileItem(imageURL: URL(string: "https://s3-media3.fl.yelpcdn.com/bphoto/6EAS55xRwHUf3O777LRgEw/o.jpg")!),
        ProfileItem(imageURL: URL(string: "https://s3-media4.fl.yelpcdn.com/bphoto/4XSt4Fq0DKwJqnoMeQ1_Wg/o.jpg")!),
        ProfileItem(imageURL: URL(string: "https://s3-media1.fl.yelpcdn.com/bphoto/mcCbBCwiQxfTgE3Yczlt2g/o.jpg")!)
        // Add more as needed
    ]

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
                .padding(.vertical, 35)

                // Friends row
                ProfileRowView(title: "Friends", titleIconName: "person.2.fill", titleIconColor: .purple, items: exampleFriends, isCircle: true)
                    .padding(.bottom,35)

                ProfileRowView(title: "Favorites", titleIconName: "star.fill", titleIconColor: .red, items: exampleFavorites, isCircle: false)
                    .padding(.bottom,35)

                ProfileRowView(title: "Visited", titleIconName: "mappin.and.ellipse", titleIconColor: .green, items: exampleVisited, isCircle: false)
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

struct ProfileItem: Identifiable {
    let id = UUID() // Automatically generates a new UUID
    var imageURL: URL
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

