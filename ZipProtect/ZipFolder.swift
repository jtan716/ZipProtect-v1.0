//
//  ZipFolder.swift
//  ZipProtect
//
//  Created by Jeremy  Tan on 5/1/23.
//

import Foundation

struct ZipFolder {
    var fileUrls: [URL] = []
    var selectedFileName: String = ""
    var selectedDestinationFolder: String = ""
    var nameOfZipFile: String = ""
    var enteredPassword: String = ""
}
