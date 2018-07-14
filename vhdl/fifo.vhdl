


library ieee;
use ieee.std_logic_1164.all;


entity fifo is 
    generic (
        data_width              : integer := 32;
        number_of_words         : integer := 32;
        used_width              : integer := 5;
        show_ahead              : boolean := false;
        almost_empty_threshold  : integer := 4;
        almost_full_threshold   : integer := 28
    );
    port (
        clk                     : in    std_logic;
        aclr                    : in    std_logic;
        sclr                    : in    std_logic;
        wrreq                   : in    std_logic;
        rdreq                   : in    std_logic;
        data                    : in    std_logic_vector(data_width-1 downto 0);

        q                       : out   std_logic_vector(data_width-1 downto 0);
        full                    : out   std_logic;
        almost_full             : out   std_logic;
        empty                   : out   std_logic;
        almost_empty            : out   std_logic;
        used_words              : out   std_logic_vector(used_width-1 downto 0)
    );
end entity;

architecture behavioural of fifo is
    type mem_array_t is array (0 to number_of_words-1) of std_logic_vector(data_width-1 downto 0);

    signal mem_array        : mem_array_t := (others => (others => '0'));
    signal words            : integer := 0;
begin

    process (clk, aclr) 
        variable write_ptr        : integer := 0;
        variable read_ptr         : integer := 0;
        variable looped           : boolean := false;
    begin
        if (aclr = '0') then
            mem_array <= (others => (others => '0'));
            write_ptr := 0;
            read_ptr := 0;
            words <= 0;
            looped := false;
        else
            if (rising_edge(clk)) then
                if (sclr = '0') then
                    mem_array <= (others => (others => '0'));
                    write_ptr := 0;
                    read_ptr := 0;
                    words <= 0;
                    looped := false;
                else
                    if (wrreq = '1' and words < number_of_words) then
                        mem_array(write_ptr) <= data;
                        if (write_ptr < number_of_words - 1) then
                            write_ptr := write_ptr + 1;
                        else 
                            write_ptr := 0;
                            looped := true;
                        end if;
                        words <= words + 1;
                    end if;
                    
                    if (rdreq = '1' and words > 0) then
                        q <= mem_array(read_ptr);
                        words <= words - 1;
                        if (read_ptr < number_of_words - 1) then
                            read_ptr := read_ptr + 1;
                        else
                            read_ptr := 0;
                            looped := false;
                        end if;
                    end if;

                    if (words > almost_full_threshold) then
                        almost_full <= '1';
                    else 
                        almost_full <= '0';
                    end if; 
                    
                    if (words < almost_empty_threshold) then
                        almost_empty <= '1';
                    else 
                        almost_empty <= '0';
                    end if;

                    if (words = 0) then
                        empty <= '1';
                    else 
                        empty <= '0';
                    end if;

                    if (words = number_of_words) then
                        full <= '1';
                    else 
                        full <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;
end architecture;
