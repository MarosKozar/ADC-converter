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

## 🔍 File-by-File Breakdown

## 1.`top_level.vhd`
 🧩 **Role: System Integrator**
 
 This file defines the **top-level VHDL entity** for the entire system. It glues together the major components:
 - `processing_unit`: captures and filters the analog signal
 - `display_unit`: outputs the filtered result both digitally and visually
 
 
 🧮 **Interfaces Entity: `top_level`**
  ```vhdl 
entity top_level is
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    vp_in     : in  std_logic;
    vn_in     : in  std_logic;
    seg_an    : out std_logic_vector(3 downto 0);
    seg_cat   : out std_logic_vector(6 downto 0);
    leds      : out std_logic_vector(15 downto 0)
  );
end entity;
```
 **Inputs**:
 - `clk`: Main system clock  
 - `reset`: Global synchronous reset  
 - `vp_in`, `vn_in`: Differential analog voltage inputs for XADC  
 
 **Outputs**:
 - `leds`: 16-bit binary display of the filtered signal  
 - `seg_cat`, `seg_an`: 7-segment cathode/anode display drivers  
 
  🧱 **Component Declaration: `processing_unit` and `display_unit`**
 ```vhdl
 component processing_unit
  port (
    clk          : in  std_logic;
    reset        : in  std_logic;
    vp_in        : in  std_logic;
    vn_in        : in  std_logic;
    filtered_out : out std_logic_vector(15 downto 0)
  );
end component;
```
- Filters incoming analog signals and outputs 16-bit digital data.

 ```vhdl
component display_unit
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    data_in   : in  std_logic_vector(15 downto 0);
    seg_cat   : out std_logic_vector(6 downto 0);
    seg_an    : out std_logic_vector(3 downto 0);
    leds      : out std_logic_vector(15 downto 0)
  );
end component;

```
- Converts 16-bit input data to visual output (7-segment + LEDs).

 🧠 **Internal Signal: `processing_unit` and `display_unit`**
 The top-level logic instantiates both components and connects them through internal signals:

 ```vhdl
 signal filtered : std_logic_vector(15 downto 0);
  ```
- A bridge signal connecting `processing_unit` output to `display_unit` input.
    
 🕹️ **Component Instantiations: `processing_unit` and `display_unit`**
 ```vhdl
core : processing_unit
  port map (
    clk          => clk,
    reset        => reset,
    vp_in        => vp_in,
    vn_in        => vn_in,
    filtered_out => filtered_signal
  );
```
- Routes clock/reset and analog inputs to the processor.
- Outputs filtered data to `filtered_signal`.

 ```vhdl
disp : display_unit
  port map (
    clk     => clk,
    reset   => reset,
    data_in => filtered_signal,
    seg_cat => seg_cat,
    seg_an  => seg_an,
    leds    => leds
  );
```
- Feeds filtered signal into display logic.
- Drives visual hardware outputs.

---

## 2.`processing_unit`




 
