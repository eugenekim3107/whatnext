import SwiftUI

struct FoodAndDrinksView: View {
    @StateObject private var viewModel = PreferenceViewModel(allTags: ["Korean Food","Chinese Food","Japanese Food","Italian Food","Mexican Food","Burgers","Tacos","Hot Pot","Sushi"])
    let tagIconLinks: [String: String] = [
        "Chinese Food": "🍜",
        "Korean Food": "🍱",
        "Italian Food": "🍕",
        "Japanese Food": "🍣",
        "Burgers": "🍔",
        "Mexican Food": "🥙",
        "Hot Pot":"🫕",
        "Sushi":"🍣",
        "Tacos":"🌮"
    ]
    @State private var isSaveButtonDisabled = false
    var body: some View {
        
        VStack {
            SplitProgressBarView(leftProgress: 0, rightProgress: 1)
                                .frame(height: 4)
                                .padding(.vertical)
            

//            HStack {
//                Button(action: {}) {
//                    Image(systemName: "arrow.left")
//                        .foregroundColor(.black)
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(10)
//                        .shadow(radius: 1)
//                }
//                Spacer()
//                Button(action: {}) {
//Image(systemName: "arrow.right")
//                        .foregroundColor(.black)
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(10)
//                        .shadow(radius: 1)
//                }
//
//
//            }.padding(.horizontal,30)
            let columns = [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ]
            ZStack() {
              Text("Food & Drinks")
                .font(Font.custom("Inter", size: 34).weight(.semibold))
//                .lineSpacing(51)
                .foregroundColor(.black)
                .offset(x:0, y: -10)
              Text("Let us know your preferences.")
                .font(Font.custom("Inter", size: 13))
                .lineSpacing(19.50)
                .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.70))
                .offset(x: -20, y: 25.50)
            }
            .frame(width: 295, height: 71)
            .padding(.leading,-80)
            .padding(.bottom,30)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Array(viewModel.FDtags.enumerated()), id: \.element.0) { index, tag in
                        TagView(text: tag.0, isSelected: tag.1,icon:tagIconLinks[tag.0] ?? "")
                            .onTapGesture {
                                // Implement tag selection toggle logic here
                                viewModel.toggleFDTagSelection(tag.0)
                            }
                    }
                }
                .padding(.horizontal)
            }
            
            Button(action: saveButtonAction) {
                 Text("Save")
                     .foregroundColor(isSaveButtonDisabled ? .gray : .white) // Change text color based on button state
                     .frame(width: 295, height: 56)
                     .background(isSaveButtonDisabled ? Color.gray : Color.blue) // Change background color based on button state
                     .cornerRadius(15)
             }
            .disabled(isSaveButtonDisabled)
            .padding(.bottom,50)
        }
        .padding(.horizontal)
    }
    private func saveButtonAction() {
            isSaveButtonDisabled = true // Disable the button
            
            // Re-enable the button after 0.3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isSaveButtonDisabled = false
            }
            
            // Your save action logic here
        
        }
}


struct FoodAndDrinksView_Previews: PreviewProvider {
    static var previews: some View {
        FoodAndDrinksView()
    }
}
