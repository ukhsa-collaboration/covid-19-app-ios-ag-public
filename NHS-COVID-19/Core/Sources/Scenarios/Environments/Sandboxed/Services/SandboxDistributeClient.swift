//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

class SandboxDistributeClient: HTTPClient {
    private let queue = DispatchQueue(label: "sandbox-distribution-client")
    
    let host: SandboxHost
    
    init(host: SandboxHost) {
        self.host = host
    }
    
    public func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        _perform(request).publisher
            .receive(on: queue)
            .eraseToAnyPublisher()
    }
    
    private func _perform(_ request: HTTPRequest) -> Result<HTTPResponse, HTTPRequestError> {
        if request.path == "/distribution/symptomatic-questionnaire" {
            return Result.success(.ok(with: .json(getQuestionnaire(host: host))))
        }
        if request.path == "/distribution/self-isolation" {
            return Result.success(.ok(with: .json(isolationConfig)))
        }
        if request.path == "/distribution/risky-post-districts-v2" {
            return .success(.ok(with: .json(riskyPostcodes)))
        }
        
        return Result.failure(.rejectedRequest(underlyingError: SimpleError("")))
    }
}

private let isolationConfig = """
{
  "england": {
    "indexCaseSinceSelfDiagnosisOnset": \(Sandbox.Config.Isolation.indexCaseSinceSelfDiagnosisOnset),
    "indexCaseSinceSelfDiagnosisUnknownOnset": \(Sandbox.Config.Isolation.indexCaseSinceSelfDiagnosisUnknownOnset),
    "contactCase": 3,
    "maxIsolation": \(Sandbox.Config.Isolation.indexCaseSinceSelfDiagnosisUnknownOnset),
    "indexCaseSinceTestResultEndDate": 5,
    "testResultPollingTokenRetentionPeriod": 28
  },
  "wales_v2": {
    "indexCaseSinceSelfDiagnosisOnset": \(Sandbox.Config.Isolation.indexCaseSinceSelfDiagnosisOnset),
    "indexCaseSinceSelfDiagnosisUnknownOnset": \(Sandbox.Config.Isolation.indexCaseSinceSelfDiagnosisUnknownOnset),
    "contactCase": 3,
    "maxIsolation": \(Sandbox.Config.Isolation.indexCaseSinceSelfDiagnosisUnknownOnset),
    "indexCaseSinceTestResultEndDate": 5,
    "testResultPollingTokenRetentionPeriod": 28
  }
}

"""

