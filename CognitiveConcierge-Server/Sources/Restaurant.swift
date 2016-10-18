/**
* Copyright IBM Corporation 2016
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation
import SwiftyJSON
import KituraNet
import LoggerAPI
import AlchemyLanguage

class Restaurant {

    fileprivate var name: String
    fileprivate var rating: Double
    fileprivate var expense: Int
    fileprivate var address: String
    fileprivate var reviews: Array<String>
    fileprivate var matchScore: Int
    fileprivate var matchPercentage: Double
    fileprivate var keywords: Array<String>
    fileprivate var googleID: String
    fileprivate var isOpenNow: Bool
    fileprivate var openingTimeNow: Array<String>
    fileprivate var website: String

    var negativeSentiments: Array<String>
    var positiveSentiments: Array<String>

    //MARK: Initializer
    init(googleID: String, isOpenNow: Bool, openingTimeNow: Array<String>, name: String, rating: Double, expense: Int, address: String, reviews: Array<String>, website: String) {
        self.googleID = googleID
        self.isOpenNow = isOpenNow
        self.openingTimeNow = openingTimeNow
        self.name = name
        self.rating = rating
        self.expense = expense
        self.address = address
        self.reviews = reviews
        self.matchScore = 0
        self.matchPercentage = 0
        self.keywords = []
        self.negativeSentiments = []
        self.positiveSentiments = []
        self.website = website
    }
    
    func populateWatsonKeywords(_ completion: @escaping ( Array<String>)->(), failure: @escaping (String) -> Void) {
        //append reviews from restaurant into a string to pass to watson
        var reviewStrings = ""
        for review in self.reviews {
            reviewStrings.append(review)
            reviewStrings.append(" ")
        }
        
        var watsonAPIKey = ""
        
        do {
            let service = try getConfiguration(configFile: configFile,
                                               serviceName: alchemyServiceName)
            if let credentials = service.credentials {
                watsonAPIKey = credentials["apikey"].stringValue
            } else {
                //no credentials for the service
            }
        } catch {
            //no configuration file.
        }

        let alchemyLanguage = AlchemyLanguage(apiKey: watsonAPIKey)
        
        alchemyLanguage.getRankedKeywords(forText: reviewStrings, sentiment: QueryParam.Included,
                                          failure: { error in print (error)},
                                          success: { response in
            
            if let keywords = response.keywords {
                for keyword in keywords {
                    if let text = keyword.text {
                        if let keySentiment = keyword.sentiment?.type {
                            if keySentiment == "negative" {
                                self.negativeSentiments.append(keyword.text!)
                            } else if keySentiment == "positive" {
                                self.positiveSentiments.append(keyword.text!)
                            }
                        }
                        let wordsArray = text.components(separatedBy: " ")
                        for word in wordsArray {
                            self.keywords.append(word)
                        }
                    }
                }
                completion(self.keywords)
            }
        })
    }

    //increment the match score by 1
    func incrementMatchScore() {
        self.matchScore += 1
    }
    //Getters
    func getGoogleID() -> String {
        return self.googleID
    }
    //Getters
    func getIsOpenNow() -> Bool {
        return self.isOpenNow
    }
    func getOpeningTimeNow() -> Array<String> {
        return self.openingTimeNow
    }
    func getName() -> String {
        return self.name
    }
    func getRating() -> Double {
        return self.rating
    }
    func getExpense() -> Int {
        return self.expense
    }
    func getAddress() -> String {
        return self.address
    }
    func getReviews() -> Array<String> {
        return self.reviews
    }

    func getMatchScore() -> Int {
        return self.matchScore
    }
    func getMatchPercentage() -> Double {
        return self.matchPercentage
    }
    func getWatsonKeywords() -> Array<String> {
        return self.keywords
    }
    func getNegativeSentiments() ->Array<String> {
        return self.negativeSentiments
    }
    func getPositiveSentiments() -> Array<String> {
        return self.positiveSentiments
    }
    func getWebsite() -> String {
        return self.website
    }

    //Setters
    func setMatchPercentage(_ percentage: Double) {
        self.matchPercentage = percentage
    }
}
