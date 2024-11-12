import Foundation
import ThirdWeb

/// Service to handle blockchain operations using ThirdWeb
class ThirdWebService {
    static let shared = ThirdWebService()
    
    private var sdk: ThirdwebSDK?
    private var contract: Contract?
    
    private init() {
        setupSDK()
    }
    
    private func setupSDK() {
        // Initialize ThirdWeb SDK
        // Note: Replace with your actual client ID from ThirdWeb dashboard
        sdk = ThirdwebSDK(clientId: "YOUR_THIRDWEB_CLIENT_ID")
    }
    
    // MARK: - Voice NFT Management
    
    /// Create an NFT for a voice recording
    func createVoiceNFT(
        title: String,
        description: String,
        audioURL: URL,
        metadata: [String: Any]
    ) async throws -> String {
        guard let contract = try? await sdk?.getContract("YOUR_CONTRACT_ADDRESS") else {
            throw ThirdWebError.contractNotFound
        }
        
        // Prepare metadata for the NFT
        let nftMetadata: [String: Any] = [
            "name": title,
            "description": description,
            "audio": audioURL.absoluteString,
            "attributes": metadata
        ]
        
        // Mint NFT
        let result = try await contract.erc721.mint(metadata: nftMetadata)
        return result.id
    }
    
    /// Set up royalties for a voice NFT
    func setupRoyalties(
        tokenId: String,
        royaltyPercent: Double,
        recipientAddress: String
    ) async throws {
        guard let contract = try? await sdk?.getContract("YOUR_CONTRACT_ADDRESS") else {
            throw ThirdWebError.contractNotFound
        }
        
        try await contract.royalty.setTokenRoyaltyInfo(
            tokenId: tokenId,
            recipient: recipientAddress,
            bps: Int(royaltyPercent * 100)
        )
    }
    
    /// Get earnings for a specific address
    func getEarnings(address: String) async throws -> Double {
        guard let contract = try? await sdk?.getContract("YOUR_CONTRACT_ADDRESS") else {
            throw ThirdWebError.contractNotFound
        }
        
        let balance = try await contract.erc20.balance()
        return Double(balance) / 1e18 // Convert from Wei to ETH
    }
    
    /// List a voice NFT on the marketplace
    func listVoiceNFT(
        tokenId: String,
        price: Double,
        currencyAddress: String
    ) async throws {
        guard let contract = try? await sdk?.getContract("YOUR_MARKETPLACE_ADDRESS") else {
            throw ThirdWebError.contractNotFound
        }
        
        try await contract.marketplace.createListing(
            type: .direct,
            tokenId: tokenId,
            price: price,
            currencyAddress: currencyAddress
        )
    }
    
    /// Buy a voice NFT from the marketplace
    func buyVoiceNFT(listingId: String) async throws {
        guard let contract = try? await sdk?.getContract("YOUR_MARKETPLACE_ADDRESS") else {
            throw ThirdWebError.contractNotFound
        }
        
        try await contract.marketplace.buyoutListing(listingId: listingId, quantity: 1)
    }
}

// MARK: - Supporting Types

enum ThirdWebError: Error {
    case sdkNotInitialized
    case contractNotFound
    case mintingFailed
    case royaltySetupFailed
    case transactionFailed
}

extension ThirdWebService {
    struct VoiceNFTMetadata {
        let title: String
        let description: String
        let duration: TimeInterval
        let language: String
        let culturalTags: [String]
        let voiceCharacteristics: [String: String]
        
        var asDictionary: [String: Any] {
            return [
                "title": title,
                "description": description,
                "duration": duration,
                "language": language,
                "culturalTags": culturalTags,
                "voiceCharacteristics": voiceCharacteristics
            ]
        }
    }
}

// MARK: - Usage Example

/*
 How to use ThirdWebService:
 
 // Initialize service (happens automatically via shared instance)
 let service = ThirdWebService.shared
 
 // Create a voice NFT
 Task {
     do {
         let metadata = VoiceNFTMetadata(
             title: "Morning Narration",
             description: "Professional morning voice recording",
             duration: 120.0,
             language: "en",
             culturalTags: ["American", "Professional"],
             voiceCharacteristics: [
                 "tone": "warm",
                 "pace": "moderate",
                 "clarity": "high"
             ]
         )
         
         let tokenId = try await service.createVoiceNFT(
             title: "Morning Narration",
             description: "Professional morning voice recording",
             audioURL: audioFileURL,
             metadata: metadata.asDictionary
         )
         
         // Setup royalties
         try await service.setupRoyalties(
             tokenId: tokenId,
             royaltyPercent: 2.5,
             recipientAddress: "0x..."
         )
         
         // List on marketplace
         try await service.listVoiceNFT(
             tokenId: tokenId,
             price: 0.1,
             currencyAddress: "0x..." // ETH address
         )
     } catch {
         print("Error: \(error)")
     }
 }
 */
