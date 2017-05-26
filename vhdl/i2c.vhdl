-- 
-- I2C Controller
-- 
-- 
-- 
-- 
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

LIBRARY altera_mf;
USE altera_mf.all;

entity i2c is
    generic(
        clk_freq        : integer := 50_000_000
    );
    port(
        clk             : in        std_logic;
        
        high_speed      : in        std_logic;
        receive         : in        std_logic;
        start_bit       : in        std_logic;
        stop_bit        : in        std_logic;
        enable          : in        std_logic;
        ack             : out       std_logic := '0';
        data_in         : in        std_logic_vector(7 downto 0);
        data_out        : out       std_logic_vector(7 downto 0);
                
        sda             : inout     std_logic;
        scl             : inout     std_logic
    );
end entity i2c;


architecture i2c of i2c is
constant fast_count     : integer := integer(ceil(real(clk_freq) / real(2 * 400_000))) - 1;
constant slow_count     : integer := integer(ceil(real(clk_freq) / real(2 * 100_000))) - 1;
signal target_count     : integer := fast_count; 


begin
    
    transrec : process (clk)
    type state_t is (s_transmit, s_receive, s_nop);
    
    variable state      : state_t := s_nop;
    variable sample     : integer := 0;
    variable f_start    : integer := 0;
    variable f_stop     : integer := 0;
    variable clk_count  : integer := 0;
    variable bit_count  : integer := 0;
    variable word       : std_logic_vector(7 downto 0);
    
    begin
    
    if (rising_edge(clk)) then
        if (state = s_nop) then
            if (enable = '1') then
                -- Sample control lines
                if (receive = '1') then
                    state := s_receive;
                    
                    if (start_bit = '1') then
                        f_start := 1;
                    end if;
                    if (stop_bit = '1') then
                        f_stop := 1;
                    end if;
                    
                    if (high_speed = '1') then
                        target_count <= fast_count;
                    else
                        target_count <= slow_count;
                    end if;
                    data_out <= X"00";
                    
                else
                    state := s_transmit;
                    if (start_bit = '1') then
                        f_start := 1;
                    end if;
                    if (stop_bit = '1') then
                        f_stop := 1;
                    end if;
                    
                    if (high_speed = '1') then
                        target_count <= fast_count;
                    else
                        target_count <= slow_count;
                    end if;
                    
                    word := data_in;
                end if; -- receive
            end if; -- enable
            
        elsif (state = s_transmit) then
            if (clk_count < target_count) then
                clk_count := clk_count + 1;
            else 
                clk_count := 0;
                
                if (bit_count = 0 and f_start = 1) then
                    -- start bit
                    sda <= '0';
                    scl <= 'Z';
                    bit_count := bit_count + 1;
                elsif (bit_count = 9 and f_stop = 1) then
                    -- stop bit
                    if (sample = 0) then
                        scl <= '0';
                        sda <= '0';
                        sample := 1;
                    elsif (sample = 1) then
                        scl <= 'Z';
                        sda <= '0';
                        sample := 2;
                    else 
                        scl <= 'Z';
                        sda <= 'Z';
                        bit_count := 0;
                        state := s_nop;
                        f_start := 0;
                        f_stop := 0;
                        sample := 0;
                    end if;
                    
                elsif (bit_count = 8) then
                    -- ack condition
                    if (sample = 1) then
                        scl <= 'Z';
                        ack <= not sda;
                        bit_count := bit_count + 1;
                        sample := 0;
                    else
                        scl <= '0';
                        sda <= 'Z';
                        sample := 1;
                    end if;
                else
                    if (sample = 1) then
                        scl <= 'Z';
                        bit_count := bit_count + 1;
                        sample := 0;
                    else
                        scl <= '0';
                        case (word(8 - bit_count)) is
                            when '1' => sda <= 'Z';
                            when '0' => sda <= '0';
                            when others => 
                        end case;
                        sample := 1;
                    end if;
                end if;
                
            end if; -- clk_count < target_count
            
        elsif (state = s_receive) then
            if (clk_count < target_count) then
                clk_count := clk_count + 1;
            else 
                clk_count := 0;
               
                if (bit_count = 0 and f_start = 1) then
                    -- start bit
                    sda <= '0';
                    scl <= 'Z';
                    sample := 0;
                    bit_count := bit_count + 1;
               elsif (bit_count = 10 and f_stop = 1) then
                   if (sample = 0)  then
                       scl <= '0';
                       sda <= '0';
                       sample := 1;
                   elsif (sample = 1) then
                       scl <= 'Z';
                       sda <= '0';
                       sample := 2;
                   elsif (sample = 2) then
                       scl <= 'Z';
                       sda <= 'Z';
                       bit_count := 0;
                       state := s_nop;
                       f_start := 0;
                       f_stop := 0;
                       sample := 0;
                       data_out <= word;
                   end if;
               elsif (bit_count = 9) then
                   -- ack condition
                   if (sample = 1) then
                       scl <= 'Z';
                       sda <= '0';
                       bit_count := bit_count + 1;
                       sample := 0;
                   else 
                       scl <= '0';
                       sda <= '0';
                       sample := 1;
                   end if;
               else
                   if (sample = 1) then
                       scl <= 'Z';
                       sda <= 'Z';
                       bit_count := bit_count + 1;
                       word(9 - bit_count) := sda;
                       sample := 0;
                   else
                       scl <= '0';
                       sda <= 'Z';
                       sample := 1;
                   end if;
               end if; -- bit count
            end if; -- clk_count < target_count
            
        end if; -- state
    end if; -- clk
        
        
    end process transrec;
    
end architecture i2c;




