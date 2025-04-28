//
//  CredentialsView.swift
//  testera
//
//  Created by David Sedlář on 28.04.2025.
//

import SwiftUI
import AuthenticationServices

struct SocialCredential: Codable {
    let service: String
    let username: String
    let password: String
}

struct CredentialsView: View {
    
    
    @State private var username: String = ""
    @State private var password: String = ""
    func onCredentials() {
        // Example generated credentials
        let credentials = [
            SocialCredential(service: "test1.server", username: "someUser1", password: "StrongPasswordMasto123!"),
            SocialCredential(service: "test2.server", username: "someUser1", password: "StrongPasswordBlue123!")
        ]
        
        // Save to App Group
        if let data = try? JSONEncoder().encode(credentials) {
            let userDefaults = UserDefaults(suiteName: "group.com.example.credentials") // <-- Important, match App Group ID
            userDefaults?.set(data, forKey: "savedCredentials")
        }
        
        // Also populate system credential identity store
        let identities = credentials.map { credential in
            ASPasswordCredentialIdentity(
                serviceIdentifier: ASCredentialServiceIdentifier(identifier: credential.service, type: .domain),
                user: credential.username,
                recordIdentifier: nil
            )
        }
        
        ASCredentialIdentityStore.shared.saveCredentialIdentities(identities) { success, error in
            if success {
                print("Credential Identities saved successfully.")
            } else if let error = error {
                print("Error saving identities: \(error)")
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Save demo credentials for testing:")
                .font(.headline)
            
            Button(action: onCredentials) {
                Text("Save Credentials")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Divider()
                .padding(.vertical)
            
            Text("Test AutoFill Login Form:")
                .font(.headline)
            
            // TEST LOGIN FORM
            TextField("Username", text: $username)
                .textContentType(.username) // Important for AutoFill
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            SecureField("Password", text: $password)
                .textContentType(.password) // Important for AutoFill
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}
