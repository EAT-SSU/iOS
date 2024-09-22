//
//  MyPageRightItemData.swift
//  EATSSU_MVC
//
//  Created by Jiwoong CHOI on 9/19/24.
//

import Foundation

/// "마이페이지"에서 사용하는 셀의 오른쪽 데이터
struct MyPageRightItemData {

  /// 앱의 배포 버전
  static var version: String? {
    if let info = Bundle.main.infoDictionary, let version = info["CFBundleShortVersionString"] as? String {
      return version
    } else {
      return nil
    }
  }
}
