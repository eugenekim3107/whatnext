import SwiftUI

enum NavigationDestination {
    case foodAndDrinks
}

struct ActivityView: View {
    @StateObject private var viewModel = PreferenceViewModel(allTags: ["Shopping", "Yoga", "Beaches", "Hiking","Spa","Aquariums","Beautysvc"])
//    @State private var isNavigatingToFoodAndDrinks = false
    @State private var navigationPath = NavigationPath()
    @State private var isSaveButtonDisabled = false
    let tagIconLinks: [String: String] = [
        "Shopping": "🍜",
        "Spa": "💆‍♂️",
        "Hiking": "⛰️",
        "Beaches": "🏖️",
        "Restaurant":"🍴",
        "Yoga":"🧘",
        "Aquariums":"🐠",
        "Beautysvc":"💅",
    ]
    
    //Shopping to be shopping
    //Spa to be spas
    //Hiking to be hiking
    //Restaurant to be restaurant
    //Yoga to be yoga
    //Beaches to be beaches
    //Beautysvc to be beautysvc
    //Aquariums to be aquariums
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                SplitProgressBarView(leftProgress: 1, rightProgress: 0)
                    .frame(height: 4)
                    .padding(.vertical)
                
                HStack {
                    Spacer()
                    Button(action: {
                        let destination: NavigationDestination = .foodAndDrinks
                        navigationPath.append(destination)
                    }) {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 1)
                    }
                }
                .padding(.horizontal,30)
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
                            TagView(text: tag.0, isSelected: tag.1,icon:tagIconLinks[tag.0] ?? "")
                                .onTapGesture {
                                    viewModel.toggleACTagSelection(tag.0)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                Button(action: saveButtonAction) {
                    Text("Save")
                        .foregroundColor(isSaveButtonDisabled ? .gray : .white)
                        .frame(width: 295, height: 56)
                        .background(isSaveButtonDisabled ? Color.gray : Color.blue)
                        .cornerRadius(15)
                }
                .disabled(isSaveButtonDisabled)
                .padding(.bottom,50)
            }
            .padding(.horizontal)
            .navigationDestination(for: NavigationDestination.self) { destination in switch destination {
            case .foodAndDrinks:
                FoodAndDrinksView()
            }
            }
        }
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

