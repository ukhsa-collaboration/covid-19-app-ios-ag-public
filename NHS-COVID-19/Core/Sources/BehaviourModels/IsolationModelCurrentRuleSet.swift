//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

public struct IsolationModelCurrentRuleSet: IsolationRuleSet {
    
    public static let unreachableStatePredicates: [StatePredicate] = [
        // Symptomatic and positive test isolations finish together.
        StatePredicate(
            symptomatic: [.notIsolatingAndHadSymptomsPreviously],
            positiveTest: [.isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest]
        ),
        StatePredicate(
            symptomatic: [.isolating],
            positiveTest: [.notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHadUnconfirmedTestPreviously, .notIsolatingAndHasNegativeTest]
        ),
        
        // A symptomatic and unconfirmed positive test isolation will not happen at the same time.
        StatePredicate(
            symptomatic: [.isolating],
            positiveTest: [.isolatingWithUnconfirmedTest]
        ),
        
        // As a result of the above, finished symptomatic and unconfirmed positive test isolation will not happen at the same time.
        StatePredicate(
            symptomatic: [.notIsolatingAndHadSymptomsPreviously],
            positiveTest: [.notIsolatingAndHadUnconfirmedTestPreviously]
        ),
        
        // A contact case and unconfirmed positive test isolation will not happen at the same time.
        StatePredicate(
            contact: [.isolating],
            positiveTest: [.isolatingWithConfirmedTest]
        ),
        
        // To simplify logic, contact case isolation is always removed when we have a positive test isolation.
        StatePredicate(
            contact: [.notIsolatingAndHadRiskyContactPreviously],
            positiveTest: [.isolatingWithConfirmedTest]
        ),
    ]
    
