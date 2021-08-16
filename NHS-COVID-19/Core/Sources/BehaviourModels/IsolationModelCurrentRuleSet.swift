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
                contact: .all(except: .isolating),
                positiveTest: .all(except: .isolatingWithConfirmedTest)
            ),
            event: .riskyContact,
            update: .init(contact: .isolating)
        ),
        
        Rule(
            """
            A risky contact isolation will be terminated for users that are below the age limit or fully vaccinated (self-declared).
            """,
            predicate: StatePredicate(
                contact: [.isolating]
            ),
            event: .terminatedRiskyContactEarly,
            update: .init(contact: .notIsolatingAndHadRiskyContactIsolationTerminatedEarly)
        ),
        
        Rule(
            """
            Exception: A risky contact will not start a new isolation if it’s older than contact case opt-out (self-declared under the age limit or fully vaccinated).
            """,
            predicate: StatePredicate(
                contact: [.notIsolatingAndHadRiskyContactIsolationTerminatedEarly],
                positiveTest: .all(except: .isolatingWithConfirmedTest)
            ),
            event: .riskyContactWithExposureDayOlderThanEarlyIsolationTermination,
            update: .init()
        ),
        
        Rule(
            """
            A symptomatic isolation will start on a symptomatic self-diagnosis.
            Symptom entry is only allowed if not already isolating as symptomatic.
            
            Delete any tests remembered if it is not causing an active isolation.
            """,
            predicate: StatePredicate(
                symptomatic: .all(except: .isolating),
                positiveTest: .all(except: .isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest)
            ),
            event: .selfDiagnosedSymptomatic,
            update: .init(
                symptomatic: .isolating,
                positiveTest: .noIsolation
            )
        ),
        
        Rule(
            """
            A symptomatic isolation will start on a symptomatic self-diagnosis.
            Symptom entry is only allowed if not already isolating as symptomatic.
            
            Keep any remembered tests if they are causing an active isolation.
            """,
            predicate: StatePredicate(
                symptomatic: .all(except: .isolating),
                positiveTest: [.isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest]
            ),
            event: .selfDiagnosedSymptomatic,
            update: .init(
                symptomatic: .isolating
            )
        ),
        
        Rule(
            """
            Exception: We allow new self-diagnosis during an active positive test isolation,
            but do not store it if assumed symptom onset date is newer than test end date.
            """,
            predicate: StatePredicate(
                symptomatic: .all(except: .isolating),
                positiveTest: [.isolatingWithUnconfirmedTest, .isolatingWithConfirmedTest]
            ),
            event: .selfDiagnosedSymptomaticWithAssumedOnsetDateOlderThanPositiveTestEndDate,
            update: .init()
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
                positiveTest: [.notIsolatingAndHadConfirmedTestPreviously, .noIsolation, .notIsolatingAndHadUnconfirmedTestPreviously]
            ),
            event: .receivedConfirmedPositiveTest,
            update: .init(
                contact: .noIsolation,
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
            A symptomatic test isolation will continue on a new positive test.
            The positive test will be stored if there is not one.
            Any contact case isolation will be cleared.
            See below for exceptions related to the test being old.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.isolating],
                    positiveTest: [.noIsolation, .isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest]
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
            Exception: A positive test will be ignored if the isolation resulting from it would end before any active
            or expired isolation
            No EN keys should be shared as a result of this test entry.
            """,
            predicates: [
                StatePredicate(
                    contact: .all(except: .noIsolation),
                    symptomatic: .all(except: .noIsolation),
                    positiveTest: .all(except: .noIsolation)
                ),
                StatePredicate(
                    contact: [.noIsolation],
                    symptomatic: .all(except: .noIsolation),
                    positiveTest: .all(except: .noIsolation)
                ),
                StatePredicate(
                    contact: .all(except: .noIsolation),
                    symptomatic: [.noIsolation],
                    positiveTest: .all(except: .noIsolation)
                ),
                StatePredicate(
                    contact: .all(except: .noIsolation),
                    symptomatic: .all(except: .noIsolation),
                    positiveTest: [.noIsolation]
                ),
                StatePredicate(
                    contact: [.noIsolation],
                    symptomatic: [.noIsolation],
                    positiveTest: .all(except: .noIsolation)
                ),
                StatePredicate(
                    contact: .all(except: .noIsolation),
                    symptomatic: [.noIsolation],
                    positiveTest: [.noIsolation]
                ),
                StatePredicate(
                    contact: [.noIsolation],
                    symptomatic: .all(except: .noIsolation),
                    positiveTest: [.noIsolation]
                ),
            ],
            event: .receivedConfirmedPositiveTestWithIsolationPeriodOlderThanAssumedIsolationStartDate,
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
                positiveTest: .all(except: .isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest)
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
            Exception: An unconfirmed positive test will override a negative test if it’s more than N days older.
            See below for exceptions related to the test being even older.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.noIsolation, .notIsolatingAndHadSymptomsPreviously],
                    positiveTest: [.notIsolatingAndHasNegativeTest]
                ),
            ],
            event: .receivedUnconfirmedPositiveTestWithEndDateNDaysOlderThanRememberedNegativeTestEndDateAndOlderThanAssumedSymptomOnsetDayIfAny,
            update: .init(
                symptomatic: .noIsolation,
                positiveTest: .isolatingWithUnconfirmedTest
            )
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
            Exception: An unconfirmed positive test will not modify a symptomatic isolation if its end date is older.
            See below for exceptions related to the test being even older.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.notIsolatingAndHadSymptomsPreviously],
                    positiveTest: [.noIsolation, .notIsolatingAndHadUnconfirmedTestPreviously]
                ),
            ],
            event: .receivedUnconfirmedPositiveTestWithEndDateOlderThanAssumedSymptomOnsetDate,
            update: .init(
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
            update: .init()
        ),
        
        Rule(
            """
            An unconfirmed positive test will not change state of existing symptomatic isolation.
            See below for exceptions related to the test being old.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.isolating],
                    positiveTest: [.noIsolation, .isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest]
                ),
            ],
            event: .receivedUnconfirmedPositiveTest,
            update: .init()
        ),
        
        Rule(
            """
            Exception: An unconfirmed positive test will not modify a symptomatic isolation if its end date is older.
            See below for exceptions related to the test being even older.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.isolating],
                    positiveTest: [.noIsolation, .isolatingWithUnconfirmedTest]
                ),
            ],
            event: .receivedUnconfirmedPositiveTestWithEndDateOlderThanAssumedSymptomOnsetDate,
            update: .init(
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
            update: .init()
        ),
        
        Rule(
            """
            Exception: A positive test will be ignored if the isolation resulting from it would end before any active
            or expired isolation
            No EN keys should be shared as a result of this test entry.
            """,
            predicates: [
                StatePredicate(
                    contact: .all(except: .noIsolation),
                    symptomatic: .all(except: .noIsolation),
                    positiveTest: .all(except: .noIsolation)
                ),
                StatePredicate(
                    contact: [.noIsolation],
                    symptomatic: .all(except: .noIsolation),
                    positiveTest: .all(except: .noIsolation)
                ),
                StatePredicate(
                    contact: .all(except: .noIsolation),
                    symptomatic: [.noIsolation],
                    positiveTest: .all(except: .noIsolation)
                ),
                StatePredicate(
                    contact: .all(except: .noIsolation),
                    symptomatic: .all(except: .noIsolation),
                    positiveTest: [.noIsolation]
                ),
                StatePredicate(
                    contact: [.noIsolation],
                    symptomatic: [.noIsolation],
                    positiveTest: .all(except: .noIsolation)
                ),
                StatePredicate(
                    contact: .all(except: .noIsolation),
                    symptomatic: [.noIsolation],
                    positiveTest: [.noIsolation]
                ),
                StatePredicate(
                    contact: [.noIsolation],
                    symptomatic: .all(except: .noIsolation),
                    positiveTest: [.noIsolation]
                ),
                
            ],
            event: .receivedUnconfirmedPositiveTestWithIsolationPeriodOlderThanAssumedIsolationStartDate,
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
            A negative test will not override a confirmed test.
            If there are symptoms after the positive test but before the negative test, remove them.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.isolating],
                    positiveTest: [.isolatingWithConfirmedTest, .notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHasNegativeTest]
                ),
                StatePredicate(
                    symptomatic: [.notIsolatingAndHadSymptomsPreviously],
                    positiveTest: [.notIsolatingAndHadConfirmedTestPreviously]
                ),
            ],
            event: .receivedNegativeTestWithEndDateNewerThanAssumedSymptomOnsetDateAndAssumedSymptomOnsetDateNewerThanPositiveTestEndDate,
            update: .init(
                symptomatic: .noIsolation
            )
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
                symptomatic: [.noIsolation, .isolating, .notIsolatingAndHadSymptomsPreviously],
                positiveTest: [.isolatingWithUnconfirmedTest, .notIsolatingAndHadUnconfirmedTestPreviously]
            ),
            event: .receivedNegativeTestWithEndDateOlderThanRememberedUnconfirmedTestEndDateAndOlderThanAssumedSymptomOnsetDayIfAny,
            update: .init()
        ),
        
        Rule(
            """
            When has symptoms but no test results, a negative test will be stored, possibly ending isolation.
            Note: See below for exceptions.
            """,
            predicate: StatePredicate(
                symptomatic: [.isolating, .notIsolatingAndHadSymptomsPreviously],
                positiveTest: [.noIsolation, .isolatingWithUnconfirmedTest, .notIsolatingAndHadUnconfirmedTestPreviously]
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
            Unconfirmed tests will be cleared.
            """,
            predicate: StatePredicate(
                symptomatic: [.isolating, .notIsolatingAndHadSymptomsPreviously],
                positiveTest: [.noIsolation, .notIsolatingAndHadUnconfirmedTestPreviously, .isolatingWithUnconfirmedTest]
            ),
            event: .receivedNegativeTestWithEndDateOlderThanAssumedSymptomOnsetDate,
            update: .init(
                positiveTest: .noIsolation
            )
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
            A negative test with a test end date n days newer than the remembered unconfirmed test end date will not
            change the isolation state.
            """,
            predicate: StatePredicate(
                positiveTest: [.isolatingWithUnconfirmedTest, .notIsolatingAndHadUnconfirmedTestPreviously]
            ),
            event: .receivedNegativeTestWithEndDateNDaysNewerThanRememberedUnconfirmedTestEndDateButOlderThanAssumedSymptomOnsetDayIfAny,
            update: .init()
        ),
        
        Rule(
            """
            A negative test with a test end date n days newer than the remembered unconfirmed test end date will not
            override the test.
            Symptoms will be deleted.
            """,
            predicate: StatePredicate(
                symptomatic: [.isolating, .notIsolatingAndHadSymptomsPreviously],
                positiveTest: [.isolatingWithUnconfirmedTest, .notIsolatingAndHadUnconfirmedTestPreviously]
            ),
            event: .receivedNegativeTestWithEndDateNDaysNewerThanRememberedUnconfirmedTestEndDate,
            update: .init(
                symptomatic: .noIsolation
            )
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
            A combined symptomatic and unconfirmed positive test isolation will end together.
            """,
            predicate: StatePredicate(
                symptomatic: [.isolating],
                positiveTest: [.isolatingWithUnconfirmedTest]
            ),
            event: .indexIsolationEnded,
            update: .init(
                symptomatic: .notIsolatingAndHadSymptomsPreviously,
                positiveTest: .notIsolatingAndHadUnconfirmedTestPreviously
            )
        ),
        
        Rule(
            """
            After retention period ends all isolation is deleted.
            """,
            predicates: [
                StatePredicate(
                    contact: [.notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadRiskyContactIsolationTerminatedEarly],
                    symptomatic: [.noIsolation],
                    positiveTest: [.noIsolation, .notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHadUnconfirmedTestPreviously, .notIsolatingAndHasNegativeTest]
                ),
                StatePredicate(
                    contact: [.noIsolation],
                    symptomatic: [.notIsolatingAndHadSymptomsPreviously],
                    positiveTest: [.noIsolation, .notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHadUnconfirmedTestPreviously, .notIsolatingAndHasNegativeTest]
                ),
                StatePredicate(
                    contact: [.notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadRiskyContactIsolationTerminatedEarly],
                    symptomatic: [.notIsolatingAndHadSymptomsPreviously],
                    positiveTest: [.noIsolation]
                ),
                StatePredicate(
                    contact: [.noIsolation],
                    symptomatic: [.noIsolation],
                    positiveTest: [.notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHadUnconfirmedTestPreviously, .notIsolatingAndHasNegativeTest]
                ),
                StatePredicate(
                    contact: [.notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadRiskyContactIsolationTerminatedEarly],
                    symptomatic: [.notIsolatingAndHadSymptomsPreviously],
                    positiveTest: [.notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHadUnconfirmedTestPreviously, .notIsolatingAndHasNegativeTest]
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
                    contact: [.noIsolation, .notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadRiskyContactIsolationTerminatedEarly],
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
                    contact: [.notIsolatingAndHadRiskyContactIsolationTerminatedEarly],
                    positiveTest: [.isolatingWithConfirmedTest]
                ),
            ],
            event: .riskyContactWithExposureDayOlderThanEarlyIsolationTermination
        ),
        
        Rule(
            filler: """
            If not in contact isolation, then the event to end it is meaningless.
            """,
            predicate: StatePredicate(contact: [.noIsolation, .notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadRiskyContactIsolationTerminatedEarly]),
            event: .contactIsolationEnded
        ),
        
        Rule(
            filler: """
            If not in contact isolation, then terminating it early is meaningless.
            """,
            predicate: StatePredicate(contact: [.noIsolation, .notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadRiskyContactIsolationTerminatedEarly]),
            event: .terminatedRiskyContactEarly
        ),
        
        Rule(
            filler: """
            We do not allow new self-diagnosis during an active symptomatic isolation.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.isolating]
                ),
            ],
            event: .selfDiagnosedSymptomatic
        ),
        
        Rule(
            filler: """
            We do not allow new self-diagnosis during an active symptomatic isolation.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.isolating]
                ),
            ],
            event: .selfDiagnosedSymptomaticWithAssumedOnsetDateOlderThanPositiveTestEndDate
        ),
        
        Rule(
            filler: """
            This event can not happen without an active positive result isolation and if there is already
            a symptomatic isolation
            """,
            predicates: [
                StatePredicate(
                    symptomatic: .all(except: .isolating),
                    positiveTest: .all(except: .isolatingWithUnconfirmedTest, .isolatingWithConfirmedTest)
                ),
            ],
            event: .selfDiagnosedSymptomaticWithAssumedOnsetDateOlderThanPositiveTestEndDate
        ),
        
        Rule(
            filler: """
            If not in symptomatic or positive test isolation, then the event to finish it is meaningless.
            """,
            predicate: StatePredicate(
                symptomatic: .all(except: .isolating),
                positiveTest: .all(except: .isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest)
            ),
            event: .indexIsolationEnded
        ),
        
        Rule(
            filler: """
            Ending retention period with no isolation is meaningless.
            """,
            predicate: StatePredicate(
                contact: [.noIsolation],
                symptomatic: [.noIsolation],
                positiveTest: [.noIsolation]
            ),
            event: .retentionPeriodEnded
        ),
        
        Rule(
            filler: """
            Retention period should not end if we have an active isolation.
            """,
            predicates: [
                StatePredicate(
                    contact: [.isolating],
                    symptomatic: .all(except: .isolating),
                    positiveTest: .all(except: .isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest)
                ),
                StatePredicate(
                    contact: .all(except: .isolating),
                    symptomatic: [.isolating],
                    positiveTest: .all(except: .isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest)
                ),
                StatePredicate(
                    contact: .all(except: .isolating),
                    symptomatic: .all(except: .isolating),
                    positiveTest: [.isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest]
                ),
                StatePredicate(
                    contact: [.isolating],
                    symptomatic: [.isolating],
                    positiveTest: .all(except: .isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest)
                ),
                StatePredicate(
                    contact: .all(except: .isolating),
                    symptomatic: [.isolating],
                    positiveTest: [.isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest]
                ),
                StatePredicate(
                    contact: [.isolating],
                    symptomatic: .all(except: .isolating),
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
                positiveTest: .all(except: .isolatingWithUnconfirmedTest, .notIsolatingAndHadUnconfirmedTestPreviously)
            ),
            event: .receivedNegativeTestWithEndDateOlderThanRememberedUnconfirmedTestEndDateAndOlderThanAssumedSymptomOnsetDayIfAny
        ),
        
        Rule(
            filler: """
            This event is not possible if we do not have symptoms, or have an unconfirmed test.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.noIsolation]
                ),
            ],
            event: .receivedNegativeTestWithEndDateOlderThanAssumedSymptomOnsetDate
        ),
        
        Rule(
            filler: """
            This event is not possible if we do not have symptoms and an unconfirmed test.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.noIsolation]
                ),
                StatePredicate(
                    positiveTest: .all(except: .isolatingWithUnconfirmedTest, .notIsolatingAndHadUnconfirmedTestPreviously)
                ),
            ],
            event: .receivedNegativeTestWithEndDateNDaysNewerThanRememberedUnconfirmedTestEndDate
        ),
        
        Rule(
            filler: """
            This event is not possible if we do not have symptoms and a confirmed test.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.noIsolation]
                ),
                StatePredicate(
                    positiveTest: .all(except: .isolatingWithConfirmedTest, .notIsolatingAndHadConfirmedTestPreviously)
                ),
            ],
            event: .receivedNegativeTestWithEndDateNewerThanAssumedSymptomOnsetDateAndAssumedSymptomOnsetDateNewerThanPositiveTestEndDate
        ),
        
        Rule(
            filler: """
            This event is not possible if we do not have negative tests.
            """,
            predicate: StatePredicate(
                positiveTest: .all(except: .notIsolatingAndHasNegativeTest)
            ),
            event: .receivedConfirmedPositiveTestWithEndDateOlderThanRememberedNegativeTestEndDate
        ),
        
        Rule(
            filler: """
            This event is not possible if we do not have any isolation
            """,
            predicate: StatePredicate(
                contact: [.noIsolation],
                symptomatic: [.noIsolation],
                positiveTest: [.noIsolation]
            ),
            event: .receivedConfirmedPositiveTestWithIsolationPeriodOlderThanAssumedIsolationStartDate
        ),
        
        Rule(
            filler: """
            This event is not possible if we do not have negative tests.
            """,
            predicate: StatePredicate(
                positiveTest: .all(except: .notIsolatingAndHasNegativeTest)
            ),
            event: .receivedUnconfirmedPositiveTestWithEndDateOlderThanRememberedNegativeTestEndDate
        ),
        
        Rule(
            filler: """
            This event is not possible if we do not have negative tests.
            """,
            predicate: StatePredicate(
                positiveTest: .all(except: .notIsolatingAndHasNegativeTest)
            ),
            event: .receivedUnconfirmedPositiveTestWithEndDateNDaysOlderThanRememberedNegativeTestEndDateAndOlderThanAssumedSymptomOnsetDayIfAny
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
            This event is not possible if we do not have any isolation
            """,
            predicate: StatePredicate(
                contact: [.noIsolation],
                symptomatic: [.noIsolation],
                positiveTest: [.noIsolation]
            ),
            event: .receivedUnconfirmedPositiveTestWithIsolationPeriodOlderThanAssumedIsolationStartDate
        ),
        
        Rule(
            filler: """
            This event is not possible if isolation wasn't terminated early by self-declaring under age limit or fully vaccinated.
            """,
            predicate: StatePredicate(
                contact: .all(except: .notIsolatingAndHadRiskyContactIsolationTerminatedEarly)
            ),
            event: .riskyContactWithExposureDayOlderThanEarlyIsolationTermination
        ),
        Rule(
            filler: """
            This event is not possible if we don't have an unconfirmed test
            """,
            predicate: StatePredicate(
                positiveTest: .all(except: .isolatingWithUnconfirmedTest, .notIsolatingAndHadUnconfirmedTestPreviously)
            ),
            event: .receivedNegativeTestWithEndDateNDaysNewerThanRememberedUnconfirmedTestEndDateButOlderThanAssumedSymptomOnsetDayIfAny
        ),
    ]
    
}
