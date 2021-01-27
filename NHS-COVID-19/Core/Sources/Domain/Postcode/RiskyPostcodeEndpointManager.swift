//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common

public class RiskyPostcodeEndpointManager {
    public struct PostcodeRisk: Equatable {
        public enum RiskType {
            case postcode
            case localAuthority
        }
        
        let id: String
        public let style: RiskyPostcodes.RiskStyle
        public let type: RiskType
        
        public init(id: String, style: RiskyPostcodes.RiskStyle, type: RiskType) {
            self.id = id
            self.style = style
            self.type = type
        }
    }
    
    private let cachedResponseV2: CachedResponse<RiskyPostcodes>
    private var cancellable: AnyCancellable?
    
    let postcodeInfo: DomainProperty<(postcode: Postcode, localAuthority: LocalAuthority?, risk: DomainProperty<PostcodeRisk?>)?>
    
    var isEmpty: Bool {
        cachedResponseV2.value.isEmpty
    }
    
    init(distributeClient: HTTPClient, storage: FileStoring, postcode: AnyPublisher<Postcode?, Never>, localAuthority: AnyPublisher<LocalAuthority?, Never>) {
        let cachedResponseV2 = CachedResponse(
            httpClient: distributeClient,
            endpoint: RiskyPostcodesEndpointV2(),
            storage: storage,
            name: "risky_postcodes_v2",
            initialValue: RiskyPostcodes(postDistricts: [:], riskLevels: [:])
        )
        
        postcodeInfo = postcode.combineLatest(localAuthority) { postcode, localAuthority -> (postcode: Postcode, localAuthority: LocalAuthority?, risk: DomainProperty<PostcodeRisk?>)? in
            guard let postcode = postcode else { return nil }
            let risk = cachedResponseV2.$value
                .map { v2 -> PostcodeRisk? in
                    if let localAuthority = localAuthority,
                        let v2LocalAuthorityRisk = v2.riskStyle(for: localAuthority.id) {
                        return PostcodeRisk(id: v2LocalAuthorityRisk.id, style: v2LocalAuthorityRisk.style, type: .localAuthority)
                    } else if let v2Risk = v2.riskStyle(for: postcode) {
                        return PostcodeRisk(id: v2Risk.id, style: v2Risk.style, type: .postcode)
                    } else {
                        return nil
                    }
                }
                .domainProperty()
            return (postcode, localAuthority, risk)
        }
        .domainProperty()
        
        self.cachedResponseV2 = cachedResponseV2
    }
    
    func update() -> AnyPublisher<Void, Never> {
        cachedResponseV2.update().eraseToAnyPublisher()
    }
}