func getQuestionnaire(host: SandboxHost) -> String {
"""
{
  "symptoms": [
    {
      "title": {
        "en-GB": "\(Sandbox.Text.SymptomsList.cardHeading.rawValue)"
      },
      "description": {
        "en-GB": "\(Sandbox.Text.SymptomsList.cardContent.rawValue)"
      },
      "riskWeight": 1
    }
  ],
  "cardinal": {
    "title": {
      "ar": "هل لديك درجة حرارة مرتفعة؟",
      "bn": "আপনার কী জ্বর আছে?",
      "cy": "A oes gennych chi dymheredd uchel?",
      "en": "Do you have a high temperature?",
      "gu": "તમને ભારે તાવ છે?",
      "pa": "ਕੀ ਤੁਹਾਨੂੰ ਤੇਜ਼ ਬੁਖ਼ਾਰ ਹੈ?",
      "pl": "Czy masz podniesioną temperaturę?",
      "ro": "Aveți temperatură mare?",
      "so": "Ma leedahay heerkul sare?",
      "tr": "Ateşiniz var mı?",
      "ur": "کیا آپ کا درجۂ حرارت بڑھا ہوا ہے؟",
      "zh": "您发烧吗？"
    }
  },
  "noncardinal": {
    "title": {
      "ar": "هل لديك أي من هذه الاعراض؟",
      "bn": "আপনার কী এর মধ্যে কোনও উপসর্গ আছে?",
      "cy": "A oes gennych unrhyw un o’r symptomau hyn?",
      "en": "Do you have any of these symptoms?",
      "gu": "તમને આમાંથી કોઈ લક્ષણો છે?",
      "pa": "ਕੀ ਤੁਹਾਨੂੰ ਇਹਨਾਂ ਵਿੱਚੋਂ ਕੋਈ ਲੱਛਣ ਹੈ?",
      "pl": "Czy masz, któreś z tych objawów?",
      "ro": "Aveți vreunul dintre simptomele următoare?",
      "so": "Ma  leedahay wax astaamahan ah?",
      "tr": "Bu belirtilerden herhangi biri sizde var mı?",
      "ur": "کیا آپ میں ان میں سے کوئی علامات پائی جاتی ہیں؟",
      "zh": "您有这些症状吗？"
    },
    "description": {
      "ar": "رجفة أو قشعريرة\\n\\nسعال جديد مستمر\\n\\nفقدان أو تغير في حاسة الشم أو التذوق\\n\\nضيق في التنفس\\n\\nشعور بالتعب أو الإرهاق\\n\\nألم في جسدك\\n\\nصداع\\n\\nالتهاب في الحلق\\n\\nانسداد أو سيلان في الأنف\\n\\nفقدان الشهية\\n\\nإسهال\\n\\nشعور بالمرض أو انت مريض",
      "bn": "কাঁপুনি বা ঠান্ডা লাগা\\n\\nএকটি নতুন অবিরত কাশি\\n\\nআপনার ঘ্রাণশক্তি বা স্বাদ হারানো অথবা তার পরিবর্তন হওয়া\\n\\nহাঁফ ধরা\\n\\nক্লান্ত বা পরিশ্রান্ত বোধ করা \\n\\nগায়ে ব্যথা\\n\\nমথাধরা\\n\\nগলাব্যথা\\n\\nনাক বন্ধ বা নাক দিয়ে জল পড়া\\n\\nক্ষুধামান্দ্য\\n\\nউদরাময়\\n\\nঅসুস্থ বোধ করা বা অসুস্থ হওয়া",
      "cy": "Cryndod neu fferdod\\n\\nPeswch parhaus newydd\\n\\nColled neu newid i'ch synnwyr arogli neu flasu\\n\\nDiffyg anadl\\n\\nTeimlo'n flinedig neu luddedig\\n\\nCorff dolurus\\n\\nCur pen\\n\\nDolur gwddf\\n\\nTrwyn wedi blocio neu'n rhedeg\\n\\nColli awydd bwyd\\n\\nDolur rhydd\\n\\nTeimlo'n sâl neu fod yn sâl",
      "en": "Shivering or chills\\n\\nA new, continuous cough\\n\\nA loss or change to your sense of smell or taste\\n\\nShortness of breath\\n\\nFeeling tired or exhausted\\n\\nAn aching body\\n\\nA headache\\n\\nA sore throat\\n\\nA blocked or runny nose\\n\\nLoss of appetite\\n\\nDiarrhoea\\n\\nFeeling sick or being sick",
      "gu": "ટાઢ અથવા ઠંડી લાગવી\\n\\nનવી, સતત રહેતી ખાંસી\\n\\nગંધ અથવા સ્વાદની સંવેદના ચાલી જવી કે તેમાં ફેરફારો થવા\\n\\nશ્વાસ ચડવો\\n\\nથાક લાગવો કે થકાન અનુભવવી\\n\\nશરીરમાં કળતર\\n\\nમાથાનો દુખાવો\\n\\nગળામાં સોજો\\n\\nનાક જામ થવું કે દદડવું\\n\\nભૂખ મરી જવી\\n\\nડાયેરિયા\\n\\nબિમારી જેવું લાગવું કે બિમાર હોવું",
      "pa": "ਕੰਬਣਾ ਜਾਂ ਬਹੁਤ ਠੰਢ ਲੱਗਣੀ\\n\\nਨਵੀਂ, ਨਿਰੰਤਰ ਖੰਘ\\n\\nਤੁਹਾਡੇ ਸੁੰਘਣ ਜਾਂ ਸੁਆਦ ਮਹਿਸੂਸ ਕਰਨ ਵਿੱਚ ਤਬਦੀਲੀ, ਜਾਂ ਇਸਦਾ ਖਤਮ ਹੋ ਜਾਣਾ\\n\\nਸਾਹ ਚੜ੍ਹਨਾ\\n\\nਥਕਾਵਟ ਜਾਂ ਹੰਭਿਆ ਮਹਿਸੂਸ ਕਰਨਾ\\n\\nਦਰਦ ਕਰਦਾ ਸਰੀਰ\\n\\nਸਿਰ-ਦਰਦ\\n\\nਗਲੇ ਦੀ ਸੋਜ਼\\n\\nਬੰਦ ਜਾਂ ਵਗਦਾ ਨੱਕ\\n\\nਭੁੱਖ ਨਾ ਲਗਣੀ\\n\\nਦਸਤ\\n\\nਬਿਮਾਰ ਮਹਿਸੂਸ ਕਰਨਾ ਜਾਂ ਬਿਮਾਰ ਹੋਣਾ",
      "pl": "Dygotanie lub dreszcze\\n\\nNowy ciągły kaszel\\n\\nUtrata lub zmiana zmysłu węchu lub smaku\\n\\nZadyszka\\n\\nUczucie zmęczenia lub wyczerpania\\n\\nBolące ciało\\n\\nBól głowy\\n\\nBól gardła\\n\\nZatkany nos lub katar\\n\\nUtrata apetytu\\n\\nBiegunka\\n\\nNudności lub wymioty",
      "ro": "Tremurat sau frisoane\\n\\nO tuse nouă, continuă\\n\\nPierderea sau modificarea mirosului sau a gustului\\n\\nRespirație dificilă\\n\\nSenzație de oboseală sau epuizare\\n\\nDureri în tot corpul\\n\\nMigrenă\\n\\nDureri în gât\\n\\nNas înfundat sau care curge mult\\n\\nPierderea apetitului\\n\\nDiaree\\n\\nSenzație de rău sau stare de rău",
      "so": "Gariir ama qadhqadhyo\\n\\nqufac cusub, oo joogto ah\\n\\nWaayida ama isbeddelka dareenka urta ama dhadhanka\\n\\nNeefta oo gaaban\\n\\ndaalan ama aad u daalan\\n\\nJidh xanuunaya\\n\\nMadax xanuun\\n\\nHunguri xanuunka\\n\\nSan xidhan ama duufku ka socdo\\n\\nWaayida dareenka doonida cuntadda\\n\\nShuban\\n\\nDareemaya bukaan ama jiran yahay",
      "tr": "Titreme veya üşüme\\n\\nYeni başlayan, devamlı öksürük\\n\\nKoku veya tat almada değişiklik veya koku veya tat alma kaybı\\n\\nNefes darlığı\\n\\nYorgunluk veya bitkinlik\\n\\nVücut ağrısı\\n\\nBaş ağrısı\\n\\nBoğaz ağrısı\\n\\nBurunda tıkanıklık veya akıntı\\n\\nİştah kaybı\\n\\nİshal\\n\\nMide bulantısı veya kusma",
      "ur": "کپکپی یا ٹھنڈ لگنا\\n\\nنئی، مسلسل کھانسی\\n\\nآپ کی سونگھنے یا چکھنے کی حس کا ختم ہونا یا اس میں تبدیلی آنا\\n\\nسانس پھولنا\\n\\nتھکان یا تھکاوٹ محسوس کرنا\\n\\nبدن درد\\n\\nسر درد\\n\\nگلے میں تکلیف\\n\\nبند یا بہتی ناک\\n\\nبھوک نہ لگنا\\n\\nدست\\n\\nبیمار محسوس کرنا یا بیمار ہونا",
      "zh": "颤抖或寒颤\\n\\n新发性持续咳嗽\\n\\n嗅觉或味觉出现丧失或改变\\n\\n呼吸急促\\n\\n感到疲倦或疲惫\\n\\n身体疼痛\\n\\n头疼\\n\\n喉咙痛\\n\\n鼻塞或流鼻涕\\n\\n食欲不振\\n\\n腹泻\\n\\n感觉不适或生病"
    }
  },
  "riskThreshold": 0.5,
  "symptomsOnsetWindowDays": 5,
  "isSymptomaticSelfIsolationForWalesEnabled": \(host.initialState.isSymptomaticSelfIsolationForWalesEnabled)
}
"""
}

