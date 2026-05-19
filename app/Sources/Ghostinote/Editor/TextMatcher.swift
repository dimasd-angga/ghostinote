import Foundation

enum TextMatcher {
    static func ranges(of needle: String, in haystack: String) -> [NSRange] {
        let trimmed = needle
        guard !trimmed.isEmpty else { return [] }
        let nsString = haystack as NSString
        var ranges: [NSRange] = []
        var searchStart = 0
        while searchStart < nsString.length {
            let searchRange = NSRange(location: searchStart, length: nsString.length - searchStart)
            let found = nsString.range(of: trimmed, options: .caseInsensitive, range: searchRange)
            if found.location == NSNotFound { break }
            ranges.append(found)
            // Advance by at least one to avoid infinite loop on empty match (defensive).
            searchStart = max(found.location + found.length, found.location + 1)
        }
        return ranges
    }
}
