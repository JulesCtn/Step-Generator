----------------------------------------------------------------------------------
-- Author:          Jules CONTADIN 
-- 
-- Create Date:     07.05.2024 15:00:20
-- Module Name:     recep_spi_tb - Behavioral
-- Target Devices:  MachXO3LF-9400C
-- Description: 
--      testbench for recep_spi
-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity recep_spi_tb is
end recep_spi_tb;

architecture Behavioral of recep_spi_tb is
	-- Component UUT
	component recep_spi is 
	generic(		
		constant DATA_BITS	: integer
		);
	port (
		clk_i:		in std_logic;
		reset_n_i:	in std_logic;
		mosi_i:		in std_logic;
		cs_i:		in std_logic;
		data_o:		out std_logic_vector(DATA_BITS-1 downto 0);
		data_rdy_o:	out std_logic
	);
	end component;

	-- Clock period & generics definitions
	constant CLK_PERIOD : time := 83 ns; -- Période de l'horloge (12 MHz)
	constant DATA_BITS : integer := 32;
	-- Inputs
	signal clk_i : std_logic := '0';
	signal reset_n_i : std_logic := '1';
	signal mosi_i : std_logic := '0';
	signal cs_i : std_logic := '1'; 
	-- Outputs
	signal data_rdy_o : std_logic;
	signal data_o : std_logic_vector(DATA_BITS-1 downto 0);

	-- Function to send an SPI frame
	procedure send_spi_frame(
		constant data_frame : in std_logic_vector(DATA_BITS-1 downto 0);
		signal mosi:	out std_logic;
		signal clk:		out std_logic
	) is
	begin
		for i in DATA_BITS-1 downto 0 loop
			clk <= '0';
			mosi <= data_frame(i);
			wait for CLK_PERIOD/2;
			clk <= '1';
			wait for CLK_PERIOD/2;
		end loop;
		clk <= '0';
		mosi <= '0';
	end procedure; 
	
begin
	-- Instantiation of Unit Under Test
	uut : recep_spi
		generic map (
			DATA_BITS => DATA_BITS
		)
		port map (
			clk_i => clk_i,
			reset_n_i => reset_n_i,
			mosi_i => mosi_i,
			cs_i => cs_i,
			data_o => data_o,
			data_rdy_o => data_rdy_o
		);
		
	-- Clock process
	--spi_clk_process: process
	--begin
		--clk_i <= '0';
        --wait until cs_i = '0';
        --while cs_i = '0' loop
            --clk_i <= '0';
            --wait for CLK_PERIOD/2;
            --clk_i <= '1';
            --wait for CLK_PERIOD/2;
        --end loop;
        --clk_i <= '0';
	--end process;

	-- Stimulus process
	stimulus_process: process
	begin
		-- Reset
		reset_n_i <= '0';
		wait for CLK_PERIOD;
		reset_n_i <= '1';
		wait for CLK_PERIOD;
		
		-- Send first frame
		cs_i <= '0';  
		wait for 2 * CLK_PERIOD;	-- Work with and without
		send_spi_frame (x"aaaaaaaa", mosi_i, clk_i);
		cs_i <= '1';
		wait for 10 * CLK_PERIOD;
		
		-- Send 2nd & 3rd frame in burst mode, 10 CLK_PERIOD in between
		cs_i <= '0';  
		send_spi_frame (x"55555555", mosi_i, clk_i);
		wait for 10 * CLK_PERIOD;
		send_spi_frame (x"cccccccc", mosi_i, clk_i);
		cs_i <= '1';
		
		wait;
	end process;
end Behavioral;
