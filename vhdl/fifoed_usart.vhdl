



use ieee;
library ieee.std_logic_1164.all;
library ieee.numeric_std.all;


entity fifoed_usart is
    generic (
        clk_freq            : integer := 50000000;
        baud_rate           : integer := 115200;
        flow_control        : boolean := false;
        word_length         : integer := 8; -- Valid values are 7, 8, 9
        parity              : boolean := false;
        parity_even         : boolean := false;
        tx_fifo_depth       : integer := 64;
        rx_fifo_depth       : integer := 64
    );
    port (
        clk                 : in    std_logic;
        
        -- Avalon MM
        rst_n               : in    std_logic;
        chipselect_n        : in    std_logic;
        write_n             : in    std_logic;
        read_n              : in    std_logic;
        address             : in    std_logic_vector(7 downto 0);
        readdata            : out   std_logic_vector(31 downto 0);
        writedata           : in    std_logic_vector(31 downto 0);
        
        -- UART interface
        tx                  : out   std_logic;
        rx                  : in    std_logic;
        cts_n               : in    std_logic;
        rts_n               : out   std_logic
    );
end entity;


architecture behavioural of fifed_usart is
        
begin
    
    mm : process (clk)
        
    begin
        if (rising_edge(clk)) then
        end if;
    end process;

end architecture;



