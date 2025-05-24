-- File: pwm_prog.vhd
-- Fully synchronous, programmable PWM generator

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_prog is
  generic (
    N : positive := 8  -- Counter width (resolution)
  );
  port (
    i_clk        : in  std_logic;                           -- System clock
    i_rstb       : in  std_logic;                           -- Active-low asynchronous reset
    i_sync_reset : in  std_logic;                           -- Synchronous load of new period & duty
    i_pwm_module : in  std_logic_vector(N-1 downto 0);      -- Period register (period = i_pwm_module + 1)
    i_pwm_width  : in  std_logic_vector(N-1 downto 0);      -- Duty register (high time)
    o_pwm        : out std_logic                            -- PWM output
  );
end entity pwm_prog;

architecture rtl of pwm_prog is
  -- Internal registers
  signal cnt        : unsigned(N-1 downto 0) := (others => '0');
  signal period_reg : unsigned(N-1 downto 0) := (others => '0');
  signal duty_reg   : unsigned(N-1 downto 0) := (others => '0');
begin

  -- Main synchronous process: handles reset, reload & counting
  pwm_proc: process(i_clk, i_rstb)
  begin
    if i_rstb = '0' then
      -- Asynchronous reset
      cnt        <= (others => '0');
      period_reg <= (others => '0');
      duty_reg   <= (others => '0');
    elsif rising_edge(i_clk) then
      if i_sync_reset = '1' then
        -- Synchronously load new period/duty and reset counter
        period_reg <= unsigned(i_pwm_module);
        duty_reg   <= unsigned(i_pwm_width);
        cnt        <= (others => '0');
      else
        if cnt = period_reg then
          -- End of cycle: reload and wrap counter
          period_reg <= unsigned(i_pwm_module);
          duty_reg   <= unsigned(i_pwm_width);
          cnt        <= (others => '0');
        else
          -- Increment counter
          cnt <= cnt + 1;
        end if;
      end if;
    end if;
  end process pwm_proc;

  -- PWM output: high when counter is below duty threshold
  o_pwm <= '1' when cnt < duty_reg else '0';

end architecture rtl;
