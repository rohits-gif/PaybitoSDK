//
//  ZipBuilder.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 11/05/26.
//

import Foundation
import Compression

// Minimal ZIP writer — no external dependency
struct ZipBuilder {

    private var entries: [(name: String, data: Data)] = []

    mutating func addFile(_ name: String, data: Data) {
        entries.append((name, data))
    }

    func build() -> Data {
        var zip        = Data()
        var centralDir = Data()
        var offsets    = [UInt32]()

        for entry in entries {
            let offset   = UInt32(zip.count)
            offsets.append(offset)

            let nameData = entry.name.data(using: .utf8)!
            let crc      = crc32(entry.data)

            // Local file header
            zip += uint32LE(0x04034B50)          // signature
            zip += uint16LE(20)                  // version needed
            zip += uint16LE(0)                   // flags
            zip += uint16LE(0)                   // compression = stored
            zip += uint16LE(0)                   // mod time
            zip += uint16LE(0)                   // mod date
            zip += uint32LE(crc)
            zip += uint32LE(UInt32(entry.data.count))   // compressed size
            zip += uint32LE(UInt32(entry.data.count))   // uncompressed size
            zip += uint16LE(UInt16(nameData.count))
            zip += uint16LE(0)                   // extra field length
            zip += nameData
            zip += entry.data
        }

        let cdOffset = UInt32(zip.count)

        for (i, entry) in entries.enumerated() {
            let nameData = entry.name.data(using: .utf8)!
            let crc      = crc32(entry.data)

            centralDir += uint32LE(0x02014B50)   // central dir signature
            centralDir += uint16LE(20)           // version made by
            centralDir += uint16LE(20)           // version needed
            centralDir += uint16LE(0)            // flags
            centralDir += uint16LE(0)            // compression
            centralDir += uint16LE(0)            // mod time
            centralDir += uint16LE(0)            // mod date
            centralDir += uint32LE(crc)
            centralDir += uint32LE(UInt32(entry.data.count))
            centralDir += uint32LE(UInt32(entry.data.count))
            centralDir += uint16LE(UInt16(nameData.count))
            centralDir += uint16LE(0)            // extra
            centralDir += uint16LE(0)            // comment
            centralDir += uint16LE(0)            // disk start
            centralDir += uint16LE(0)            // internal attr
            centralDir += uint32LE(0)            // external attr
            centralDir += uint32LE(offsets[i])
            centralDir += nameData
        }

        zip += centralDir

        // End of central directory
        zip += uint32LE(0x06054B50)
        zip += uint16LE(0)                       // disk number
        zip += uint16LE(0)                       // disk with cd
        zip += uint16LE(UInt16(entries.count))
        zip += uint16LE(UInt16(entries.count))
        zip += uint32LE(UInt32(centralDir.count))
        zip += uint32LE(cdOffset)
        zip += uint16LE(0)                       // comment length

        return zip
    }

    // MARK: - Helpers

    private func uint16LE(_ v: UInt16) -> Data {
        var val = v.littleEndian
        return Data(bytes: &val, count: 2)
    }

    private func uint32LE(_ v: UInt32) -> Data {
        var val = v.littleEndian
        return Data(bytes: &val, count: 4)
    }

    private func crc32(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xFFFFFFFF
        for byte in data {
            crc ^= UInt32(byte)
            for _ in 0..<8 {
                if crc & 1 == 1 { crc = (crc >> 1) ^ 0xEDB88320 }
                else             { crc >>= 1 }
            }
        }
        return crc ^ 0xFFFFFFFF
    }
}

private func += (lhs: inout Data, rhs: Data) { lhs.append(rhs) }
