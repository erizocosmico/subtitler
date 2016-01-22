import Foundation

private let chunkSize: Int = 65536

struct FileHash {
    var hash: String
    var size: UInt64
}

private func applyChunk(hash: UInt64, chunk: NSData) -> UInt64 {
    let bytes = UnsafeBufferPointer<UInt64>(
        start: UnsafePointer(chunk.bytes),
        count: chunk.length / sizeof(UInt64)
    )

    return bytes.reduce(hash, combine: &+)
}

private func getChunk(f: NSFileHandle, start: UInt64) -> NSData {
    f.seekToFileOffset(start)
    return f.readDataOfLength(chunkSize)
}

private func hexHash(hash: UInt64) -> String {
    return String(format:"%qx", hash)
}

private func fileSize(f: NSFileHandle) -> UInt64 {
    f.seekToEndOfFile()
    return f.offsetInFile
}

func fileHash(path: String) -> FileHash? {
    if let f = NSFileHandle(forReadingAtPath: path) {
        let size = fileSize(f)
        if size < UInt64(chunkSize) {
            return nil
        }

        let start = getChunk(f, start: 0)
        let end = getChunk(f, start: size - UInt64(chunkSize))
        var hash = size
        hash = applyChunk(hash, chunk: start)
        hash = applyChunk(hash, chunk: end)
        
        f.closeFile()
        return FileHash(hash: hexHash(hash), size: size)
    }
    return nil
}

