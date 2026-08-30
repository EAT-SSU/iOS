//
//  AcademicNameLocalizer.swift
//  EATSSU
//
//  Created by 황상환 on 8/30/26.
//

import Foundation

/// 서버가 내려주는 한국어 단과대/학과명을 현재 앱 언어에 맞는 표기로 변환
///
/// 서버 응답과 Realm 저장값은 한국어 원본을 유지하고, 화면에 표시하는 시점에만 변환한다.
/// 번역 테이블에 없는 이름은 한국어 원본을 그대로 반환한다.
/// 번역 데이터 출처: 다국어 스프레드시트 college_collection / department_collection
enum AcademicNameLocalizer {

    // MARK: - Public

    /// 단과대명 → 현재 앱 언어 표기
    static func college(_ koreanName: String) -> String {
        localized(koreanName, in: colleges)
    }

    /// 학과명 → 현재 앱 언어 표기
    static func department(_ koreanName: String) -> String {
        localized(koreanName, in: departments)
    }

    // MARK: - Private

    private struct Translation {
        let en: String
        let ja: String
        let vi: String
    }

    private static func localized(_ koreanName: String, in table: [String: Translation]) -> String {
        let key = koreanName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let translation = table[key] else { return koreanName }

        switch AppLanguageManager.shared.currentLanguage {
        case .korean: return koreanName
        case .english: return translation.en
        case .japanese: return translation.ja
        case .vietnamese: return translation.vi
        }
    }

    // MARK: - Tables

    private static let colleges: [String: Translation] = [
        "총학생회": Translation(en: "Student Council", ja: "学生自治会", vi: "Hội Sinh viên"),
        "AI대학": Translation(en: "College of AI", ja: "AI学部", vi: "Khoa AI"),
        "IT대학": Translation(en: "College of IT", ja: "IT学部", vi: "Khoa IT"),
        "경영대학": Translation(en: "College of Business Administration", ja: "経営学部", vi: "Khoa Quản trị Kinh doanh"),
        "경제통상대학": Translation(en: "College of Economics and International Commerce", ja: "経済・国際商学部", vi: "Khoa Kinh tế và Thương mại Quốc tế"),
        "공과대학": Translation(en: "College of Engineering", ja: "工学部", vi: "Khoa Kỹ thuật"),
        "법과대학": Translation(en: "College of Law", ja: "法学部", vi: "Khoa Luật"),
        "사회과학대학": Translation(en: "College of Social Sciences", ja: "社会科学部", vi: "Khoa Khoa học Xã hội"),
        "인문대학": Translation(en: "College of Humanities", ja: "人文学部", vi: "Khoa Nhân văn"),
        "자연과학대학": Translation(en: "College of Natural Sciences", ja: "自然科学部", vi: "Khoa Khoa học Tự nhiên"),
        "자유전공학부": Translation(en: "School of Liberal Studies", ja: "リベラル・スタディーズ学部", vi: "Khoa Nghiên cứu Tự do"),
        "차세대반도체학과": Translation(en: "Department of Next-Generation Semiconductor", ja: "次世代半導体学科", vi: "Khoa Bán dẫn Thế hệ Mới"),
    ]

