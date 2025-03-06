----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.03.2025 14:30:00
-- Design Name: 
-- Module Name: exemple - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity exemple is
--  generic(
--	  constant X:		integer := 32
--  );
    Port(
		  clk_i:		in std_logic;
		  reset_n_i:		in std_logic;
		  reg_o:			out std_logic_vector(DATA_BITS - 1 downto 0);
    );
end exemple;

architecture Behavioral of exemple is
-- Constants
-- Signals
begin
-- Processes
	exemple_proc : process(clk_i)
	begin
		if rising_edge(clk_i) then
			if reset_n_i = '0' then
		     reg_o <= (others => '0');	
			else
				
			end if;
		end if;
	end process;
end Behavioral;
