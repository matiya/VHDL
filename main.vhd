----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:14:26 11/23/2013 
-- Design Name: 
-- Module Name:    main - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
    Port ( 
				RESET 		: in  STD_LOGIC;
           SEL 					: in  STD_LOGIC_VECTOR (1 downto 0) := "00";
           CLK 					: in  STD_LOGIC;
           D_OUT 			: out  STD_LOGIC_VECTOR (7 downto 0) := "00000000"
			  );
end main;

architecture Behavioral of main is

type state_type is (SHIFT, COUNTER, RUNNING, IDLE);

signal NSTATE, PSTATE : state_type; --next_state, present_state
signal hVecOutRunning : std_logic_vector(7 downto 0) := "00000000"; --intermediate signal
signal hVecOutTemp : unsigned(7 downto 0):="00000000" ;  --don't use both
signal count : std_logic_vector(14 downto 0) := "00000000"; --counter for freq divider
signal CLK_DIV : STD_LOGIC;
signal temp: STD_LOGIC;

begin
	--TODO: when the state changes, the hVecOut should reset to 0
	sync_proc : process(RESET, CLK, NSTATE)
	begin 
		if(RESET = '1') then PSTATE <= IDLE; --reset to "00000000"
		elsif(rising_edge(CLK)) then PSTATE <= NSTATE; --switch states
		end if;
	end process sync_proc;
	
	switch: process(PSTATE, SEL)
	--switches between states
	--this ain't necesarry since "11" will land in counter no matter what
	begin
		case PSTATE is
		  when IDLE =>
			  if(SEL = "01") then NSTATE <= RUNNING;
			  elsif(SEL = "11") then NSTATE <= COUNTER;
			  elsif(SEL = "10") then NSTATE <= SHIFT;
			  else NSTATE <= IDLE;
			  end if;
			when RUNNING =>
			  if(SEL = "00") then NSTATE <= IDLE;
			  elsif(SEL = "11") then NSTATE <= COUNTER;
			  elsif(SEL = "10") then NSTATE <= SHIFT;
			  else NSTATE <= RUNNING;
			  end if;
			when SHIFT =>
			  if(SEL = "01") then NSTATE <= RUNNING;
			  elsif(SEL = "11") then NSTATE <= COUNTER;
			  elsif(SEL = "00") then NSTATE <= IDLE;
			  else NSTATE <= SHIFT;
			  end if;
			when COUNTER =>
			  if(SEL = "01") then NSTATE <= RUNNING;
			  elsif(SEL = "00") then NSTATE <= IDLE;
			  elsif(SEL = "10") then NSTATE <= SHIFT;
			  else NSTATE <= COUNTER;
			  end if;
			when others=>  --shouldn't happen
				hVecOutRunning <= "11111111";
				D_OUT <= hVecOutRunning;
		end case;
	end process switch;
	
	running_state : process(CLK)
	begin
		--D_OUT <= "00000000"; --pre-assign
		if( rising_edge(CLK) and PSTATE = RUNNING)  then  
			  hVecOutRunning <= hVecOutRunning + "00000001";
			  D_OUT <= hVecOutRunning;
		end if;
	end process running_state;
	
	idle_state : process(CLK)
	begin
		if( rising_edge(CLK) and PSTATE = IDLE)  then 
			hVecOutRunning  <= "00000000";
			D_OUT <= hVecOutRunning;
		end if;
	end process idle_state;

    frequency_divider: process (CLK) 
	 begin
        if (RESET = '1') then
            temp <= '0';
            count <= "000000000000000";
        elsif( rising_edge(CLK) ) then
            if (count = 24999) then
                temp <= NOT(temp);
                count <= "000000000000000";
            else
                count <= count + 1;
            end if;
        end if;
    end process frequency_divider;

CLK_DIV <= temp;
--D_OUT <= V
end Behavioral;

