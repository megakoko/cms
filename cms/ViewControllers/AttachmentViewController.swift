//
//  AttachmentViewController.swift
//  cms
//
//  Created by Andrey on 24/11/2018.
//  Copyright © 2018 Andy. All rights reserved.
//

import UIKit
import WebKit

class AttachmentViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!

    var attachmentId: Int!

    override func viewDidLoad() {
        super.viewDidLoad()

        NetworkManager.request(.attachment(id: attachmentId)) {
            response in

            if let error = response?.error {
                print("Failed to get attachmnet: \(error)")
            } else {
                let attachment = response?.parsed(Attachment.self)

                guard let base64string = attachment?.file?.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil),
                      let base64 = Data(base64Encoded: base64string) else {
                    print("Failed to parse attachment")
                    return
                }

                guard let lastDotIndex = attachment?.fileName.lastIndex(of: "."),
                      let suffix = attachment?.fileName.suffix(from: lastDotIndex) else {
                    print("Can't determine attachment suffix")
                    return
                }

                var mimeType = ""
                switch suffix {
                case ".pdf":
                    mimeType = "application/pdf"
                case ".xhtml":
                    mimeType = "application/xhtml"
                default:
                    print("Invalid attachment format: \(suffix)")
                    return
                }

                DispatchQueue.main.async {
                    self.webView!.load(base64, mimeType: mimeType, characterEncodingName: "", baseURL: URL(string: "http://localhost")!)
                }
            }
        }
    }
}
