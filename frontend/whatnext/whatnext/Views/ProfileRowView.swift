import SwiftUI

struct ProfileRowView: View {
    var title: String
    var titleIconName: String
    var titleIconColor: Color
    var items: [ProfileItem] // Assuming ProfileItem is defined elsewhere
    var isCircle: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 5) {
                Image(systemName: titleIconName)
                    .foregroundColor(titleIconColor)
                    .imageScale(.small)
                Text(title)
                    .font(.title2)
            }
            .padding(.leading, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(items) { item in
                        AsyncImage(url: item.imageURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                if isCircle {
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                } else {
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 2))
                                }
                            case .failure(_):
                                Image(systemName: "exclamationmark.circle").resizable().scaledToFill()
                                    .frame(width: 80, height: 80)
                                    // RoundedRectangle with zero corner radius equals a rectangle
                                    .clipShape(RoundedRectangle(cornerRadius: 0))
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .padding(.vertical)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// Preview Provider
struct ProfileRowView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileRowView(
            title: "Example Title",
            titleIconName: "star.fill",
            titleIconColor: .yellow,
            items: [
                ProfileItem(imageURL: URL(string: "https://s3-media1.fl.yelpcdn.com/bphoto/vxSx2j9gnJ-dWu9OFYyhRQ/o.jpg")!),
                ProfileItem(imageURL: URL(string: "https://s3-media1.fl.yelpcdn.com/bphoto/6Z_nkxlxwN5KjSI4o-T1uA/o.jpg")!),
                ProfileItem(imageURL: URL(string: "https://s3-media3.fl.yelpcdn.com/bphoto/GH7ulQACJUkL-GKjke_YgA/o.jpg")!),
                ProfileItem(imageURL: URL(string: "https://s3-media4.fl.yelpcdn.com/bphoto/UTRNj5MtbuC7SC0Owso-bw/o.jpg")!),
                
            ],
            isCircle: true // Set this to false to see rectangles instead
        )
    }
}
