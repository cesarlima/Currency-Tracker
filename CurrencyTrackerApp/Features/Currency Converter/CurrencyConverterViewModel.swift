//
//  CurrencyConverterViewModel.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 12/03/24.
//

import SwiftUI
import Combine
import CurrencyTrackerCore

final class CurrencyConverterViewModel: ObservableObject {
    @Published var fromCurrencyAmount: String = "1"
    @Published var fromCurrency: Currency = Currency(code: "USD", name: "Dólar")
    @Published var toCurrencyAmount: String = ""
    @Published var toCurrency: Currency = Currency(code: "BRL", name: "Real")
    
    private let useCase: CurrencyConvertUseCase
    private var cancellables = Set<AnyCancellable>()
    
    var isConvertButtonDisabled: Bool {
        return fromCurrency.code.isEmpty
        || toCurrency.code.isEmpty
        || fromCurrencyAmount.isEmpty
    }
    
    init(useCase: CurrencyConvertUseCase) {
        self.useCase = useCase
        
        $fromCurrencyAmount
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] newValue in
                guard let value = Formatter.fromBRLFormatedCurrency(newValue) else { return }
                self?.fromCurrencyAmount = Formatter.toBRLFormatedCurrency(value)
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func convert() {
        guard let value = Formatter.fromBRLFormatedCurrency(fromCurrencyAmount) else { return }
        
        Task {
            do {
                let result = try await useCase.convert(from: fromCurrency,
                                                       toCurrency: toCurrency,
                                                       amount: value)
                toCurrencyAmount = Formatter.toBRLFormatedCurrency(result)
            } catch{
                
            }
        }
    }
}
