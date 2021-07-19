//
//  AdView.swift
//  twenty-five
//
//  Created by 松中誉生 on 2020/10/22.
//

import SwiftUI
import GoogleMobileAds

struct AdView: UIViewRepresentable {
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView()
        //banner.adUnitID = "ca-app-pub-3940256099942544/2934735716" //テスト
        banner.rootViewController = UIApplication.shared.windows.first?.rootViewController
        banner.load(GADRequest())
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {
    }
}

struct AdRectView: UIViewRepresentable {
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView()
        //banner.adUnitID = "ca-app-pub-3940256099942544/2934735716" //テスト
        banner.rootViewController = UIApplication.shared.windows.first?.rootViewController
        banner.load(GADRequest())
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {
    }
}
