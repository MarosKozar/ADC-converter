library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sim_top_tb is
end sim_top_tb;

architecture test of sim_top_tb is

  component top_level
    port (
      clk     : in  std_logic;
      reset   : in  std_logic;
      vauxp3  : in  std_logic;
      vauxn3  : in  std_logic;
      seg_an  : out std_logic_vector(3 downto 0);
      seg_cat : out std_logic_vector(6 downto 0);
      leds    : out std_logic_vector(15 downto 0)
    );
  end component;

  signal clk     : std_logic := '0';
  signal reset   : std_logic := '1';
  signal vauxp3  : std_logic := '0';
  signal vauxn3  : std_logic := '0';
  signal seg_an  : std_logic_vector(3 downto 0);
  signal seg_cat : std_logic_vector(6 downto 0);
  signal leds    : std_logic_vector(15 downto 0);

  -- emulate internal ADC signal for filtered input
  signal filtered_inject : std_logic_vector(15 downto 0) := (others => '0');

  -- Internal signals to drive simulation
  signal adc_clock : integer := 0;

begin

  -- DUT
  dut: top_level
    port map (
      clk     => clk,
      reset   => reset,
      vauxp3  => vauxp3,
      vauxn3  => vauxn3,
      seg_an  => seg_an,
      seg_cat => seg_cat,
      leds    => leds
    );

  -- Clock generator
  clk_proc: process
  begin
    while true loop
      clk <= '1';
      wait for 5 ns;
      clk <= '0';
      wait for 5 ns;
    end loop;
  end process;

  -- Reset deassert
  process
  begin
    wait for 100 ns;
    reset <= '0';
  end process;

  -- Fake ADC behavior: manually toggle ADC bits to emulate analog input
  stimulus_proc: process
  begin
    wait for 200 ns;

    -- Simulate rising filtered value: emulate ADC detecting voltage ramp
    for i in 0 to 4095 loop
      filtered_inject <= std_logic_vector(to_unsigned(i * 16, 16)); -- left shifted
      wait for 100 ns;
    end loop;

    wait;
  end process;

  -- Emulate XADC internally: patch vauxp3 high, vauxn3 low
  -- This won't impact your XADC instantiation but shows expected toggling
  vauxp3 <= '1' when filtered_inject > x"0100" else '0';
  vauxn3 <= '0';  -- fixed ground reference

end architecture;
