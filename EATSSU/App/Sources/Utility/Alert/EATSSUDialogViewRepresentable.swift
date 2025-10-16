//
//  EATSSUDialogViewRepresentable.swift
//  EATSSU
//
//  Created by 황상환 on 10/16/25.
//

import SwiftUI

// UIViewRepresentable wrapper
struct EATSSUDialogViewRepresentable: UIViewRepresentable {
    let title: String
    let message: String
    let isSingleButton: Bool
    let cancelTitle: String?
    let confirmTitle: String
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemGray6
        
        let dialogView = EATSSUDialogView()
        dialogView.configure(
            title: title,
            message: message,
            isSingleButton: isSingleButton
        )
        
        if let cancelTitle = cancelTitle {
            dialogView.setButtonTitles(cancel: cancelTitle, confirm: confirmTitle)
        } else {
            dialogView.setButtonTitles(confirm: confirmTitle)
        }
        
        containerView.addSubview(dialogView)
        dialogView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dialogView.topAnchor.constraint(equalTo: containerView.topAnchor),
            dialogView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dialogView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            dialogView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 업데이트 로직이 필요한 경우 여기에 구현
    }
}

// Preview
#Preview("Two Buttons Dialog") {
    EATSSUDialogViewRepresentable(
        title: "로그아웃 하시겠습니까?",
        message: "로그아웃하면 다시 로그인해야 합니다.",
        isSingleButton: false,
        cancelTitle: "취소",
        confirmTitle: "로그아웃"
    )
    .frame(height: 400)
    .previewLayout(.sizeThatFits)
}

#Preview("Single Button Dialog") {
    EATSSUDialogViewRepresentable(
        title: "알림",
        message: "성공적으로 처리되었습니다.",
        isSingleButton: true,
        cancelTitle: nil,
        confirmTitle: "확인"
    )
    .frame(height: 400)
    .previewLayout(.sizeThatFits)
}

#Preview("Long Message Dialog") {
    EATSSUDialogViewRepresentable(
        title: "이용약관 동의",
        message: "서비스를 이용하기 위해서는 이용약관 및 개인정보처리방침에 동의해야 합니다. 자세한 내용은 설정에서 확인할 수 있습니다.",
        isSingleButton: false,
        cancelTitle: "거부",
        confirmTitle: "동의"
    )
    .frame(height: 400)
    .previewLayout(.sizeThatFits)
}
