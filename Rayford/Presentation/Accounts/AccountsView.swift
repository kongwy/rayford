//
//  AccountsView.swift
//  Rayford
//
//  Created by Weiyi Kong on 15/8/2025.
//

import SwiftUI
import PhotosUI

struct AccountsView: View {
    @EnvironmentObject var store: Store
    @StateObject private var viewModel = ViewModel()

    var loadingPlaceholder: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(.circular)
                .controlSize(.large)
            Text("Loading...")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    var emptyPlaceholder: some View {
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
    }

    var body: some View {
        Group {
            switch viewModel.cellModels {
            case .none: loadingPlaceholder
            case let .some(models) where models.isEmpty: emptyPlaceholder
            case let .some(models):
                List {
                    ForEach(models) { model in
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
                    }
                )
                .navigationDestination(isPresented: $viewModel.presentEditAccountView) {
                    if let accountId = viewModel.editingAccountId,
                       let viewModel = EditAccountView.ViewModel(id: accountId, in: store) {
                        EditAccountView(viewModel: viewModel)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add", systemImage: "plus.circle") {
                    viewModel.presentAddAccountConfirmation = true
                }
            }
        }
        .confirmationDialog(
            "Add Account",
            isPresented: $viewModel.presentAddAccountConfirmation,
            titleVisibility: .visible,
            actions: {
                Button("Scan QR Code") { viewModel.presentScannerView = true }
                Button("Import QR Image") { viewModel.presentPhotoPicker = true }
                Button("Enter Manually") { viewModel.presentAddAccountView = true }
            },
            message: {
                Text("Add an account by scanning a QR code, importing a QR image, or entering a secret manually.")
            }
        )
        .sheet(isPresented: $viewModel.presentScannerView) {
            ScannerView().ignoresSafeArea(.container, edges: .bottom)
        }
        .photosPicker(isPresented: $viewModel.presentPhotoPicker,
                      selection: $viewModel.pickedImageItem,
                      matching: .images,
                      preferredItemEncoding: .automatic)
        .sheet(isPresented: $viewModel.presentAddAccountView) {
            AddAccountView()
        }
        .navigationTitle("Accounts")
    }
}

#Preview {
    NavigationView {
        AccountsView()
    }
}
