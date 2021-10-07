//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import XCTest
@testable import Domain

class ContactCaseOptOutQuestionnaireTests: XCTestCase {
    
    func testInitialValue() {
        let questionnaire = ContactCaseOptOutQuestionnaire(country: .constant(.england))
        
        let nextQuestions = questionnaire.nextQuestion(with: [:])
        let resolution = questionnaire.getResolution(with: [:])
        
        let expectedQuestions: [ContactCaseOptOutQuestion] = [
            .fullyVaccinated,
        ]
        let expectedResolution: ContactCaseOptOutQuestionnaire.Resolution = .notFinished
        
        XCTAssertEqual(expectedQuestions, nextQuestions)
        XCTAssertEqual(expectedResolution, resolution)
    }
    
    func testFullyVaccinated() {
        let questionnaire = ContactCaseOptOutQuestionnaire(country: .constant(.england))
        
        let answers: [ContactCaseOptOutQuestion: Bool] = [
            .fullyVaccinated: true,
        ]
        
        let nextQuestions = questionnaire.nextQuestion(with: answers)
        let resolution = questionnaire.getResolution(with: answers)
        
        let expectedQuestions: [ContactCaseOptOutQuestion] = [
            .fullyVaccinated,
            .lastDose,
        ]
        let expectedResolution: ContactCaseOptOutQuestionnaire.Resolution = .notFinished
        
        XCTAssertEqual(expectedQuestions, nextQuestions)
        XCTAssertEqual(expectedResolution, resolution)
    }
    
    func testFullyVaccinatedAndLastDose() {
        let questionnaire = ContactCaseOptOutQuestionnaire(country: .constant(.england))
        
        let answers: [ContactCaseOptOutQuestion: Bool] = [
            .fullyVaccinated: true,
            .lastDose: true,
        ]
        
        let nextQuestions = questionnaire.nextQuestion(with: answers)
        let resolution = questionnaire.getResolution(with: answers)
        
        let expectedQuestions: [ContactCaseOptOutQuestion] = [
            .fullyVaccinated,
            .lastDose,
        ]
        let expectedResolution: ContactCaseOptOutQuestionnaire.Resolution = .optedOutOfIsolation(.fullyVaccinated, expectedQuestions)
        
        XCTAssertEqual(expectedQuestions, nextQuestions)
        XCTAssertEqual(expectedResolution, resolution)
    }
    
    func testFullyVaccinatedNoLastDose() {
        let questionnaire = ContactCaseOptOutQuestionnaire(country: .constant(.england))
        
        let answers: [ContactCaseOptOutQuestion: Bool] = [
            .fullyVaccinated: true,
            .lastDose: false,
        ]
        
        let nextQuestions = questionnaire.nextQuestion(with: answers)
        let resolution = questionnaire.getResolution(with: answers)
        
        let expectedQuestions: [ContactCaseOptOutQuestion] = [
            .fullyVaccinated,
            .lastDose,
            .clinicalTrial,
        ]
        let expectedResolution: ContactCaseOptOutQuestionnaire.Resolution = .notFinished
        
        XCTAssertEqual(expectedQuestions, nextQuestions)
        XCTAssertEqual(expectedResolution, resolution)
    }
    
    func testFullyVaccinatedNoLastDoseClinicalTrial() {
        let questionnaire = ContactCaseOptOutQuestionnaire(country: .constant(.england))
        
        let answers: [ContactCaseOptOutQuestion: Bool] = [
            .fullyVaccinated: true,
            .lastDose: false,
            .clinicalTrial: true,
        ]
        
        let nextQuestions = questionnaire.nextQuestion(with: answers)
        let resolution = questionnaire.getResolution(with: answers)
        
        let expectedQuestions: [ContactCaseOptOutQuestion] = [
            .fullyVaccinated,
            .lastDose,
            .clinicalTrial,
        ]
        let expectedResolution: ContactCaseOptOutQuestionnaire.Resolution = .optedOutOfIsolation(.fullyVaccinated, expectedQuestions)
        
        XCTAssertEqual(expectedQuestions, nextQuestions)
        XCTAssertEqual(expectedResolution, resolution)
    }
    
    func testFullyVaccinatedNoLastDoseNoClinicalTrialWales() {
        let questionnaire = ContactCaseOptOutQuestionnaire(country: .constant(.wales))
        
        let answers: [ContactCaseOptOutQuestion: Bool] = [
            .fullyVaccinated: true,
            .lastDose: false,
            .clinicalTrial: false,
        ]
        
        let nextQuestions = questionnaire.nextQuestion(with: answers)
        let resolution = questionnaire.getResolution(with: answers)
        
        let expectedQuestions: [ContactCaseOptOutQuestion] = [
            .fullyVaccinated,
            .lastDose,
            .clinicalTrial,
        ]
        let expectedResolution: ContactCaseOptOutQuestionnaire.Resolution = .needToIsolate(expectedQuestions)
        
        XCTAssertEqual(expectedQuestions, nextQuestions)
        XCTAssertEqual(expectedResolution, resolution)
    }
    
