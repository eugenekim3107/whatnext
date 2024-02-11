import SwiftUI



//Created by Wenzhou Lyu
struct SearchView: View {
    @State private var searchText = ""

    var body: some View {
        TabView {
            NavigationView {
                VStack {
                    Spacer()
                    Image("logo-icon") // Replace with your logo image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    
                    Text("Let's find your next favorite spot!")
                        .font(.headline)
                    Text("What are you in the mood for?")
                        .font(.headline)
                    Image("openai-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120,alignment:.top)
                    Spacer(minLength:270)
                    TextField("Type your message here...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 50)
                    Spacer()
                }
            }

            // Add other tabs here...
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

