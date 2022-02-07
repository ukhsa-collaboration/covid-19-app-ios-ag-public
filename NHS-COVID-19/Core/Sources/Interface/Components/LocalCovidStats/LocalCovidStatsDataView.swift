//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import SwiftUI

public struct LocalCovidStatsDataView: View {
    
    let localStats: InterfaceLocalCovidStatsDaily
    let localAuthorityStats: InterfaceLocalCovidStatsDaily.LocalAuthorityStats
    
    public init(localCovidStats: InterfaceLocalCovidStatsDaily) {
        localStats = localCovidStats
        localAuthorityStats = localStats.lowerTierLocalAuthority
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: .halfSpacing) {
            Text(localAuthorityStats.name)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .styleAsHeading()
                .fixedSize(horizontal: false, vertical: true)
            
            Text(localize(.local_statistics_main_screen_local_authority_lower_tier))
                .styleAsBody()
                .fixedSize(horizontal: false, vertical: true)
            
            PositiveCovidView(localStats: localStats)
                .padding([.bottom, .top], .halfSpacing)
            Divider()
            AccordionView(
                localize(.local_statistics_main_screen_about_the_data_heading),
                displayMode: .singleWithChevron
            ) {
                Text(
                    localize(.local_statistics_main_screen_about_data_footnote_1(
                        startDate: setDateWith(offset: -13),
                        endDate: setDateWith(offset: -7)
                    ))
                )
                .padding(.bottom)
                Text(localize(.local_statistics_main_screen_about_data_footnote_2))
            }
            .accessibility(hidden: true)
        }
        .padding()
        .background(Color(.surface))
        .cornerRadius(.buttonCornerRadius)
    }
    
    private func setDateWith(offset: Int) -> Date {
        let lastFetchDate = GregorianDay(date: localStats.lastFetch, timeZone: .current)
        let adjustedDate = lastFetchDate.advanced(by: offset)
        return (adjustedDate.startDate(in: .current))
    }
}

public struct PositiveCovidView: View {
    let localStats: InterfaceLocalCovidStatsDaily
    
    public var body: some View {
        VStack(alignment: .leading, spacing: .halfSpacing) {
            
            Text(localize(.local_statistics_main_screen_people_tested_positive))
                .styleAsHeading()
                .fixedSize(horizontal: false, vertical: true)
            
            let startDate = localStats.lowerTierLocalAuthority.newCasesByPublishDateChange.lastUpdate.startDate(in: .current)
            Text(
                localize(
                    .local_statistics_main_screen_people_tested_positive_last_updated(
                        date: startDate)
                )
            )
            .styleAsSecondaryBody()
            .fixedSize(horizontal: false, vertical: true)
            
            PositiveCovidStatsView(localAuthorityStats: localStats.lowerTierLocalAuthority)
            RollingStatsView(localStats: localStats)
        }
    }
}

public struct PositiveCovidStatsView: View {
    let localAuthorityStats: InterfaceLocalCovidStatsDaily.LocalAuthorityStats
    public var body: some View {
        HStack(alignment: .top) {
            
            NumbersView(
                period: localize(.local_statistics_main_screen_daily),
                periodType: .daily,
                numberOfCases: localAuthorityStats.newCasesByPublishDate.value,
                trend: nil,
                changeValue: nil,
                percentChange: nil,
                authorityName: localAuthorityStats.name
                
            )
            
            Spacer()
            
            NumbersView(
                period: localize(.local_statistics_main_screen_last_7_days),
                periodType: .weekly,
                numberOfCases: localAuthorityStats.newCasesByPublishDateRollingSum.value,
                trend: localAuthorityStats.newCasesByPublishDateDirection.value,
                changeValue: localAuthorityStats.newCasesByPublishDateChange.value,
                percentChange: localAuthorityStats.newCasesByPublishDateChangePercentage.value,
                authorityName: localAuthorityStats.name
            )
        }
        .padding([.top, .bottom])
    }
}

public struct NumbersView: View {
    public let period: String
    public let periodType: PeriodType
    public let numberOfCases: Int?
    public let trend: InterfaceLocalCovidStatsDaily.LocalAuthorityStats.Direction?
    public let changeValue: Int?
    public let percentChange: Double?
    public let authorityName: String
    
