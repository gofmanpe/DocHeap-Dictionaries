//
//  Protocols.swift
//  docHeap-Dictionaries
//
//  Created by Pavel Gofman on 02.07.23.
//

import Foundation

protocol UpdateView{
    func didUpdateView(sender:String)
}

protocol SaveWordsPairToDictionary{
    func saveWordsPair(word:String,translation:String, imageName:String?, wrdID:String)
}

protocol CellButtonPressed{
    func cellButtonPressed(dicID:String, button:String)
}

protocol UpdateDictionaryData: AnyObject{
    func setDownloadStatus(dicIndex:Int)
}
protocol PerformToSegue{
    func performToSegue(identifier:String, dicID:String, roundsNumber: Int)
}

protocol GetFilteredData{
    func setDataAfterFilter(array:[SharedDictionary], learnLang:String, transLang:String, clear:Bool)
}

protocol SetDownloadedMarkToDictionary{
    func dictionaryWasDownloaded(dicID:String)
}

protocol LogOutUser{
    func performToStart()
}

