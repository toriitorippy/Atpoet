//
//  LoginView.swift
//  geosy
//
//  Created by 鳥居克哉 on 2021/09/01.
//

import SwiftUI
import GoogleSignIn
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var userData: UserData
    var body: some View {
        ZStack() {
            Color(UIColor(named: "LightBrown")!)
                .edgesIgnoringSafeArea(.all)
            Image(uiImage: UIImage(named:"top")!)
                .edgesIgnoringSafeArea(.all)
            VStack{
                Spacer()
                if userData.isfetched == true {
                    SignInWithAppleToFirebase({ response in
                        if response == .success {
                            print("logged into Firebase through Apple!")
                            userData.isfetched = false
                            userData.fetchMyUserData()
                        } else if response == .error {
                            print("error. Maybe the user cancelled or there's no internet")
                        }
                    })
                    .frame(width: 170, height: 60.0).cornerRadius(30)
                    
                    Button(action: {
                        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {return}
                        GIDSignIn.sharedInstance.signIn(
                            with: self.userData.signInConfig!,
                            presenting: presentingViewController,
                            callback: { user, error in
                                if let error = error {
                                    print("error: \(error.localizedDescription)")
                                }
                                else if let user = user {
                                    userData.isfetched = false
                                    self.userData.signIn(user: user)
                                }
                            })
                    } ) {
                        Text("Googleでログイン")
                            .foregroundColor(Color.white)
                            .padding()
                            .background(Color(UIColor(named: "DarkBrown")!))
                            .cornerRadius(100)
                    }.frame(width: 180, height: 100, alignment: .center)
                    
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
