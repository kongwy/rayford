//
//  AccountCellView.swift
//  Rayford
//
//  Created by Weiyi Kong on 20/8/2025.
//

import SwiftUI

struct AccountCellView: View {
    var model: Model
    
    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .padding(12)
                .frame(width: 64, height: 64)
                .foregroundStyle(.white)
                .background(.gray)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            
            VStack(alignment: .leading) {
                Text(formattedValue(model.passcode))
                    .font(.system(size: 44, weight: .thin))
                    .lineLimit(1)
                    .monospacedDigit()
                
                Text(model.description)
                    .font(.system(size: 15, weight: .medium))
                    .lineLimit(1)
            }
            
            Spacer()
            
            switch model.accessoryType {
            case let .progressCircle(value, text):
                CircularProgressView(progress: value, text: text)
                    .frame(width: 30, height: 30)
            case let .nextButton(closure):
                Button(action: closure) {
                    Image(systemName: "arrowtriangle.forward.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .offset(x: 1)
                        .frame(width: 28, height: 28)
                        .foregroundStyle(.white)
                        .background(.blue)
                        .clipShape(Circle())
                }
            }
        }
    }
    
    private func formattedValue(_ value: String) -> String {
        let length = value.count
        let prefix = String(value.prefix(length / 2))
        let suffix = String(value.suffix(length - length / 2))
        return "\(prefix) \(suffix)"
    }
}

extension AccountCellView {
    struct Model: Identifiable {
        var id: UUID
        var passcode: String
        var description: String
        var accessoryType: AccessoryType
    }

    enum AccessoryType {
        case progressCircle(value: Double, text: String)
        case nextButton(_: () -> Void)
    }
}

#Preview {
    AccountCellView(model: .init(id: UUID(),
                                 passcode: "111111",
                                 description: "Demo Issuer: Demo Account",
                                 accessoryType: .progressCircle(value: 0, text: "0")))
}
