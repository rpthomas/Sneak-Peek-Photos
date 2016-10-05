//
//  Crypto.swift
//  Sneak Peek Photos
//
//  Created by Roland Thomas on 6/19/16.
//  Copyright © 2016 Jedisware, LLC. All rights reserved.
//

import Foundation

extension String {
    
    /*
 http://sketchytech.blogspot.com/2016/02/resurrecting-commoncrypto-in-swift-for.html
 let encodedECB = message.aesEncrypt(keyString, iv: iv, options: kCCOptionPKCS7Padding + kCCOptionECBMode)

 let unencodeECB = encodedECB?.aesDecrypt(keyString, iv: iv, options: kCCOptionPKCS7Padding + kCCOptionECBMode)

    */
 
    func aesEncrypt(key:String, iv:String, options:Int = kCCOptionPKCS7Padding) -> String? {
        if let keyData = key.dataUsingEncoding(NSUTF8StringEncoding),
            data = self.dataUsingEncoding(NSUTF8StringEncoding),
            cryptData    = NSMutableData(length: Int((data.length)) + kCCBlockSizeAES128) {
            
            
            let keyLength              = size_t(kCCKeySizeAES128)
            let operation: CCOperation = UInt32(kCCEncrypt)
            let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
            let options:   CCOptions   = UInt32(options)
            
            
            
            var numBytesEncrypted :size_t = 0
            
            let cryptStatus = CCCrypt(operation,
                                      algoritm,
                                      options,
                                      keyData.bytes, keyLength,
                                      iv,
                                      data.bytes, data.length,
                                      cryptData.mutableBytes, cryptData.length,
                                      &numBytesEncrypted)
            
            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                cryptData.length = Int(numBytesEncrypted)
                let base64cryptString = cryptData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                return base64cryptString
                
                
            }
            else {
                return nil
            }
        }
        return nil
    }
    
    func aesDecrypt(key:String, iv:String, options:Int = kCCOptionPKCS7Padding) -> String? {
        if let keyData = key.dataUsingEncoding(NSUTF8StringEncoding),
            data = NSData(base64EncodedString: self, options: .IgnoreUnknownCharacters),
            cryptData    = NSMutableData(length: Int((data.length)) + kCCBlockSizeAES128) {
            
            let keyLength              = size_t(kCCKeySizeAES128)
            let operation: CCOperation = UInt32(kCCDecrypt)
            let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
            let options:   CCOptions   = UInt32(options)
            
            var numBytesEncrypted :size_t = 0
            
            let cryptStatus = CCCrypt(operation,
                                      algoritm,
                                      options,
                                      keyData.bytes, keyLength,
                                      iv,
                                      data.bytes, data.length,
                                      cryptData.mutableBytes, cryptData.length,
                                      &numBytesEncrypted)
            
            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                cryptData.length = Int(numBytesEncrypted)
                let unencryptedMessage = String(data: cryptData, encoding:NSUTF8StringEncoding)
                return unencryptedMessage
            }
            else {
                return nil
            }
        }
        return nil
    }
    
    
}