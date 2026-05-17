//
//  MomsyApp.swift
//  Momsy
//
//  Created by Ruslan Abdulov on 16.05.26.
//

import SwiftUI

@main
struct MomsyApp: App {
    @AppStorage("appTheme") private var appTheme = "system"

    private var resolvedColorScheme: ColorScheme? {
        switch appTheme {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(resolvedColorScheme)
        }
    }
}