    func testFullyVaccinatedNoLastDoseNoClinicalTrialEngland() {
        let questionnaire = ContactCaseOptOutQuestionnaire(country: .constant(.england))
        
        let answers: [ContactCaseOptOutQuestion: Bool] = [
            .fullyVaccinated: true,
            .lastDose: false,
            .clinicalTrial: false,
        ]
        
        let nextQuestions = questionnaire.nextQuestion(with: answers)
        let resolution = questionnaire.getResolution(with: answers)
        
        let expectedQuestions: [ContactCaseOptOutQuestion] = [
            .fullyVaccinated,
            .lastDose,
            .clinicalTrial,
            .medicallyExempt,
        ]
        let expectedResolution: ContactCaseOptOutQuestionnaire.Resolution = .notFinished
        
        XCTAssertEqual(expectedQuestions, nextQuestions)
        XCTAssertEqual(expectedResolution, resolution)
    }
    
    func testFullyVaccinatedNoLastDoseNoClinicalTrialMedicallyExemptEngland() {
        let questionnaire = ContactCaseOptOutQuestionnaire(country: .constant(.england))
        
        let answers: [ContactCaseOptOutQuestion: Bool] = [
            .fullyVaccinated: true,
            .lastDose: false,
            .clinicalTrial: false,
            .medicallyExempt: true,
        ]
        
        let nextQuestions = questionnaire.nextQuestion(with: answers)
        let resolution = questionnaire.getResolution(with: answers)
        
        let expectedQuestions: [ContactCaseOptOutQuestion] = [
            .fullyVaccinated,
            .lastDose,
            .clinicalTrial,
            .medicallyExempt,
        ]
        let expectedResolution: ContactCaseOptOutQuestionnaire.Resolution = .optedOutOfIsolation(.medicallyExempt, expectedQuestions)
        
        XCTAssertEqual(expectedQuestions, nextQuestions)
        XCTAssertEqual(expectedResolution, resolution)
    }
    
    func testFullyVaccinatedNoLastDoseNoClinicalTrialNoMedicallyExemptEngland() {
        let questionnaire = ContactCaseOptOutQuestionnaire(country: .constant(.england))
        
        let answers: [ContactCaseOptOutQuestion: Bool] = [
            .fullyVaccinated: true,
            .lastDose: false,
            .clinicalTrial: false,
            .medicallyExempt: false,
        ]
        
        let nextQuestions = questionnaire.nextQuestion(with: answers)
        let resolution = questionnaire.getResolution(with: answers)
        
        let expectedQuestions: [ContactCaseOptOutQuestion] = [
            .fullyVaccinated,
            .lastDose,
            .clinicalTrial,
            .medicallyExempt,
        ]
        let expectedResolution: ContactCaseOptOutQuestionnaire.Resolution = .needToIsolate(expectedQuestions)
        
        XCTAssertEqual(expectedQuestions, nextQuestions)
        XCTAssertEqual(expectedResolution, resolution)
    }
    
    func testNotFullyVaccinatedWales() {
        let questionnaire = ContactCaseOptOutQuestionnaire(country: .constant(.wales))
        
        let answers: [ContactCaseOptOutQuestion: Bool] = [
            .fullyVaccinated: false,
        ]
        
        let nextQuestions = questionnaire.nextQuestion(with: answers)
        let resolution = questionnaire.getResolution(with: answers)
        
        let expectedQuestions: [ContactCaseOptOutQuestion] = [
            .fullyVaccinated,
            .clinicalTrial,
        ]
        let expectedResolution: ContactCaseOptOutQuestionnaire.Resolution = .notFinished
        
        XCTAssertEqual(expectedQuestions, nextQuestions)
        XCTAssertEqual(expectedResolution, resolution)
    }
    
    func testNotFullyVaccinatedClinicalTrialWales() {
        let questionnaire = ContactCaseOptOutQuestionnaire(country: .constant(.wales))
        
        let answers: [ContactCaseOptOutQuestion: Bool] = [
            .fullyVaccinated: false,
            .clinicalTrial: true,
        ]
        
        let nextQuestions = questionnaire.nextQuestion(with: answers)
        let resolution = questionnaire.getResolution(with: answers)
        
        let expectedQuestions: [ContactCaseOptOutQuestion] = [
            .fullyVaccinated,
            .clinicalTrial,
        ]
        let expectedResolution: ContactCaseOptOutQuestionnaire.Resolution = .optedOutOfIsolation(.fullyVaccinated, expectedQuestions)
        
        XCTAssertEqual(expectedQuestions, nextQuestions)
        XCTAssertEqual(expectedResolution, resolution)
    }
    
