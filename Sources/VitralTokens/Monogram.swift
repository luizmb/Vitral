/// A name's two letters: the first of each of its first two words, upper case. What tells
/// "Highway to Hell" (HT) from "Hells Bells" (HB) on a small disc.
public enum Initials {
    public static func of(_ name: String) -> String {
        name.split(separator: " ").prefix(2).compactMap { $0.first.map(String.init) }.joined().uppercased()
    }
}

public extension ColorToken {
    /// The colours `stable(for:)` picks from: the washes and the accent, nothing grey (grey reads
    /// as "no colour").
    static let stablePalette: [ColorToken] = [.washTeal, .washViolet, .washPink, .washAmber, .washGreen, .accent, .counterAccent]

    /// A colour for `name`, the same one every time, on every device and every launch, so a thing
    /// with no picture (a band, a person, a project) is still known by its colour at a glance.
    /// Hashed with FNV-1a over the name's UTF-8 bytes, never `hashValue`, which is seeded per
    /// process.
    static func stable(for name: String, palette: [ColorToken] = stablePalette) -> ColorToken {
        palette.isEmpty ? .inkMuted : palette[Int(fnv1a(name) % UInt64(palette.count))]
    }

    internal static func fnv1a(_ text: String) -> UInt64 {
        text.utf8.reduce(0xCBF2_9CE4_8422_2325) { hash, byte in (hash ^ UInt64(byte)) &* 0x0000_0100_0000_01B3 }
    }
}
