//
//  SwiftUIView.swift
//  geosy
//
//  Created by 鳥居克哉 on 2021/07/28.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth

let testData = [
    Book(title: "The Ultimate Hitchhiker's Guide to the Galaxy: Five Novels in One Outrageous Volume", author: "Douglas Adams", numberOfPages: 815),
    Book(title: "Changer", author: "Matt Gemmell", numberOfPages: 474),
    Book(title: "Toll", author: "Matt Gemmell", numberOfPages: 474)
]

struct ExampleView: View {
    @ObservedObject var viewModel = ExampleViewModel()
    @EnvironmentObject var userData: UserData
    @State var isModalActive = false
    var body: some View {
        ZStack {
            NavigationView {
                List(viewModel.books) { book in // (2)
                    VStack(alignment: .leading) {
                        Text(book.title)
                            .font(.headline)
                        Text(book.author)
                            .font(.subheadline)
                        Text("\(book.numberOfPages) pages")
                            .font(.subheadline)
                    }
                }
                .navigationBarTitle("Books")
                .onAppear() { // (3)
                    self.viewModel.fetchData()
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .padding(EdgeInsets(
                            top: 0,
                            leading: 0,
                            bottom: 10,
                            trailing: 30
                        ))
                        .onTapGesture {
                            self.isModalActive.toggle()
                        }            }
            }
            VStack { // ログアウトテスト用
                HStack {
                    Spacer()
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .padding(EdgeInsets(
                            top: 0,
                            leading: 0,
                            bottom: 10,
                            trailing: 10
                        ))
                        .onTapGesture {
                            let firebaseAuth = Auth.auth()
                            do {
                                try firebaseAuth.signOut()
                                userData.isSignedIn = false
                            } catch let signOutError as NSError {
                                print("Error signing out: %@", signOutError)
                            }
                            
                        }            }
                Spacer()
            }
        }
        .sheet(isPresented: $isModalActive){
            ExampleModalView()
        }
    }
}

struct ExampleView_Previews: PreviewProvider {
    static var previews: some View {
        ExampleView()
    }
}
