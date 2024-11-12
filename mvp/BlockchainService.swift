import Foundation
import web3swift
import Web3Core
import BigInt

class BlockchainService {
    static let shared = BlockchainService()
    
    private var web3: Web3?
    private var keystore: BIP32Keystore?
    
    // Smart contract addresses
    private let voiceNFTAddress = "YOUR_NFT_CONTRACT_ADDRESS"
    private let marketplaceAddress = "YOUR_MARKETPLACE_ADDRESS"
    
    private init() {
        setupWeb3()
    }
    
    private func setupWeb3() {
        // Initialize Web3 instance with your preferred network
        // For development, we'll use a test network
        let clientUrl = "https://goerli.infura.io/v3/YOUR_INFURA_KEY"
        guard let web3Provider = Web3HttpProvider(URL(string: clientUrl)!) else { return }
        web3 = Web3(provider: web3Provider)
    }
    
    // MARK: - Wallet Management
    
    func createWallet(password: String) throws -> String {
        // Generate mnemonic
        guard let mnemonic = try? BIP39.generateMnemomic(bitsOfEntropy: 128) else {
            throw BlockchainError.walletCreationFailed
        }
        
        // Create keystore
        guard let keystore = try? BIP32Keystore(
            mnemonics: mnemonic,
            password: password,
            mnemonicsPassword: "",
            language: .english
        ) else {
            throw BlockchainError.walletCreationFailed
        }
        
        self.keystore = keystore
        return keystore.addresses?.first?.address ?? ""
    }
    
    // MARK: - Voice NFT Management
    
    func mintVoiceNFT(
        metadata: VoiceNFTMetadata,
        password: String
    ) async throws -> String {
        guard let web3 = web3,
              let keystore = keystore,
              let address = keystore.addresses?.first else {
            throw BlockchainError.notInitialized
        }
        
        // NFT Contract ABI
        let contractABI = """
        [
            {
                "inputs": [
                    {
                        "internalType": "string",
                        "name": "tokenURI",
                        "type": "string"
                    }
                ],
                "name": "mintNFT",
                "outputs": [
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    }
                ],
                "stateMutability": "nonpayable",
                "type": "function"
            }
        ]
        """
        
        // Prepare contract
        guard let contractAddress = EthereumAddress(voiceNFTAddress) else {
            throw BlockchainError.invalidAddress
        }
        
        let contract = web3.contract(contractABI, at: contractAddress, abiVersion: 2)
        
        // Prepare metadata JSON
        let metadataJson = try JSONEncoder().encode(metadata)
        let ipfsHash = try await uploadToIPFS(metadataJson)
        
        // Prepare transaction
        guard let transaction = contract?.write(
            "mintNFT",
            parameters: [ipfsHash] as [AnyObject],
            extraData: Data(),
            transactionOptions: .defaultOptions
        ) else {
            throw BlockchainError.transactionFailed
        }
        
        // Send transaction
        guard let result = try? await transaction.send(password: password) else {
            throw BlockchainError.transactionFailed
        }
        
        return result.hash
    }
    
    func setupRoyalties(
        tokenId: String,
        percentage: Double,
        password: String
    ) async throws {
        guard let web3 = web3,
              let keystore = keystore,
              let address = keystore.addresses?.first else {
            throw BlockchainError.notInitialized
        }
        
        // Royalty Contract ABI
        let contractABI = """
        [
            {
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "tokenId",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint96",
                        "name": "percentage",
                        "type": "uint96"
                    }
                ],
                "name": "setRoyalty",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            }
        ]
        """
        
        guard let contractAddress = EthereumAddress(voiceNFTAddress) else {
            throw BlockchainError.invalidAddress
        }
        
        let contract = web3.contract(contractABI, at: contractAddress, abiVersion: 2)
        
        let percentageBasis = Int(percentage * 100) // Convert to basis points
        
        guard let transaction = contract?.write(
            "setRoyalty",
            parameters: [tokenId, percentageBasis] as [AnyObject],
            extraData: Data(),
            transactionOptions: .defaultOptions
        ) else {
            throw BlockchainError.transactionFailed
        }
        
        _ = try await transaction.send(password: password)
    }
    
    func listVoiceNFT(
        tokenId: String,
        price: Double,
        password: String
    ) async throws {
        guard let web3 = web3,
              let keystore = keystore,
              let address = keystore.addresses?.first else {
            throw BlockchainError.notInitialized
        }
        
        // Marketplace Contract ABI
        let contractABI = """
        [
            {
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "tokenId",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "price",
                        "type": "uint256"
                    }
                ],
                "name": "listItem",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            }
        ]
        """
        
        guard let contractAddress = EthereumAddress(marketplaceAddress) else {
            throw BlockchainError.invalidAddress
        }
        
        let contract = web3.contract(contractABI, at: contractAddress, abiVersion: 2)
        
        // Convert price to Wei
        let priceWei = BigUInt(price * 1e18)
        
        guard let transaction = contract?.write(
            "listItem",
            parameters: [tokenId, priceWei] as [AnyObject],
            extraData: Data(),
            transactionOptions: .defaultOptions
        ) else {
            throw BlockchainError.transactionFailed
        }
        
        _ = try await transaction.send(password: password)
    }
    
    // MARK: - Helper Methods
    
    private func uploadToIPFS(_ data: Data) async throws -> String {
        // Implement IPFS upload logic here
        // For MVP, you might want to use a service like Pinata or Infura's IPFS
        return "ipfs://YOUR_IPFS_HASH"
    }
}

// MARK: - Supporting Types

enum BlockchainError: Error {
    case notInitialized
    case invalidAddress
    case transactionFailed
    case uploadFailed
    case walletCreationFailed
}

struct VoiceNFTMetadata: Codable {
    let title: String
    let description: String
    let duration: TimeInterval
    let language: String
    let culturalTags: [String]
    let voiceCharacteristics: [String: String]
    let audioUrl: String
    
    enum CodingKeys: String, CodingKey {
        case title, description, duration, language
        case culturalTags = "cultural_tags"
        case voiceCharacteristics = "voice_characteristics"
        case audioUrl = "audio_url"
    }
}

// MARK: - Usage Example

/*
 How to use BlockchainService:
 
 let service = BlockchainService.shared
 
 // Create wallet
 Task {
     do {
         let walletAddress = try service.createWallet(password: "your_secure_password")
         print("New wallet created: \(walletAddress)")
         
         // Mint NFT
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
             ],
             audioUrl: "ipfs://YOUR_AUDIO_HASH"
         )
         
         let tokenId = try await service.mintVoiceNFT(
             metadata: metadata,
             password: "your_secure_password"
         )
         
         // Setup royalties (2.5%)
         try await service.setupRoyalties(
             tokenId: tokenId,
             percentage: 2.5,
             password: "your_secure_password"
         )
         
         // List on marketplace
         try await service.listVoiceNFT(
             tokenId: tokenId,
             price: 0.1,
             password: "your_secure_password"
         )
     } catch {
         print("Error: \(error)")
     }
 }
 */
