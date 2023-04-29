//
//  ContentView.swift
//  ZipProtect
//
//  Created by Jeremy  Tan on 4/17/23.
//
import SwiftUI
import Foundation

struct ContentView: View {
    @State private var fileUrls: [URL] = []
    @State private var selectedFileName: String = ""
    @State private var selectedDestinationFolder: String = ""
    @State private var nameOfZipFile : String = ""
    @State private var enteredPassword : String = ""
    @State private var progressValue: Double = 0.0
    @State private var isCancelled: Bool = false

    @State private var errorMessages: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Choose file or folder to zip and password protect")
                    .frame(alignment: .leading)
                
                HStack(spacing: 40) {
                    Button("Select Folder") {
                        let openPanel = NSOpenPanel()
                        openPanel.canChooseFiles = false // Only select folders
                        openPanel.canChooseDirectories = true
                        openPanel.allowsMultipleSelection = true
                        openPanel.showsHiddenFiles = false
                        openPanel.allowedFileTypes = ["public.folder"] // Only allow folders
                        
                        if openPanel.runModal() == NSApplication.ModalResponse.OK {
                            fileUrls = openPanel.urls
                            selectedFileName = ""
                            for url in fileUrls {
                                let fileName = url.deletingPathExtension().lastPathComponent
                                if selectedFileName.isEmpty {
                                    selectedFileName = fileName
                                } else {
                                    selectedFileName += ", \(fileName)"
                                }
                            }
                        }
                    }
                    .frame(alignment: .leading)
                    
                    Button("Select Destination") {
                        let openPanel = NSOpenPanel()
                        openPanel.canChooseFiles = false
                        openPanel.canChooseDirectories = true
                        openPanel.allowsMultipleSelection = false
                        
                        if openPanel.runModal() == NSApplication.ModalResponse.OK {
                            let selectedUrl = openPanel.url
                            selectedDestinationFolder = selectedUrl?.lastPathComponent ?? ""
                            // do something with the selectedUrl, e.g. store it in a variable
                        }
                    }

                }

                Text("Selected Folder: " + (selectedFileName.isEmpty ? "None" : selectedFileName))
                    .frame(alignment: .leading)
                
                Text("Destination: " + (selectedDestinationFolder.isEmpty ? "None" : selectedDestinationFolder))
                
                TextField("Name your zip folder", text: $nameOfZipFile)
                    .frame(alignment: .leading)

                TextField("Enter a Password", text: $enteredPassword)
                    .frame(alignment: .leading)
                
                Button("Create Password Protected Zip File") {
                    errorMessages.removeAll()
                    
                    if fileUrls.isEmpty { errorMessages.append("Please select a file or folder to zip.") }
                    if selectedFileName.isEmpty { errorMessages.append("Selected file(s) is empty.") }
                    if selectedDestinationFolder.isEmpty { errorMessages.append("Please select a destination folder.") }
                    if nameOfZipFile.isEmpty { errorMessages.append("Please provide a name for the zip folder.") }
                    if enteredPassword.isEmpty { errorMessages.append("Please enter a password.") }


                    
                    if !errorMessages.isEmpty {
                        let errorMessage = errorMessages.joined(separator: "\n")
                        let alert = NSAlert()
                        alert.messageText = "Error"
                        alert.informativeText = errorMessage
                        alert.runModal()
                    }
                    else {
                        progressValue = 0
                                let task = Process()
                                task.launchPath = "/usr/bin/zip"
                                task.arguments = ["-r", "-P", enteredPassword, "\(selectedDestinationFolder)/\(nameOfZipFile).zip"] + fileUrls.map({ $0.path + "/\($0.lastPathComponent)" })
                                let pipe = Pipe()
                                task.standardOutput = pipe
                                let outHandle = pipe.fileHandleForReading
                                outHandle.waitForDataInBackgroundAndNotify()
                                var obs1 : NSObjectProtocol!
                                obs1 = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outHandle, queue: nil) {  notification -> Void in
                                    let data = outHandle.availableData
                                    if data.count > 0 {
                                        let str = String(data: data, encoding: String.Encoding.utf8)!
                                        progressValue += 0.1 // increase the progress by 0.1 for each notification received
                                        print(str)
                                        outHandle.waitForDataInBackgroundAndNotify()
                                    } else {
                                        NotificationCenter.default.removeObserver(obs1!)
                                    }
                                }
                                task.launch()


                    }
                }

                ProgressView(value: progressValue)
            }
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .center
        )
        .frame(
            width: NSScreen.main!.frame.width / 4,
            height: NSScreen.main!.frame.height / 2,
                alignment: .center
            )
        }
    }

