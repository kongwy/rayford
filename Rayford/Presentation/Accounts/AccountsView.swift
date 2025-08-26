//
//  AccountsView.swift
//  Rayford
//
//  Created by Weiyi Kong on 15/8/2025.
//

import SwiftUI

struct AccountsView: View {
    @EnvironmentObject var store: Store
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        List(viewModel.cellModels) { model in
            AccountCellView(model: model)
        }
        .listStyle(.grouped)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add", systemImage: "plus.circle") {
                    viewModel.presentAddAccountView = true
                }
            }
        }
        .navigationTitle("Accounts")
        .sheet(isPresented: $viewModel.presentAddAccountView) {
            AddAccountView(viewModel: .init(isPresented: $viewModel.presentAddAccountView))
        }
    }
}

#Preview {
    NavigationView {
        AccountsView()
            .environmentObject(mockStore)
    }
}
