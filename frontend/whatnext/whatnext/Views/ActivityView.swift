import SwiftUI

struct ActivityView: View {
    @StateObject private var viewModel = PreferenceViewModel(allTags: ["Shopping", "Yoga", "Italian Food", "Swimming", "Hiking"])
    @State private var isNavigatingToFoodAndDrinks = false

    
    
    

    var body: some View {
        NavigationView{
            VStack {
                SplitProgressBarView(leftProgress: 1, rightProgress: 0)
                                    .frame(height: 4)
                                    .padding(.vertical)
                
                HStack {
//                    Button(action: {}) {
//                        Image(systemName: "arrow.left")
//                            .foregroundColor(.black)
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(10)
//                            .shadow(radius: 1)
//                    }
                    Spacer()
                    NavigationLink(destination: FoodAndDrinksView(), isActive: $isNavigatingToFoodAndDrinks) {
                        Button(action: {
                            isNavigatingToFoodAndDrinks = true
                        }) {
                            Image(systemName: "arrow.right")
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 1)
                        }
                    }
                    
                    
                }.padding(.horizontal,30)
                let columns = [
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8)
                ]
                ZStack() {
                    Text("Activities")
                        .font(Font.custom("Inter", size: 34).weight(.semibold))
                    //                .lineSpacing(51)
                        .foregroundColor(.black)
                        .offset(x: -40, y: -10)
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
                        ForEach(Array(viewModel.ACtags.enumerated()), id: \.element.0) { index, tag in
                            TagView(text: tag.0, isSelected: tag.1,icon:"")
                                .onTapGesture {
                                    // Implement tag selection toggle logic here
                                    viewModel.toggleACTagSelection(tag.0)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                Button(action: {}) {
                    Text("Save")
                        .foregroundColor(.white)
                        .frame(width: 295, height: 56)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .padding(.bottom,50)
            }
            .padding(.horizontal)
        }
    }
}


struct ProgressBar: View {
    var step: Double
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: 10)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))
                
                Rectangle().frame(width: geometry.size.width * step, height: 10)
                    .foregroundColor(Color(UIColor.systemBlue))
                    .animation(.linear, value: 0.5)
            }
            .cornerRadius(45.0)
        }
    }
}




extension PreferenceViewModel {
    // Toggles the selection of a tag and updates the stored tags accordingly
    func toggleACTagSelection(_ tag: String) {
        if let index = storedACTags.firstIndex(of: tag) {
            storedACTags.remove(at: index)
        } else {
            storedACTags.append(tag)
        }
        updateACTagsForStoredTags()
    }
    func toggleFDTagSelection(_ tag: String) {
        if let index = storedFDTags.firstIndex(of: tag) {
            storedFDTags.remove(at: index)
        } else {
            storedFDTags.append(tag)
        }
        updateFDTagsForStoredTags()
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}

