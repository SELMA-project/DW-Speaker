//
//  Locale+displayName.swift
//  DW Speaker
//
//  Created by Andy Giefer on 03.08.23.
//

import Foundation

extension Locale {
    var displayName: String {
        let currentLocale = Locale.current
        let languageName = currentLocale.localizedString(forIdentifier: self.identifier) ?? "unknown language"
        return languageName
    }
}
