# VHDL PWM Controller

A high-performance, fully synchronous VHDL implementation of a programmable PWM (Pulse-Width Modulation) generator.  
This core features runtime-configurable period and duty-cycle registers, glitch-free updates on cycle boundaries, and minimal logic for easy integration into FPGA or ASIC designs.

---

## Table of Contents

- [Features](#features)   
- [Requirements](#requirements)  
- [Getting Started](#getting-started)  
  - [Synthesis](#synthesis)  
  - [Simulation](#simulation)  
- [Usage](#usage)  
- [Core Interface](#core-interface)  
- [Extensions & Customization](#extensions--customization)  
- [License](#license)  

---

## Features

- **Fully synchronous design**  
  All registers (period, duty, and counter) update on the rising clock edge with an asynchronous reset.  
- **Glitch-free duty-cycle updates**  
  New period or duty takes effect only at the start of a new PWM cycle or on an explicit synchronous reset.  
- **Configurable resolution**  
  Generic parameter `N` sets the counter width (e.g., 8-bit, 16-bit, etc.).  
- **Minimal logic footprint**  
  Simple comparator for output generation and a single process for state updates.  


## Requirements

- Any VHDL-2008-compliant synthesis or simulation tool  
- Standard IEEE libraries:  
```vhdl
  library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;
````

---

## Getting Started

### Synthesis

1. Add `src/pwm_controller.vhd` to your project.
2. Set generic `N` to your desired counter width (default: 8).
3. Connect clock, reset, period, and duty inputs as appropriate.
4. Synthesize for your target FPGA or ASIC flow.

### Simulation

1. Compile both `pwm_controller.vhd` and `pwm_controller_tb.vhd`.
2. Run your simulator to view the duty-cycle behavior across period changes.
3. Refer to `docs/waveform_example.png` for expected timing diagram.

---

## Usage

```vhdl
-- Example instantiation in your top‐level file
signal clk       : std_logic;
signal rst_n     : std_logic;
signal sync_ld   : std_logic;
signal period_i  : std_logic_vector(7 downto 0);
signal duty_i    : std_logic_vector(7 downto 0);
signal pwm_out   : std_logic;

...

pwm_inst : entity work.pwm_prog
  generic map (
    N => 8
  )
  port map (
    i_clk        => clk,
    i_rstb       => rst_n,
    i_sync_reset => sync_ld,
    i_period     => period_i,
    i_duty       => duty_i,
    o_pwm        => pwm_out
  );
```

* **`i_period`** sets the PWM period as `i_period + 1` clock cycles.
* **`i_duty`** defines the high-time; when `i_duty = 0` output is always low; when `i_duty = i_period` output is always high.
* Toggle `i_sync_reset` high for one clock to immediately load new values and reset the cycle.

---

## Core Interface

| Port Name      | Direction | Width | Description                              |
| -------------- | --------- | ----- | ---------------------------------------- |
| `i_clk`        | in        | 1     | System clock                             |
| `i_rstb`       | in        | 1     | Active-low asynchronous reset            |
| `i_sync_reset` | in        | 1     | Synchronous load/reset of period & duty  |
| `i_period`     | in        | N     | PWM period register (period = value + 1) |
| `i_duty`       | in        | N     | PWM high-time register                   |
| `o_pwm`        | out       | 1     | PWM output                               |

---

## Extensions & Customization

* **Polarity inversion**
  Add a generic flag to invert `o_pwm` output polarity.
* **Center-aligned PWM**
  Modify counter logic to count up/down for center-aligned waveforms.
* **Multiple channels**
  Replicate the core with shared counter and individual duty comparators.

---

## License

This project is licensed under the [MIT License](LICENSE). Feel free to use, modify, and distribute under the terms of MIT.
