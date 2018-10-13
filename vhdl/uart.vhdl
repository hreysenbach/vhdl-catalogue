

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.my_lib.all;

entity uart is
    generic(
        clk_freq    : integer := 50000000;
        word_width  : integer := 8;
        parity      : boolean := false;
        parity_even : boolean := false;
        stop_bits   : integer := 1
    );
    port (
        clk         : in    std_logic;

        -- Baud rate divisor
        clk_target  : in    unsigned(31 downto 0) := (others => '0');

        -- Transmit data and handshake
        tx_data     : in    std_logic_vector(word_width-1 downto 0);
        tx_idle     : out   std_logic := '1';
        tx_start    : in    std_logic := '0';

        -- Receive data and handshake
        rx_data     : out   std_logic_vector(word_width-1 downto 0);
        rx_new_word : out   std_logic := '0';

        -- UART Outputs
        tx          : out   std_logic := '1';
        rx          : in    std_logic
    );
end entity;

architecture behavioural of uart is 

    type tx_state_t is (tx_idle_s, tx_start_s, tx_data_s, tx_parity_s, tx_stop_s);
    type rx_state_t is (rx_idle_s, rx_start_s, rx_data_s, rx_parity_s, rx_stop_s);

    signal tx_state                 : tx_state_t := tx_idle_s;
    signal rx_state                 : rx_state_t := rx_idle_s;

begin

    transmit : process (clk)
        variable tx_count           : unsigned(23 downto 0) 
                                        := (others => '0');
        variable tx_bit_count       : unsigned(f_log2(word_width) downto 0) 
                                        := (others => '0');
        variable tx_word            : std_logic_vector(word_width-1 downto 0)
                                        := (others => '0');
        variable parity_bit         : std_logic := '0';
        variable tx_stop_count      : unsigned(1 downto 0) := (others => '0');
    begin
        if (rising_edge(clk)) then
            tx <= '1';
            tx_idle <= '0';
            case (tx_state) is
                when tx_idle_s =>
                    tx_idle <= '1';
                    if (tx_start = '1') then
                        tx_word := tx_data;
                        tx_idle <= '0';
                        tx_state <= tx_start_s;
                    end if;
                when tx_start_s =>
                    tx <= '0';
                    if (tx_count < clk_target) then
                        tx_count := tx_count + 1;
                    else
                        tx_count := X"000000";
                        tx_state <= tx_data_s;
                        tx_bit_count := (others => '0');
                        if (parity = true) then
                            if (parity_even = true) then
                                parity_bit := '0';
                            else
                                parity_bit := '1';
                            end if;
                        end if;
                    end if;
                when tx_data_s =>
                    tx <= tx_word(to_integer(tx_bit_count));
                    if (tx_count < clk_target) then
                        tx_count := tx_count + 1;
                    else
                        tx_count := X"000000";

                        if (parity = true) then
                            parity_bit := parity_bit xor tx_word(to_integer(tx_bit_count));
                        end if;

                        if (tx_bit_count < word_width - 1) then
                            tx_bit_count := tx_bit_count + 1;
                        else
                            tx_bit_count := (others => '0');
                            if (parity = true) then
                                tx_state <= tx_parity_s;
                            else
                                tx_state <= tx_stop_s;
                            end if;
                        end if;
                    end if;
                when tx_parity_s =>
                    tx <= parity_bit;
                    if (tx_count < clk_target) then
                        tx_count := tx_count + 1;
                    else 
                        tx_count := X"000000";

                        tx_state <= tx_stop_s;
                    end if;
                when tx_stop_s =>
                    tx <= '1';
                    if (tx_count < clk_target) then
                        tx_count := tx_count + 1;
                    else
                        tx_count := X"000000";

                        if (tx_stop_count < stop_bits) then
                            tx_stop_count := tx_stop_count + 1;
                        else 
                            tx_state <= tx_idle_s;
                            tx_stop_count := (others => '0');
                        end if;
                    end if;

            end case; -- tx_state
        end if;
    end process;

    receive : process (clk)

    begin
        if (rising_edge(clk)) then
            
        end if;
    end process;

end architecture;