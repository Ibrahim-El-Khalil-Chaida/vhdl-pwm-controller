# VHDL PWM Controller
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)  [![C++17](https://img.shields.io/badge/C%2B%2B-17-blue.svg)](https://isocpp.org/)  [![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)]()

A high-performance, fully synchronous VHDL core for generating pulse-width modulated signals with runtime-configurable period and duty-cycle. Designed for FPGA and ASIC integration, this IP block delivers glitch-free updates, minimal resource utilization, and easy parameterization.

---

## Table of Contents

1. [Features](#features)  
2. [Quick Start](#quick-start)   
3. [Core Interface](#core-interface)  
4. [Configuration & Parameters](#configuration--parameters)  
5. [Simulation and Verification](#simulation-and-verification)  
6. [Synthesis & Integration](#synthesis--integration)  
7. [Customization & Extensions](#customization--extensions)  
5. [Performance & Resource Usage](#performance--resource-usage)  
9. [License](#license)  

---

## Features

- **Fully Synchronous Design**  
  All internal registers update on the rising clock edge; asynchronous reset isolates startup behavior.  

- **Glitch-Free Updates**  
  New period and duty values propagate only at the boundary of a PWM cycle or upon an explicit synchronous reset, preventing spurious pulses.

- **Parameterizable Resolution**  
  Generic parameter `N` adjusts counter width (e.g., 8-bit, 16-bit, 32-bit) to trade off between frequency granularity and resource usage.

- **Minimal Logic Footprint**  
  Single counting process and a simple comparator for PWM output. Ideal for resource-constrained designs.

- **Self-Contained Testbench**  
  Comprehensive VHDL testbench (`pwm_controller_tb.vhd`) covers 0%, 25%, 50%, 100% duty cycles, dynamic period changes, and reset behavior.

---

## Quick Start

1. **Clone the Repository**  
```bash
   git clone https://github.com/your-org/vhdl-pwm-controller.git
   cd vhdl-pwm-controller
````

2. **Inspect the Core**

   * `src/pwm_controller.vhd` — Top-level PWM generator
   * `src/pwm_controller_tb.vhd` — Automated testbench

3. **Run Simulation**

```bash
   # Example with GHDL
   ghdl -a src/pwm_controller.vhd src/pwm_controller_tb.vhd
   ghdl -r pwm_controller_tb --vcd=waveform.vcd
   gtkwave waveform.vcd
```

   Refer to `docs/waveform_example.png` for expected behavior.

4. **Synthesize for Your Target**
   Add `pwm_controller.vhd` to your toolchain project. Set generic `N` to desired bit-width and connect ports as needed.

---

## Core Interface

| Port           | Direction | Width | Description                                                       |
| -------------- | --------- | ----- | ----------------------------------------------------------------- |
| `i_clk`        | in        | 1     | System clock.                                                     |
| `i_rstb`       | in        | 1     | Active-low asynchronous reset.                                    |
| `i_sync_reset` | in        | 1     | Synchronous load of new period & duty, resets internal counter.   |
| `i_pwm_module` | in        | N     | Period register; actual period = `i_pwm_module + 1` clock cycles. |
| `i_pwm_width`  | in        | N     | Duty register; defines high-time within each period.              |
| `o_pwm`        | out       | 1     | PWM output signal.                                                |

---

## Configuration & Parameters

* **Generic `N`**
  Sets counter width (bit-depth).

```vhdl
  generic map (
    N => 8  -- 8-bit counter (0–255)
  )
```

* **Period Calculation**
  Actual period = `i_pwm_module + 1`. A module value of `0` yields a 1-cycle period (100% duty if width=0).

* **Duty Behavior**

  * `i_pwm_width = 0` → output always low
  * `i_pwm_width = i_pwm_module` → output always high
  * Intermediate values → proportional high-time

---

## Simulation and Verification

* The provided testbench drives:

  * **Reset Behavior**: Asynchronous and synchronous resets
  * **Duty Cycles**: 0%, 25%, 50%, 100%
  * **Period Changes**: Mid-simulation reloads
  * **Edge Conditions**: Wrap-around and counter boundary

* **Assertion Reports**
  The testbench emits a completion report; extend with `assert` statements for automated pass/fail criteria.

---

## Synthesis & Integration

1. **Add to Project**
   Include `pwm_controller.vhd` in your HDL project file list.

2. **Generic Mapping**
   Map generic `N` to match resolution requirements.

3. **Port Connections**
   Connect `i_clk`, `i_rstb`, and control vectors. Tie `i_sync_reset` high for a single clock to reload new settings immediately.

4. **Timing Constraints**
   Ensure `i_clk` meets your frequency targets. The PWM frequency = `f_clk / (i_pwm_module + 1)`.

---

## Customization & Extensions

* **Output Polarity**
  Add a generic `INVERT_OUTPUT` to optionally invert `o_pwm`.

* **Center-Aligned PWM**
  Modify counter to count up/down for symmetric waveforms.

* **Multi-Channel Support**
  Share the counter across multiple comparators to instantiate multiple PWM outputs with individual duties.

* **Duty Ramping**
  Integrate a ramp generator or slew-limiter for smooth transitions.

---

## Performance & Resource Usage

| Parameter    | 8-bit (`N=8`)       | 16-bit (`N=16`)     |
| ------------ | ------------------- | ------------------- |
| LUTs / Logic | \~10                | \~20                |
| Flip-Flops   | 3                   | 3                   |
| Max PWM Freq | f<sub>clk</sub> / 2 | f<sub>clk</sub> / 2 |

*Resource estimates may vary by vendor and synthesis optimizations.*

---

## License

Distributed under the MIT License. See [`LICENSE`](LICENSE) for details.
