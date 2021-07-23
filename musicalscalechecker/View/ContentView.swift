//
//  ContentView.swift
//  musicalscalechecker
//
//  Created by 松中誉生 on 2020/10/23.
//

import SwiftUI
import AudioKit
import StoreKit
import GoogleMobileAds

struct ContentView: View {
    @ObservedObject var tunerView = TunerViewModel()
    @State var isPresentedSubView: Bool = false
    @State var navBarHidden: Bool = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "262626")
                    .edgesIgnoringSafeArea(.all)
                
                HStack {
                    Spacer()
                    VStack {
                        NavigationLink(destination: SettingView(userData: $tunerView.userData, navBarHidden: $navBarHidden)) {
                            Image("setting")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(Color.gray)
                                .padding()
                        }
                        Spacer()
                    }
                }
                VStack {
                    ZStack {
                        HStack {
                            VStack {
                                Slider(value: $tunerView.userData.slider, in: 0...100, step: 1)
                                    .accentColor(Color(hex: "D06969"))
                                    .frame(width: 200)
                                HStack {
                                    Spacer()
                                    Text("マイク感度: \(Int(100-tunerView.userData.slider), specifier: "%3d")%")
                                        .font(.custom("komorebi-gothic", size: 10))
                                        .foregroundColor(Color(hex: "D9D9D9"))
                                        .rotationEffect(.degrees(-180.0), anchor: .center)
                                }
                                .frame(width: 200)
                            }
                            .rotationEffect(.degrees(-90.0), anchor: .topLeading)
                            .padding(.leading, 35)
                            .offset(x: -100, y: 100)
                        }
                        VStack {
                            Text("\(tunerView.sound.pitch)")
                                .font(.custom("komorebi-gothic", size: 20))
                                .foregroundColor(Color(hex: "D9D9D9"))
                                .padding(5)
                            Text("\(tunerView.sound.note)")
                                .font(.custom("komorebi-gothic", size: 20))
                                .foregroundColor(Color(hex: "D9D9D9"))
                                .padding(5)
                            Text("\(tunerView.sound.noteJa)")
                                .font(.custom("komorebi-gothic", size: 100))
                                .foregroundColor(Color(hex: "D9D9D9"))
                                .padding(5)
                            Text("\(Int(tunerView.sound.frequency), specifier: "%4d")Hz")
                                .font(.custom("komorebi-gothic", size: 20))
                                .foregroundColor(Color(hex: "D9D9D9"))
                                .padding(5)
                            Text(tunerView.isStopped ? "Stopped" : "       ")
                                .font(.custom("komorebi-gothic", size: 20))
                                .foregroundColor(Color(hex: "FA8383"))
                                .padding()
                        }
                    }
                    .padding(.top)
                    ChartView(freq: tunerView.sound.frequency, reload: tunerView.reload, isFlat: tunerView.userData.isFlat)
                        .padding(.top)
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        AdView()
                            .frame(height: 90)
                    }else{
                        AdView()
                            .frame(height: 60)
                    }
                }
            }
            .onTapGesture {
                tunerView.isStopped.toggle()
            }
            .onAppear {
                tunerView.start()
                navBarHidden = true
                /// n回に1回レビューを促す
                UserDefaults.standard.register(defaults: ["slider": 0.0, "count": 1])
                let count: Int = UserDefaults.standard.integer(forKey: "count")
                UserDefaults.standard.setValue(count+1, forKey: "count")
                if count%15 == 0 {
                    SKStoreReviewController.requestReview()
                }
            }
            .onDisappear {
                tunerView.stop()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                tunerView.start()
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(navBarHidden)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
