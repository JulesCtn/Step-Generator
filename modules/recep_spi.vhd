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
        data_o: 	out std_logic_vector(DATA_BITS-1 downto 0);
        data_rdy_o:	out std_logic
    );
end recep_spi;

architecture Behavioral of recep_spi is
	-- Signaux
    --type state_type is (IDLE, RECEIVE, READY);
    --signal state:			state_type := IDLE;
    signal sig_count:		integer := 0;
    signal sig_data:		std_logic_vector(DATA_BITS-1 downto 0) := (others => '0');
begin
	-- Process reception MOSI & stockage data_in
recep_proc : process(clk_i, reset_n_i)
	--variable state:			state_type := IDLE;
    variable bit_count:		integer := 0;
    variable var_data:		std_logic_vector(DATA_BITS-1 downto 0) := (others => '0');
    begin
        if reset_n_i = '0' then
            --state := IDLE;
            var_data := (others => '0');
			bit_count := 0;
			data_rdy_o <= '0';
		else
			if cs_i = '1' then
				bit_count := 0;
				var_data := (others => '0');
				data_rdy_o <= '0';		-- Remove if doesn't work for 1 clock cycle on main
			else
				if bit_count = 0 then
					data_rdy_o <= '0';	-- Remove if doesn't work for 1 clock cycle on main
				end if;
				if rising_edge(clk_i)then
					var_data := var_data(DATA_BITS-2 downto 0) & mosi_i;	-- Shift MOSI in register (for MSB first)
					if bit_count = DATA_BITS-1 then -- Last frame bit
						bit_count := 0;
						data_o <= var_data; 
						data_rdy_o <= '1';	
					else	-- All frame bit
						bit_count := bit_count + 1;
					end if;
				end if;
			end if;
		end if;
		sig_count <= bit_count;
		sig_data <= var_data;
    end process;          
end Behavioral;

			--case state is
				--when IDLE =>
					--data_rdy_o <= '0';
					--bit_count := 0;
					--var_data := (others => '0');
					--if cs_i = '0' and rising_edge(clk_i)then
						--state := RECEIVE;
						--var_data := var_data(DATA_BITS-2 downto 0) & mosi_i;
					--end if;

				--when RECEIVE =>
					--if cs_i = '1' then
						--state := IDLE;
					--elsif rising_edge(clk_i) then
						--if bit_count = DATA_BITS-1 then -- Last bit
							--data_o <= var_data; 
							--data_rdy_o <= '1';
							--state := IDLE;
						--else
							--var_data := var_data(DATA_BITS-2 downto 0) & mosi_i;
							--bit_count := bit_count + 1;
						--end if;
					--end if;
					
				--when others =>
					--state := IDLE;
			--end case;
					
