-- 
-- I2C Testbench
-- 
-- 
-- 


library ieee;
use ieee.std_logic_1164.all;


entity i2c_test is 
end entity i2c_test;

architecture i2c_test of i2c_test is

component i2c is
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
        ack             : out       std_logic;
        data_in         : in        std_logic_vector(7 downto 0);
        data_out        : out       std_logic_vector(7 downto 0);
                
        sda             : inout std_logic;
        scl             : inout std_logic
    );
end component;

signal clk              : std_logic := '0';
        
signal high_speed       : std_logic;
signal receive          : std_logic;
signal start_bit        : std_logic;
signal stop_bit         : std_logic;
signal enable           : std_logic;
signal ack              : std_logic;
signal data_in          : std_logic_vector(7 downto 0);
signal data_out         : std_logic_vector(7 downto 0);
                
signal sda              : std_logic := 'Z';
signal scl              : std_logic := 'Z';


signal ticks            : integer := 0;
signal slow_ticks       : integer := 0;
begin

    inst1 : i2c 
        generic map (
            clk_freq    => 20_000_000 
        )
        port map (
            clk => clk,
            high_speed => high_speed,
            receive => receive,
            start_bit => start_bit,
            stop_bit => stop_bit,
            enable => enable,
            ack => ack,
            data_in => data_in,
            data_out => data_out,
            sda => sda,
            scl => scl
        );

    scl <= 'H';
    sda <= 'H';

    clk_gen : process
    begin
        wait for 25 ns;
        clk <= not clk;
    end process clk_gen;
    
    process (clk)
    begin
        if (rising_edge(clk)) then
            ticks <= ticks + 1;
        end if;
    end process;

    process (clk)
        variable prev_sample : std_logic := '0';
    begin
        if (rising_edge(clk)) then
            if (scl <= '1' and prev_sample /= scl) then
                slow_ticks <= slow_ticks + 1;
            end if;
            prev_sample := scl;
        end if;
    end process;
    
    process (clk)
    begin
        
        case (ticks) is
            when 0 =>
--                data <= X"AA";
                high_speed <= '1';
                start_bit <= '1';
                stop_bit <= '1';
                receive <= '1';
                enable <='1';
            when others =>
                enable <= '0';
        end case;
    end process;

    process (clK)
    begin
        case (slow_ticks) is
            when 0 =>
            when 2 => 
                sda <= '1';
            when 3 => 
                sda <= '0';
            when 4 => 
                sda <= '1';
            when 5 => 
                sda <= '0';
            when 6 => 
                sda <= '1';
            when 7 => 
                sda <= '0';
            when 8 =>
                sda <= '1';
            when 9 =>
                sda <= '0';
            when others =>
                scl <= 'H';
                sda <= 'H';

        end case;
    end process;

        
end architecture i2c_test;









