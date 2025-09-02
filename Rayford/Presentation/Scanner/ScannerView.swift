//
//  ScannerView.swift
//  Rayford
//
//  Created by Weiyi Kong on 2/9/2025.
//

import SwiftUI

struct ScannerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UINavigationController

    @EnvironmentObject var store: Store
    private var viewModel = ViewModel()

    func makeUIViewController(context: Context) -> UINavigationController {
        let scanningVC = UIStoryboard(name: "ScanningViewController",
                                      bundle: nil)
            .instantiateInitialViewController() as! ScanningViewController
        scanningVC.delegate = viewModel

        let navigationVC = UINavigationController(rootViewController: scanningVC)
        navigationVC.navigationBar.backgroundColor = .systemBackground
        return navigationVC
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) { }
}

extension ScannerView {
    class ViewModel: SaveAccountDelegate {
        var store: Store

        init(store: Store = .shared) {
            self.store = store
        }

        func save(_ account: Account) {
            store.appState.accounts.append(account)
        }
    }
}

#Preview {
    ScannerView()
}
