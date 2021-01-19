//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Integration
import Localization
import Interface
import SwiftUI
import UIKit

public class LanguageSelectionScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Language Selection"
    
    static var appController: AppController {
        NavigationAppController { parent in
            LanguageSelectionViewController(
                viewModel: .init(
                    currentSelection: .systemPreferred,
                    selectableDefault: defaultLanguage,
                    selectableOverrides: languages
                ),
                interacting: Interactor { selectionState in
                    switch selectionState {
                    case .systemPreferred:
                        parent.showAlert(title: "You picked the system language")
                    case .custom(let locale):
                        parent.showAlert(title: "You chose to override the system language with \(locale)")
                    }
                }
            )
        }
    }
}

private struct Interactor: LanguageSelectionViewController.Interacting {
    let completion: (LocaleConfiguration) -> Void
    
    func didSelect(configuration: LocaleConfiguration) {
        completion(configuration)
    }
}

private let defaultLanguage = SelectableLanguage(isoCode: "en", exonym: "English", endonym: "English")

private let languages = [
    SelectableLanguage(isoCode: "en", exonym: "English", endonym: "English"),
    SelectableLanguage(isoCode: "ar", exonym: "Arabic", endonym: "اَلْعَرَبِيَّةُ‎"),
    SelectableLanguage(isoCode: "bn", exonym: "Bengali", endonym: "বাংলা"),
    SelectableLanguage(isoCode: "zh", exonym: "Chinese Simplified", endonym: "汉语"),
    SelectableLanguage(isoCode: "gu", exonym: "Gujarati (India)", endonym: "ગુજરાતી"),
    SelectableLanguage(isoCode: "pl", exonym: "Polish", endonym: "Polski"),
    SelectableLanguage(isoCode: "pa", exonym: "Punjabi", endonym: "ਪੰਜਾਬੀ"),
    SelectableLanguage(isoCode: "ro", exonym: "Romanian", endonym: "limba română"),
    SelectableLanguage(isoCode: "som", exonym: "Somali", endonym: "Af-Soomaali"),
    SelectableLanguage(isoCode: "tur", exonym: "Turkish", endonym: "Turkçe"),
    SelectableLanguage(isoCode: "ur", exonym: "Urdu", endonym: "اُردُو‎"),
    SelectableLanguage(isoCode: "cy", exonym: "Welsh", endonym: "Cymraeg"),
    
]
