----------------------------------------------------------------------------------
-- Author:          Jules CONTADIN 
-- 
-- Create Date:     07.05.2024 13:49:00
-- Module Name:     recep_spi - Behavioral
-- Target Devices:  MachXO3LF-9400C
-- Description: 
--      Receive a SPI mode 0 databus (MSB first) and store it into an output register.
--	(Update 17/07/2024) : Data bus is DATA_BITS long (modifiable).
--
-- Exemple : It takes 35ms to send a 32 bits databus and store it.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity recep_spi is
    generic(	
	    constant DATA_BITS  : integer := 32
        );
    port (
        clk_i : in std_logic;
        reset_n_i : in std_logic;
        mosi_i : in std_logic;
        cs_i : in std_logic;
        data_o : out std_logic_vector(DATA_BITS-1 downto 0);
        data_ready_o : out std_logic
    );
end recep_spi;

architecture Behavioral of recep_spi is
-- Signaux
    type state_type is (IDLE, RECEIVE, READY);
    signal state       : state_type := IDLE;
    signal bit_count   : integer := 0;
    signal sig_data    : STD_LOGIC_VECTOR(DATA_BITS-1 downto 0) := (others => '0');
begin
-- Process reception MOSI & stockage data_in
process(clk_i, reset_n_i)
    begin
        if reset_n_i = '0' then
            state <= IDLE;
            sig_data <= (others => '0');
            data_ready_o <= '0';
            bit_count <= 0;
        elsif rising_edge(clk_i) then
            case state is
                when IDLE =>
                    data_ready_o <= '0';
                    bit_count <= 0;
                    sig_data <= (others => '0');
                    if cs_i = '0' then
                        state <= RECEIVE;
                        sig_data <= sig_data(DATA_BITS-2 downto 0) & mosi_i;
                    end if;

                when RECEIVE =>
                    if cs_i = '1' then
                        state <= IDLE;
                   elsif bit_count < DATA_BITS-2 then -- Data bits
                        sig_data <= sig_data(DATA_BITS-2 downto 0) & mosi_i;
                        bit_count <= bit_count + 1;
                    else -- Last data bit 
                        sig_data <= sig_data(DATA_BITS-2 downto 0) & mosi_i;
                        --bit_count <= bit_count + 1; -- If debugging (more understandable)   
                        state <= READY;
                    end if;
                    
                when READY =>
                    data_o <= sig_data;
                    data_ready_o <= '1';
                    state <= IDLE;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;          
end Behavioral;
