-- File: pwm_controller_tb.vhd
-- Testbench for pwm_prog.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_controller_tb is
end entity;

architecture tb of pwm_controller_tb is

  -- Generic parameter for DUT
  constant N : integer := 8;
  
  -- Signals for DUT interface
  signal clk         : std_logic := '0';
  signal rstb        : std_logic := '0';
  signal sync_reset  : std_logic := '0';
  signal period_iv   : std_logic_vector(N-1 downto 0) := (others => '0');
  signal duty_iv     : std_logic_vector(N-1 downto 0) := (others => '0');
  signal pwm_out     : std_logic;
  
  -- Clock period
  constant CLK_PERIOD : time := 10 ns;

begin

  -- Instantiate the PWM controller (Device Under Test)
  dut: entity work.pwm_prog
    generic map (
      N => N
    )
    port map (
      i_clk        => clk,
      i_rstb       => rstb,
      i_sync_reset => sync_reset,
      i_pwm_module => period_iv,
      i_pwm_width  => duty_iv,
      o_pwm        => pwm_out
    );

  ------------------------------------------------------------------
  -- Clock generation
  clk_gen : process
  begin
    while true loop
      clk <= '0';
      wait for CLK_PERIOD/2;
      clk <= '1';
      wait for CLK_PERIOD/2;
    end loop;
  end process;

  ------------------------------------------------------------------
  -- Stimulus process
  stim_proc: process
  begin
    -- Apply asynchronous reset
    rstb <= '0';
    wait for 25 ns;
    rstb <= '1';
    wait for CLK_PERIOD;
    
    -- Test 1: 50% duty, period = 100
    period_iv  <= std_logic_vector(to_unsigned(99, N));  -- period = 100
    duty_iv    <= std_logic_vector(to_unsigned(49, N));  -- 50% duty
    sync_reset <= '1';
    wait for CLK_PERIOD;
    sync_reset <= '0';
    
    -- Let it run for 10 full PWM cycles
    wait for 100 * CLK_PERIOD * 10;
    
    -- Test 2: 25% duty, period = 80
    period_iv  <= std_logic_vector(to_unsigned(79, N));  -- period = 80
    duty_iv    <= std_logic_vector(to_unsigned(19, N));  -- 25% duty
    sync_reset <= '1';
    wait for CLK_PERIOD;
    sync_reset <= '0';
    
    -- Let it run for 10 full PWM cycles
    wait for 80 * CLK_PERIOD * 10;
    
    -- Test 3: Full-on and full-off cases
    -- Full-off (duty = 0)
    period_iv  <= std_logic_vector(to_unsigned(49, N));  -- period = 50
    duty_iv    <= (others => '0');                       -- 0% duty
    sync_reset <= '1';
    wait for CLK_PERIOD;
    sync_reset <= '0';
    wait for 50 * CLK_PERIOD * 5;
    
    -- Full-on (duty = period)
    duty_iv    <= std_logic_vector(to_unsigned(49, N));  -- 100% duty
    sync_reset <= '1';
    wait for CLK_PERIOD;
    sync_reset <= '0';
    wait for 50 * CLK_PERIOD * 5;
    
    -- End simulation
    report "PWM testbench completed successfully." severity note;
    wait;
  end process;

end architecture;
