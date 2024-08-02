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
--
-- Update 2.0:		Linear interpolation (1 point)
-- Next update:		Linear interpolation (N_POINT point) / Direction
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity step_generator is
    generic(
		constant PULSE_WIDTH:	integer := 2; 		-- Width of one pulse (in µs)
		constant FREQ_FPGA:		integer := 400 		-- Internal FPGA frequency (in MHz)
        );
    Port(
		cpt_clk_i:		in std_logic;
		reset_n_i:		in std_logic;
		arr_i:			in integer;
		step_o:			out std_logic
        );
end step_generator;

architecture Behavioral of step_generator is
-- Constant
	constant ARR_MIN: integer := FREQ_FPGA * PULSE_WIDTH; -- A step lasts from ARR_MIN to 0
-- Signals
	signal counter:			integer := 0;
	signal nb_point:		std_logic := '0';
	signal dbug_nxt_arr:	std_logic_vector(26 downto 0); 	-- Debugg signal (optional)
	signal dbug_curr_arr:	std_logic_vector(26 downto 0);	-- Debugg signal (optional)
	signal old_arr:			integer := 0;
begin
-- Down counting process
	down_cpt_proc : process(cpt_clk_i, reset_n_i)
	variable interpolated_arr:	integer := 0;
	variable next_arr:			integer := 0; -- ARR(n+1)
	begin
		if reset_n_i = '0' then
			counter <= 0;
			old_arr <= 0;
			next_arr := 0;
			interpolated_arr := 0;
			nb_point <= '0';
			step_o <= '0';
		elsif rising_edge(cpt_clk_i) then
			if counter = ARR_MIN then
				step_o <= '1';
				counter <= counter - 1;
			elsif counter <= 1 then
				step_o <= '0';
				-- If 1st point -> interpolated point
				if nb_point = '0' then
					next_arr := arr_i;
					interpolated_arr := old_arr + ((next_arr - old_arr)/2); -- ARR = ARR0 + (ARR1 - ARR0)/2
					counter <= interpolated_arr;
					nb_point <= '1';
					dbug_curr_arr <= std_logic_vector(to_unsigned(interpolated_arr, 27));	-- Debugg signal (optional)
				-- If 2nd point -> goal point
				else
					old_arr <= next_arr;
					counter <= next_arr;
					nb_point <= '0';
					dbug_curr_arr <= std_logic_vector(to_unsigned(next_arr, 27));	-- Debugg signal (optional)
				end if;
			else
				counter <= counter -1;
			end if;
		end if;
		dbug_nxt_arr <= std_logic_vector(to_unsigned(next_arr, 27));	-- Debugg signal (optional)
	end process;
	
end Behavioral;
