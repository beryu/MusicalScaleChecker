//
//  SoundModel.swift
//  musicalscalechecker
//
//  Created by 松中誉生 on 2021/07/23.
//

import Foundation

class SoundModel {
    let noteFrequencies:[Float] = [16.35, 17.32, 18.35, 19.45, 20.6, 21.83, 23.12, 24.5, 25.96, 27.5, 29.14, 30.87]
    var noteNames:[String] = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
    var scaleNames:[String] = ["ド", "ド#", "レ", "レ#", "ミ", "ファ", "ファ#", "ソ", "ソ#", "ラ", "ラ#", "シ"]
    
    var frequency:Float = 0
    
    var pitch:String = "--"
    var note:String = "--"
    var noteJa:String = "--"
    
    init(){
        
    }
    
    func changeSharpFlat(isFlat: Bool){
        if(isFlat){
            noteNames = ["C", "D♭", "D", "E♭", "E", "F", "G♭", "G", "A♭", "A", "B♭", "B"]
            scaleNames = ["ド", "レ♭", "レ", "ミ♭", "ミ", "ファ", "ソ♭", "ソ", "ラ♭", "ラ", "シ♭", "シ"]
        }else{
            noteNames = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
            scaleNames = ["ド", "ド#", "レ", "レ#", "ミ", "ファ", "ファ#", "ソ", "ソ#", "ラ", "ラ#", "シ"]
        }
    }

}
