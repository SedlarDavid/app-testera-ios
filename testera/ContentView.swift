//
//  ContentView.swift
//  testera
//
//  Created by David Sedlář on 28.04.2025.
//

import SwiftUI

struct Credentials {
    var username: String
    var password: String
}

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

struct ContentView: View {
    var credentials = Credentials(username: "davca", password: "pswd");
    
    func onKeychainStore() -> Void {
        let account = credentials.username
        let password = credentials.password.data(using: String.Encoding.utf8)!
        let server = "testserver.com"
        var query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: account,
                                    kSecAttrServer as String: server,
                                    kSecValueData as String: password]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { print(KeychainError.unhandledError(status: status)); return; }
    }
    
    func sharedWebCredentials() -> Void {
        SecRequestSharedWebCredential(nil, nil) { credentials, error in
            if let credentials = credentials as? [[String: Any]],
               let credential = credentials.first,
               let account = credential[kSecAttrAccount as String] as? String,
               let password = credential[kSecSharedPassword as String] as? String {
                
                print(account)
                // Use the account and password
            } else if let error = error {
                print(error)
                // Handle error
            }
        }
    }
    
    func storeWebCreds () -> Void {
        /*   SecAddSharedWebCredential("test.server" as CFString,
         "someUser1" as CFString,
         "strongPassword123!" as CFString) { error in
         if let error = error {
         print("Error saving credential: \(error)")
         } else {
         print("Credential saved (user must have confirmed).")
         }
         }*/
        
        SecAddSharedWebCredential("sedlardavid.cz" as CFString,
                                  "firstUser@test.com" as CFString,
                                  "firstStrongPassword123!" as CFString) { error in
            if let error = error {
                print("Error saving first credential: \(error)")
            } else {
                print("First credential saved successfully.")
            }
        }
        
        // Entry 2
        SecAddSharedWebCredential("mastodon.sedlardavid.cz" as CFString,
                                  "secondUser@test.com" as CFString,
                                  "secondStrongPassword456!" as CFString) { error in
            if let error = error {
                print("Error saving second credential: \(error)")
            } else {
                print("Second credential saved successfully.")
            }
        }}
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button(action: storeWebCreds) {
                Text("Sign In")
            }
        }
        .padding()
    }
}
