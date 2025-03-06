----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.03.2025 10:03:44
-- Design Name: 
-- Module Name: SYNTH_100MHz_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity exemple_tb is
end exemple_tb;

architecture Behavioral of exemple_tb is
    -- Component UUT
    component exemple is
    Port (
      clk_i:		in std_logic;
		  reset_n_i:		in std_logic;
		  reg_o:			out std_logic_vector(DATA_BITS - 1 downto 0);
    );
    end component;
    
	-- Clock period definitions
	constant CLK_I_PERIOD:	time := 10 ns;
	-- Inputs
	signal clk_i:          std_logic := '0';
	signal reset_n_i:      std_logic := '1';
	-- Outputs
	signal reg_o:      std_logic_vector(DATA_BITS - 1 downto 0);
begin
    -- Unit Under Test
	uut : exemple
		port map (
			clk_i => clk_i,
			reset_n_i => reset_n_i,
			reg_o => reg_o
		);
		
	-- Internal clock process
	input_clk_process: process
	begin
		i_Clk <= '0';
		wait for I_CLK_PERIOD / 2;
		i_Clk <= '1';
		wait for I_CLK_PERIOD / 2;
	end process;
	
	-- Stimulus process
	stimulus_process: process
	begin
		-- Reset & init variable
		i_Rst_L <= '0';
		wait for 2 * I_CLK_PERIOD;
		i_Rst_L <= '1';
		
		wait;
	end process;
end Behavioral;
