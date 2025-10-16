//
//  EATSSUToastViewRepresentable.swift
//  EATSSU
//
//  Created by 황상환 on 10/16/25.
//

import SwiftUI

// UIViewRepresentable wrapper for Preview
struct EATSSUToastViewRepresentable: UIViewRepresentable {
    let type: ToastType
    let message: String
    let showAction: Bool
    let actionTitle: String?
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        
        let toastView = EATSSUToastView()
        toastView.configure(
            type: type,
            message: message,
            showAction: showAction
        )
        
        if let actionTitle = actionTitle {
            toastView.setActionButtonTitle(actionTitle)
        }
        
        containerView.addSubview(toastView)
        toastView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            toastView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            toastView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            toastView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -20)
        ])
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// Preview
#Preview("Danger Toast") {
    EATSSUToastViewRepresentable(
        type: .danger,
        message: "메시지",
        showAction: false,
        actionTitle: nil
    )
    .frame(height: 100)
    .previewLayout(.sizeThatFits)
}

#Preview("Danger Toast with Action") {
    EATSSUToastViewRepresentable(
        type: .danger,
        message: "메시지",
        showAction: true,
        actionTitle: "보러가기"
    )
    .frame(height: 100)
    .previewLayout(.sizeThatFits)
}

#Preview("Info Toast") {
    EATSSUToastViewRepresentable(
        type: .info,
        message: "메시지",
        showAction: false,
        actionTitle: nil
    )
    .frame(height: 100)
    .previewLayout(.sizeThatFits)
}

#Preview("Info Toast with Action") {
    EATSSUToastViewRepresentable(
        type: .info,
        message: "메시지",
        showAction: true,
        actionTitle: "보러가기"
    )
    .frame(height: 100)
    .previewLayout(.sizeThatFits)
}

#Preview("Success Toast") {
    EATSSUToastViewRepresentable(
        type: .success,
        message: "메시지",
        showAction: false,
        actionTitle: nil
    )
    .frame(height: 100)
    .previewLayout(.sizeThatFits)
}

#Preview("Success Toast with Action") {
    EATSSUToastViewRepresentable(
        type: .success,
        message: "메시지",
        showAction: true,
        actionTitle: "보러가기"
    )
    .frame(height: 100)
    .previewLayout(.sizeThatFits)
}

#Preview("Warning Toast") {
    EATSSUToastViewRepresentable(
        type: .warning,
        message: "메시지",
        showAction: false,
        actionTitle: nil
    )
    .frame(height: 100)
    .previewLayout(.sizeThatFits)
}

#Preview("Warning Toast with Action") {
    EATSSUToastViewRepresentable(
        type: .warning,
        message: "메시지",
        showAction: true,
        actionTitle: "보러가기"
    )
    .frame(height: 100)
    .previewLayout(.sizeThatFits)
}

#Preview("Long Message Toast") {
    EATSSUToastViewRepresentable(
        type: .info,
        message: "네트워크 연결이 불안정합니다. 잠시 후 다시 시도해주세요.",
        showAction: true,
        actionTitle: "다시 시도"
    )
    .frame(height: 120)
    .previewLayout(.sizeThatFits)
}

#Preview("All Toast Types") {
    VStack(spacing: 16) {
        EATSSUToastViewRepresentable(
            type: .danger,
            message: "오류가 발생했습니다",
            showAction: false,
            actionTitle: nil
        )
        .frame(height: 80)
        
        EATSSUToastViewRepresentable(
            type: .info,
            message: "새로운 알림이 있습니다",
            showAction: true,
            actionTitle: "보러가기"
        )
        .frame(height: 80)
        
        EATSSUToastViewRepresentable(
            type: .success,
            message: "성공적으로 처리되었습니다",
            showAction: false,
            actionTitle: nil
        )
        .frame(height: 80)
        
        EATSSUToastViewRepresentable(
            type: .warning,
            message: "주의가 필요합니다",
            showAction: true,
            actionTitle: "확인하기"
        )
        .frame(height: 80)
    }
    .previewLayout(.sizeThatFits)
}
