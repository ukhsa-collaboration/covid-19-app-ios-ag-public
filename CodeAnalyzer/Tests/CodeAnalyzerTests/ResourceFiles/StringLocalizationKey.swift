public enum StringLocalizationKey: String, CaseIterable {
    case onboarding_strapline_title
    case onboarding_strapline_accessiblity_label
    case home_strapline_title
    case home_strapline_accessiblity_label
    case home_strapline_accessiblity_label_wls
}

public enum ParameterisedStringLocalizable {
    
    enum Key: String, CaseIterable {
        case numbered_list_item = "numbered_list_item %ld %@"
        case risk_level_banner_text = "risk_level_banner_text %@ %@"
        case checkin_confirmation_date = "checkin_confirmation_date %@"
    }
    
    case numbered_list_item(index: Int, text: String)
    case risk_level_banner_text(postcode: String, risk: String)    
}
