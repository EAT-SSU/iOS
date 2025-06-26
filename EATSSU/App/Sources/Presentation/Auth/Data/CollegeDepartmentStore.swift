//
//  CollegeDepartmentStore.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 6/26/25.
//

import Foundation

// Sources/Data/CollegeDepartmentStore.swift

struct CollegeDepartment {
    let college: String
    let departments: [String]
}

enum CollegeDepartmentStore {
    static let list: [CollegeDepartment] = [
        .init(college: "IT대학", departments: ["컴퓨터학부", "전자정보공학부\n전자공학전공", "전자정보공학부\nIT융합전공", "글로벌미디어학부", "소프트웨어학부", "AI융합학부", "미디어경영학과", "정보보호학과"]),
        .init(college: "경영대학", departments: ["경영학부", "벤처중소기업학과", "회계학과", "금융학부", "벤처경영학과", "혁신경영학과", "복지경영학과", "회계세무학과"]),
        .init(college: "경제통상대학", departments: ["경제학과", "글로벌통상학과", "금융경제학과", "국제무역학과"]),
        .init(college: "공과대학", departments: ["화학공학과", "신소재공학과", "전기공학부", "기계공학부", "산업ㆍ정보시스템공학과", "건축학부"]),
        .init(college: "법과대학", departments: ["법학과", "국제법무학과"]),
        .init(college: "사회과학대학", departments: ["사회복지학부", "행정학부", "행정학부", "정보사회학과", "언론홍보학과", "평생교육학과"]),
        .init(college: "인문대학", departments: ["기독교학과", "국어국문학과", "영어영문학과", "독어독문학과", "불어불문학과", "중어중문학과", "일어일문학과", "철학과", "철학과", "문예창작전공", "영화예술전공", "스포츠학부"]),
        .init(college: "자연과학대학", departments: ["수학과", "물리학과", "화학과", "정보통계∙보험수리학과", "의생명시스템학부"]),
        .init(college: "자유전공학부", departments: ["자유전공학부"]),
        .init(college: "차세대반도체학과", departments: ["차세대반도체학과"]),
    ]

    static var colleges: [String] { list.map(\.college) }

    static func departments(of college: String) -> [String] {
        list.first { $0.college == college }?.departments ?? []
    }
}
