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
                .contextMenu {
                    Button("Edit", systemImage: "pencil") {
                        viewModel.editingAccountId = model.id
                        viewModel.presentEditAccountView = true
                    }
                }
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
            AddAccountView()
        }
        .navigationDestination(isPresented: $viewModel.presentEditAccountView) {
            if let accountId = viewModel.editingAccountId,
               let viewModel = EditAccountView.ViewModel(id: accountId, in: store) {
                EditAccountView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    NavigationView {
        AccountsView()
    }
}
