import SwiftUI

//Created by Wenzhou Lyu
struct ProfileRowView: View {
    var title: String
    var titleIconName: String 
    var titleIconColor: Color
    var iconName: String
    var itemCount: Int
    var isCircle: Bool
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 5) { // Adjust spacing between the icon and the text as needed
                Image(systemName: titleIconName)
                    .foregroundColor(titleIconColor) // Use the titleIconColor here
                    .imageScale(.small) // Adjust the size of the icon
                Text(title)
                    .font(.title2)
            }
            .padding(.leading, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(0..<itemCount, id: \.self) { _ in
                        Group {
                            if isCircle {
                                Image(systemName: iconName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            } else {
                                Image(systemName: iconName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    // RoundedRectangle with zero corner radius equals a rectangle
                                    .clipShape(RoundedRectangle(cornerRadius: 0))
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




struct ProfileRowView_Previews: PreviewProvider {
    static var previews: some View {
        // Example usage with a system icon
        ProfileRowView(title: "Friends", titleIconName: "person.2.fill", titleIconColor: .blue, iconName: "person.crop.circle.fill", itemCount: 10, isCircle: true)
    }
}

