import SwiftUI
import Firebase
import GoogleSignIn

struct MoreView: View {
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("userID") var storedUserID: String = ""
    @State private var showingLogoutAlert = false
    

    var settings: [SettingsSection] = [
        .init(name: "Notifications", imageName: "bell.circle", color: .black),
        .init(name: "Location", imageName: "location.circle", color: .black),
        .init(name: "Privacy", imageName: "hand.raised.circle", color: .black),
        .init(name: "Preferences", imageName: "person.crop.circle", color: .black),
        .init(name: "Logout", imageName: "arrow.right.circle", color: .black)
    ]
    
    var feedbacks: [FeedbackSection] = [
        .init(name: "Overall Experience", imageName: "hand.thumbsup.circle", color: .black),
        .init(name: "Recommendation Accuracy", imageName: "target", color: .black),
        .init(name: "Suggestions", imageName: "lightbulb.circle", color: .black)
    ]
    
    var terms: [TermsAndConditionsSection] = [
        .init(name: "Acceptance of Terms", imageName: "doc.circle", color: .black),
        .init(name: "Privacy Policy", imageName: "lock.circle", color: .black),
        .init(name: "User Conduct", imageName: "figure.walk.circle", color: .black)
    ]
    
    var body: some View {
        NavigationStack {
            List {
                Section("Settings") {
                    ForEach(settings, id: \.name) { setting in
                        if setting.name == "Logout" {
                            Button(action: {
                                showingLogoutAlert = true
                            }) {
                                Label(setting.name, systemImage: setting.imageName)
                                    .foregroundColor(setting.color)
                            }
                            .alert(isPresented: $showingLogoutAlert) {
                                Alert(
                                    title: Text("Confirm Logout"),
                                    message: Text("Are you sure you want to log out?"),
                                    primaryButton: .destructive(Text("Logout")) {
                                        logout()
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                        } else if setting.name == "Preferences" {
                            NavigationLink(destination: ActivityView()) {
                                Label(setting.name, systemImage: setting.imageName)
                                    .foregroundColor(setting.color)
                            }
                        }
                        else {
                            NavigationLink(value: setting) {
                                Label(setting.name, systemImage: setting.imageName)
                                    .foregroundColor(setting.color)
                            }
                        }
                    }
                }
                .foregroundColor(Color.black)
                
                Section("Feedback") {
                    ForEach(feedbacks, id: \.name) { feedback in
                        NavigationLink(value: feedback) {
                            Label(feedback.name, systemImage: feedback.imageName)
                                .foregroundColor(feedback.color)
                                .id(feedback.name)
                        }
                    }
                }.foregroundColor(Color.black)
                
                Section("Terms And Conditions") {
                    ForEach(terms, id: \.name) { term in
                        NavigationLink(value: term) {
                            Label(term.name, systemImage: term.imageName)
                                .foregroundColor(term.color)
                                .id(term.name)
                        }
                    }
                }.foregroundColor(Color.black)
                
                Spacer().listRowBackground(Color.clear)
            }
            .navigationTitle("More")
            .navigationDestination(for: SettingsSection.self) { setting in
                    ZStack {
                        Color.white.ignoresSafeArea()
                        Label(setting.name, systemImage: setting.imageName)
                            .font(.largeTitle).bold()
                    }
                }
                .navigationDestination(for: FeedbackSection.self) { feedback in
                    ZStack {
                        Color.white.ignoresSafeArea()
                        Label(feedback.name, systemImage: feedback.imageName)
                            .font(.largeTitle).bold()
                    }
                }
                .navigationDestination(for: TermsAndConditionsSection.self) { term in
                    ZStack {
                        Color.white.ignoresSafeArea()
                        Label(term.name, systemImage: term.imageName)
                            .font(.largeTitle).bold()
                    }
                }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            withAnimation(.easeInOut) {
                logStatus = false
                storedUserID = ""
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
    }
}

struct SettingsSection: Hashable {
    let name: String
    let imageName: String
    let color: Color
}

struct FeedbackSection: Hashable {
    let name: String
    let imageName: String
    let color: Color
}

struct TermsAndConditionsSection: Hashable {
    let name: String
    let imageName: String
    let color: Color
}
