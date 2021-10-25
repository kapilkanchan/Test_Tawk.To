//
//  tawk_toTests.swift
//  tawk.toTests
//
//  Created by Kapil Kanchan on 23/10/21.
//

import XCTest
@testable import tawk_to

class tawk_toTests: XCTestCase {
    
    //MARK:- Checks for valid data with valid user parameter
    func testFetchUserProfile_With_ValidRequest_ReturnsValidData() {
        let user = "morocco"
        
        let apiService = APIService()
        let expectations = expectation(description: "ValidRequest_ReturnsValidData")
        
        apiService.fetchUserProfile(for: user) { result in
            switch result {
            case .success(let profileUser):
                XCTAssertNotNil(profileUser)
                XCTAssertEqual(profileUser.login, "morocco")
                expectations.fulfill()
                break
            case .failure(let error):
                switch error {
                case .localizedDescription(let errorDescription):
                    XCTAssertEqual(errorDescription, "The Internet connection appears to be offline.")
                    expectations.fulfill()
                    break
                }
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    //MARK:-
    func testFetchUserProfile_With_InValidRequest_ReturnsError() {
        let user = ""
        let apiService = APIService()
        let expectations = expectation(description: "InValidRequest_ReturnsError")

        apiService.fetchUserProfile(for: user) { result in
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
                switch error {
                case .localizedDescription(let description):
                    if description.elementsEqual("Request Failed") {
                        XCTAssertEqual(description, "Request Failed")
                    } else {
                        XCTAssertEqual(description, "The Internet connection appears to be offline.")
                    }
                    expectations.fulfill()
                }
                break
            default:
                XCTFail()
                expectations.fulfill()
                break
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    //MARK:- Next 30 users will be fetched whatever number you pass
    func testFetchListOfUsers_With_CorrectPaginationIndex_ReturnsValidData() {
        let apiService = APIService()
        let expectations = expectation(description: "InValidRequest_ReturnsError")
        
        apiService.fetchUsersListData(0) { result in
            switch result {
            case .success(let users):
                XCTAssertNotNil(users)
                XCTAssert(users.count>0)
                expectations.fulfill()
                break
            case .failure(let error):
                switch error {
                case .localizedDescription(let errorDescription):
                    XCTAssertEqual(errorDescription, "The Internet connection appears to be offline.")
                    expectations.fulfill()
                    break
                }
            }
        }
        
        waitForExpectations(timeout: 15, handler: nil)
    }
}
