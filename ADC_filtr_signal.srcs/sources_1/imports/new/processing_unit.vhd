library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processing_unit is
  port (
    clk          : in  std_logic;
    reset        : in  std_logic;
    vp_in        : in  std_logic;
    vn_in        : in  std_logic;
    filtered_out : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of processing_unit is

  component XADC
    port (
      DCLK        : in  std_logic;
      RESET       : in  std_logic;
      VAUXP       : in  std_logic_vector(15 downto 0);
      VAUXN       : in  std_logic_vector(15 downto 0);
      VP          : in  std_logic;
      VN          : in  std_logic;
      ALM         : out std_logic_vector(7 downto 0);
      DO          : out std_logic_vector(15 downto 0);
      DRDY        : out std_logic;
      DEN         : in  std_logic;
      DADDR       : in  std_logic_vector(6 downto 0);
      DWE         : in  std_logic;
      DI          : in  std_logic_vector(15 downto 0);
      CONVST      : in  std_logic;
      CONVSTCLK   : in  std_logic;
      EOS         : out std_logic;
      BUSY        : out std_logic
    );
  end component;

  signal adc_do        : std_logic_vector(15 downto 0);
  signal adc_drdy      : std_logic;
  signal daddr         : std_logic_vector(6 downto 0) := "0000000";
  signal den           : std_logic := '1';
  signal dwe           : std_logic := '0';
  signal di            : std_logic_vector(15 downto 0) := (others => '0');
  signal convst        : std_logic := '0';
  signal convstclk     : std_logic := '0';
  signal alm           : std_logic_vector(7 downto 0);
  signal eos           : std_logic;
  signal busy          : std_logic;

  signal raw_val       : integer := 0;
  signal smoothed_val  : integer := 0;
  signal prev_output   : integer := 0;
  signal filtered      : std_logic_vector(15 downto 0);

begin

  u_xadc : XADC
    port map (
      DCLK        => clk,
      RESET       => reset,
      VAUXP       => (others => '0'),
      VAUXN       => (others => '0'),
      VP          => vp_in,
      VN          => vn_in,
      ALM         => alm,
      DO          => adc_do,
      DRDY        => adc_drdy,
      DEN         => den,
      DADDR       => daddr,
      DWE         => dwe,
      DI          => di,
      CONVST      => convst,
      CONVSTCLK   => convstclk,
      EOS         => eos,
      BUSY        => busy
    );

  process(clk)
    constant threshold : integer := 41; -- ~10mV
  begin
    if rising_edge(clk) then
      if reset = '1' then
        raw_val <= 0;
        smoothed_val <= 0;
        prev_output <= 0;
      elsif adc_drdy = '1' then
        raw_val <= to_integer(unsigned(adc_do(15 downto 4))); -- 12-bit
        -- IIR low-pass filter: y[n] = (x + 7*y[n-1]) / 8
        smoothed_val <= (raw_val + (smoothed_val * 7)) / 8;

        if abs(smoothed_val - prev_output) > threshold then
          prev_output <= smoothed_val;
        end if;
      end if;
    end if;
  end process;

  filtered <= std_logic_vector(to_signed(prev_output, 16));
  filtered_out <= filtered;

end architecture;
