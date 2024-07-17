----------------------------------------------------------------------------------
-- Author:          Jules CONTADIN 
-- 
-- Create Date:     15.07.2024 16:07
-- Module Name:     step_generator - Behavioral
-- Target Devices:  MachXO3LF-9400C-6BG484C
-- Description: 
--			This is an ARR (Auto Reload Register) that generate steps. ARR_MIN is calculated 
--		depending on the user's defnition:
--			- PULSE_WIDTH is the width of one step, default is 2 (in us);
--			- FREQ_FPGA is the internal frequency of the FPGA, default is 400 (in MHz).
--		User have to keep a DATA_BITS value large enough to let the down-counter reach user's max ARR. 
-- Next update:		Linear interpolation / Direction
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity step_generator is
    generic(
		constant DATA_BITS:		integer := 32;		-- Number of bits to support ARR_MAX
		constant PULSE_WIDTH:	integer := 2; 		-- Width of one pulse (in us)
		constant FREQ_FPGA:		integer := 400 		-- Internal FPGA frequency (in MHz)
        );
    Port(
        spi_clk_i:		in std_logic;
		cpt_clk_i:		in std_logic;
		reset_n_i:		in std_logic;
		arr_n_i:		in std_logic_vector(DATA_BITS-1 downto 0);
		step_o:			out std_logic
        );
end step_generator;

architecture Behavioral of step_generator is
-- Constant
	constant ARR_MIN: integer := FREQ_FPGA*PULSE_WIDTH; -- A step lasts from ARR_MIN to 0
-- Signals
	signal counter:		integer := 0;
	signal sig_arr_n: 	std_logic_vector(DATA_BITS-1 downto 0); -- ARR(n)
begin
-- Down counting process
	down_cpt_proc : process(cpt_clk_i, reset_n_i)
	begin
		if reset_n_i = '0' then
			counter <= 0;
			sig_arr_n <= x"00000000";
			step_o <= '0';
		elsif rising_edge(cpt_clk_i) then
			if counter = ARR_MIN then
				step_o <= '1';
				counter <= counter -1;
			elsif counter = 0 then
				sig_arr_n <= arr_n_i;
				step_o <= '0';
				counter <= conv_integer(signed(sig_arr_n));
			else
				counter <= counter -1;
			end if;
		end if;
	end process;
end Behavioral;
