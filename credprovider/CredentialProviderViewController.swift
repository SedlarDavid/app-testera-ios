import AuthenticationServices

// Define your credential model
struct SocialCredential: Codable {
    let service: String
    let username: String
    let password: String
}

class CredentialProviderViewController: ASCredentialProviderViewController {

    private var credentials: [SocialCredential] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCredentials()
    }

    /// Load credentials from shared storage (e.g., App Group UserDefaults)
    private func loadCredentials() {
        let userDefaults = UserDefaults(suiteName: "group.cz.sedlardavid.credprovider") // Replace with your App Group ID
        if let data = userDefaults?.data(forKey: "savedCredentials") {
            do {
                credentials = try JSONDecoder().decode([SocialCredential].self, from: data)
            } catch {
                print("Error decoding credentials: \(error)")
            }
        }
    }

    /// Called when the system requests credentials without user interaction
    override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
        guard let matchedCredential = credentials.first(where: {
            $0.service == credentialIdentity.serviceIdentifier.identifier &&
            $0.username == credentialIdentity.user
        }) else {
            // No matching credential found; cancel the request
            let error = NSError(domain: ASExtensionErrorDomain,
                                code: ASExtensionError.userInteractionRequired.rawValue)
            self.extensionContext.cancelRequest(withError: error)
            return
        }

        // Provide the credential to the system
        let credential = ASPasswordCredential(user: matchedCredential.username,
                                              password: matchedCredential.password)
        self.extensionContext.completeRequest(withSelectedCredential: credential, completionHandler: nil)
    }

    /// Called when the system requires user interaction to provide credentials
    override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
        // Implement UI to allow the user to select or enter credentials
        // For simplicity, this example cancels the request
        let error = NSError(domain: ASExtensionErrorDomain,
                            code: ASExtensionError.userCanceled.rawValue)
        self.extensionContext.cancelRequest(withError: error)
    }

    /// Optional: Prepare a list of credentials for the user to choose from
    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        // Implement if you want to show a list of credentials matching the service identifiers
        // For simplicity, this example does nothing
    }

    /// Handle user cancellation
    @IBAction func cancel(_ sender: AnyObject?) {
        let error = NSError(domain: ASExtensionErrorDomain,
                            code: ASExtensionError.userCanceled.rawValue)
        self.extensionContext.cancelRequest(withError: error)
    }
}
