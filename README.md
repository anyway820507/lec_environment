# Cadence Conformal LEC 範例環境

本專案提供兩個可修改的 Cadence Conformal Equivalence Checker 範例：

| 比較情境 | 使用說明 | Tcl 腳本 |
| --- | --- | --- |
| Golden RTL vs. Revised RTL | [RTL_to_RTL_LEC_guide.md](./RTL_to_RTL_LEC_guide.md) | [rtl_to_rtl_lec.tcl](./rtl_to_rtl_lec.tcl) |
| Golden RTL vs. synthesis netlist | [RTL_to_Netlist_LEC_guide.md](./RTL_to_Netlist_LEC_guide.md) | [rtl_to_netlist_lec.tcl](./rtl_to_netlist_lec.tcl) |

> 這些腳本是範本，不含實際 RTL、netlist 或 standard-cell library，因此必須先修改各腳本頂端的「User configuration」才能執行。

## 工具與命令介面

腳本使用 **Cadence Conformal 的 Tcl mode**，不是 Synopsys Formality。兩套工具的流程概念相近，但命令不能混用。以下範例預期可從 shell 找到 Conformal 執行檔 `lec`；實際執行檔名稱與 license option 可能因安裝版本而異。

```bash
lec -nogui -tclmode -dofile rtl_to_rtl_lec.tcl
lec -nogui -tclmode -dofile rtl_to_netlist_lec.tcl
```

若該版本不接受命令列的 `-tclmode`，可移除它；腳本第一行的 `tclmode` 仍會切換命令模式。請以站點安裝版本的 `lec -help` 與 Conformal Command Reference 為準。

## 使用前檢查

1. 修改 `TOP_MODULE`、輸入檔案清單及 log 路徑。
2. RTL-to-netlist flow 必須填入 synthesis 實際使用的 Liberty 或 Verilog cell model；不要任意 black-box 未驗證的 cell。
3. 加入與 synthesis 相同的 define、include directory、parameter、low-power/DFT 設定及 functional-mode constraints。
4. 確認 golden 與 revised 的 clock、reset、scan/test mode 假設一致。
5. 不要只看程序 exit status；必須同時檢查 `report_verification`、unmapped points、black boxes、aborted points 與 ignored points。

## 範例目錄

```text
project/
├── rtl/
│   ├── golden/
│   └── revised/
├── netlist/
├── libs/
├── logs/
├── rtl_to_rtl_lec.tcl
└── rtl_to_netlist_lec.tcl
```

建議從專案根目錄執行。腳本中的相對路徑會以啟動 `lec` 時的 working directory 為基準。

## 結果判讀

- **Equivalent / PASS**：所有應比較點已證明等價，且沒有未處理的 abort、black box 或 coverage 缺口。
- **Non-equivalent / FAIL**：至少一個 compare point 有反例，需要追查 RTL、constraint 或 synthesis 設定差異。
- **Aborted / inconclusive**：工具未能完成證明；這不是 PASS，通常需要調整 partition、effort、datapath 或 mapping。
- **Unmapped / ignored / black-box**：代表驗證範圍可能不完整；即使摘要顯示 PASS，也要確認這些項目符合預期。

## 限制

這是最小的 flat-compare 教學範例。大型 RTL-to-netlist 設計通常應採用 Conformal 產生的 hierarchical compare flow，並沿用 synthesis 工具輸出的 LEC dofile、mapping guidance 與實作資訊。不同 Conformal release 的 option 名稱可能略有差異，上線前應在實際版本執行並對照該版本文件。
