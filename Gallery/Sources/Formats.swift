import SwiftUI
import VitralTokens

/// How the gallery writes numbers and dates: in one locale it holds, never the device's. Vitral
/// formats nothing itself; an app hands every control its own `format`, the way this does.
/// Each one writes a `String` in that locale and shows it verbatim: `Text(_:format:)` would swap
/// in the environment's locale.
struct Formats {
    let locale: Locale

    /// A number with `places` decimals: 1.50 in English, 1,50 in Portuguese.
    func number(_ places: Int) -> @Sendable (Double) -> Text {
        { [locale] value in Text(verbatim: value.formatted(.number.precision(.fractionLength(places)).locale(locale))) }
    }

    /// A whole number, grouped: 5,000 in English, 5.000 in Portuguese.
    var whole: @Sendable (Int) -> Text {
        { [locale] value in Text(verbatim: value.formatted(.number.locale(locale))) }
    }

    /// A gain in signed decibels with `places` decimals (+6.0, −12.0), and −∞ for silence.
    func decibels(_ places: Int) -> @Sendable (Double) -> Text {
        { [locale] gain in
            gain > 0
                ? Text(verbatim: ValueScale.decibels(gain: gain).formatted(
                    .number.precision(.fractionLength(places)).sign(strategy: .always(includingZero: false)).locale(locale)
                ))
                : Text(verbatim: "−∞")
        }
    }

    /// A date, written out (9 May 2026; 9 de maio de 2026).
    var date: @Sendable (Date) -> Text {
        { [locale] date in Text(verbatim: date.formatted(Date.FormatStyle(date: .long, time: .omitted).locale(locale))) }
    }
}
