library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sim_top_tb is
end sim_top_tb;

architecture test of sim_top_tb is

  component top_level
    generic (
      SIM : boolean
    );
    port (
      clk     : in  std_logic;
      reset   : in  std_logic;
      vp_in   : in  std_logic;
      vn_in   : in  std_logic;
      seg_an  : out std_logic_vector(3 downto 0);
      seg_cat : out std_logic_vector(6 downto 0);
      leds    : out std_logic_vector(15 downto 0)
    );
  end component;

  signal clk     : std_logic := '0';
  signal reset   : std_logic := '1';
  signal vp_in   : std_logic := '0';
  signal vn_in   : std_logic := '0';
  signal seg_an  : std_logic_vector(3 downto 0);
  signal seg_cat : std_logic_vector(6 downto 0);
  signal leds    : std_logic_vector(15 downto 0);

  signal analog_counter : integer := 0;
  signal filtered_out   : std_logic_vector(15 downto 0);
  signal filtered_mv    : integer := 0;
  signal raw_mv         : integer := 0;
  signal analog_in      : integer := 0;

begin

  dut: top_level
    generic map (
      SIM => true
    )
    port map (
      clk     => clk,
      reset   => reset,
      vp_in   => vp_in,
      vn_in   => vn_in,
      seg_an  => seg_an,
      seg_cat => seg_cat,
      leds    => leds
    );

  clk_gen: process
  begin
    while true loop
      clk <= '1'; wait for 5 ns;
      clk <= '0'; wait for 5 ns;
    end loop;
  end process;

  rst_gen: process
  begin
    wait for 100 ns;
    reset <= '0';
    wait;
  end process;

  analog_emulation: process(clk)
  begin
    if rising_edge(clk) then
      if reset = '0' then
        if analog_counter < 100 then
          analog_counter <= analog_counter + 1;
        end if;

        if analog_counter >= 10 then
          vp_in <= '1';
        else
          vp_in <= '0';
        end if;

        vn_in <= '0';
      end if;
    end if;
  end process;

  filtered_out <= leds;

  monitor: process(clk)
  begin
    if rising_edge(clk) then
      analog_in   <= to_integer(unsigned(filtered_out));
      raw_mv      <= analog_in * 1000 / 65535;
      filtered_mv <= to_integer(unsigned(filtered_out(15 downto 4))) * 1000 / 4095;
      report "Analog In = " & integer'image(analog_in) &
             ", Raw mV = " & integer'image(raw_mv) &
             ", Filtered mV = " & integer'image(filtered_mv);
    end if;
  end process;

end architecture;