    func testNotFullyVaccinatedNoClinicalTrialWales() {
        let questionnaire = ContactCaseOptOutQuestionnaire(country: .constant(.wales))
        
        let answers: [ContactCaseOptOutQuestion: Bool] = [
            .fullyVaccinated: false,
            .clinicalTrial: false,
        ]
        
        let nextQuestions = questionnaire.nextQuestion(with: answers)
        let resolution = questionnaire.getResolution(with: answers)
        
        let expectedQuestions: [ContactCaseOptOutQuestion] = [
            .fullyVaccinated,
            .clinicalTrial,
        ]
        let expectedResolution: ContactCaseOptOutQuestionnaire.Resolution = .needToIsolate(expectedQuestions)
        
        XCTAssertEqual(expectedQuestions, nextQuestions)
        XCTAssertEqual(expectedResolution, resolution)
    }
    
    func testNotFullyVaccinatedEngland() {
        let questionnaire = ContactCaseOptOutQuestionnaire(country: .constant(.england))
        
        let answers: [ContactCaseOptOutQuestion: Bool] = [
            .fullyVaccinated: false,
        ]
        
        let nextQuestions = questionnaire.nextQuestion(with: answers)
        let resolution = questionnaire.getResolution(with: answers)
        
        let expectedQuestions: [ContactCaseOptOutQuestion] = [
            .fullyVaccinated,
            .medicallyExempt,
        ]
        let expectedResolution: ContactCaseOptOutQuestionnaire.Resolution = .notFinished
        
        XCTAssertEqual(expectedQuestions, nextQuestions)
        XCTAssertEqual(expectedResolution, resolution)
    }
    
    func testNotFullyVaccinatedMedicallyExemptEngland() {
        let questionnaire = ContactCaseOptOutQuestionnaire(country: .constant(.england))
        
        let answers: [ContactCaseOptOutQuestion: Bool] = [
            .fullyVaccinated: false,
            .medicallyExempt: true,
        ]
        
        let nextQuestions = questionnaire.nextQuestion(with: answers)
        let resolution = questionnaire.getResolution(with: answers)
        
        let expectedQuestions: [ContactCaseOptOutQuestion] = [
            .fullyVaccinated,
            .medicallyExempt,
        ]
        let expectedResolution: ContactCaseOptOutQuestionnaire.Resolution = .optedOutOfIsolation(.medicallyExempt, expectedQuestions)
        
        XCTAssertEqual(expectedQuestions, nextQuestions)
        XCTAssertEqual(expectedResolution, resolution)
    }
    
    func testNotFullyVaccinatedNoMedicallyExemptEngland() {
        let questionnaire = ContactCaseOptOutQuestionnaire(country: .constant(.england))
        
        let answers: [ContactCaseOptOutQuestion: Bool] = [
            .fullyVaccinated: false,
            .medicallyExempt: false,
        ]
        
        let nextQuestions = questionnaire.nextQuestion(with: answers)
        let resolution = questionnaire.getResolution(with: answers)
        
        let expectedQuestions: [ContactCaseOptOutQuestion] = [
            .fullyVaccinated,
            .medicallyExempt,
            .clinicalTrial,
        ]
        let expectedResolution: ContactCaseOptOutQuestionnaire.Resolution = .notFinished
        
        XCTAssertEqual(expectedQuestions, nextQuestions)
        XCTAssertEqual(expectedResolution, resolution)
    }
    
    func testNotFullyVaccinatedNoMedicallyExemptClinicalTrialEngland() {
        let questionnaire = ContactCaseOptOutQuestionnaire(country: .constant(.england))
        
        let answers: [ContactCaseOptOutQuestion: Bool] = [
            .fullyVaccinated: false,
            .medicallyExempt: false,
            .clinicalTrial: true,
        ]
        
        let nextQuestions = questionnaire.nextQuestion(with: answers)
        let resolution = questionnaire.getResolution(with: answers)
        
        let expectedQuestions: [ContactCaseOptOutQuestion] = [
            .fullyVaccinated,
            .medicallyExempt,
            .clinicalTrial,
        ]
        let expectedResolution: ContactCaseOptOutQuestionnaire.Resolution = .optedOutOfIsolation(.fullyVaccinated, expectedQuestions)
        
        XCTAssertEqual(expectedQuestions, nextQuestions)
        XCTAssertEqual(expectedResolution, resolution)
    }
    
    func testNotFullyVaccinatedNoMedicallyExemptNoClinicalTrialEngland() {
        let questionnaire = ContactCaseOptOutQuestionnaire(country: .constant(.england))
        
        let answers: [ContactCaseOptOutQuestion: Bool] = [
            .fullyVaccinated: false,
            .medicallyExempt: false,
            .clinicalTrial: false,
        ]
        
        let nextQuestions = questionnaire.nextQuestion(with: answers)
        let resolution = questionnaire.getResolution(with: answers)
        
        let expectedQuestions: [ContactCaseOptOutQuestion] = [
            .fullyVaccinated,
            .medicallyExempt,
            .clinicalTrial,
        ]
        let expectedResolution: ContactCaseOptOutQuestionnaire.Resolution = .needToIsolate(expectedQuestions)
        
        XCTAssertEqual(expectedQuestions, nextQuestions)
        XCTAssertEqual(expectedResolution, resolution)
    }
    
}
