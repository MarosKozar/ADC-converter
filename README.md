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

## 2.`processing_unit`




## nexys_A7

🔍 Overview
This XDC file is used in Xilinx Vivado projects to:

Assign logical ports in your HDL design (e.g., Verilog/VHDL) to physical pins on the FPGA.

Define the I/O standard (electrical characteristics) for each port.

Set up timing constraints (especially for clocks).

Most likely, this is for a board like the Basys 3 or Nexys A7, which includes:

A clock input

16 LEDs

A 4-digit 7-segment display

XADC analog input pins

A reset button

🕒 Clock and Timing
tcl
Zkopírovat
Upravit
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports { clk }]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk }]
PACKAGE_PIN E3: Maps the clk input signal to physical FPGA pin E3.

IOSTANDARD LVCMOS33: Uses the LVCMOS 3.3V voltage level standard.

create_clock: Defines a clock constraint named sys_clk_pin with:

Period = 10 ns → Frequency = 100 MHz.

Waveform {0 5} = 50% duty cycle (clock high for 5ns, low for 5ns).

🧠 Why it's needed: Tells Vivado the timing characteristics of your clock source so it can perform proper static timing analysis.

⚡️ XADC Analog Inputs
tcl
Zkopírovat
Upravit
set_property -dict { PACKAGE_PIN A13 IOSTANDARD LVCMOS18 } [get_ports { vp_in }]
set_property -dict { PACKAGE_PIN A14 IOSTANDARD LVCMOS18 } [get_ports { vn_in }]
These two lines assign vp_in and vn_in ports to A13 and A14, which are dedicated analog input pins for the Xilinx XADC (Analog-to-Digital Converter).

LVCMOS18 = 1.8V logic standard — required for analog input compatibility.

🧠 Why it's needed: Enables use of onboard sensors or other analog input for digitization within the FPGA.

🔁 Reset Button
tcl
Zkopírovat
Upravit
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports { reset }]
Assigns the reset signal (e.g., for resetting a state machine) to pin N17.

Standard 3.3V logic.

🧠 Why it's needed: Provides a way to reset your logic design externally via a button on the board.

🔢 7-Segment Display - Anodes
tcl
Zkopírovat
Upravit
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports { seg_an[0] }]
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports { seg_an[1] }]
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports { seg_an[2] }]
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports { seg_an[3] }]
Assigns the control lines for each digit of a 4-digit 7-segment display.

seg_an[0] through seg_an[3] enable each of the 4 digits.

Active-low typically: driving low enables that digit.

🧠 Why it's needed: Allows time-multiplexed control of each 7-segment digit.

🔠 7-Segment Display - Cathodes
tcl
Zkopírovat
Upravit
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { seg_cat[0] }]
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports { seg_cat[1] }]
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports { seg_cat[2] }]
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports { seg_cat[3] }]
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports { seg_cat[4] }]
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports { seg_cat[5] }]
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports { seg_cat[6] }]
These control the individual segments a–g (no decimal point here).

When combined with an anode, lighting specific segments shows numbers or letters.

🧠 Why it's needed: To draw characters on the 7-segment display, your logic activates the correct segments and anodes.

💡 LED Outputs
tcl
Zkopírovat
Upravit
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports { leds[15] }]
...
set_property -dict { PACKAGE_PIN V11 IOSTANDARD LVCMOS33 } [get_ports { leds[0] }]
Maps 16 LEDs (from leds[0] to leds[15]) to FPGA pins.

Allows your design to output binary patterns, status indicators, counters, etc.

Each LED typically turns on when driven high, depending on board design.

🧠 Why it's needed: Useful for debugging, visualizing signals, and interactive control.

✅ Summary
Feature	Purpose	Pins Used
Clock	100 MHz system clock input	E3
Reset	Reset signal from a push-button	N17
XADC Inputs	Analog input signals for XADC	A13 (vp), A14 (vn)
7-Segment Display	Digit & segment control	J17, J18, T9, J14, etc.
LEDs (16)	Visual output	H17 to V11




 
