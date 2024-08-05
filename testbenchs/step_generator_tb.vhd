----------------------------------------------------------------------------------
-- Author:          Jules CONTADIN 
-- 
-- Create Date:     17.07.2024 11:56
-- Module Name:     step_generator_tb - Behavioral
-- Target Devices:  MachXO3LF-9400C
-- Description: 
--		Testbench for step_generator
-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity step_generator_tb is
end step_generator_tb;

architecture Behavioral of step_generator_tb is
	-- Component UUT
	component step_generator is 
	generic(
		constant DATA_BITS:		integer;
		constant PULSE_WIDTH:	integer;
		constant FREQ_FPGA:		integer
		);
	Port(
		cpt_clk_i:		in std_logic;
		reset_n_i:		in std_logic;
		arr_i:			in signed(DATA_BITS - 1 downto 0);
		step_o:			out std_logic
		);
	end component;

	-- Clock period & generics definitions
	constant DATA_BITS:			integer := 32;
	constant PULSE_WIDTH:		integer := 2;	-- in us
	constant FREQ_FPGA:			integer := 96;	-- in MHz
	-- Clock period definitions
	constant FPGA_CLK_PERIOD:	time := 10.42 ns; -- Internal clock peridoe (96 MHz)

	-- Inputs
	signal reset_n_i:		std_logic := '1';
	signal cpt_clk_i:		std_logic := '0';
	signal arr_i:			signed(DATA_BITS - 1 downto 0) := (others => '0');
	-- Outputs
	signal step_o : std_logic;
	
begin
	-- Unit Under Test
	uut : step_generator
		generic map (
			DATA_BITS => DATA_BITS,
			PULSE_WIDTH => PULSE_WIDTH,
			FREQ_FPGA => FREQ_FPGA
		)
		port map (
			cpt_clk_i => cpt_clk_i,
			reset_n_i => reset_n_i,
			arr_i => arr_i,
			step_o => step_o
		);

	-- Internal clock process (96 MHz)
	cpt_clk_process: process
	begin
		cpt_clk_i <= '0';
		wait for FPGA_CLK_PERIOD / 2;
		cpt_clk_i <= '1';
		wait for FPGA_CLK_PERIOD / 2;
	end process;

	-- Stimulus process
	stimulus_process: process
	begin
		-- Reset
		reset_n_i <= '0';
		wait for FPGA_CLK_PERIOD;
		reset_n_i <= '1';
		
		-- Send first frame
		arr_i <= to_signed(680e3, DATA_BITS);
		wait for 800e3 * FPGA_CLK_PERIOD;	-- Longer than 680e3, so down-count 2 time from 680e3
		arr_i <= to_signed(480e3, DATA_BITS);
		wait for 680e3 * FPGA_CLK_PERIOD;	-- Still active after end of down-counts from 680e3: down-counting from 480e3
		arr_i <= to_signed(280e3, DATA_BITS);
		wait for 200e3 * FPGA_CLK_PERIOD;	-- Too short, so no down-count from 280e3
		arr_i <= to_signed(30e3, DATA_BITS);
		
		wait;
	end process;
end Behavioral;
