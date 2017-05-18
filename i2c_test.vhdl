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
		clk_freq			: integer := 50_000_000
	);
	port(
		clk				: in 		std_logic;
		
		high_speed		: in 		std_logic;
		receive			: in 		std_logic;
		start_bit		: in		std_logic;
		stop_bit			: in 		std_logic;
		enable			: in		std_logic;
		ack				: out		std_logic;
		data				: inout 	std_logic_vector(7 downto 0);
				
		sda				: inout	std_logic;
		scl				: inout	std_logic
	);
end component;

signal clk				: std_logic := '0';
		
signal high_speed		: std_logic;
signal receive			: std_logic;
signal start_bit		: std_logic;
signal stop_bit		: std_logic;
signal enable			: std_logic;
signal ack				: std_logic;
signal data				: std_logic_vector(7 downto 0);
				
signal sda				: std_logic := 'Z';
signal scl				: std_logic := 'Z';


signal ticks			: integer := 0;
signal slow_ticks 	: integer := 0;
begin

	inst1 : i2c 
		generic map (
			clk_freq	=> 50_000_000 
		)
		port map (
			clk => clk,
			high_speed => high_speed,
			receive => receive,
			start_bit => start_bit,
			stop_bit => stop_bit,
			enable => enable,
			ack => ack,
			data => data,
			sda => sda,
			scl => scl
		);
	
	clk_gen : process
	begin
		wait for 10 ns;
		clk <= not clk;
	end process clk_gen;
	
	process (clk)
	begin
		if (rising_edge(clk)) then
			ticks <= ticks + 1;
		end if;
	end process;
	
	process (clk)
	begin
		
		case (ticks) is
			when 0 =>
				receive <= '0';
				high_speed <= '1';
				start_bit <= '1';
				stop_bit <= '1';
				data <= X"AA";
				enable <='1';
			when others =>
				enable <= '0';
		end case;
		
	end process;
		
end architecture i2c_test;









