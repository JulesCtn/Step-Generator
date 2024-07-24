----------------------------------------------------------------------------------
-- Author:          Jules CONTADIN 
-- 
-- Create Date:     07.05.2024 13:49:00
-- Module Name:     recep_spi - Behavioral
-- Target Devices:  MachXO3LF-9400C
-- Description: 
--      Receive an SPI mode 0 (CPHA=0, CPOL =0) data bus (MSB first) and store it in an output register.
--	(Update 17/07/2024) : Data bus lenght is DATA_BITS(modifiable).
--	(UPdate 24/07/2024) : The module can now receive actual SPI frame (if either clock is low or cs is high, not receiving)
--
-- Example : With a 12MHz clock, it takes 2.78 µs to send a 32-bit data bus and store it.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity recep_spi is
    generic(	
	    constant DATA_BITS  : integer := 32
        );
    port (
        clk_i:		in std_logic;
        reset_n_i:	in std_logic;
        mosi_i: 	in std_logic;
        cs_i: 		in std_logic;
        data_o: 	out std_logic_vector(DATA_BITS-1 downto 0)
    );
end recep_spi;

architecture Behavioral of recep_spi is
begin
	-- Process reception MOSI & stockage data_in
recep_proc : process(clk_i, reset_n_i)
	-- Variables
    variable bit_count:		integer := 0;
    variable var_data:		std_logic_vector(DATA_BITS-1 downto 0) := (others => '0');
	-- Architecture
    begin
        if reset_n_i = '0' then
            var_data := (others => '0');
			bit_count := 0;
		else
			if cs_i = '1' then
				bit_count := 0;
				var_data := (others => '0');
			else
				if rising_edge(clk_i)then
					var_data := var_data(DATA_BITS-2 downto 0) & mosi_i;	-- Shift MOSI in register (for MSB first)
					if bit_count = DATA_BITS-1 then -- Last frame bit
						bit_count := 0;
						data_o <= var_data; 
					else	-- All frame bit
						bit_count := bit_count + 1;
					end if;
				end if;
			end if;
		end if;
    end process;          
end Behavioral;
