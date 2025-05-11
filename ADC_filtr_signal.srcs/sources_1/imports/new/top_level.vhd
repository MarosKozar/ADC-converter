library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
  generic (
    SIM : boolean := false
  );
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    vp_in     : in  std_logic;
    vn_in     : in  std_logic;
    seg_an    : out std_logic_vector(3 downto 0);
    seg_cat   : out std_logic_vector(6 downto 0);
    leds      : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of top_level is

  component processing_unit
    port (
      clk          : in  std_logic;
      reset        : in  std_logic;
      vp_in        : in  std_logic;
      vn_in        : in  std_logic;
      filtered_out : out std_logic_vector(15 downto 0)
    );
  end component;

  component sim_processing_unit
    port (
      clk          : in  std_logic;
      reset        : in  std_logic;
      vp_in        : in  std_logic;
      vn_in        : in  std_logic;
      filtered_out : out std_logic_vector(15 downto 0)
    );
  end component;

  component display_unit
    port (
      clk       : in  std_logic;
      reset     : in  std_logic;
      data_in   : in  std_logic_vector(15 downto 0);
      seg_cat   : out std_logic_vector(6 downto 0);
      seg_an    : out std_logic_vector(3 downto 0);
      leds      : out std_logic_vector(15 downto 0)
    );
  end component;

  signal filtered_signal : std_logic_vector(15 downto 0);

begin

  gen_sim : if SIM generate
    u_proc_sim : sim_processing_unit
      port map (
        clk          => clk,
        reset        => reset,
        vp_in        => vp_in,
        vn_in        => vn_in,
        filtered_out => filtered_signal
      );
  end generate;

  gen_synth : if not SIM generate
    u_proc : processing_unit
      port map (
        clk          => clk,
        reset        => reset,
        vp_in        => vp_in,
        vn_in        => vn_in,
        filtered_out => filtered_signal
      );
  end generate;

  disp : display_unit
    port map (
      clk     => clk,
      reset   => reset,
      data_in => filtered_signal,
      seg_cat => seg_cat,
      seg_an  => seg_an,
      leds    => leds
    );

end architecture;
