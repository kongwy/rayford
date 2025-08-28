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
        Group {
            if viewModel.cellModels.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("No Accounts")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Add one by tapping the add button in the upper right corner.")
                        .multilineTextAlignment(.center)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.cellModels) { model in
                        AccountCellView(model: model)
                            .onTapGesture {
                                UIPasteboard.general.string = model.passcode
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            }
                            .contextMenu {
                                Section {
                                    Button("Copy", systemImage: "document.on.document") {
                                        UIPasteboard.general.string = model.passcode
                                    }
                                }
                                Section {
                                    Button("Edit", systemImage: "square.and.pencil") {
                                        viewModel.presentEditAccountView(for: model.id)
                                    }
                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        viewModel.presentDeleteAccountConfirmation(for: model.id)
                                    }
                                }
                            }
                            .swipeActions {
                                Button("Delete", systemImage: "trash") {
                                    viewModel.presentDeleteAccountConfirmation(for: model.id)
                                }.tint(.red)
                                
                                Button("Edit", systemImage: "square.and.pencil") {
                                    viewModel.presentEditAccountView(for: model.id)
                                }
                            }
                    }
                    .onMove { source, destination in
                        viewModel.moveAccount(from: source, to: destination, in: store)
                    }
                }
                .listStyle(.grouped)
                .confirmationDialog(
                    "Deleting This Account Will Not Turn Off Two-Factor Authentication",
                    isPresented: $viewModel.presentDeleteAccountConfirmation,
                    titleVisibility: .visible,
                    presenting: viewModel.deletingAccountId,
                    actions: { id in
                        Button("Delete Account", role: .destructive) {
                            withAnimation {
                                viewModel.deleteAccount(for: id, in: store)
                            }
                        }
                    }, message: { _ in
                        Text("Please make sure two-factor authentication is turned off in the issuer's settings before deleting this account to prevent being locked out.")
                    })
                .navigationDestination(isPresented: $viewModel.presentEditAccountView) {
                    if let accountId = viewModel.editingAccountId,
                       let viewModel = EditAccountView.ViewModel(id: accountId, in: store) {
                        EditAccountView(viewModel: viewModel)
                    }
                }
            }
        }
        .confirmationDialog(
            "Add Account",
            isPresented: $viewModel.presentAddAccountConfirmation,
            titleVisibility: .visible,
            actions: {
                Button("Scan QR Code") { }
                Button("Import QR Image") { }
                Button("Enter Manually") {
                    viewModel.presentAddAccountView = true
                }
            },
            message: {
                Text("Add an account by scanning a QR code, importing a QR image, or entering a secret manually.")
            })
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add", systemImage: "plus.circle") {
                    viewModel.presentAddAccountConfirmation = true
                }
            }
        }
        .navigationTitle("Accounts")
        .sheet(isPresented: $viewModel.presentAddAccountView) {
            AddAccountView()
        }
    }
}

#Preview {
    NavigationView {
        AccountsView()
    }
}
