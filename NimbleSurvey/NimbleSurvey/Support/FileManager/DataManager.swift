//
//  DataManager.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit
import CoreData

class DataManager {

    // MARK: Lifecycle

    private init() {
        // Referencing AppDelegate's persistent container context
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate unavailable")
        }
        self.context = appDelegate.persistentContainer.viewContext
    }

    // MARK: Internal

    static let shared = DataManager()

    // Reference to managed object context
    let context: NSManagedObjectContext

    func saveSurveyToCoreData(surveyList: SurveyListModel) {
        guard let surveyDataList = surveyList.data else { return }

        for surveyData in surveyDataList {
            // Create a new object based on the Survey entity
            let surveyEntity = NSEntityDescription.insertNewObject(
                forEntityName: "SurveyListData",
                into: self.context) as! SurveyListData

            surveyEntity.id = surveyData.id
            surveyEntity.type = surveyData.type

            // Set the attributes for the Survey entity
            if let attributesData = surveyData.attributes {
                let attributesEntity = NSEntityDescription.insertNewObject(
                    forEntityName: "SurveyListAttributes",
                    into: self.context) as! SurveyListAttributes

                attributesEntity.title = attributesData.title
                attributesEntity.descriptions = attributesData.description
                attributesEntity.thankEmailAboveThreshold = attributesData.thankEmailAboveThreshold
                attributesEntity.thankEmailBelowThreshold = attributesData.thankEmailBelowThreshold
                attributesEntity.isActive = attributesData.isActive ?? false
                attributesEntity.coverImageURL = attributesData.coverImageURL
                attributesEntity.createdAt = attributesData.createdAt
                attributesEntity.activeAt = attributesData.activeAt
                attributesEntity.inactiveAt = attributesData.inactiveAt
                attributesEntity.surveyType = attributesData.surveyType

                // Connect the Attributes entity to the Survey
                surveyEntity.attributes = attributesEntity
            }

            guard let questionsData = surveyData.relationships?.questions?.data else { return }
            for index in questionsData.indices {
                let questionsEntity = NSEntityDescription.insertNewObject(
                    forEntityName: "SurveyListQuestionsData",
                    into: self.context) as! SurveyListQuestionsData

                questionsEntity.id = surveyData.relationships?.questions?.data?[index].id
                questionsEntity.type = surveyData.relationships?.questions?.data?[index].type

                // Connect the Questions entity to the Survey
                surveyEntity.relationships?.questions?.data = questionsEntity
            }
        }

        // After setting all properties and relationships, we save the context.
        do {
            try self.context.save() // This commits the changes and saves them to disk
            print("Surveys saved successfully!")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }


    func fetchAndPrintSurveys() {
        // Step 1: Create a fetch request for the type of entity you want to retrieve
        let fetchRequest: NSFetchRequest<SurveyListData> = SurveyListData.fetchRequest()

        do {
            // Step 2: Execute the fetch request on the context
            let surveys = try context.fetch(fetchRequest)

            // Step 3: Iterate over the fetched results and use/print them as needed
            for survey in surveys {
                print("Survey ID: \(survey.id ?? "No ID")")
                print("Survey Type: \(survey.type ?? "No Type")")

                // If the attributes are a separate entity related to the survey, you can access them like this:
                if let attributes = survey.attributes {
                    print("attributes Title: \(attributes.title ?? "No Title")")
                    print("attributes Description: \(attributes.descriptions ?? "No Description")")
                    // ... print other attributes as needed ...
                }

                if let questionsSet = survey.relationships?.questions as? Set<SurveyListQuestionsData> {
                    questionsSet.forEach { question in
                        print("Question ID: \(question.id ?? "No ID")")
                        print("Question Type: \(question.type ?? "No Type")")
                    }
                } else {
                    print("Failed to cast questions for survey ID: \(survey.id ?? "No ID")")
                }
                // Print a separator between surveys
                print("-------")
            }
        } catch let error as NSError {
            // Handle failure to fetch results
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

}
