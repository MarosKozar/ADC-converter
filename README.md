# ADC-converter
# 🎛️ ADC Signal Filtering on Nexys A7

This FPGA project demonstrates how to digitize and filter an analog signal using Xilinx's XADC, and display the result in real-time on 7-segment displays and LEDs. Implemented in VHDL for the Digilent Nexys A7 board.

---

## 📦 Features

- 🔌 Analog input via XADC (`vp_in`, `vn_in`)
- 📉 Digital IIR low-pass filtering
- 📟 Real-time display on 7-segment
- 💡 LED binary display of filtered data
- 🧪 VHDL testbench simulation

---

## 🧠 Architecture Overview
 Stage | Component | Description | Output |
|-------|-----------|-------------|--------|
| 1 | **DC Source** | External analog voltage source or function generator connected to analog pins | Analog voltage signal |
| 2 | **Nexys A7 Board** | FPGA board that hosts the digital signal processing system | Internal signal flow |
| 3 | **XADC** (`processing_unit.vhd`) | Xilinx Analog to Digital Converter: Converts analog voltage into 12-bit digital value | Digital 12-bit raw ADC sample |
| 4 | **IIR Filter** (`processing_unit.vhd`) | Applies low-pass filter using exponential smoothing to reduce noise | Smoothed digital signal |
| 5 | **Threshold Logic** (`processing_unit.vhd`) | Ignores minor changes under 10mV to suppress flicker and noise | Stable filtered signal |
| 6 | **Voltage Scaling** (`display_unit.vhd`) | Converts filtered 12-bit value to millivolts | Integer voltage in mV |
| 7 | **BCD Converter + 7-Segment Driver** (`display_unit.vhd`) | Converts mV into 4-digit BCD and multiplexes to 7-segment display | Real-time visual output on display |
| 8 | **LED Display** (`display_unit.vhd`) | Mirrors the 16-bit filtered signal on the onboard LEDs | Binary indicator of signal level |
---

## 📂 File Structure

| File | Role |
|------|------|
| `top_level.vhd` | Connects all components |
| `processing_unit.vhd` | Handles XADC + filtering |
| `display_unit.vhd` | Converts value to voltage, updates 7-seg/LEDs |
| `fir_pkg.vhd` | Type definitions for filter dev(No longer used in project, not connected to any file) |
| `nexys_a7.xdc` | FPGA pin constraints |
| `sim_top.vhd` | Testbench for simulation |

---

## 🔧 XADC Configuration

Xilinx’s internal XADC reads analog voltage from dedicated pins.

```vhdl
DO      → 12-bit ADC data (MSBs)
DRDY    → Indicates ready state
