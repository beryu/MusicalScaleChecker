//
//  TunerModel.swift
//  musicalscalechecker
//
//  Created by 松中誉生 on 2021/07/20.
//

import Foundation

//https://github.com/SwiftfulThinking/SwiftUI-Todo-List-MVVM-UserDefaults/blob/main/TodoList/Models/ItemModel.swift
//https://swdevnotes.com/swift/2021/persist-data-userdefaults-swiftui/
struct UserDataModel {
    private let isFlatKey = "UserData.isFlat"
    private let sliderKey = "UserData.slider"
    private let timerIntervalKey = "UserData.timerInterval"
    
    var isFlat: Bool {
        didSet {
            UserDefaults.standard.set(isFlat, forKey: isFlatKey)
        }
    }
    var slider: Float {
        didSet {
            UserDefaults.standard.set(slider, forKey: sliderKey)
        }
    }
    var timerInterval: Float {
        didSet {
            UserDefaults.standard.set(timerInterval, forKey: timerIntervalKey)
        }
    }
    
    init() {
        UserDefaults.standard.register(defaults: [isFlatKey: false,
                                                  sliderKey: 0,
                                                  timerIntervalKey: 0.005])
        
        isFlat = UserDefaults.standard.bool(forKey: isFlatKey)
        slider = UserDefaults.standard.float(forKey: sliderKey)
        timerInterval = UserDefaults.standard.float(forKey: timerIntervalKey)
    }
}
