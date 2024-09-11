import ProjectDescription

let workspace = Workspace(name: "EATSSU_WORKSPACE", projects: [
  "EATSSU_MVC",
//  MVVM 프로젝트를 설계하기 시작하면 재활성화 하면 됩니다.
//  현재 번들ID가 같아서 시뮬레이터에서 혼선이 발생하는 경우가 너무 많아서 시행하는 조치입니다.
//  "EATSSU_MVVM",
  "EATSSUComponents"
])
