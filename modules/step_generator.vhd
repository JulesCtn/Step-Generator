----------------------------------------------------------------------------------
-- Author:          Jules CONTADIN 
-- 
-- Create Date:     15.07.2024 16:07
-- Module Name:     step_generator - Behavioral
-- Target Devices:  MachXO3LF-9400C-6BG484C
-- Description: 
--			This is an ARR (Auto Reload Register) that generates steps. ARR_MIN is calculated 
--		depending on the user's defnition:
--			- PULSE_WIDTH is the width of one step, default is 2 (in µs);
--			- FREQ_FPGA is the internal frequency of the FPGA, default is 96 (in MHz).
--		The user has to keep a DATA_BITS value large enough to let the down-counter reach user's max ARR. 
--
-- Update 1.1:		Changed integers to logic_vectors
-- Next update:		Linear interpolation (1 point) / Direction
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity step_generator is
    generic(
		constant DATA_BITS:		integer := 32;
		constant PULSE_WIDTH:	integer := 2; 		-- Width of one pulse (in µs)
		constant FREQ_FPGA:		integer := 96 		-- Internal FPGA frequency (in MHz)
        );
    Port(
		cpt_clk_i:		in std_logic;
		reset_n_i:		in std_logic;
		arr_i:			in signed(DATA_BITS - 1 downto 0);
		step_o:			out std_logic
        );
end step_generator;

architecture Behavioral of step_generator is
-- Constant
	--constant ARR_MIN:	integer := FREQ_FPGA * PULSE_WIDTH; -- A step lasts from ARR_MIN to 0
	constant ARR_MIN: signed(DATA_BITS - 1 downto 0) := to_signed(FREQ_FPGA * PULSE_WIDTH, DATA_BITS);
-- Signals
	--signal counter:		integer range 0 to 2147483647 := 0;
	signal counter: signed(DATA_BITS - 1 downto 0) := (others => '0');
begin
-- Down counting process
	down_cpt_proc : process(cpt_clk_i, reset_n_i)
	begin
		if reset_n_i = '0' then
			counter <= arr_i;
			step_o <= '0';
		elsif rising_edge(cpt_clk_i) then
			if counter < x"00000002" then
				step_o <= '0';
				counter <= arr_i;
			elsif counter = ARR_MIN then
				step_o <= '1';
				counter <= counter - 1;
			else
				counter <= counter - 1;
			end if;
		end if;
	end process;
	
end Behavioral;
