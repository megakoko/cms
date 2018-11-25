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
                guard let attachment = response?.parsed(Attachment.self) else {
                    print("Failed to parse attachment")
                    return
                }

                guard let base64string = attachment.file?.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil),
                      let data = Data(base64Encoded: base64string) else {
                    print("Failed to parse attachment")
                    return
                }

                let attachmentUrl = FileManager.default.temporaryDirectory.appendingPathComponent(attachment.fileName)

                guard let _ = try? data.write(to: attachmentUrl) else {
                    print("Failed to save attachment to temporary file: \(attachmentUrl)")
                    return
                }

                DispatchQueue.main.async {
                    self.webView.loadFileURL(attachmentUrl, allowingReadAccessTo: attachmentUrl)
                }
            }
        }
    }
}
