


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.my_lib.all;


entity fifoed_usart is
    generic (
        clk_freq            : integer := 50000000;
        default_baud_rate   : integer := 115200;
        flow_control        : boolean := false; -- Not implemented
        word_width          : integer := 8; -- Valid values are 7, 8, 9
        parity              : boolean := false;
        parity_even         : boolean := false;
        stop_bits           : integer := 1;
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
        readdata            : out   std_logic_vector(31 downto 0) := (others => '0');
        writedata           : in    std_logic_vector(31 downto 0);
        irq                 : out   std_logic  := '0';

        -- UART interface
        tx                  : out   std_logic := '1';
        rx                  : in    std_logic;
        cts_n               : in    std_logic;
        rts_n               : out   std_logic := '1'
    );
end entity;


architecture behavioural of fifoed_usart is

    constant tx_fifo_depth_widthu   : unsigned(f_log2(tx_fifo_depth) downto 0) 
                                        := to_unsigned(f_log2(tx_fifo_depth), 
                                        f_log2(tx_fifo_depth));

    constant rx_fifo_depth_widthu   : unsigned(f_log2(rx_fifo_depth) downto 0) 
                                        := to_unsigned(f_log2(rx_fifo_depth), 
                                        f_log2(rx_fifo_depth));

    constant bit_count_target       : unsigned(f_log2(word_width) downto 0) 
                                        := to_unsigned(word_width, f_log2(word_width));

    signal rx_almost_empty          : std_logic := '0';
    signal rx_almost_full           : std_logic := '0';
    signal rx_received              : std_logic_vector(word_width-1 downto 0) 
                                        := (others => '0');
    signal rx_empty                 : std_logic := '0';
    signal rx_full                  : std_logic := '0';
    signal rx_out                   : std_logic_vector(word_width-1 downto 0)
                                        := (others => '0');
    signal rx_rdreq                 : std_logic := '0';
    signal rx_sclr                  : std_logic := '0';
    signal rx_usedw                 : std_logic_vector(to_integer(
                                        rx_fifo_depth_widthu)-1 downto 0) 
                                        := (others => '0');
    signal rx_wrreq                 : std_logic := '0';

    signal tx_almost_empty          : std_logic := '0';
    signal tx_almost_full           : std_logic := '0';
    signal tx_received              : std_logic_vector(word_width-1 downto 0) 
                                            := (others => '0');
    signal tx_empty                 : std_logic := '0';
    signal tx_full                  : std_logic := '0';
    signal tx_out                   : std_logic_vector(word_width-1 downto 0) 
                                            := (others => '0');
    signal tx_rdreq                 : std_logic := '0';
    signal tx_sclr                  : std_logic := '0';
    signal tx_usedw                 : std_logic_vector(to_integer(
                                        tx_fifo_depth_widthu)-1 downto 0) 
                                        := (others => '0');
    signal tx_wrreq                 : std_logic := '0';

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

begin

    tx_fifo :  scfifo
        generic map(
            almost_empty_value      =>  8,
            almost_full_value       => tx_fifo_depth - 8,
            intended_device_family  => "Cyclone V",
            lpm_numwords            => tx_fifo_depth,
            lpm_showahead           => "on",
            lpm_width               => word_width,
            lpm_widthu              => to_integer(tx_fifo_depth_widthu),
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
            rx_rdreq <= '0';
            tx_wrreq <= '0';
            if (read_n = '0') then
                case (to_integer(unsigned(address))) is
                    when 0 =>
                        -- RX Data Reg
                        readdata <= rx_out;
                    when 1 =>
                        -- TX Data Reg
                        tx_received <= writedata;
                        tx_wrreq <= '1';
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

end architecture;



