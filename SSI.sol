// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SSI {
    uint256 public docCount = 0;

    struct Document {
        uint256 id;
        string user_did;
        string did;
        string ipfs;
        string signature;
        bool status;
    }

    mapping(uint256 => Document) public documents;

    function addDocument(string memory user_did, string memory did, string memory ipfs) public {
        documents[docCount] = Document(docCount, user_did, did, ipfs, "", false);
        docCount++;
    }

    function getDocCount() public view returns (uint256) {
        return docCount;
    }

    function getDocument(uint256 id) public view returns (string memory user_did, string memory did, string memory ipfs, bool status) {
        Document memory doc = documents[id];
        return (doc.user_did, doc.did, doc.ipfs, doc.status);
    }

    function verifyDocument(uint256 id, string memory user_did, string memory did, string memory ipfs, bytes memory signature) public {
    require(id < docCount, "Invalid document ID");
    Document storage doc = documents[id];
    
    string memory message = string(abi.encodePacked(user_did, did, ipfs));
    bytes32 messageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(bytes(message))));
    
    address recoveredAddress = ECDSA.recover(messageHash, signature);
    
    require(keccak256(abi.encodePacked(recoveredAddress)) == keccak256(abi.encodePacked(user_did)), "Signature verification failed");
    
    doc.user_did = user_did;
    doc.did = did;
    doc.ipfs = ipfs;
    doc.signature = string(signature);
    doc.status = true;
}


    function totalDocuments() public view returns (uint256) {
        return docCount;
    }

    function showAllDocs(string memory user_did) public view returns (uint256[] memory) {
        uint256[] memory indices = new uint256[](docCount);
        uint256 count = 0;
        for (uint256 i = 0; i < docCount; i++) {
            if (keccak256(abi.encodePacked((documents[i].user_did))) == keccak256(abi.encodePacked((user_did)))) {
                indices[count] = i;
                count++;
            }
        }
        uint256[] memory result = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = indices[i];
        }
        return result;
    }
}
