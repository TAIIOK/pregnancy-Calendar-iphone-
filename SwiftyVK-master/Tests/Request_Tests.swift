import XCTest
@testable import SwiftyVK


class Sending_Tests: VKTestCase {

  
  
  func test_A_get_method() {
    let readyExpectation = expectationWithDescription("ready")
    
      let req = VK.API.Users.get([VK.Arg.userIDs : "1"])
      req.isAsynchronous = true
      req.send(
        method: .GET,
        success: {response in
          readyExpectation.fulfill()
        },
        error: {error in
          XCTFail("Unexpected error in GET request: \(error)")
          readyExpectation.fulfill()
      })
    
      waitForExpectationsWithTimeout(5) {_ in}
  }
  
  
  
  func test_A_post_method() {
    let readyExpectation = expectationWithDescription("ready")
    
    let req = VK.API.Users.get([VK.Arg.userIDs : "1"])
    req.isAsynchronous = true
    req.send(
      method: .POST,
      success: {response in
        readyExpectation.fulfill()
      },
      error: {error in
        XCTFail("Unexpected error in GET request: \(error)")
        readyExpectation.fulfill()
    })
    
    waitForExpectationsWithTimeout(5) {_ in}
  }
  
  
  
  /**
   To use this test you need:
   Disable internet ->
   Run test ->
   Enable internet.
   */
  func test_A_infinite() {
    let readyExpectation = expectationWithDescription("ready")
    
    let req = VK.API.Users.get([VK.Arg.userIDs : "1"])
    req.maxAttempts = 0
    req.send(
      success: {response in
        readyExpectation.fulfill()
      },
      error: {error in
        XCTFail("Unexpected error in request: \(error)")
        readyExpectation.fulfill()
    })
    
    waitForExpectationsWithTimeout(5) {_ in}
  }
  
  
  
  func test_A_errorblock() {
    let readyExpectation = expectationWithDescription("ready")
    
    let req = VK.API.Messages.getHistory()
    req.send(
      success: {response in
        XCTFail("Unexpected succes in request: \(response)")
        readyExpectation.fulfill()
      },
      error: {error in
        readyExpectation.fulfill()
    })
    
    waitForExpectationsWithTimeout(5) {_ in}
  }
  
  
  
  func test_B_synchronious() {
    let readyExpectation = expectationWithDescription("ready")
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
      for n in 1...10 {
        let req = VK.API.Users.get([VK.Arg.userIDs : "\(n)"])
        req.isAsynchronous = false
        var executed = false
        
        req.send(
          success: {response in
            executed = true
          },
          error: {error in
            executed = true
            XCTFail("Unexpected error in \(n) request: \(error)")
            readyExpectation.fulfill()
        })
        
        if !executed {XCTFail("Request \(n) is not synchronious")}
        if n >= 10 {readyExpectation.fulfill()}
      }
    }
    
    waitForExpectationsWithTimeout(5) {_ in}
  }
  
  
  
  func test_B_asynchronious() {
    let readyExpectation = expectationWithDescription("ready")
    var exeCount = 0
    
    for n in 1...10 {
      let req = VK.API.Users.get([VK.Arg.userIDs : "\(n)"])
      req.isAsynchronous = true
      req.send(
        success: {response in
          exeCount += 1
          exeCount >= 10 ? readyExpectation.fulfill() : ()
        },
        error: {error in
          XCTFail("Unexpected error in \(n) request: \(error)")
          readyExpectation.fulfill()
      })
    }
    
    waitForExpectationsWithTimeout(5) {_ in}
  }
  
  
  
  func test_C_random() {
    let readyExpectation = expectationWithDescription("ready")
    var exeCount = 0
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
      for n in 1...10 {
        let asynchronously = !(n % 3 == 0)
        let req = VK.API.Users.get([VK.Arg.userIDs : "\(n)"])
        req.isAsynchronous = asynchronously
        var executed = false
        
        req.send(
          success: {response in
            exeCount += 1
            executed = true
            exeCount >= 10 ? readyExpectation.fulfill() : ()
          },
          error: {error in
            XCTFail("Unexpected error in \(n) request: \(error)")
        })
        
        if !asynchronously && !executed {
          XCTFail("Request \(n) is not synchronious")
          readyExpectation.fulfill()
        }
      }
    }
    
    waitForExpectationsWithTimeout(5) {_ in}
  }
  
  
  
  func test_C_many() {
    let readyExpectation = self.expectationWithDescription("ready")
    let backup = VK.defaults.maxRequestsPerSec
    VK.defaults.maxRequestsPerSec = 100
    let requests = NSMutableDictionary()
    var executed = 0
    
    for n in 1...VK.defaults.maxRequestsPerSec {
      let req = VK.API.Users.get([VK.Arg.userIDs : "\(n)"])
      requests[req.id] = "~"
      req.isAsynchronous = true
      
      req.send(
        success: {response in
          requests[req.id] = "+"
          executed += 1
          executed >= VK.defaults.maxRequestsPerSec ? readyExpectation.fulfill() : ()
        },
        error: {error in
          requests[req.id] = "-"
          executed += 1
          executed >= VK.defaults.maxRequestsPerSec ? readyExpectation.fulfill() : ()
      })
    }
    
    self.waitForExpectationsWithTimeout(60) {_ in
      VK.defaults.maxRequestsPerSec = backup
      let results = self.getResults(requests)
      printSync(results.statistic)
      if results.error.count > results.all.count/50 {
        XCTFail("Too many errors")
      }
    }
  }
  
  
  
  func test_C_performance() {
    self.measureBlock() {
      let readyExpectation = self.expectationWithDescription("ready")
      var executed = 0
      
      for n in 1...VK.defaults.maxRequestsPerSec {
        let req = VK.API.Users.get([VK.Arg.userIDs : "\(n)"])
        req.isAsynchronous = true
        req.send(
          success: {response in
            executed += 1
            executed == VK.defaults.maxRequestsPerSec ? readyExpectation.fulfill() : ()
          },
          error: {error in
            executed += 1
            executed == VK.defaults.maxRequestsPerSec ? readyExpectation.fulfill() : ()
        })
      }
      
      self.waitForExpectationsWithTimeout(10) {_ in}
    }
  }
}
