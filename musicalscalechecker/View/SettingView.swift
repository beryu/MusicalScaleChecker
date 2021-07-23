//
//  SettingView.swift
//  musicalscalechecker
//
//  Created by 松中誉生 on 2020/11/25.
//

import SwiftUI
import GoogleMobileAds

struct SettingView: View {
    @Binding var userData: UserDataModel
    
    @Binding var navBarHidden:Bool
    
    init(userData: Binding<UserDataModel>, navBarHidden: Binding<Bool>){
        self._userData = userData
        self._navBarHidden = navBarHidden
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
        //UINavigationBar.appearance().tintColor = .clear
        UINavigationBar.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        Form{
            Section(header: Text("表記")){
                Toggle(isOn: $userData.isFlat,
                       label: {
                        Text("♭(フラット)表記")
                       })
            }
            Section(header: Text("グラフの表示速度")){
                HStack{
                    Text("速")
                    Slider(value: $userData.timerInterval,
                        in: 0.001...0.1)
                    Text("遅")
                }
            }
            Section{
                Rectangle()
                    .frame(height: 250)
                    .foregroundColor(.clear)
                    .background(AdRectView()
                                    .frame(height: 250))
            }
        }
        .onAppear(){
            navBarHidden = false
        }
        .onDisappear(){
            navBarHidden = true
        }
    }
}
