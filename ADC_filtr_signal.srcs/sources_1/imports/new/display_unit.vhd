library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_unit is
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    data_in   : in  std_logic_vector(15 downto 0);
    seg_cat   : out std_logic_vector(6 downto 0);
    seg_an    : out std_logic_vector(3 downto 0);
    leds      : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of display_unit is

  type digit_array_t is array (0 to 3) of integer range 0 to 9;

  signal digit_index   : integer range 0 to 3 := 0;
  signal refresh_cnt   : integer := 0;
  signal voltage_mv    : integer range 0 to 1000 := 0;
  signal abs_data      : unsigned(15 downto 0);
  signal bcd_digits    : digit_array_t;
  signal seg_raw       : std_logic_vector(6 downto 0);
  signal anodes        : std_logic_vector(3 downto 0);
  signal digit_val     : integer range 0 to 9 := 0;

begin

  leds <= data_in;
  abs_data <= unsigned(abs(signed(data_in)));

  -- Clock divider for refresh rate
  process(clk)
  begin
    if rising_edge(clk) then
      refresh_cnt <= refresh_cnt + 1;
      if refresh_cnt = 25000 then
        refresh_cnt <= 0;
        digit_index <= (digit_index + 1) mod 4;
      end if;
    end if;
  end process;

  -- Voltage conversion
  process(clk)
    variable val : integer;
  begin
    if rising_edge(clk) then
      voltage_mv <= to_integer(abs_data(15 downto 4)) * 1000 / 4095;
      val := voltage_mv;
      bcd_digits(0) <= (val / 1000) mod 10;
      bcd_digits(1) <= (val / 100) mod 10;
      bcd_digits(2) <= (val / 10) mod 10;
      bcd_digits(3) <= val mod 10;
    end if;
  end process;

  -- Drive segment and anode logic
  process(clk)
  begin
    if rising_edge(clk) then
      digit_val <= bcd_digits(digit_index);

      case digit_val is
        when 0 => seg_raw <= "0000001";
        when 1 => seg_raw <= "1001111";
        when 2 => seg_raw <= "0010010";
        when 3 => seg_raw <= "0000110";
        when 4 => seg_raw <= "1001100";
        when 5 => seg_raw <= "0100100";
        when 6 => seg_raw <= "0100000";
        when 7 => seg_raw <= "0001111";
        when 8 => seg_raw <= "0000000";
        when 9 => seg_raw <= "0000100";
        when others => seg_raw <= "1111111"; -- blank
      end case;

      anodes <= (others => '1');
      anodes(digit_index) <= '0';
    end if;
  end process;

  seg_cat <= seg_raw;
  seg_an  <= anodes;

end architecture;
