//
//  SurveyListModel.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

// MARK: - SurveyListModel
struct SurveyListModel: Codable {
    let data: [SurveyListModelData]?
    let meta: SurveyListModelMeta?
}

// MARK: - SurveyListModelDatum
struct SurveyListModelData: Codable {
    let id, type: String?
    let attributes: SurveyListModelAttributes?
    let relationships: SurveyListModelRelationships?
}

// MARK: - Attributes
struct SurveyListModelAttributes: Codable {
    let title, description, thankEmailAboveThreshold, thankEmailBelowThreshold: String?
    let isActive: Bool?
    let coverImageURL: String?
    let createdAt, activeAt: String?
    let inactiveAt: String?
    let surveyType: String?

    enum CodingKeys: String, CodingKey {
        case title, description
        case thankEmailAboveThreshold = "thank_email_above_threshold"
        case thankEmailBelowThreshold = "thank_email_below_threshold"
        case isActive = "is_active"
        case coverImageURL = "cover_image_url"
        case createdAt = "created_at"
        case activeAt = "active_at"
        case inactiveAt = "inactive_at"
        case surveyType = "survey_type"
    }
}

// MARK: - Relationships
struct SurveyListModelRelationships: Codable {
    let questions: SurveyListModelQuestions?
}

// MARK: - Questions
struct SurveyListModelQuestions: Codable {
    let data: [QuestionsData]?
}

// MARK: - QuestionsDatum
struct QuestionsData: Codable {
    let id: String?
    let type: String?
}

struct SurveyListModelMeta: Codable {
    let page, pages, pageSize, records: Int?

    enum CodingKeys: String, CodingKey {
        case page, pages
        case pageSize = "page_size"
        case records
    }
}

