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
import CombineExt

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
        @Published var cellModels: [AccountCellView.Model]? = nil

        private var qrImageDetectionStatus = CurrentValueRelay<Status<Progress, [Account], Error>>(.idle)

        private var cancellable = Set<AnyCancellable>()

        init(with store: Store = .shared) {
            passwordManager = PasswordManager(store: store)
            store.publisher(\.accounts)
                .combineLatest(passwordManager.passcodes, passwordManager.progresses, passwordManager.secondsRemainings)
                .compactMap { [weak self] accounts, passcodes, progresses, secondsRemainings in
                    self?.composeCellStates(accounts: accounts,
                                          passcodes: passcodes,
                                          progresses: progresses,
                                          secondsRemainings: secondsRemainings,
                                          in: store)
                }
                .receive(on: DispatchQueue.main)
                .assign(to: &$cellModels)

            $pickedImageItem
                .sink { [weak self] item in
                    guard let self else { return }
                    self.received(photosPickerItem: item)
                }
                .store(in: &cancellable)

            qrImageDetectionStatus
                .receive(on: DispatchQueue.main)
                .sink { [weak self] status in
                    if let self, case let .success(accounts) = status {
                        accounts.forEach { self.save(account: $0, in: store) }
                    }
                }
                .store(in: &cancellable)
        }

        // MARK: - Cell Models Data Flow

        private func composeCellStates(accounts: [Account],
                                       passcodes: [UUID : String],
                                       progresses: [UUID : Double],
                                       secondsRemainings: [UUID : Int],
                                       in store: Store = .shared) -> [AccountCellView.Model] {
            accounts.compactMap { account in
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

        private func received(photosPickerItem item: PhotosPickerItem?) {
            if case let .progress(progress) = qrImageDetectionStatus.value { progress.cancel() }
            guard let item else { qrImageDetectionStatus.accept(.idle); return }
            let progress = item.loadTransferable(type: Data.self) { [weak self] result in
                guard let self else { return }
                let postprocessResult: Result<[Account], Error> = result.flatMap { data in
                    guard let data else { return .failure(ConversionError.noData) }
                    guard let cgImage = UIImage(data: data)?.cgImage else { return .failure(ConversionError.coruptedData) }
                    do {
                        return .success(try self.detect(qrcode: cgImage))
                    } catch {
                        return .failure(error)
                    }
                }
                qrImageDetectionStatus.accept(postprocessResult.status())
            }
            qrImageDetectionStatus.accept(.progress(progress))
        }

        enum ConversionError: Error {
            case noData
            case coruptedData
        }

        private func detect(qrcode cgImage: CGImage) throws -> [Account] {
            let qrcodeRequest = VNDetectBarcodesRequest()
            qrcodeRequest.symbologies = [.qr]
            let handler = VNImageRequestHandler(cgImage: cgImage)
            try handler.perform([qrcodeRequest])
            return (qrcodeRequest.results ?? [])
                .sorted { $0.confidence > $1.confidence }
                .compactMap { $0.payloadStringValue?.trimmingCharacters(in: .whitespacesAndNewlines) }
                .compactMap { URL(string: $0) }
                .compactMap { Account(url: $0) }
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