    private static let departments: [String: Translation] = [
        "컴퓨터학부": Translation(en: "Computer Science & Engineering", ja: "コンピュータ科学工学", vi: "Khoa học và Kỹ thuật Máy tính"),
        "전자정보공학부(전자공학전공)": Translation(en: "Electronic Engineering(Electronic Engineering major)", ja: "電子工学（電子工学専攻）", vi: "Kỹ thuật Điện tử (chuyên ngành Kỹ thuật Điện tử)"),
        "전자정보공학부(IT융합전공)": Translation(en: "Electronic Engineering(IT convergence major)", ja: "電子工学（IT融合専攻）", vi: "Kỹ thuật Điện tử (chuyên ngành Hội tụ IT)"),
        "글로벌미디어학부": Translation(en: "Global School of Media", ja: "グローバルメディア学部", vi: "Khoa Truyền thông Toàn cầu"),
        "소프트웨어학부": Translation(en: "Software", ja: "ソフトウェア", vi: "Phần mềm"),
        "AI융합학부": Translation(en: "AI Convergence", ja: "AI融合", vi: "Hội tụ AI"),
        "AI소프트웨어학부": Translation(en: "AI Software", ja: "AIソフトウェア", vi: "Phần mềm AI"),
        "디지털미디어학과": Translation(en: "Digital Media", ja: "デジタルメディア", vi: "Truyền thông Kỹ thuật số"),
        "경영학부": Translation(en: "Business Administration", ja: "経営学", vi: "Quản trị Kinh doanh"),
        "벤처중소기업학과": Translation(en: "Entrepreneurship & Small Business", ja: "ベンチャー・中小企業", vi: "Khởi nghiệp và Doanh nghiệp Nhỏ"),
        "회계학과": Translation(en: "Accounting", ja: "会計学", vi: "Kế toán"),
        "금융학부": Translation(en: "Finance", ja: "金融学", vi: "Tài chính"),
        "벤처경영학과": Translation(en: "Venture Management", ja: "ベンチャー経営", vi: "Quản trị Khởi nghiệp"),
        "혁신경영학과": Translation(en: "Innovation Management", ja: "イノベーション経営", vi: "Quản trị Đổi mới"),
        "복지경영학과": Translation(en: "Welfare & Management", ja: "福祉経営", vi: "Quản trị Phúc lợi"),
        "회계세무학과": Translation(en: "Accounting & Tax", ja: "会計・税務", vi: "Kế toán và Thuế"),
        "경제학과": Translation(en: "Economics", ja: "経済学", vi: "Kinh tế học"),
        "글로벌통상학과": Translation(en: "Global Commerce", ja: "グローバル商学", vi: "Thương mại Toàn cầu"),
        "금융경제학과": Translation(en: "Ecofinance", ja: "エコファイナンス", vi: "Tài chính Kinh tế"),
        "국제무역학과": Translation(en: "International Trade & Transaction", ja: "国際貿易・取引", vi: "Thương mại và Giao dịch Quốc tế"),
        "화학공학과": Translation(en: "Chemical Engineering", ja: "化学工学", vi: "Kỹ thuật Hóa học"),
        "신소재공학과": Translation(en: "Materials Science & Engineering", ja: "材料科学工学", vi: "Khoa học và Kỹ thuật Vật liệu"),
        "전기공학부": Translation(en: "Electrical Engineering", ja: "電気工学", vi: "Kỹ thuật Điện"),
        "기계공학부": Translation(en: "Mechanical Engineering", ja: "機械工学", vi: "Kỹ thuật Cơ khí"),
        "산업정보시스템공학과": Translation(en: "Industrial & Information Systems Engineering", ja: "産業・情報システム工学", vi: "Kỹ thuật Hệ thống Công nghiệp và Thông tin"),
        "건축학부": Translation(en: "Architecture", ja: "建築学", vi: "Kiến trúc"),
        "법학과": Translation(en: "Law", ja: "法学", vi: "Luật"),
        "국제법무학과": Translation(en: "Global Law", ja: "グローバル法学", vi: "Luật Toàn cầu"),
        "사회복지학부": Translation(en: "Social Welfare", ja: "社会福祉学", vi: "Phúc lợi Xã hội"),
        "행정학부": Translation(en: "Public Administration", ja: "行政学", vi: "Hành chính Công"),
        "정치외교학과": Translation(en: "Political Science & International Relations", ja: "政治学・国際関係", vi: "Khoa học Chính trị và Quan hệ Quốc tế"),
        "정보사회학과": Translation(en: "Information Sociology", ja: "情報社会学", vi: "Xã hội học Thông tin"),
        "언론홍보학과": Translation(en: "Journalism, Public Relations, and Advertising", ja: "ジャーナリズム・広報・広告", vi: "Báo chí, Quan hệ Công chúng và Quảng cáo"),
        "평생교육학과": Translation(en: "Lifelong Education", ja: "生涯教育", vi: "Giáo dục Suốt đời"),
        "기독교학과": Translation(en: "Christian Studies", ja: "キリスト教学", vi: "Cơ đốc học"),
        "국어국문학과": Translation(en: "Korean Language & Literature", ja: "韓国語文学", vi: "Ngôn ngữ và Văn học Hàn Quốc"),
        "영어영문학과": Translation(en: "English Language & Literature", ja: "英語英文学", vi: "Ngôn ngữ và Văn học Anh"),
        "독어독문학과": Translation(en: "German Language & Literature", ja: "ドイツ語文学", vi: "Ngôn ngữ và Văn học Đức"),
        "불어불문학과": Translation(en: "French Language & Literature", ja: "フランス語文学", vi: "Ngôn ngữ và Văn học Pháp"),
        "중어중문학과": Translation(en: "Chinese Language & Literature", ja: "中国語文学", vi: "Ngôn ngữ và Văn học Trung Quốc"),
        "일어일문학과": Translation(en: "Japanese Language & Literature", ja: "日本語文学", vi: "Ngôn ngữ và Văn học Nhật Bản"),
        "철학과": Translation(en: "Philosophy", ja: "哲学", vi: "Triết học"),
        "사학과": Translation(en: "History", ja: "歴史学", vi: "Lịch sử"),
        "문예창작전공": Translation(en: "Creative Writing", ja: "文芸創作", vi: "Sáng tác Văn học"),
        "영화예술전공": Translation(en: "Film Arts", ja: "映画芸術", vi: "Nghệ thuật Điện ảnh"),
        "스포츠학부": Translation(en: "Sports", ja: "スポーツ", vi: "Thể thao"),
        "수학과": Translation(en: "Mathematics", ja: "数学", vi: "Toán học"),
        "물리학과": Translation(en: "Physics", ja: "物理学", vi: "Vật lý"),
        "화학과": Translation(en: "Chemistry", ja: "化学", vi: "Hóa học"),
        "정보통계보험수리학과": Translation(en: "Actuarial Science", ja: "保険数理学", vi: "Khoa học Bảo hiểm"),
        "의생명시스템학부": Translation(en: "Biomedical Science", ja: "生命医科学", vi: "Khoa học Y sinh"),
        "자유전공학부": Translation(en: "Liberal Studies", ja: "リベラル・スタディーズ", vi: "Nghiên cứu Tự do"),
        "차세대반도체학과": Translation(en: "Next-Generation Semiconductor", ja: "次世代半導体", vi: "Bán dẫn Thế hệ Mới"),
    ]
}
