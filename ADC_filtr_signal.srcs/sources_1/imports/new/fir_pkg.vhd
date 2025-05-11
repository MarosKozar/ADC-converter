-- FILE: fir_pkg.vhd
-- Filter package with types only (no FIR logic used)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fir_pkg is
  -- 12-bit ADC word
  subtype sample_word is std_logic_vector(11 downto 0);
end package;
