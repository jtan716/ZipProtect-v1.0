//
//  ContentView.swift
//  ZipProtect
//
//  Created by Jeremy  Tan on 4/17/23.
//
import SwiftUI
import Foundation

struct ContentView: View {
    
    @State private var zipController : ZipController
    
    public init(zipController: ZipController = ZipController()) {
        self.zipController = zipController
    }

    var body: some View {
        
        ScrollView {
            VStack(spacing: 20) {
                Text("Choose file or folder to zip and password protect")
                    .frame(alignment: .leading)
                
                HStack(spacing: 40) {
                    Button("Select Folder") {
                        zipController.selectFolder()
                        if !zipController.zipFolder.selectedFileName.isEmpty {
                            if let lastUrl = zipController.zipFolder.fileUrls.last {
                                zipController.zipFolder.selectedFileName = lastUrl.lastPathComponent
                    
                            }
                        }
                    }
                    .frame(alignment: .leading)
                    
                    Button("Select Destination") {
                        zipController.selectDestination()
                    }

                }

                Text("Selected Folder: " + (zipController.zipFolder.selectedFileName.isEmpty ? "None" : zipController.zipFolder.selectedFileName))
                    .frame(alignment: .leading)
                
                Text("Destination: " + (zipController.zipFolder.selectedDestinationFolder.isEmpty ? "None" : zipController.zipFolder.selectedDestinationFolder))
                
                TextField("Name your zip folder", text: $zipController.zipFolder.nameOfZipFile)
                    .frame(alignment: .leading)

                TextField("Enter a Password", text: $zipController.zipFolder.enteredPassword)
                    .frame(alignment: .leading)
                
                Button("Create Password Protected Zip File") {
                    zipController.createZipFolder()
                }

                ProgressView(value: zipController.progressValue)
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

