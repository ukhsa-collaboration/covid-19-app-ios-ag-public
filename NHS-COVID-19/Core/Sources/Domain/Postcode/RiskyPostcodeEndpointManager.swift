//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common

public class RiskyPostcodeEndpointManager {
    public enum PostcodeRisk: Equatable {
        case v1(Domain.PostcodeRisk)
        case v2(id: String, style: RiskyPostcodes.RiskStyle)
        
        var id: String {
            switch self {
            case .v1(let risk):
                return risk.rawValue
            case .v2(let id, _):
                return id
            }
        }
    }
    
    private let cachedResponseV1: CachedResponse<[Postcode: Domain.PostcodeRisk]>
    private let cachedResponseV2: CachedResponse<RiskyPostcodes>
    private var cancellable: AnyCancellable?
    
    let postcodeInfo: DomainProperty<(postcode: Postcode, risk: DomainProperty<PostcodeRisk?>)?>
    
    var isEmpty: Bool {
        cachedResponseV2.value.isEmpty && cachedResponseV1.value.isEmpty
    }
    
    init(distributeClient: HTTPClient, storage: FileStorage, postcode: AnyPublisher<Postcode?, Never>) {
        let cachedResponseV2 = CachedResponse(
            httpClient: distributeClient,
            endpoint: RiskyPostcodesEndpointV2(),
            storage: storage,
            name: "risky_postcodes_v2",
            initialValue: RiskyPostcodes(postDistricts: [:], riskLevels: [:])
        )
        
        let cachedResponseV1 = CachedResponse(
            httpClient: distributeClient,
            endpoint: RiskyPostcodesEndpointV1(),
            storage: storage,
            name: "risky_postcodes",
            initialValue: [:]
        )
        
        postcodeInfo = postcode.map { postcode -> (postcode: Postcode, risk: DomainProperty<PostcodeRisk?>)? in
            guard let postcode = postcode else { return nil }
            let risk = cachedResponseV1.$value.combineLatest(cachedResponseV2.$value)
                .map { v1, v2 -> PostcodeRisk? in
                    if let v2Risk = v2.riskStyle(for: postcode) {
                        return .v2(id: v2Risk.id, style: v2Risk.style)
                    } else if let v1Risk = v1[postcode] {
                        return .v1(v1Risk)
                    } else {
                        return nil
                    }
                }
                .domainProperty()
            
            return (postcode, risk)
        }
        .domainProperty()
        
        self.cachedResponseV1 = cachedResponseV1
        self.cachedResponseV2 = cachedResponseV2
    }
    
    func update() -> AnyPublisher<Void, Never> {
        cachedResponseV2.update()
            // make sure we fetch v1 after v2; so we first use data from v2 if available
            .append(Deferred(createPublisher: cachedResponseV1.update))
            .eraseToAnyPublisher()
    }
}
