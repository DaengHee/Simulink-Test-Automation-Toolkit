`Simulink.io.MatFile`로 내보내신 거 맞습니다, 그걸로 하시면 됩니다 (이전에 알려드린 2단계 방법은 이제 안 하셔도 돼요).

## 지금 계속 에러 나는 이유

어떤 방법으로 만들든, Signal Editor에서 내보낸 `.mat` 파일은 **SLDV 전용 형식이 아닙니다.** 그래서 엑셀에서 "이 파일은 SLDV 형식이 아니라 일반 Dataset 형식이야"라고 알려주는 설정을 **반드시** 같이 해주셔야 합니다. 이걸 안 하셔서 계속 같은 에러가 나는 거예요.

## 확인/수정해주세요

`TestManagement.xlsx` → `Targets` 시트 → 37번 행에 `DataFileFormat`이라는 열이 있는지 확인해주세요.

- **열이 없으면**: 새 열을 추가하고 37번 행에 `MAT`이라고 입력
- **열은 있는데 비어있으면**: 37번 행 칸에 `MAT`이라고 입력
- **이미 `MAT`이라고 써있으면**: 캡처해서 보여주세요 (다른 원인일 수 있음)

수정하신 뒤 다시 STEP1부터 돌려주세요.

```matlab
st_run_standalone_coverage_pipeline('RunMode','STEP1','PreparationMode','FORCE')
```
