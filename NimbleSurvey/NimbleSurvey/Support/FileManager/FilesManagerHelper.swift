//
//  FilesManagerHelper.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

class FilesManagerHelper {

    // MARK: Lifecycle

    // MARK: - Initializers
    private init?() {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        self.documentsURL = url
    }

    // MARK: Internal

    // MARK: - Singleton Instance
    static let shared = FilesManagerHelper()

    // MARK: - Public Methods
    func save(data: Data, withName fileName: String) -> Bool {
        let fileURL = self.documentsURL.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            return true
        } catch {
            print("Error saving data: \(error)")
            return false
        }
    }

    func read(withName fileName: String) -> Data? {
        let fileURL = self.documentsURL.appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("File does not exist!")
            return nil
        }

        do {
            let savedData = try Data(contentsOf: fileURL)
            return savedData
        } catch {
            print("Error reading data: \(error)")
            return nil
        }
    }

    func saveSurveys(surveys: [SurveyListModelData], withName fileName: String) -> Bool {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(surveys)
            return self.save(data: data, withName: fileName)
        } catch {
            print("Error encoding surveys: \(error)")
            return false
        }
    }

    func readSurveys(withName fileName: String) -> [SurveyListModelData]? {
        guard let data = read(withName: fileName) else { return nil }

        do {
            let decoder = JSONDecoder()
            let surveys = try decoder.decode([SurveyListModelData].self, from: data)
            return surveys
        } catch {
            print("Error decoding surveys: \(error)")
            return nil
        }
    }

    // MARK: Private

    // MARK: - Properties
    private let documentsURL: URL

}
