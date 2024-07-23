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
--			- FREQ_FPGA is the internal frequency of the FPGA, default is 400 (in MHz).
--		The user has to keep a DATA_BITS value large enough to let the down-counter reach user's max ARR. 
-- Next update:		Linear interpolation / Direction
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity step_generator is
    generic(
		constant DATA_BITS:		integer := 32;		-- Number of bits to support ARR_MAX
		constant PULSE_WIDTH:	integer := 2; 		-- Width of one pulse (in µs)
		constant FREQ_FPGA:		integer := 400 		-- Internal FPGA frequency (in MHz)
        );
    Port(
		cpt_clk_i:		in std_logic;
		reset_n_i:		in std_logic;
		arr_i:			in integer; --std_logic_vector(DATA_BITS-1 downto 0);
		step_o:			out std_logic
        );
end step_generator;

architecture Behavioral of step_generator is
-- Constant
	constant ARR_MIN: integer := FREQ_FPGA*PULSE_WIDTH; -- A step lasts from ARR_MIN to 0
-- Signals
	signal counter:			integer := 0;
	signal desired_arr:		integer; -- ARR(n)
	signal next_arr:		integer; -- ARR(n+1)
	signal nb_point:		std_logic;
	--signal debug_calculated_arr:	integer;	-- Debugg signal
begin
-- Down counting process
	down_cpt_proc : process(cpt_clk_i, reset_n_i)
	variable interpolated_arr:	integer;
	begin
		if reset_n_i = '0' then
			counter <= 0;
			desired_arr <= 0;
			next_arr <= 0;
			interpolated_arr := 0;
			nb_point <= '0';
			step_o <= '0';
		elsif rising_edge(cpt_clk_i) then
			if counter = ARR_MIN then
				step_o <= '1';
				counter <= counter -1;
			elsif counter = 0 then
				step_o <= '0';
			-- If 1st point: interpolated point
				if nb_point = '0' then	
					next_arr <= arr_i;
					desired_arr <= next_arr;
					interpolated_arr := desired_arr + ((next_arr - desired_arr)/2); -- ARR = ARR0 + (ARR1 - ARR0)/?
					counter <= interpolated_arr;
					nb_point <= '1';
					--debug_calculated_arr <= interpolated_arr;	-- Debugg signal
			-- Si 2nd point: goal point
				else	
					next_arr <= arr_i;
					desired_arr <= next_arr;
					counter <= desired_arr;
					nb_point <= '0';
					--debug_calculated_arr <= desired_arr;	-- Debugg signal
				end if;
				
			else
				counter <= counter -1;
			end if;
		end if;
	end process;
end Behavioral;