private func policyData(alertLevel: Int) -> String {
    """
    {
        "localAuthorityRiskTitle": {
            "en": "[local authority] ([postcode]) is in Local Alert Level \(alertLevel)"
        },
        "heading": {
            "en": "Coronavirus cases are very high in your area"
        },
        "content": {
            "en": "The restrictions placed on areas with a very high level of infections can vary and are based on discussions between central and local government. You should check the specific rules in your area."
        },
        "footer": {
            "en": "Find out what rules apply in your area to help reduce the spread of coronavirus."
        },
        "policies": [
            {
                "policyIcon": "default-icon",
                "policyHeading": {
                    "en": "Default"
                },
                "policyContent": {
                    "en": "Venues must close…"
                }
            },
            {
                "policyIcon": "meeting-people",
                "policyHeading": {
                    "en": "Meeting people"
                },
                "policyContent": {
                    "en": "No household mixing indoors or outdoors in venues or private gardens. Rule of six applies in outdoor public spaces like parks."
                }
            },
            {
                "policyIcon": "bars-and-pubs",
                "policyHeading": {
                    "en": "Bars and pubs"
                },
                "policyContent": {
                    "en": "Venues not serving meals will be closed."
                }
            },
            {
                "policyIcon": "worship",
                "policyHeading": {
                    "en": "Worship"
                },
                "policyContent": {
                    "en": "These remain open, subject to indoor or outdoor venue restrictions."
                }
            },
            {
                "policyIcon": "overnight-stays",
                "policyHeading": {
                    "en": "Overnight Stays"
                },
                "policyContent": {
                    "en": "If you have to travel, avoid staying overnight."
                }
            },
            {
                "policyIcon": "education",
                "policyHeading": {
                    "en": "Education"
                },
                "policyContent": {
                    "en": "Schools, colleges and universities remain open, with restrictions."
                }
            },
            {
                "policyIcon": "travelling",
                "policyHeading": {
                    "en": "Travelling"
                },
                "policyContent": {
                    "en": "Avoid travelling around or leaving the area, other than for work, education, youth services or because of caring responsibilities."
                }
            },
            {
                "policyIcon": "exercise",
                "policyHeading": {
                    "en": "Exercise"
                },
                "policyContent": {
                    "en": "Classes and organised adult sport are allowed outdoors and only allowed indoors if no household mixing. Sports for the youth and disabled is allowed indoors and outdoors."
                }
            },
            {
                "policyIcon": "weddings-and-funerals",
                "policyHeading": {
                    "en": "Weddings and Funerals"
                },
                "policyContent": {
                    "en": "Up to 15 guests for weddings, 30 for funerals and 15 for wakes. Wedding receptions not permitted."
                }
            },
            {
                "policyIcon": "businesses",
                "policyHeading": {
                    "en": "Businesses"
                },
                "policyContent": {
                    "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                }
            },
            {
                "policyIcon": "retail",
                "policyHeading": {
                    "en": "Retail"
                },
                "policyContent": {
                    "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                }
            },
            {
                "policyIcon": "entertainment",
                "policyHeading": {
                    "en": "Entertainment"
                },
                "policyContent": {
                    "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                }
            },
            {
                "policyIcon": "personal-care",
                "policyHeading": {
                    "en": "Personal Care"
                },
                "policyContent": {
                    "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                }
            },
            {
                "policyIcon": "large-events",
                "policyHeading": {
                    "en": "Large Events"
                },
                "policyContent": {
                    "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                }
            },
            {
                "policyIcon": "clinically-extremely-vulnerable",
                "policyHeading": {
                    "en": "Clinically Extremely Vulnerable"
                },
                "policyContent": {
                    "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                }
            },
            {
                "policyIcon": "social-distancing",
                "policyHeading": {
                    "en": "Social Distancing"
                },
                "policyContent": {
                    "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                }
            },
            {
                "policyIcon": "face-coverings",
                "policyHeading": {
                    "en": "Face Coverings"
                },
                "policyContent": {
                    "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                }
            },
            {
                "policyIcon": "meeting-outdoors",
                "policyHeading": {
                    "en": "Meeting Outdoors"
                },
                "policyContent": {
                    "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                }
            },
            {
                "policyIcon": "meeting-indoors",
                "policyHeading": {
                    "en": "Meeting Indoors"
                },
                "policyContent": {
                    "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                }
            },
            {
                "policyIcon": "work",
                "policyHeading": {
                    "en": "Work"
                },
                "policyContent": {
                    "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                }
            },
            {
                "policyIcon": "international-travel",
                "policyHeading": {
                    "en": "International Travel"
                },
                "policyContent": {
                    "en": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                }
            }
        ]
    }
    """
}

