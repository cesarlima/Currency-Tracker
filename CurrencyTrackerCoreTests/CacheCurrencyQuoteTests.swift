//
//  CacheCurrencyQuoteTests.swift
//  CurrencyTrackerCoreTests
//
//  Created by MacPro on 08/03/24.
//

import XCTest
@testable import CurrencyTrackerCore

final class CacheCurrencyQuoteTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() async throws {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() async throws {
        let (sut, store) = makeSUT()
        let models = makeCurrencies().models
        store.completeDeletion(with: makeNSError())
        
        try? await sut.save(quotes: models)
    
        XCTAssertEqual(store.receivedMessages, [.deleteCachedCurrencyQuote(models.first!.codeIn)])
    }
    
    func test_save_failsOnDeletionError() async throws {
        let (sut, store) = makeSUT()
        let deletionError = makeNSError()
        
        await expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsOnInsertionError() async throws {
        let (sut, store) = makeSUT()
        let insertionError = makeNSError()
        
        await expect(sut, toCompleteWithError: insertionError) {
            store.completeInsertion(with: insertionError)
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: LocalCurrencyQuoteHandler, store: CurrencyQuoteStoreStub) {
        let store = CurrencyQuoteStoreStub()
        let sut = LocalCurrencyQuoteHandler(store: store)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalCurrencyQuoteHandler,
                        toCompleteWithError expectedError: NSError,
                        when storeAction: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) async {
        storeAction()
        var receivedError: NSError?
        
        do {
            try await sut.save(quotes: makeCurrencies().models)
        } catch {
            receivedError = error as NSError
        }
        
        XCTAssertEqual(expectedError, receivedError, file: file, line: line)
    }
    
    private func makeCurrencies() -> (data: Data, models: [CurrencyQuote]) {
        let data = """
        {
           "USDBRL":{
              "code":"USD",
              "codein":"BRL",
              "name":"Dólar Americano/Real Brasileiro",
              "high":"4.9473",
              "low":"4.9451",
              "varBid":"0.0005",
              "pctChange":"0.01",
              "bid":"4.9446",
              "ask":"4.9456",
              "timestamp":"1709773060",
              "create_date":"2024-03-06 21:57:40"
           },
           "EURBRL":{
              "code":"EUR",
              "codein":"BRL",
              "name":"Euro/Real Brasileiro",
              "high":"5.3884",
              "low":"5.3884",
              "varBid":"0",
              "pctChange":"0",
              "bid":"5.3844",
              "ask":"5.3924",
              "timestamp":"1709772809",
              "create_date":"2024-03-06 21:53:29"
           },
           "BTCBRL":{
              "code":"BTC",
              "codein":"BRL",
              "name":"Bitcoin/Real Brasileiro",
              "high":"337412",
              "low":"314801",
              "varBid":"12379",
              "pctChange":"3.89",
              "bid":"330376",
              "ask":"330618",
              "timestamp":"1709773087",
              "create_date":"2024-03-06 21:58:07"
           }
        }
        """.data(using: .utf8)!
        
        let response = HTTPURLResponse(
            url: anyURL(),
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)!
        let currencies = try! CurrencyQuoteMapper.map(data, from: response)
        return (data, currencies)
    }
}
