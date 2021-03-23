//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest
@testable import Domain

private struct Base64EncodedString: DataConvertible, Equatable {
    
    private var value = ""
    
    var data: Data {
        Data(base64Encoded: value)!
    }
    
    init(data: Data) throws {
        value = data.base64EncodedString()
    }
    
    init(_ string: String) {
        value = string
    }
}

class EncryptedTests: XCTestCase {
    private var encrypted: Encrypted<Base64EncodedString>!
    private var keyString = Base64EncodedString("5S0+ofPG2UuweJMAJuJYq5jv/hKwgZgsZzXVuC4SyKE=")
    private var tagString = Base64EncodedString("RURFQ0YzMTYtMUJCQS00NkI0LTgxQUYtNzg1RjdCQzZBOTM2")
    private var plaintextString = Base64EncodedString("NUFBRjdCRDQtMkJDQS00REQ2LUEwMTItNkNGRTI0QkY1NEUy")
    private var ciphertextString = Base64EncodedString("W2pg9G4N4i+AjwxjmzT3dc5IHcL6TQyGSXOd3tfKeKKlHpr8JXwa9kMcIR1fdDc8DOl2U7XxsA0lBw60X6MQVQ==")
    
    override func tearDown() {
        super.tearDown()
        encrypted.wrappedValue = nil
    }
    
    func testCanGetAnEncryptedValue() {
        let service = UUID().uuidString
        let name = UUID().uuidString
        let directory = FileManager().temporaryDirectory
        encrypted = Encrypted(service: service, directory: directory, name: name)
        
        let key = KeychainStored<Base64EncodedString>(keychain: Keychain(service: service), key: "\(name).key")
        key.wrappedValue = keyString
        
        let tag = KeychainStored<Base64EncodedString>(keychain: Keychain(service: service), key: "\(name).tag")
        tag.wrappedValue = tagString
        
        let fileStore = FileStored<Data>(storage: FileStorage(directory: directory), name: name)
        fileStore.wrappedValue = ciphertextString.data
        
        XCTAssertEqual(encrypted.wrappedValue, plaintextString)
    }
    
    func testCanSetAnEncryptedValue() {
        let service = UUID().uuidString
        let name = UUID().uuidString
        let directory = FileManager().temporaryDirectory
        encrypted = Encrypted(service: service, directory: directory, name: name)
        
        encrypted.wrappedValue = plaintextString
        XCTAssertEqual(encrypted.wrappedValue, plaintextString)
    }
    
    func testCanDeleteAValue() {
        let service = UUID().uuidString
        let name = UUID().uuidString
        let directory = FileManager().temporaryDirectory
        encrypted = Encrypted(service: service, directory: directory, name: name)
        
        encrypted.wrappedValue = plaintextString
        encrypted.wrappedValue = nil
        XCTAssertFalse(encrypted.hasValue)
    }
    
    func testHasValueReturnsTrueWhenThereIsAValue() {
        let service = UUID().uuidString
        let name = UUID().uuidString
        let directory = FileManager().temporaryDirectory
        encrypted = Encrypted(service: service, directory: directory, name: name)
        
        encrypted.wrappedValue = plaintextString
        XCTAssertTrue(encrypted.hasValue)
    }
    
    func testKeyAndTagAreDeletedIfCipherTextHasNoValue() {
        let service = UUID().uuidString
        let name = UUID().uuidString
        let directory = FileManager().temporaryDirectory
        let key = KeychainStored<Base64EncodedString>(keychain: Keychain(service: service), key: "\(name).key")
        key.wrappedValue = keyString
        
        let tag = KeychainStored<Base64EncodedString>(keychain: Keychain(service: service), key: "\(name).tag")
        tag.wrappedValue = tagString
        
        encrypted = Encrypted(service: service, directory: directory, name: name)
        XCTAssertFalse(key.hasValue)
        XCTAssertFalse(tag.hasValue)
    }
    
    func testKeyAndTagRemainIfCipherTextHasAValue() {
        let service = UUID().uuidString
        let name = UUID().uuidString
        let directory = FileManager().temporaryDirectory
        let key = KeychainStored<Base64EncodedString>(keychain: Keychain(service: service), key: "\(name).key")
        key.wrappedValue = keyString
        
        let tag = KeychainStored<Base64EncodedString>(keychain: Keychain(service: service), key: "\(name).tag")
        tag.wrappedValue = tagString
        
        let ciphertext = FileStored<Data>(storage: FileStorage(directory: directory), name: name)
        ciphertext.wrappedValue = ciphertextString.data
        
        encrypted = Encrypted(service: service, directory: directory, name: name)
        XCTAssertTrue(key.hasValue)
        XCTAssertTrue(tag.hasValue)
    }
}

private extension Encrypted {
    
    init(service: String, directory: URL, name: String) {
        let store = EncryptedStore(
            keychain: Keychain(service: service),
            storage: FileStorage(directory: directory)
        )
        self = store.encrypted(name)
    }
    
}
