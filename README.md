# 字母溝通板（LetterBoard）

給 iPad 使用的溝通輔助 App：超大按鍵、低干擾，支援注音與 QWERTY 兩種鍵盤，按「朗讀」就用語音唸出來。完全離線、無廣告、無追蹤。

需求規格見 [`docs/spec.md`](docs/spec.md)；本版為 **MVP 骨架**。

## 注音怎麼變成語音

1. **選字引擎（主要）**：注音音節交給 [Megrez](https://github.com/vChewing/Megrez)（vChewing 唯音輸入法的組句引擎），搭配新酷音詞庫自動組出最可能的漢字，例如「ㄨㄛˇ ㄧㄠˋ ㄏㄜ ㄕㄨㄟˇ」→「我要喝水」。畫面上的底線字是「還可以換」的部分，選字列可以換字，**不選也能直接朗讀**。
2. **代表字表（做法 A，備援）**：還沒按聲調的注音、詞庫載入前打的注音、或詞庫沒有的音節，朗讀時用「注音音節 → 讀音唯一的代表字」對照表換成漢字再唸（`ㄕㄨㄟˇ` → `水`）。

輸入規則：

- 依序按聲母、介音、韻母，再按聲調鍵（ˊ ˇ ˋ ˙）完成一個音節；一聲按「一聲／空白」。
- 忘了按聲調，直接打下一個字的聲母時，前一個音節自動當作一聲。
- 沒有正在拼的注音時，按「一聲／空白」會把底線字確定下來；再按一次才是空白。
- 「刪除」依序刪掉：正在拼的注音符號 → 最後一個音節 → 已確定的最後一個字。
- 同一顆鍵 0.3 秒內重複觸發會被忽略（減少誤觸，可在 `Constants.swift` 調整）。
- 英文字母按鍵顯示大寫、輸入小寫（全大寫會被語音當縮寫逐字母唸）。
- 中文用 `zh-TW` 語音、英文字母與數字自動改用 `en-US` 語音。

## 在 Mac 上建置

需要：macOS、**Xcode 26 以上**（Megrez 5.x 需要 Swift 6.2 工具鏈）、[XcodeGen](https://github.com/yonaskolb/XcodeGen)。

```sh
brew install xcodegen
xcodegen generate          # 由 project.yml 產生 LetterBoard.xcodeproj
open LetterBoard.xcodeproj
```

1. 在 target「LetterBoard」的 *Signing & Capabilities* 選自己的 Team；Bundle ID 預設是 `com.example.letterboard`，請改成自己的。
2. 選 iPad 模擬器或實機執行；`⌘U` 執行單元測試。
3. 裝到實機：用免費 Apple ID 需每 7 天重新安裝；付費開發者帳號可用 TestFlight。

**第一次在實機上要確認的事**

- iPad「設定 → 輔助使用 → 朗讀內容 → 聲音 → 中文（台灣）」已下載語音，品質選「增強版」會自然很多。
- 打開側邊靜音時，按「朗讀」仍有聲音。
- 試唸幾句常用的話，確認選字與發音。
- 建議搭配系統「引導使用模式」（設定 → 輔助使用 → 引導使用模式）把 iPad 鎖在這個 App。

## 專案結構

```
project.yml                     XcodeGen 設定
LetterBoard/
├── App/LetterBoardApp.swift
├── Views/
│   ├── ContentView.swift        由上到下：顯示區 → 控制列 → 選字列 → 鍵盤
│   ├── TextDisplayView.swift    頂部單行顯示區 + 刪除／清除
│   ├── ControlBarView.swift     朗讀、注音／QWERTY 切換
│   ├── CandidateBarView.swift   選字列（注音布局才有）
│   ├── KeyboardView.swift       依畫面大小計算按鍵尺寸
│   ├── ZhuyinKeyboardView.swift 注音按鍵排列（ㄅㄆㄇ 順序）
│   ├── QWERTYKeyboardView.swift
│   └── KeyButton.swift
├── ViewModels/BoardViewModel.swift  輸入流程與狀態
├── Models/                      LayoutType、KeyItem、Zhuyin（音節拆解）
├── Services/
│   ├── SpeechService.swift      AVSpeechSynthesizer
│   ├── SpeechPlanner.swift      把文字切成中文／英文片段、注音換代表字
│   ├── ZhuyinReadingTable.swift 代表字表
│   ├── ZhuyinComposer.swift     Megrez 組字器包裝
│   └── LexiconLanguageModel.swift
├── Utilities/Constants.swift    所有尺寸、顏色、時間參數
└── Resources/
    ├── zhuyin_readings.tsv      注音音節 → 代表字（1,397 個音節）
    └── lexicon.tsv              選字詞庫（約 16 萬筆）
LetterBoardTests/                單元測試
tools/gen_zhuyin_data.py         從新酷音詞庫重新產生 Resources 的兩個資料檔
```

## 重新產生資料檔

```sh
git clone --depth 1 https://github.com/chewing/libchewing-data /tmp/libchewing-data
python3 tools/gen_zhuyin_data.py /tmp/libchewing-data/dict/chewing
```

## 已知限制

- 選字只用單元（unigram）詞頻，沒有上下文模型，也不會學習使用者習慣；少數同分的字（例如 ㄧㄠˋ 的「要／藥」）單獨打時可能選錯，需要從選字列換。
- 代表字是一個字一個字唸，字與字之間的連讀變調不一定自然；經過選字引擎組成詞的部分比較自然。
- 注音按鍵依課本順序排列；若他習慣電腦的大千排列，改 `ZhuyinKeyboardView.rows` 即可。

## 後續規劃

- 第二階段（規格 4.2）：常用短句快速鍵、按鍵大小與語音速度調整、家長設定頁（可鎖定）、高對比主題。
- **字卡**：打出字詞後自動跳出對應的圖卡，加強視覺回饋。圖卡來源待評估：
  - 香港開源字卡（待確認名稱、內容與授權）
  - 其他開放授權的 AAC 圖示集，例如 ARASAAC（CC BY-NC-SA）、Mulberry Symbols（CC BY-SA）；使用前需確認授權條款
- 選字學習使用者常用詞。

## 授權與第三方元件

- [Megrez](https://github.com/vChewing/Megrez) 5.0.9：LGPL-3.0-or-later，附加 Swift Package 簽署例外條款，見 `licenses/Megrez-CUSTOM_LGPLv3_EXCEPTION.md`。
  > This project includes a Swift package licensed under LGPLv3 with an additional permission granted to allow linking and combining with other modules without requiring a paid Apple Developer ID for code signing. For details, see the CUSTOM_LGPLv3_EXCEPTION.md file included with this project.
- `Resources/*.tsv` 由[新酷音詞庫 libchewing-data](https://github.com/chewing/libchewing-data) 產生，LGPL-2.1-or-later，見 `licenses/libchewing-data-LGPL-2.1.txt`。

若要上架 App Store，請先確認 LGPL 對靜態連結與資料檔散布的要求。
