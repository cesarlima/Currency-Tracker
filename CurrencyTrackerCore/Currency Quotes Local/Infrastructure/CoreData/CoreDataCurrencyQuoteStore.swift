//
//  CoreDataCurrencyQuoteStore.swift
//  CurrencyTrackerCore
//
//  Created by MacPro on 09/03/24.
//

import Foundation
import CoreData

final class CoreDataCurrencyQuoteStore: CurrencyQuoteStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "CurrencyQuotes", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    func save(quotes: [CurrencyTrackerCore.CurrencyQuote]) async throws {
        let context = context
        
        try await context.perform({
            quotes.forEach { currencyQuote in
                ManagedCurrencyQuote.createManagedCurrencyQuote(from: currencyQuote,
                                                                in: context)
            }
            try context.save()
        })
    }
    
    func delete(with codeIn: String) async throws {
        
    }
    
    func retrieve(codeIn: String) async throws -> [CurrencyTrackerCore.CurrencyQuote]? {
        let context = context
        
        let managedQuotes = try await context.perform({
            try ManagedCurrencyQuote.findByCodeIn(codeIn, in: context)
        }) ?? []
        
        return managedQuotes.map { $0.toLocal() }
    }
}