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
use IEEE.STD_LOGIC_ARITH.ALL;

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
		spi_clk_i:		in std_logic;
		cpt_clk_i:		in std_logic;
		reset_n_i:		in std_logic;
		arr_n_i:		in std_logic_vector(DATA_BITS-1 downto 0);
		step_o:			out std_logic
		);
	end component;

	-- Clock period & generics definitions
	constant DATA_BITS:			integer := 32;	-- in bits
	constant PULSE_WIDTH:		integer := 2;	-- in us
	constant FREQ_FPGA:			integer := 400;	-- in MHz
	-- Clock period definitions
	constant FPGA_CLK_PERIOD:	time := 2.5 ns; -- Internal clock peridoe
	constant SPI_CLK_PERIOD:	time := 83 ns;	-- SPI clock periode (12 MHz)

	-- Inputs
	signal reset_n_i:	std_logic := '1';
	signal spi_clk_i:	std_logic := '0';
	signal cpt_clk_i:	std_logic := '0';
	signal arr_n_i:		std_logic_vector(31 downto 0) := (others => '0');
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
			spi_clk_i => spi_clk_i,
			cpt_clk_i => cpt_clk_i,
			reset_n_i => reset_n_i,
			arr_n_i => arr_n_i,
			step_o => step_o
		);
	-- External clock process (12 MHz)
	spi_clk_process: process
	begin
		spi_clk_i <= '0';
		wait for SPI_CLK_PERIOD / 2;
		spi_clk_i <= '1';
		wait for SPI_CLK_PERIOD / 2;
	end process;

	-- Internal clock process (400 MHz)
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
		wait for SPI_CLK_PERIOD;
		reset_n_i <= '1';
		
		-- Send first frame
		arr_n_i <= conv_std_logic_vector(680e3, 32); 
		wait for 800e3 * FPGA_CLK_PERIOD;	-- Longer than 680e3, so down-count 2 time from 680e3
		arr_n_i <= conv_std_logic_vector(480e3, 32);
		wait for 680e3 * FPGA_CLK_PERIOD;	-- Still active after end of down-counts from 680e3: down-counting from 480e3
		arr_n_i <= conv_std_logic_vector(280e3, 32);
		wait for 200e3 * FPGA_CLK_PERIOD;	-- Too short, so no down-count from 280e3
		arr_n_i <= conv_std_logic_vector(30e3, 32);
		
		wait;
	end process;
end Behavioral;