    public static let rulesRespondingToExternalEvents: [Rule] = [
        Rule(
            """
            A risky contact will start a contact isolation.
            Risky contacts are only considered when the user is not already in contact or confirmed positive isolation.
            See below for exceptions if contact is old.
            """,
            predicate: StatePredicate(
                contact: [.noIsolation, .notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT],
                positiveTest: [.noIsolation, .notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHadUnconfirmedTestPreviously, .notIsolatingAndHasNegativeTest, .isolatingWithUnconfirmedTest]
            ),
            event: .riskyContact,
            update: .init(contact: .isolating)
        ),
        
        Rule(
            """
            Exception: A risky contact will not start a new isolation if it’s older than DCT opt in.
            """,
            predicate: StatePredicate(
                contact: [.notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT],
                positiveTest: [.noIsolation, .notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHadUnconfirmedTestPreviously, .notIsolatingAndHasNegativeTest, .isolatingWithUnconfirmedTest]
            ),
            event: .riskyContactWithExposureDayOlderThanIsolationTerminationDueToDCT,
            update: .init()
        ),
        
        Rule(
            """
            A risky contact isolation will be terminated for users directed to do so as part of DCT.
            """,
            predicate: StatePredicate(
                contact: [.isolating]
            ),
            event: .terminateRiskyContactDueToDCT,
            update: .init(contact: .notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT)
        ),
        
        Rule(
            """
            A symptomatic isolation will start on a symptomatic self-diagnosis.
            Symptom entry is only allowed if not already isolating as symptomatic or positive.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation, .notIsolatingAndHadSymptomsPreviously],
                positiveTest: [.noIsolation, .notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHadUnconfirmedTestPreviously, .notIsolatingAndHasNegativeTest]
            ),
            event: .selfDiagnosedSymptomatic,
            update: .init(
                symptomatic: .isolating,
                positiveTest: .noIsolation
            )
        ),
        
        Rule(
            """
            A positive test isolation will start on a positive test.
            Any contact case isolation will be cleared.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation],
                positiveTest: [.noIsolation]
            ),
            event: .receivedConfirmedPositiveTest,
            update: .init(
                contact: .noIsolation,
                positiveTest: .isolatingWithConfirmedTest
            )
        ),
        
        Rule(
            """
            A positive test will continue a positive test (asymptomatic) isolation.
            Any contact case isolation will be cleared.
            * If the new test has an earlier test end date, override the existing test entirely.
            * Otherwise, continue to remember the existing test and if it’s not already "confirmed" mark it as such.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation],
                positiveTest: [.isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest]
            ),
            event: .receivedConfirmedPositiveTest,
            update: .init(
                contact: .noIsolation,
                positiveTest: .isolatingWithConfirmedTest
            )
        ),
        
        Rule(
            """
            A positive test will not start a new isolation if a positive test (asymptomatic) isolation is expired.
            Any contact case isolation will be cleared.
            * If the new test has an earlier test end date, override the existing test entirely.
            * Otherwise, continue to remember the existing test and if it’s not already "confirmed" mark it as such.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation],
                positiveTest: [.notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHadUnconfirmedTestPreviously]
            ),
            event: .receivedConfirmedPositiveTest,
            update: .init(
                contact: .noIsolation,
                positiveTest: .notIsolatingAndHadConfirmedTestPreviously
            )
        ),
        
        Rule(
            """
            A positive test will start a new isolation if not in symptomatic isolation and has negative test.
            Any contact case isolation will be cleared.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.noIsolation],
                    positiveTest: [.notIsolatingAndHasNegativeTest]
                ),
            ],
            event: .receivedConfirmedPositiveTest,
            update: .init(
                contact: .noIsolation,
                symptomatic: .noIsolation,
                positiveTest: .isolatingWithConfirmedTest
            )
        ),
        
        Rule(
            """
            An older positive test will start a new isolation if not in symptomatic isolation and has negative test.
            Any contact case isolation will be cleared.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.noIsolation],
                    positiveTest: [.notIsolatingAndHasNegativeTest]
                ),
            ],
            event: .receivedConfirmedPositiveTestWithEndDateOlderThanRememberedNegativeTestEndDate,
            update: .init(
                contact: .noIsolation,
                symptomatic: .noIsolation,
                positiveTest: .isolatingWithConfirmedTest
            )
        ),
        
        Rule(
            """
            A positive test will not start a new isolation if a symptomatic isolation is expired.
            Any contact case isolation will be cleared.
            * If the new test has an earlier test end date, we will override the existing test entirely.
            * Otherwise, we will continue to remember the existing test and, if it’s not already "confirmed" mark it such.
            See below for exceptions related to the test being old.
            """,
            predicate: StatePredicate(
                symptomatic: [.notIsolatingAndHadSymptomsPreviously],
                positiveTest: [.notIsolatingAndHadConfirmedTestPreviously, .noIsolation]
            ),
            event: .receivedConfirmedPositiveTest,
            update: .init(
                contact: .noIsolation,
                positiveTest: .notIsolatingAndHadConfirmedTestPreviously
            )
        ),
        
        Rule(
            """
            Exception: A positive test will override symptomatic isolation if its end date is before symptom onset.
            Any contact case isolation will be cleared.
            See below for exceptions related to the test being even older.
            """,
            predicate: StatePredicate(
                symptomatic: [.notIsolatingAndHadSymptomsPreviously],
                positiveTest: [.notIsolatingAndHadConfirmedTestPreviously, .noIsolation]
            ),
            event: .receivedConfirmedPositiveTestWithEndDateOlderThanAssumedSymptomOnsetDate,
            update: .init(
                contact: .noIsolation,
                symptomatic: .noIsolation,
                positiveTest: .notIsolatingAndHadConfirmedTestPreviously
            )
        ),
        
        Rule(
            """
            A positive test will start a new isolation if symptomatic isolation ended and has negative test.
            Any contact case isolation will be cleared.
            See below for exceptions related to the test being old.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.notIsolatingAndHadSymptomsPreviously],
                    positiveTest: [.notIsolatingAndHasNegativeTest]
                ),
            ],
            event: .receivedConfirmedPositiveTest,
            update: .init(
                contact: .noIsolation,
                symptomatic: .noIsolation,
                positiveTest: .isolatingWithConfirmedTest
            )
        ),
        
        Rule(
            """
            Exception: A positive test will replace a newer negative test and resume old symptomatic isolation.
            Any contact case isolation will be cleared.
            See below for exceptions related to the test being even older.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.notIsolatingAndHadSymptomsPreviously],
                    positiveTest: [.notIsolatingAndHasNegativeTest]
                ),
            ],
            event: .receivedConfirmedPositiveTestWithEndDateOlderThanRememberedNegativeTestEndDate,
            update: .init(
                contact: .noIsolation,
                symptomatic: .isolating,
                positiveTest: .isolatingWithConfirmedTest
            )
        ),
        
        Rule(
            """
            Exception: A positive test will replace a newer symptomatic isolation and negative test result.
            Any contact case isolation will be cleared.
            See below for exceptions related to the test being even older.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.notIsolatingAndHadSymptomsPreviously],
                    positiveTest: [.notIsolatingAndHasNegativeTest]
                ),
            ],
            event: .receivedConfirmedPositiveTestWithEndDateOlderThanAssumedSymptomOnsetDate,
            update: .init(
                contact: .noIsolation,
                symptomatic: .noIsolation,
                positiveTest: .isolatingWithConfirmedTest
            )
        ),
        
        Rule(
            """
            A symptomatic test isolation will continue on a new positive test.
            The positive test will be stored if there is not one.
            Any contact case isolation will be cleared.
            See below for exceptions related to the test being old.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.isolating],
                    positiveTest: [.noIsolation, .isolatingWithConfirmedTest]
                ),
            ],
            event: .receivedConfirmedPositiveTest,
            update: .init(
                contact: .noIsolation,
                positiveTest: .isolatingWithConfirmedTest
            )
        ),
        
        Rule(
            """
            Exception: A symptomatic test isolation will be replaced with a new isolation if the test is older.
            Any contact case isolation will be cleared.
            See below for exceptions related to the test being even older.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.isolating],
                    positiveTest: [.noIsolation, .isolatingWithConfirmedTest]
                ),
            ],
            event: .receivedConfirmedPositiveTestWithEndDateOlderThanAssumedSymptomOnsetDate,
            update: .init(
                contact: .noIsolation,
                symptomatic: .noIsolation,
                positiveTest: .isolatingWithConfirmedTest
            )
        ),
        
        Rule(
            """
            Exception: A positive test will be ignored if the isolation resulting from it would end before symptom onset.
            No EN keys should be shared as a result of this test entry.
            """,
            predicate: StatePredicate(
                symptomatic: [.isolating, .notIsolatingAndHadSymptomsPreviously]
            ),
            event: .receivedConfirmedPositiveTestWithIsolationPeriodOlderThanAssumedSymptomOnsetDate,
            update: .init()
        ),
        
        Rule(
            """
            An unconfirmed positive test will continue an existing positive test (asymptomatic) isolation.
            * If the new test has an earlier test end date, it will override the existing test.
            * The new test will be marked as "confirmed" if existing test is confirmed.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.noIsolation],
                    positiveTest: [.isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest]
                ),
            ],
            event: .receivedUnconfirmedPositiveTest,
            update: .init()
        ),
        
        Rule(
            """
            An unconfirmed positive test isolation will start an isolation.
            See below for exceptions related to the test being old.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation, .notIsolatingAndHadSymptomsPreviously],
                positiveTest: [.noIsolation, .notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHadUnconfirmedTestPreviously, .notIsolatingAndHasNegativeTest]
            ),
            event: .receivedUnconfirmedPositiveTest,
            update: .init(
                symptomatic: .noIsolation,
                positiveTest: .isolatingWithUnconfirmedTest
            )
        ),
        
        Rule(
            """
            Exception: An unconfirmed positive test will not override a negative test if it’s older.
            See below for exceptions related to the test being even older.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.noIsolation, .notIsolatingAndHadSymptomsPreviously],
                    positiveTest: [.notIsolatingAndHasNegativeTest]
                ),
            ],
            event: .receivedUnconfirmedPositiveTestWithEndDateOlderThanRememberedNegativeTestEndDate,
            update: .init()
        ),
        
        Rule(
            """
            Affirmation: An unconfirmed positive test will not override a negative test if it’s even older.
            See below for exceptions related to the test being even older.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.notIsolatingAndHadSymptomsPreviously],
                    positiveTest: [.notIsolatingAndHasNegativeTest]
                ),
            ],
            event: .receivedUnconfirmedPositiveTestWithEndDateOlderThanAssumedSymptomOnsetDate,
            update: .init()
        ),
        
        Rule(
            """
            Exception: An unconfirmed positive test will override a symptomatic isolation if its end date is older.
            See below for exceptions related to the test being even older.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.notIsolatingAndHadSymptomsPreviously],
                    positiveTest: [.noIsolation]
                ),
            ],
            event: .receivedUnconfirmedPositiveTestWithEndDateOlderThanAssumedSymptomOnsetDate,
            update: .init(
                symptomatic: .noIsolation,
                positiveTest: .notIsolatingAndHadUnconfirmedTestPreviously
            )
        ),
        
        Rule(
            """
            Exception: An unconfirmed positive test will override a symptomatic isolation if its end date is older.
            If there is already a confirmed test, the new test will be marked as such.
            See below for exceptions related to the test being even older.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.notIsolatingAndHadSymptomsPreviously],
                    positiveTest: [.notIsolatingAndHadConfirmedTestPreviously]
                ),
            ],
            event: .receivedUnconfirmedPositiveTestWithEndDateOlderThanAssumedSymptomOnsetDate,
            update: .init(
                symptomatic: .noIsolation,
                positiveTest: .notIsolatingAndHadConfirmedTestPreviously
            )
        ),
        
        Rule(
            """
            An unconfirmed positive test will not change state of existing symptomatic isolation.
            See below for exceptions related to the test being old.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.isolating],
                    positiveTest: [.noIsolation, .isolatingWithConfirmedTest]
                ),
            ],
            event: .receivedUnconfirmedPositiveTest,
            update: .init()
        ),
        
        Rule(
            """
            Exception: An unconfirmed positive test will override a symptomatic isolation if its end date is older.
            See below for exceptions related to the test being even older.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.isolating],
                    positiveTest: [.noIsolation]
                ),
            ],
            event: .receivedUnconfirmedPositiveTestWithEndDateOlderThanAssumedSymptomOnsetDate,
            update: .init(
                symptomatic: .noIsolation,
                positiveTest: .isolatingWithUnconfirmedTest
            )
        ),
        
        Rule(
            """
            Exception: An unconfirmed positive test will override a symptomatic isolation if its end date is older.
            If there is already a confirmed test, the new test will be marked as such.
            See below for exceptions related to the test being even older.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.isolating],
                    positiveTest: [.isolatingWithConfirmedTest]
                ),
            ],
            event: .receivedUnconfirmedPositiveTestWithEndDateOlderThanAssumedSymptomOnsetDate,
            update: .init(
                symptomatic: .noIsolation,
                positiveTest: .isolatingWithConfirmedTest
            )
        ),
        
        Rule(
            """
            Exception: A unconfirmed positive test will be ignored if the isolation from it would end before symptom onset.
            No EN keys should be shared as a result of this test entry.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.notIsolatingAndHadSymptomsPreviously, .isolating],
                    positiveTest: [.noIsolation, .notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHasNegativeTest, .isolatingWithConfirmedTest]
                ),
            ],
            event: .receivedUnconfirmedPositiveTestWithIsolationPeriodOlderThanAssumedSymptomOnsetDate,
            update: .init()
        ),
        
        Rule(
            """
            A negative test will not override a confirmed test.
            """,
            predicate: StatePredicate(
                positiveTest: [.isolatingWithConfirmedTest, .notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHasNegativeTest]
            ),
            event: .receivedNegativeTest,
            update: .init()
        ),
        
        Rule(
            """
            A negative test when has no in symptomatic or positive isolation state will be stored.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation],
                positiveTest: [.noIsolation]
            ),
            event: .receivedNegativeTest,
            update: .init(positiveTest: .notIsolatingAndHasNegativeTest)
        ),
        
        Rule(
            """
            A negative test will override an unconfirmed positive test iolation, possibly ending isolation.
            Note: See below for exceptions.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation],
                positiveTest: [.isolatingWithUnconfirmedTest, .notIsolatingAndHadUnconfirmedTestPreviously]
            ),
            event: .receivedNegativeTest,
            update: .init(positiveTest: .notIsolatingAndHasNegativeTest)
        ),
        
        Rule(
            """
            Exception: A negative test will not override an unconfirmed positive if the negative test is older.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation],
                positiveTest: [.isolatingWithUnconfirmedTest, .notIsolatingAndHadUnconfirmedTestPreviously]
            ),
            event: .receivedNegativeTestWithEndDateOlderThanRememberedUnconfirmedTestEndDate,
            update: .init()
        ),
        
        Rule(
            """
            When has symptoms but no test results, a negative test will be stored, possibly ending isolation.
            Note: See below for exceptions.
            """,
            predicate: StatePredicate(
                symptomatic: [.isolating, .notIsolatingAndHadSymptomsPreviously],
                positiveTest: [.noIsolation]
            ),
            event: .receivedNegativeTest,
            update: .init(
                symptomatic: .notIsolatingAndHadSymptomsPreviously,
                positiveTest: .notIsolatingAndHasNegativeTest
            )
        ),
        
        Rule(
            """
            Exception: A negative test will not override a symptomatic iolation if the negative test is older.
            """,
            predicate: StatePredicate(
                symptomatic: [.isolating, .notIsolatingAndHadSymptomsPreviously],
                positiveTest: [.noIsolation]
            ),
            event: .receivedNegativeTestWithEndDateOlderThanAssumedSymptomOnsetDate,
            update: .init()
        ),
        
        Rule(
            """
            Affirmation: A negative test will not override a confirmed test even if old.
            """,
            predicate: StatePredicate(
                symptomatic: [.isolating, .notIsolatingAndHadSymptomsPreviously],
                positiveTest: [.isolatingWithConfirmedTest, .notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHasNegativeTest]
            ),
            event: .receivedNegativeTestWithEndDateOlderThanAssumedSymptomOnsetDate,
            update: .init()
        ),
        
        Rule(
            """
            A void test will never change isolation state.
            """,
            predicate: StatePredicate(),
            event: .receivedVoidTest,
            update: .init()
        ),
    ]
    
    public static let rulesAutomaticallyTriggeredOverTime: [Rule] = [
        
        Rule(
            """
            A contact isolation will end.
            """,
            predicate: StatePredicate(contact: [.isolating]),
            event: .contactIsolationEnded,
            update: .init(contact: .notIsolatingAndHadRiskyContactPreviously)
        ),
        
        Rule(
            """
            A confirmed positive test isolation will end.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation],
                positiveTest: [.isolatingWithConfirmedTest]
            ),
            event: .indexIsolationEnded,
            update: .init(positiveTest: .notIsolatingAndHadConfirmedTestPreviously)
        ),
        
        Rule(
            """
            An unconfirmed positive test isolation will end.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation],
                positiveTest: [.isolatingWithUnconfirmedTest]
            ),
            event: .indexIsolationEnded,
            update: .init(positiveTest: .notIsolatingAndHadUnconfirmedTestPreviously)
        ),
        
        Rule(
            """
            A symptomatic isolation will end.
            """,
            predicate: StatePredicate(
                symptomatic: [.isolating],
                positiveTest: [.noIsolation]
            ),
            event: .indexIsolationEnded,
            update: .init(symptomatic: .notIsolatingAndHadSymptomsPreviously)
        ),
        
        Rule(
            """
            A combined symptomatic and positive test isolation will end together.
            """,
            predicate: StatePredicate(
                symptomatic: [.isolating],
                positiveTest: [.isolatingWithConfirmedTest]
            ),
            event: .indexIsolationEnded,
            update: .init(
                symptomatic: .notIsolatingAndHadSymptomsPreviously,
                positiveTest: .notIsolatingAndHadConfirmedTestPreviously
            )
        ),
        
        Rule(
            """
            After retention period ends all isolation is deleted.
            """,
            predicates: [
                StatePredicate(
                    contact: [.noIsolation, .notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT],
                    symptomatic: [.noIsolation, .notIsolatingAndHadSymptomsPreviously],
                    positiveTest: [.noIsolation, .notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHadUnconfirmedTestPreviously, .notIsolatingAndHasNegativeTest]
                ),
            ],
            event: .retentionPeriodEnded,
            update: .init(
                contact: .noIsolation,
                symptomatic: .noIsolation,
                positiveTest: .noIsolation
            )
        ),
    ]
    
    /// Rules that are defined for completeness of the state machine, but we don't expect them as should be "impossible" for reasons not captured in state machine.
    public static let fillerRules: [Rule] = [
        Rule(
            filler: """
            We block risky contacts events during an existing contact or positive isolation.
            """,
            predicates: [
                StatePredicate(
                    contact: [.isolating]
                ),
                StatePredicate(
                    contact: [.noIsolation, .notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT],
                    positiveTest: [.isolatingWithConfirmedTest]
                ),
            ],
            event: .riskyContact
        ),
        
        Rule(
            filler: """
            We block risky contacts events during an existing positive isolation.
            """,
            predicates: [
                StatePredicate(
                    contact: [.notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT],
                    positiveTest: [.isolatingWithConfirmedTest]
                ),
            ],
            event: .riskyContactWithExposureDayOlderThanIsolationTerminationDueToDCT
        ),
        
        Rule(
            filler: """
            If not in contact isolation, then the event to end it is meaningless.
            """,
            predicate: StatePredicate(contact: [.noIsolation, .notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT]),
            event: .contactIsolationEnded
        ),
        
        Rule(
            filler: """
            If not in contact isolation, then terminating it due to DCT is meaningless.
            """,
            predicate: StatePredicate(contact: [.noIsolation, .notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT]),
            event: .terminateRiskyContactDueToDCT
        ),
        
        Rule(
            filler: """
            We do not allow new self-diagnosis during an active symptomatic or positive isolation.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.isolating],
                    positiveTest: [.noIsolation]
                ),
                StatePredicate(
                    symptomatic: [.noIsolation],
                    positiveTest: [.isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest]
                ),
                StatePredicate(
                    symptomatic: [.isolating],
                    positiveTest: [.isolatingWithConfirmedTest]
                ),
            ],
            event: .selfDiagnosedSymptomatic
        ),
        
        Rule(
            filler: """
            If not in symptomatic or positive test isolation, then the event to finish it is meaningless.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation, .notIsolatingAndHadSymptomsPreviously],
                positiveTest: [.noIsolation, .notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHadUnconfirmedTestPreviously, .notIsolatingAndHasNegativeTest]
            ),
            event: .indexIsolationEnded
        ),
        
        Rule(
            filler: """
            Retention period should not end if we have an active isolation.
            """,
            predicates: [
                StatePredicate(
                    contact: [.isolating],
                    symptomatic: [.noIsolation, .notIsolatingAndHadSymptomsPreviously],
                    positiveTest: [.noIsolation, .notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHadUnconfirmedTestPreviously, .notIsolatingAndHasNegativeTest]
                ),
                StatePredicate(
                    contact: [.noIsolation, .notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT],
                    symptomatic: [.isolating],
                    positiveTest: [.noIsolation, .notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHadUnconfirmedTestPreviously, .notIsolatingAndHasNegativeTest]
                ),
                StatePredicate(
                    contact: [.noIsolation, .notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT],
                    symptomatic: [.noIsolation, .notIsolatingAndHadSymptomsPreviously],
                    positiveTest: [.isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest]
                ),
                StatePredicate(
                    contact: [.isolating],
                    symptomatic: [.isolating],
                    positiveTest: [.noIsolation, .notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHasNegativeTest, .notIsolatingAndHadUnconfirmedTestPreviously]
                ),
                StatePredicate(
                    contact: [.noIsolation, .notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT],
                    symptomatic: [.isolating],
                    positiveTest: [.isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest]
                ),
                StatePredicate(
                    contact: [.isolating],
                    symptomatic: [.noIsolation, .notIsolatingAndHadSymptomsPreviously],
                    positiveTest: [.isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest]
                ),
                StatePredicate(
                    contact: [.isolating],
                    symptomatic: [.isolating],
                    positiveTest: [.isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest]
                ),
            ],
            event: .retentionPeriodEnded
        ),
        
        Rule(
            filler: """
            This event is not possible if we do not have an unconfirmed test.
            """,
            predicate: StatePredicate(
                positiveTest: [.noIsolation, .isolatingWithConfirmedTest, .notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHasNegativeTest]
            ),
            event: .receivedNegativeTestWithEndDateOlderThanRememberedUnconfirmedTestEndDate
        ),
        
        Rule(
            filler: """
            This event is not possible if we do not have symptoms.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation]
            ),
            event: .receivedNegativeTestWithEndDateOlderThanAssumedSymptomOnsetDate
        ),
        
        Rule(
            filler: """
            This event is not possible if we do not have negative tests.
            """,
            predicate: StatePredicate(
                positiveTest: Set(IsolationModel.PositiveTestCaseState.allCases.filter { $0 != .notIsolatingAndHasNegativeTest })
            ),
            event: .receivedConfirmedPositiveTestWithEndDateOlderThanRememberedNegativeTestEndDate
        ),
        
        Rule(
            filler: """
            This event is not possible if we do not have symptoms.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation]
            ),
            event: .receivedConfirmedPositiveTestWithEndDateOlderThanAssumedSymptomOnsetDate
        ),
        
        Rule(
            filler: """
            This event is not possible if we do not have symptoms.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation]
            ),
            event: .receivedConfirmedPositiveTestWithIsolationPeriodOlderThanAssumedSymptomOnsetDate
        ),
        
        Rule(
            filler: """
            This event is not possible if we do not have negative tests.
            """,
            predicate: StatePredicate(
                positiveTest: Set(IsolationModel.PositiveTestCaseState.allCases.filter { $0 != .notIsolatingAndHasNegativeTest })
            ),
            event: .receivedUnconfirmedPositiveTestWithEndDateOlderThanRememberedNegativeTestEndDate
        ),
        
        Rule(
            filler: """
            This event is not possible if we do not have symptoms.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation]
            ),
            event: .receivedUnconfirmedPositiveTestWithEndDateOlderThanAssumedSymptomOnsetDate
        ),
        
        Rule(
            filler: """
            This event is not possible if we do not have symptoms.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation]
            ),
            event: .receivedUnconfirmedPositiveTestWithIsolationPeriodOlderThanAssumedSymptomOnsetDate
        ),
        
        Rule(
            """
            This event is not possible if isolation wasn't terminated due to DCT.
            """,
            predicate: StatePredicate(
                contact: [
                    .noIsolation,
                    .isolating,
                    .notIsolatingAndHadRiskyContactPreviously,
                ]
            ),
            event: .riskyContactWithExposureDayOlderThanIsolationTerminationDueToDCT,
            update: .init()
        ),
    ]
    
}
