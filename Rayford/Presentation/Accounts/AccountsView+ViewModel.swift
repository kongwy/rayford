//
//  AccountsView+ViewModel.swift
//  Rayford
//
//  Created by Weiyi Kong on 20/8/2025.
//

import SwiftUI
import Combine
import PhotosUI
import Vision

extension AccountsView {
    class ViewModel: ObservableObject {
        private var passwordManager: PasswordManager

        @Published var presentDeleteAccountConfirmation = false
        @Published var deletingAccountId: UUID? = nil

        @Published var presentEditAccountView = false
        @Published var editingAccountId: UUID? = nil

        @Published var presentAddAccountConfirmation = false
        @Published var presentAddAccountView = false
        @Published var presentPhotoPicker = false
        @Published var pickedImageItem: PhotosPickerItem? = nil
        @Published private var pickedImageState: PhotosPickerItemState = .idle

        @Published var cellModels = [AccountCellView.Model]()

        private var cancellable = Set<AnyCancellable>()

        init(with store: Store = .shared) {
            passwordManager = PasswordManager(store: store)
            store.publisher(\.accounts)
                .combineLatest(passwordManager.passcodes, passwordManager.progresses, passwordManager.secondsRemainings)
                .sink { [weak self] accounts, passcodes, progresses, secondsRemainings in
                    guard let self else { return }
                    self.updateCellStates(accounts: accounts,
                                          passcodes: passcodes,
                                          progresses: progresses,
                                          secondsRemainings: secondsRemainings,
                                          in: store)
                }
                .store(in: &cancellable)

            $pickedImageItem
                .sink { [weak self] item in
                    guard let self else { return }
                    self.received(pickedImageItem: item)
                }
                .store(in: &cancellable)
            $pickedImageState
                .sink { [weak self] state in
                    guard let self else { return }
                    self.received(pickedImageState: state, store: store)
                }
                .store(in: &cancellable)
        }

        // MARK: - Cell Models Data Flow

        private func updateCellStates(accounts: [Account],
                                      passcodes: [UUID : String],
                                      progresses: [UUID : Double],
                                      secondsRemainings: [UUID : Int],
                                      in store: Store = .shared) {
            cellModels = accounts.compactMap { account in
                guard let passcode = passcodes[account.id] else { return nil }
                let accessoryType: AccountCellView.AccessoryType
                switch account.password.kind {
                case .hotp:
                    accessoryType = .nextButton { [weak self] in
                        self?.incrementCounter(for: account.id, in: store)
                    }
                case .totp:
                    guard let progress = progresses[account.id],
                          let secondsRemaining = secondsRemainings[account.id]
                    else { return nil }
                    accessoryType = .progressCircle(value: progress, text: "\(secondsRemaining)")
                }
                return AccountCellView.Model(id: account.id,
                                             passcode: passcode,
                                             description: account.description,
                                             accessoryType: accessoryType)
            }
        }

        // MARK: - Photo Picker

        private func received(pickedImageItem item: PhotosPickerItem?) {
            if case let .loading(progress) = pickedImageState { progress.cancel() }
            guard let item else { self.pickedImageState = .idle; return }
            self.pickedImageState = .loading(item.loadTransferable(type: Data.self) { result in
                let imageResult = result.map { $0.flatMap { UIImage(data: $0)?.cgImage } }
                switch imageResult {
                case let .success(cgImage?):
                    self.pickedImageState = .success(cgImage)
                case .success(nil):
                    self.pickedImageState = .idle
                case let .failure(error):
                    self.pickedImageState = .failure(error)
                }
            })
        }

        private func received(pickedImageState state: PhotosPickerItemState, store: Store = .shared) {
            switch state {
            case let .success(cgImage):
                detect(qrcode: cgImage).forEach { save(account: $0, in: store) }
            case .idle, .loading(_), .failure(_): break
            }
        }

        private func detect(qrcode cgImage: CGImage) -> [Account] {
            do {
                let qrcodeRequest = VNDetectBarcodesRequest()
                qrcodeRequest.symbologies = [.qr]
                let handler = VNImageRequestHandler(cgImage: cgImage)
                try handler.perform([qrcodeRequest])
                return (qrcodeRequest.results ?? [])
                    .sorted { $0.confidence > $1.confidence }
                    .compactMap { $0.payloadStringValue?.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .compactMap { URL(string: $0) }
                    .compactMap { Account(url: $0) }
            } catch {
                Logger.main.error("Failed to detect QR Code: \(error.localizedDescription)")
                return []
            }
        }

        // MARK: - Private Methods

        private func incrementCounter(for id: UUID, in store: Store = .shared) {
            store.appState.accounts.update(id: id) { account in
                account.password.incrementCounter()
            }
        }

        private func save(account: Account, in store: Store = .shared) {
            store.appState.accounts.append(account)
        }

        // MARK: - Public Methods

        func presentDeleteAccountConfirmation(for id: UUID) {
            deletingAccountId = id
            presentDeleteAccountConfirmation = true
        }

        func deleteAccount(for id: UUID, in store: Store = .shared) {
            store.appState.accounts.remove(id: id)
        }

        func presentEditAccountView(for id: UUID) {
            editingAccountId = id
            presentEditAccountView = true
        }

        func moveAccount(from source: IndexSet, to destination: Int, in store: Store = .shared) {
            store.appState.accounts.move(fromOffsets: source, toOffset: destination)
        }
    }
}
