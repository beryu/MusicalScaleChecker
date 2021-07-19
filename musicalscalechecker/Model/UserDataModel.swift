//
//  TunerModel.swift
//  musicalscalechecker
//
//  Created by 松中誉生 on 2021/07/20.
//

import Foundation

//https://github.com/SwiftfulThinking/SwiftUI-Todo-List-MVVM-UserDefaults/blob/main/TodoList/Models/ItemModel.swift
struct UserDataModel: Identifiable, Codable {
    let id: String
    var isFlat: Bool
    var slider: Float
    var timerInterval: Float
    
    init(id: String = UUID().uuidString, isFlat: Bool, slider:Float, timerInterval: Float) {
        self.id = id
        self.isFlat = isFlat
        self.slider = slider
        self.timerInterval = timerInterval
    }
}
