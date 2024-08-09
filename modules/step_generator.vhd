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
-- Update 1.1:		Changed integers to logic_vectors
-- Next update:		Linear interpolation (1 point) / Direction
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity step_generator is
    generic(
		constant DATA_BITS:		integer := 32;
		constant PULSE_WIDTH:	integer := 2; 		-- Width of one pulse (in µs)
		constant FREQ_FPGA:		integer := 400 		-- Internal FPGA frequency (in MHz)
        );
    Port(
		cpt_clk_i:		in std_logic;
		reset_n_i:		in std_logic;
		arr_i:			in std_logic_vector(DATA_BITS - 1 downto 0);
		step_o:			out std_logic
        );
end step_generator;

architecture Behavioral of step_generator is
-- Constant
	--constant ARR_MIN: unsigned(DATA_BITS - 1 downto 0) := to_unsigned(FREQ_FPGA * PULSE_WIDTH, DATA_BITS);
	constant ARR_MIN: std_logic_vector(9 downto 0) := "1000000000";
-- Signals
	signal counter: std_logic_vector(DATA_BITS - 1 downto 2) := (others => '0');
	signal freq_div2: std_logic := '0';
	signal freq_div4: std_logic := '0';
	--signal freq_div8: std_logic := '0';
	signal i_reset: std_logic := '0';
begin
-- Down counting process (Can only reach ~ 190 MHz with PLL for timing reasons)
	--down_cpt_proc : process(cpt_clk_i, reset_n_i)
	--begin
		--if rising_edge(cpt_clk_i) then
			--if reset_n_i = '0' or counter <= 1 then
				--counter <= arr_i;	
				--step_o <= '0';
			--else
				--counter <= counter - 1;
				--if counter <= ARR_MIN then
					--step_o <= '1';
				--else
					--step_o <= '0';
				--end if;
			--end if;
		--end if;
	--end process;
	
-- Down counting process (Reaching 400 MHz yay)
	down_cpt_proc_div : process(freq_div4)
	begin
		if rising_edge(freq_div4) then
			if reset_n_i = '0' or counter <= 4 then
				step_o <= '0';
				i_reset <= '1';
			elsif i_reset = '1' then
				counter <= arr_i(DATA_BITS - 1 downto 2);	
				step_o <= '0';
				i_reset <= '0';
			else
				counter <= counter - 1;
				if counter <= ARR_MIN then
					step_o <= '1';
				else
					step_o <= '0';
				end if;
			end if;
		end if;
		--if rising_edge(freq_div2) then
			--counter <= counter - 1;
			--if counter <= ARR_MIN then
				--step_o <= '1';
			--else
				--step_o <= '0';
			--end if;
			--if reset_n_i = '0' or counter <= 2 then
				--i_reset <= '1';
			--end if;
			--if i_reset = '1' then
				--counter <= arr_i(DATA_BITS - 1 downto 1);
				--step_o <= '0';
				--i_reset <= '0';
			--end if;
		--end if;
	end process;
	
-- Down counting process (with lesser frequency for MSBs) (Best frequency is ~ 133MHz)
	--down_cpt_proc : process(cpt_clk_i, freq_div2, freq_div4, freq_div8)
	--begin
		 
		 --Most of the bits with lesser frequency
		--if rising_edge(freq_div8) then
			--if i_reset ='1' then
				--counter(DATA_BITS - 1 downto 3) <= (others => '0');
			--else
				--counter(DATA_BITS - 1 downto 3) <= counter(DATA_BITS - 1 downto 3) - 1;
			--end if;
		--end if;
		
		--if rising_edge(freq_div4) then		--Bit2 with max freq/4
			--if i_reset ='1' then
				--counter(2) <= '0';
			--else
				--counter(2) <= not counter(2);
			--end if;
		--end if;
		
		--if rising_edge(freq_div2) then		--Bit1 with max freq/2
			--if i_reset ='1' then
				--counter(1) <= '0';
			--else
				--counter(1) <= not counter(1);
			--end if;
		--end if;
		
		--if rising_edge(cpt_clk_i) then		--Bit0 with max frequency
		--if (counter <=1) then
			--if reset_n_i ='0' then
				--i_reset<= '1';
			--end if;
		--end if;
			--if i_reset ='1' then
				--counter <= arr_i;
				--step_o <= '0';
			--else
				--counter(0) <= not counter(0);
			--end if;
		--end if;
		
		--if counter <= ARR_MIN and counter > 1 then 
			--step_o <= '1';
		--else 
			--step_o <= '0';
		--end if;
	--end process;
	
	-- Freq divider by 8
	--freq_div_by8 : process(freq_div4)
	--begin
		--if rising_edge(freq_div4) then
			--if reset_n_i = '0' then
				--freq_div8 <= '0';
			--else
				--freq_div8 <= not freq_div8;
			--end if;
		--end if;
	--end process;
	
	-- Freq divider by 4
	freq_div_by4 : process(freq_div2)
	begin
		if rising_edge(freq_div2) then
			if reset_n_i = '0' then
				freq_div4 <= '0';
			else
				freq_div4 <= not freq_div4;
			end if;
		end if;
	end process;
	
-- Freq divider by 2
	freq_div_by2 : process(cpt_clk_i)
	begin
		if rising_edge(cpt_clk_i) then
			if reset_n_i = '0' then
				freq_div2 <= '0';
			else
				freq_div2 <= not freq_div2;
			end if;
		end if;
	end process;
	
	
-- Bit0 of TEMP_Q	(can't have more than ~16MHz, with 23 other process like this)
	--BIT0 : process(cpt_clk_i, reset_n_i)
	--begin
		--if reset_n_i = '0' or counter < 1 then
			--TEMP_Q(0) <= arr_i(0);
		--elsif rising_edge(cpt_clk_i) then
			--TEMP_Q(0) <= not TEMP_Q(0);
		--end if;
	--end process;	-- (...)

end Behavioral;
