//
//  NightWatchmanService.swift
//  mservice-cachewarmer
//
//  Copyright © 2018 Christopher Reitz. Licensed under the MIT license.
//  See LICENSE file in the project root for full license information.
//

import Vapor

protocol NightWatchmanServiceType: Service {
    func entranceAllowed(on date: Date) -> Bool
}

final class NightWatchmanService: NightWatchmanServiceType {

    // MARK: - Properties

    private var calendar = Calendar(identifier: .gregorian)
    private let startHour: Int
    private let endHour: Int

    // MARK: - Initializers

    init(timeZone: TimeZone, startHour: Int, endHour: Int) {
        calendar.timeZone = timeZone
        self.startHour = startHour
        self.endHour = endHour
    }

    // MARK: - public

    func entranceAllowed(on date: Date = Date()) -> Bool {
        let dateHour = calendar.component(.hour, from: date)
        var fallsBetween: Bool

        if startHour > endHour {
            fallsBetween = dateHour >= startHour || dateHour < endHour
        } else {
            fallsBetween = (startHour..<endHour).contains(dateHour)
        }

        return !fallsBetween
    }
}
