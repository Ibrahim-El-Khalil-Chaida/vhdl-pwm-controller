library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_prog is
  generic (
    N : positive := 8  -- Counter width
  );
  port (
    i_clk        : in  std_logic;
    i_rstb       : in  std_logic;                             -- Active-low async reset
    i_sync_reset : in  std_logic;                             -- Sync load of new period & duty
    i_period     : in  std_logic_vector(N-1 downto 0);        -- PWM period = i_period + 1
    i_duty       : in  std_logic_vector(N-1 downto 0);        -- PWM high time
    o_pwm        : out std_logic
  );
end entity;

architecture rtl of pwm_prog is
  signal cnt        : unsigned(N-1 downto 0) := (others=>'0');
  signal period_reg : unsigned(N-1 downto 0) := (others=>'0');
  signal duty_reg   : unsigned(N-1 downto 0) := (others=>'0');
begin

  -- Main synchronous process:
  pwm_proc: process(i_clk, i_rstb)
  begin
    if i_rstb = '0' then
      -- Asynchronous reset
      cnt        <= (others => '0');
      period_reg <= (others => '0');
      duty_reg   <= (others => '0');
    elsif rising_edge(i_clk) then
      if i_sync_reset = '1' then
        -- Synchronously load new period & duty and clear counter
        period_reg <= unsigned(i_period);
        duty_reg   <= unsigned(i_duty);
        cnt        <= (others => '0');
      else
        if cnt = period_reg then
          -- At end of period, reload parameters and wrap counter
          period_reg <= unsigned(i_period);
          duty_reg   <= unsigned(i_duty);
          cnt        <= (others => '0');
        else
          -- Otherwise increment counter
          cnt <= cnt + 1;
        end if;
      end if;
    end if;
  end process pwm_proc;

  -- Combinational PWM output
  o_pwm <= '1' when cnt < duty_reg else '0';

end architecture;
