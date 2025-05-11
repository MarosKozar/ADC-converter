library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sim_processing_unit is
  port (
    clk          : in  std_logic;
    reset        : in  std_logic;
    vp_in        : in  std_logic;
    vn_in        : in  std_logic;
    filtered_out : out std_logic_vector(15 downto 0)
  );
end entity;

architecture sim of sim_processing_unit is
  signal raw_val       : integer := 0;
  signal smoothed_val  : integer := 0;
  signal prev_output   : integer := 0;
  signal filtered      : std_logic_vector(15 downto 0);
  signal fake_adc      : integer := 0;
  signal sample_en     : boolean := false;
  constant threshold   : integer := 41;
  constant max_val     : integer := 4095;

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        fake_adc <= 0;
        raw_val <= 0;
        smoothed_val <= 0;
        prev_output <= 0;
        sample_en <= false;
      else
        -- Simulate sampling: increment ADC value when vp_in is high
        if vp_in = '1' then
          sample_en <= true;
          if fake_adc < max_val then
            fake_adc <= fake_adc + 64;
          end if;
        else
          sample_en <= false;
        end if;

        if sample_en then
          raw_val <= fake_adc;
          smoothed_val <= (raw_val + (smoothed_val * 7)) / 8;

          if abs(smoothed_val - prev_output) > threshold then
            prev_output <= smoothed_val;
          end if;
        end if;
      end if;
    end if;
  end process;

  filtered <= std_logic_vector(to_signed(prev_output, 16));
  filtered_out <= filtered;

end architecture;
