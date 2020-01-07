//
//  DataCompressor.swift
//  Transmitter
//
//  Created by Ernest Chechelski on 03/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//
import Compression
import Foundation

class DataCompressor {

    func compressData(_ data: Data, with: Algorithm, pageSize:Int = 2048) -> Data {

        var compressedData = Data()

        do {
            let outputFilter = try OutputFilter(.compress, using: .lzma) {
                if let data = $0 {
                    compressedData.append(data)
                }
            }

            var index = 0
            let bufferSize = data.count

            while true {
                let rangeLength = min(pageSize, bufferSize - index)

                let subdata = data.subdata(in: index ..< index + rangeLength)
                index += rangeLength

                try outputFilter.write(subdata)

                if (rangeLength == 0) {
                    break
                }
            }
        } catch {
            fatalError("Error occurred during encoding: \(error.localizedDescription).")
        }
        return compressedData
    }

    func decompressData(_ compressedData: Data, with: Algorithm, pageSize:Int = 2048) -> Data {
        var decompressedData = Data()
        do {
            var index = 0
            let bufferSize = compressedData.count

            let inputFilter = try InputFilter<Data>(.decompress, using: .lzma) {
                let rangeLength = min($0, bufferSize - index)
                let subdata = compressedData.subdata(in: index ..< index + rangeLength)
                index += rangeLength
                return subdata
            }
            while let page = try inputFilter.readData(ofLength: pageSize) {
                decompressedData.append(page)
            }
        } catch {
            fatalError("Error occurred during decoding: \(error.localizedDescription).")
        }
        return decompressedData
    }
}
