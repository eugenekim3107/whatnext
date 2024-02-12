import SwiftUI

struct SearchView: View {
    @State private var chatText = ""
    @State private var chatType = ""
    @State private var messages: [String] = []
    
    var body: some View {
        NavigationView{
            messagesView
                .navigationTitle("Search")
        }
    }
    
    private var messagesView: some View {
        VStack {
            ScrollView {
                VStack (spacing: 3) {
                    ForEach(messages, id: \.self) { message in
                        HStack {
                            Spacer()
                            Text(message)
                                .foregroundColor(.white)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(30)
                        }
                        .padding(.horizontal)
                    }
                    HStack { Spacer() }
                }
            }
            .background(Color(.init(white: 0.95, alpha: 1)))
            .safeAreaInset(edge: .bottom) {
                chatBottomBar
                    .background(Color(
                        .systemBackground)
                        .ignoresSafeArea())
            }
        }
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            ZStack (alignment: .bottom) {
                
                HStack() {
                    ZStack () {
                        TextField("Type your message here...", text:$chatText)
                            .padding(.leading, 5)
                            .padding(.bottom, 3)
                        TextEditor(text: $chatText)
                            .opacity(chatText.isEmpty ? 0.5:1)
                    }
                    .frame(height:40)
                    if !chatText.isEmpty {
                        Button(action: {
                            sendMessage()
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                                .foregroundColor(.blue)
                        }
                        .transition(.scale)
                    }
                }
                .padding(.horizontal, 5)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray)
                    .frame(height: 40)
            }
            .frame(width: 370, height: 40)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .padding(.bottom, 50)
    }
    
    private func sendMessage() {
//        let _: Double = 0.0
//        let longitude: Double = 0.0
//        let userId: String = "1234"
//        let sessionId: String? = nil
        let message: String = chatText
        
        self.messages.append(message)
        self.chatText = ""
        
//        ChatService.shared.postMessage(latitude: latitude, longitude: longitude, userId: userId, sessionId: sessionId, message: message) { response, error in
//            if let chatResponse = response {
//                // Handle the chat response
//                DispatchQueue.main.async {
//                    // Append the response content to messages array to display it
//                    self.messages.append(chatResponse.content)
//                    self.chatText = "" // Reset chatText after sending
//                }
//            } else if let error = error {
//                print("Error sending message: \(error.localizedDescription)")
//            }
//        }
    }
}
//        NavigationView {
//            VStack {
//                Spacer()
//                Image("logo-icon")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 100, height: 100)
//                Text("Let's find your next favorite spot!")
//                    .font(.headline)
//                Text("What are you in the mood for?")
//                    .font(.headline)
//                Image("openai-icon")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 120, height: 120, alignment: .top)
//                Spacer(minLength: 200)
//            }
//
//        }
//    }

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
