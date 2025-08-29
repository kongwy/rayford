//
//  PhotosPickerItemState.swift
//  Rayford
//
//  Created by Weiyi Kong on 28/8/2025.
//

import SwiftUI

enum PhotosPickerItemState {
    case idle
    case loading(Progress)
    case success(CGImage)
    case failure(Error)
}
