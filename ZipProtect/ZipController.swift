//
//  ZipController.swift
//  ZipProtect
//
//  Created by Jeremy  Tan on 5/1/23.
//

import Foundation
import SwiftUI

class ZipController: ObservableObject {
    @Published var zipFolder = ZipFolder()
    @Published var progressValue: Double = 0.0
    @Published var isCancelled: Bool = false
    @Published var errorMessages: [String] = []

    func selectFolder() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false // Only select folders
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = true
        openPanel.showsHiddenFiles = false
        openPanel.allowedFileTypes = ["public.folder"] // Only allow folders

        if openPanel.runModal() == NSApplication.ModalResponse.OK {
            zipFolder.fileUrls = openPanel.urls
            zipFolder.selectedFileName = ""
            for url in zipFolder.fileUrls {
                let fileName = url.deletingPathExtension().lastPathComponent
                if zipFolder.selectedFileName.isEmpty {
                    zipFolder.selectedFileName = fileName
                } else {
                    zipFolder.selectedFileName += ", \(fileName)"
                }
            }
        }
    }

    func selectDestination() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false

        if openPanel.runModal() == NSApplication.ModalResponse.OK {
            let selectedUrl = openPanel.url
            zipFolder.selectedDestinationFolder = selectedUrl?.lastPathComponent ?? ""
            // do something with the selectedUrl, e.g. store it in a variable
        }
    }

    func createZipFolder() {
        errorMessages.removeAll()

        if zipFolder.fileUrls.isEmpty { errorMessages.append("Please select a file or folder to zip.") }
        if zipFolder.selectedFileName.isEmpty { errorMessages.append("Selected file(s) is empty.") }
        if zipFolder.selectedDestinationFolder.isEmpty { errorMessages.append("Please select a destination folder.") }
        if zipFolder.nameOfZipFile.isEmpty { errorMessages.append("Please provide a name for the zip folder.") }
        if zipFolder.enteredPassword.isEmpty { errorMessages.append("Please enter a password.") }

        if !errorMessages.isEmpty {
            let errorMessage = errorMessages.joined(separator: "\n")
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.informativeText = errorMessage
            alert.runModal()
        } else {
            progressValue = 0
            let task = Process()
            task.launchPath = "/usr/bin/zip"
            task.arguments = ["-r", "-P", zipFolder.enteredPassword, "\(zipFolder.selectedDestinationFolder)/\(zipFolder.nameOfZipFile).zip"] + zipFolder.fileUrls.map({ $0.path + "/\($0.lastPathComponent)" })
            let pipe = Pipe()
            task.standardOutput = pipe
            let outHandle = pipe.fileHandleForReading
            outHandle.waitForDataInBackgroundAndNotify()
            var obs1 : NSObjectProtocol!
            obs1 = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outHandle, queue: nil) {  notification -> Void in
                let data = outHandle.availableData
                if data.count > 0 {
                    let str = String(data: data, encoding: String.Encoding.utf8)!
                    self.progressValue += 0.1 // increase the progress by 0.1 for each notification received
                    print(str)
                    outHandle.waitForDataInBackgroundAndNotify()
                } else {
                    NotificationCenter.default.removeObserver(obs1!)
                }
            }
            task.launch()
        }
    }
}
