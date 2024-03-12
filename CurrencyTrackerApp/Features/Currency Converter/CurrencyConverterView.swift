//
//  CurrencyConverterView.swift
//  CurrencyTrackerApp
//
//  Created by MacPro on 11/03/24.
//

import SwiftUI
import CurrencyTrackerCore

struct CurrencyConverterView: View {
    @FocusState private var currentCurrencyFocused: Bool
    let currencies: [Currency] = MockData.currencies
    
    @StateObject var viewModel: CurrencyConverterViewModel
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    CurrencyView(amount: $viewModel.fromCurrencyAmount,
                                 selectedCurrency: $viewModel.fromCurrency,
                                 currencies: MockData.currenciesOringi,
                                 editable: true)
                    .focused($currentCurrencyFocused)
                    
                    CurrencyView(amount: $viewModel.toCurrencyAmount,
                                 selectedCurrency: $viewModel.toCurrency,
                                 currencies: currencies,
                                 editable: false)
                    
                    Text("A última atualização da cotação de \(viewModel.fromCurrency.name) para \(viewModel.toCurrency.name) foi em 11/03/2024 15:00")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.top, 32)
                        .padding([.leading, .trailing], 60)
                    
                    Spacer()
                    
                    StandardPrimaryButton(title: "Converter") {
                        viewModel.convert()
                    }
                    .padding(.bottom, 16)
                    .disabled(viewModel.isConvertButtonDisabled)
        
                }
                .navigationTitle("Calculadora")
            }
        }
    }
}

//struct CurrencyConverterView_Previews: PreviewProvider {
//    static var previews: some View {
//        CurrencyConverterView()
//    }
//}
