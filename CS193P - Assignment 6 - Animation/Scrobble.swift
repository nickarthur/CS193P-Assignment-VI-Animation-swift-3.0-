///////////////////////////////////////////////////////////////////////////////
//  Scrobble.swift
//  CS193P - Assignment 6 - Animation
//
//  Created by Michel Deiman on 29/08/2016.
//  Copyright © 2016 Michel Deiman. All rights reserved.
///////////////////////////////////////////////////////////////////////////////
import Foundation
import UIKit

let letterValues: [String: Int] = [
		"A": 1, "B": 3, "C": 3, "D": 2, "E": 1, "F": 4, "G": 2,
		"H": 4, "I": 1, "J": 8, "K": 5, "L": 1, "M": 3, "N": 1, "O": 1,
		"P": 3, "Q": 10, "R": 1, "S": 1, "T": 1, "U": 1, "V": 4, "W": 4,
		"X": 8, "Y": 4, "Z": 10]


enum BoardSquareType: String {
	case source = "source"
	case regular = "regular"
	case dl = "DL"
	case tl = "TL"
	case dw = "DW"
	case tw = "TW"
	
	func value() -> Int {
		switch self {
		case .dl: return 2
		case .tl: return 3
		case .dw: return 2
		case .tw: return 3
		default: return 1
		}
	}
}
	typealias CellValues = [Int: BoardSquareType]

	let cellValues1x5: CellValues = [:]
	let cellValues9x9: CellValues = [
		1: .tw,  4: .tl, 6: .tl, 9: .tw, 11: .dw, 14: .dl, 17:.dw, 21: .tl, 25: .tl, 28: .tl,
		31: .dl, 33: .dl, 36: .tl, 38: .dl, 41: .dw, 44: .dl, 46: .tl, 49: .dl, 51: .dl, 54: .tl,
		57: .tl, 61: .tl, 65: .dw, 68: .dl, 71: .dw, 73: .tw, 76:.tl, 78: .tl, 81: .tw]
	
	let cellValues7x7: CellValues = [
		1: .dw, 4: .dl, 7:.dw, 9: .tl, 13: .tl,  17: .dl, 19: .dl,  22: .dl, 25: .dw,
		28: .dl, 31: .dl, 33: .dl, 37: .tl, 41: .tl, 43: .dw, 46: .dl, 49: .dw]

	let boardColors: [String: UIColor] = [
		"source": #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1), "regular": #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1), "DL": #colorLiteral(red: 0.2202886641, green: 0.7022308707, blue: 0.9593387842, alpha: 1), "TL": #colorLiteral(red: 0.1431525946, green: 0.4145618975, blue: 0.7041897774, alpha: 1), "DW": #colorLiteral(red: 1, green: 0.4, blue: 0.6, alpha: 1), "TW": #colorLiteral(red: 0.8, green: 0, blue: 0, alpha: 1)]

    let letterColors: [String: UIColor] = [
        "backGround": #colorLiteral(red: 0.7978851795, green: 0.7254901961, blue: 0.5294117647, alpha: 1), "animationBG": #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1), "border": #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1), "tekst": #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), "tekstValue": #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)]

    let letterBoardColors: [String: UIColor] = [
        "backGround": #colorLiteral(red: 0.4, green: 0.2, blue: 0, alpha: 1), "leftButtonBG": #colorLiteral(red: 0.1603052318, green: 0, blue: 0.8195188642, alpha: 1), "rightButtonBG": #colorLiteral(red: 0.9101451635, green: 0.2575159371, blue: 0.1483209133, alpha: 1)]


enum PaddleConstants {
    static var WidthToHeightFactor: CGFloat = 12
    static var WidthPercentage: CGFloat = 40
    static let MaxWidthPercentage: CGFloat = 50
    static let MinWidthPercentage: CGFloat = 10
    static var FromBottom: CGFloat = 5
    static var Color: UIColor = #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1)
}



func boardDimension(numberOfRows: Int, numberOfColumns: Int) -> CellValues?
{	if numberOfRows == numberOfColumns {
		switch numberOfRows {
		case 7: return cellValues7x7
		case 9: return cellValues9x9
		default: break
		}
	} else if numberOfRows == 1 && numberOfColumns <= 7 {
		return cellValues1x5
	}
	return nil
}








