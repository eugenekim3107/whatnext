//
//  LoginView.swift
//  SignIn
//
//  Created by Nicholas Lyu on 2/19/24.
//

import SwiftUI
import AuthenticationServices
import GoogleSignInSwift
import GoogleSignIn

struct LoginView: View {
    @StateObject var loginModel: LoginViewModel = .init()
    var body: some View {
        ScrollView(.vertical,showsIndicators: false){
            VStack(alignment:.center, spacing: 15) {
                Image("logo-1")
                    .resizable()
                    .frame(width: 50,height: 50)
                    .padding(.bottom,-20)
                //                Image(systemName: "triangle")
                //                    .font(.system(size:38))
                //                    .foregroundColor(.indigo)
                (Text("Welcome")
                    .foregroundColor(.black) +
                 Text("\nLogin to continue")
                    .foregroundColor(.gray)
                ) .multilineTextAlignment(.center)
                    .font(.title)
                    .fontWeight(.semibold)
                    .lineSpacing(/*@START_MENU_TOKEN@*/10.0/*@END_MENU_TOKEN@*/)
                    .padding(.top,20)
                
                
                CustomTextFieldView(text: $loginModel.mobileNo, hint: " 7048982448")
                    .disabled(loginModel.showOTPField)
                    .opacity(loginModel.showOTPField ? 0.4:1)
                    .overlay(alignment: .trailing, content:{
                        Button("Send Again"){
                            withAnimation(.easeInOut){
                                loginModel.showOTPField=false
                                loginModel.otpCode=""
                                loginModel.CLIENT_CODE=""
                            }
                            
                        }
                        .font(.caption)
                        .foregroundColor(.indigo)
                        .opacity(loginModel.showOTPField ? 1:0)
                        .padding(.trailing,15)
                        
                    })
                    .padding(.top,50)
                
                CustomTextFieldView(text: $loginModel.otpCode, hint: "Verification Code")
                    .disabled(!loginModel.showOTPField)
                    .opacity(!loginModel.showOTPField ? 0.4:1)
                    .padding(.top,30)
                
                Button(action:loginModel.showOTPField ? loginModel.VerifyOTPCode: loginModel.getOTPCode){
                    HStack(spacing:15){
                        Text(loginModel.showOTPField ? "Verify Code": "Get Code")
                            .fontWeight(.semibold)
                            .contentTransition(.identity)
                        
                        Image(systemName: "line.diagonal.arrow").font(.title3).rotationEffect(.init(degrees: 45))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal,25)
                    .padding(.vertical)
                    .background{
                        RoundedRectangle(cornerRadius: 10,style: .continuous).fill(.black.opacity(0.05))
                    }
                }
                .padding(.top,30)
                
                Text("OR").foregroundStyle(.gray).frame(maxWidth:.infinity)
                    .padding(.top,20)
                    .padding(.bottom,20)
                    .padding(.horizontal)
                
                
                HStack(spacing: 8){
                    CustomButton()
                        .overlay {
                            SignInWithAppleButton { (request) in
                                loginModel.nonce = randomNonceString()
                                request.requestedScopes = [.email,.fullName]
                                request.nonce = sha256(loginModel.nonce)
                                
                            } onCompletion: { (result) in
                                switch result{
                                case .success(let user):
                                    print("success")
                                    guard let credential = user.credential as? ASAuthorizationAppleIDCredential else{
                                        print("error with firebase")
                                        return
                                    }
                                    loginModel.appleAuthenticate(credential: credential)
                                case.failure(let error):
                                    print(error.localizedDescription)
                                }
                            }
                            .signInWithAppleButtonStyle(.white)
                            .frame(height: 55)
                            .blendMode(.overlay)
                        }
                        .clipped()
                    
    
                    CustomButton(isGoogle: true)
                        .overlay {

                            
                            // It's Simple to Integrate Now
                            GoogleSignInButton{
                                Task{
                                    do{
                                        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.shared.rootController())
                                        
                                        loginModel.logGoogleUser(user: result.user)
                                        
                                    }catch{
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                            .blendMode(.overlay)
                        }
                        .clipped()
                }
                
                
                

                
            }
            
            .padding(.leading,30)
            .padding(.trailing,30)
            .padding(.vertical,10)
            .alert(loginModel.ErrorMessage,isPresented: $loginModel.showError){
                
            }
            
        }
    }
        
        @ViewBuilder
        func CustomButton(isGoogle: Bool = false)->some View{
            HStack{
                Group{
                    if isGoogle{
                        Image("Google")
                            .resizable()
                            .renderingMode(.template)
                    }else{
                        Image(systemName: "applelogo")
                            .resizable()
                    }
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .frame(height: 45)
                
                Text("\(isGoogle ? "Google" : "Apple") Sign in")
                    .font(.callout)
                    .lineLimit(1)
            }
            .foregroundColor(.white)
            .padding(.horizontal,15)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.black)
            }
        }

}
        
    
struct LoginView_Previews:PreviewProvider{
        static var previews: some View{
            ContentView()
        }
}
