


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity fifoed_usart is
    generic (
        clk_freq            : integer := 50000000;
        baud_rate           : integer := 115200;
        flow_control        : boolean := false;
        word_width          : integer := 8; -- Valid values are 7, 8, 9
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
        irq                 : out   std_logic;
        
        -- UART interface
        tx                  : out   std_logic;
        rx                  : in    std_logic;
        cts_n               : in    std_logic;
        rts_n               : out   std_logic
    );
end entity;


architecture behavioural of fifoed_usart is

    function f_log2 (x : positive) return natural is
        variable i : natural;
    begin
        i := 0;

        while (2**i < x) and i < 31 loop
            i := i + 1;
        end loop;

        return i;
    end function;
    
    constant tx_fifo_depth_widthu : natural := f_log2(tx_fifo_depth);
    constant rx_fifo_depth_widthu : natural := f_log2(rx_fifo_depth);

    component scfifo
        generic (
            almost_empty_value      : natural;
            almost_full_value       : natural;
            intended_device_family  : string;
            lpm_numwords            : natural;
            lpm_showahead           : string;
            lpm_width               : natural;
            lpm_widthu              : natural;
            overflow_checking       : string;
            underflow_checking      : string;
            use_eab                 : string;
            lpm_type                : string
        );
        port (
            almost_empty            : out   std_logic;
            almost_full             : out   std_logic;
            clock                   : in    std_logic;
            data                    : in    std_logic_vector(lpm_width-1 downto 0);
            empty                   : out   std_logic;
            full                    : out   std_logic;
            q                       : out   std_logic_vector(lpm_width-1 downto 0);
            rdreq                   : in    std_logic;
            sclr                    : in    std_logic;
            usedw                   : out   std_logic_vector(lpm_widthu-1 downto 0);
            wrreq                   : in    std_logic
        );
    end component;

    signal rx_almost_empty          : std_logic;
    signal rx_almost_full           : std_logic;
    signal rx_received              : std_logic_vector(word_width-1 downto 0);
    signal rx_empty                 : std_logic;
    signal rx_full                  : std_logic;
    signal rx_out                   : std_logic_vector(word_width-1 downto 0);
    signal rx_rdreq                 : std_logic;
    signal rx_sclr                  : std_logic;
    signal rx_usedw                 : std_logic_vector(tx_fifo_depth_widthu-1 downto 0);
    signal rx_wrreq                 : std_logic;

    signal tx_almost_empty          : std_logic;
    signal tx_almost_full           : std_logic;
    signal tx_received              : std_logic_vector(word_width-1 downto 0);
    signal tx_empty                 : std_logic;
    signal tx_full                  : std_logic;
    signal tx_out                   : std_logic_vector(word_width-1 downto 0);
    signal tx_rdreq                 : std_logic;
    signal tx_sclr                  : std_logic;
    signal tx_usedw                 : std_logic_vector(tx_fifo_depth_widthu-1 downto 0);
    signal tx_wrreq                 : std_logic;
 
begin
    
    tx_fifo :  scfifo
        generic map(
            almost_empty_value      =>  8,
            almost_full_value       => tx_fifo_depth - 8,
            intended_device_family  => "Cyclone V",
            lpm_numwords            => tx_fifo_depth,
            lpm_showahead           => "on",
            lpm_width               => word_width,
            lpm_widthu              => tx_fifo_depth_widthu,
            overflow_checking       => "on",
            underflow_checking      => "on",
            use_eab                 => "on",
            lpm_type                => "SCFIFO"
        )
        port map(
            almost_empty            => tx_almost_empty,
            almost_full             => tx_almost_full,
            clock                   => clk,
            data                    => tx_received,
            empty                   => tx_empty,
            full                    => tx_full,
            q                       => tx_out,
            rdreq                   => tx_rdreq,
            sclr                    => tx_sclr,
            usedw                   => tx_usedw,
            wrreq                   => tx_wrreq
        );

    mm : process (clk)
        
    begin
        if (rising_edge(clk)) then
            if (read_n = '0') then
                case (to_integer(unsigned(address))) is 
                    when 0 =>
                        -- RX Data Reg
                        readdata <= rx_out;
                    when 1 =>
                        -- TX Data Reg
                    when 2 =>
                        -- Status Reg
                    when 3 =>
                        -- Control Reg
                    when 4 =>
                        -- Divisor Reg
                    when 5 =>
                        -- EOP Reg
                    when others =>
                        -- No Reg
                        readdata <= (others => '0');
                end case;
            end if;
        end if;
    end process;

    transmit : process (clk)
        
    begin
        if (rising_edge(clk)) then
            
        end if;
    end process;

    receive : process (clk)
        
    begin 
        if (rising_edge(clk)) then
            
        end if;
    end process;

end architecture;