    public enum PeriodType {
        case daily, weekly
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: .halfSpacing) {
            Text(period).styleAsBody()
                .fixedSize(horizontal: false, vertical: true)
            let cases = numberOfCases == nil ? "—" : String(numberOfCases!)
            Text(cases)
                .fontWeight(.semibold)
                .font(.title)
            
            if trend != nil && numberOfCases != nil {
                HStack {
                    Image(systemName: imageName())
                        .foregroundColor(trendIconColor())
                    Text(trendText())
                        .styleAsSecondaryBody()
                        .fixedSize(horizontal: false, vertical: true)
                    
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(accessibilityText()))
    }
    
    private func accessibilityText() -> String {
        switch periodType {
        case .daily:
            return dailyAccessibilityText()
        case .weekly:
            return weeklyAccessibilityText()
        }
    }
    
    func dailyAccessibilityText() -> String {
        if let numberOfCases = numberOfCases {
            return localize(.local_statistics_main_screen_daily_accessibility_text(positivTests: numberOfCases, localAuthority: authorityName))
        } else {
            return localize(.local_statistics_main_screen_daily_cases_not_available_accessibility_text(localAuthority: authorityName))
        }
    }
    
    func weeklyAccessibilityText() -> String {
        if let numberOfCases = numberOfCases {
            let positiveCasesAccessibility = localize(.local_statistics_main_screen_last_7_days_accessibility_text(positiveTests: numberOfCases))
            var trendDescriptionAccessibility: String = ""
            switch trend {
            case .up:
                if let percentChange = percentChange, let changeValue = changeValue {
                    trendDescriptionAccessibility = localize(.local_statistics_main_screen_last_seven_days_rate_up_accessibility_text(value: changeValue, percentValue: percentChange))
                }
                
            case .down:
                if let percentChange = percentChange, let changeValue = changeValue {
                    trendDescriptionAccessibility = localize(.local_statistics_main_screen_last_seven_days_rate_down_accessibility_text(value: changeValue, percentValue: percentChange))
                }
            case .same:
                trendDescriptionAccessibility = localize(.local_statistics_main_screen_last_seven_days_rate_no_change_accessibility_text)
            case .none:
                trendDescriptionAccessibility = ""
            }
            return positiveCasesAccessibility + "\n" + trendDescriptionAccessibility
        } else {
            return localize(.local_statistics_main_screen_last_7_days_not_available_accessibility_text)
        }
    }
    
    func trendIconColor() -> Color {
        switch trend {
        case .up:
            return Color(.errorRed)
        case .down:
            return Color(.nhsButtonGreen)
        case .same:
            return Color(.secondaryText)
        case .none:
            return .black
        }
    }
    
    func trendText() -> String {
        guard let changeValue = changeValue, let percentChange = percentChange else {
            return ""
        }
        
        switch trend {
        case .up:
            return localize(.local_statistics_main_screen_last_seven_days_rate_up(value: changeValue, percentageValue: percentChange))
        case .down:
            return localize(.local_statistics_main_screen_last_seven_days_rate_down(value: changeValue, percentageValue: percentChange))
        case .same:
            return localize(.local_statistics_main_screen_last_seven_days_rate_no_change)
        case .none:
            return "—"
        }
    }
    
    func imageName() -> String {
        switch trend {
        case .up:
            return "arrow.up.right.circle.fill"
        case .down:
            return "arrow.down.backward.circle.fill"
        case .same:
            return "arrow.right.circle.fill"
        case .none:
            return ""
        }
    }
}

public struct RollingStatsView: View {
    
    let localStats: InterfaceLocalCovidStatsDaily
    
    private var localAuthorityStats: InterfaceLocalCovidStatsDaily.LocalAuthorityStats {
        return localStats.lowerTierLocalAuthority
    }
    
    private var country: Country {
        return localStats.country.country
    }
    
    public var body: some View {
        
        Text(localize(.local_statistics_main_screen_cases_per_hundred_thousand))
            .styleAsSecondaryHeading()
            .accessibility(label: Text(localize(.local_statistics_main_screen_rolling_rate_100k_accessibility_text)))
            .fixedSize(horizontal: false, vertical: true)
        
        Text(
            localize(
                .local_statistics_main_screen_rolling_rate_last_updated(
                    date: localStats.country.lastUpdate.startDate(
                        in: .current)
                )
            )
        )
        .styleAsSecondaryBody()
        .padding(.bottom)
        .fixedSize(horizontal: false, vertical: true)
        
        HStack {
            Text(localAuthorityStats.name)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Text(rollingRateForLocalAuthority())
                .font(.title)
                .fontWeight(.semibold)
                .styleAsHeading()
                .fixedSize(horizontal: false, vertical: true)
            
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(accessibilityTextForLocalAuthority()))
        
        HStack {
            Text(copyForCountry())
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Text(rollingRateForCountryStringValue())
                .font(.title)
                .fontWeight(.semibold)
                .styleAsHeading()
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(accessibilityTextForCountry()))
    }
    
    private func copyForCountry() -> String {
        switch country {
        case .england:
            return localize(.local_statistics_main_screen_england_average)
        case .wales:
            return localize(.local_statistics_main_screen_wales_average)
        }
    }
    
    private func rollingRateForCountry() -> Double? {
        return localStats.country.newCasesBySpecimenDateRollingRate
        
    }
    
    private func rollingRateForCountryStringValue() -> String {
        if let rollingRate = rollingRateForCountry() {
            return String(format: "%.1f", rollingRate)
        } else {
            return "—"
        }
    }
    
    private func rollingRateForLocalAuthority() -> String {
        if let authoritiyRollingRate = localAuthorityStats.newCasesBySpecimenDateRollingRate.value {
            return String(format: "%.1f", authoritiyRollingRate)
        } else {
            return "—"
        }
    }
    
    private func accessibilityTextForLocalAuthority() -> String {
        if let authoritiyRollingRate = localAuthorityStats.newCasesBySpecimenDateRollingRate.value {
            return localize(
                .local_statistics_main_screen_local_authority_rate_100k_accessibility_text(
                    localAuthority: localAuthorityStats.name,
                    rolingRate: authoritiyRollingRate
                )
            )
        } else {
            return localize(
                .local_statistics_main_screen_local_authority_rate_100k_not_available_accessibility_text(
                    localAuthority: localAuthorityStats.name)
            )
        }
    }
    
    private func accessibilityTextForCountry() -> String {
        switch country {
        case .england:
            if let rollingRate = rollingRateForCountry() {
                return localize(
                    .local_statistics_main_screen_england_rate_100k_accessibility_text(rollingRate: rollingRate)
                )
            } else {
                return localize(
                    .local_statistics_main_screen_england_rate_100k_not_available_accessibility_text
                )
            }
        case .wales:
            if let rollingRate = rollingRateForCountry() {
                return localize(
                    .local_statistics_main_screen_wales_rate_100k_accessibility_text(rollingRate: rollingRate)
                )
            } else {
                return localize(.local_statistics_main_screen_wales_rate_100k_not_available_accessibility_text)
            }
        }
    }
}
