//
//  UserDataModel.swift
//  SquatCounter
//
//  Created by Apiphoom Chuenchompoo on 2/2/2567 BE.
//

import Foundation


enum UserState: String, Codable, CaseIterable{
    case normal, rehab
}

enum GeneralField: Int, CaseIterable {
    case name,height, weight,mins,cals
}