private let riskyPostcodes = """
{
    "postDistricts" : {
        "SW12": "green",
        "SW13": "amber",
        "SW14": "yellow",
        "SW15": "red",
        "SW16": "neutral",
        "SW17": "maroon",
        "SW21": "black",
    },
    "localAuthorities": {
        "E09000021": "black",
        "E09000022": "green",
        "E09000023": "amber",
        "E09000024": "yellow",
        "E09000025": "red",
        "E09000026": "neutral",
        "E09000032": "maroon",

    },
    "riskLevels" : {
        "black": {
            "colorScheme": "neutral",
            "colorSchemeV2": "black",
            "name": { "en": "[postcode] is in Local Alert Level 3" },
            "heading": {},
            "content": {},
            "linkTitle": { "en": "Restrictions in your area" },
            "linkUrl": {},
            "policyData": \(policyData(alertLevel: 3))
        },
        "maroon": {
            "colorScheme": "neutral",
            "colorSchemeV2": "maroon",
            "name": { "en": "[postcode] is in Local Alert Level 3" },
            "heading": {},
            "content": {},
            "linkTitle": { "en": "Restrictions in your area" },
            "linkUrl": {},
            "policyData": \(policyData(alertLevel: 3))
        },
        "red": {
            "colorScheme": "red",
            "colorSchemeV2": "red",
            "name": { "en": "[postcode] is in Local Alert Level 3" },
            "heading": {},
            "content": {},
            "linkTitle": { "en": "Restrictions in your area" },
            "linkUrl": {},
            "policyData": \(policyData(alertLevel: 3))
        },
        "amber": {
            "colorScheme": "amber",
            "colorSchemeV2": "amber",
            "name": { "en": "[postcode] is in Local Alert Level 3" },
            "heading": {},
            "content": {},
            "linkTitle": { "en": "Restrictions in your area" },
            "linkUrl": {},
            "policyData": \(policyData(alertLevel: 3))
        },
        "yellow": {
            "colorScheme": "yellow",
            "colorSchemeV2": "yellow",
            "name": { "en": "[postcode] is in Local Alert Level 2" },
            "heading": {},
            "content": {},
            "linkTitle": { "en": "Restrictions in your area" },
            "linkUrl": {},
            "policyData": \(policyData(alertLevel: 2))
        },
        "green": {
            "colorScheme": "green",
            "colorSchemeV2": "green",
            "name": { "en": "[postcode] is in Local Alert Level 1" },
            "heading": {},
            "content": {},
            "linkTitle": { "en": "Restrictions in your area" },
            "linkUrl": {},
            "policyData": \(policyData(alertLevel: 1))
        },
        "neutral": {
            "colorScheme": "neutral",
            "colorSchemeV2": "neutral",
            "name": { "en": "[postcode] is in Local Alert Level 1" },
            "heading": {},
            "content": {},
            "linkTitle": { "en": "Restrictions in your area" },
            "linkUrl": {},
            "policyData": \(policyData(alertLevel: 1))
        }
    }
}
"""
