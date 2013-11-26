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
signal hVecOutTemp : unsigned(7 downto 0):="00000001" ;  --don't use both
signal count : std_logic_vector(14 downto 0) := "000000000000000"; --counter for freq divider
signal CLK_DIV : STD_LOGIC := '0'; --new clock @ 1Hz
signal temp: STD_LOGIC  := '0'; --temp var used in freq_div
signal shift_cnt  : integer range 0 to 14 := 0;  -- counter
signal boolVar : std_logic := '0'; --control wether shift or runnign go up or down

begin
	--TODO: when the state changes, the hVecOut should reset to 0
	sync_proc : process(RESET, CLK_DIV, NSTATE)
	begin 
		if(RESET = '1') then PSTATE <= IDLE; --reset to "00000000"
		elsif(rising_edge(CLK_DIV)) then PSTATE <= NSTATE; --switch states
			--if(pstate \= nstate)
					--reset vectors and coutners;
					--end if;
		end if;
	end process sync_proc;
	
	switch: process(PSTATE, SEL, CLK_DIV)
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
			  if(boolVar = '0') then --run ascending					
					if (shift_cnt < 7) then
						for i in 0 to 6 loop hVecOutTemp(i+1) <= hVecOutTemp(i); end loop; --shift register to the left
						shift_cnt <= shift_cnt + 1;
					else
						boolVar <= not(boolVar);
						--shift_cnt <= 0;
					end if;						
         else													--run descending
					if (shift_cnt > 0) then
						hVecOutTemp(shift_cnt) <= '0'; --s
						shift_cnt <= shift_cnt -1;
					else
						boolVar <= not(boolVar);
						--shift_cnt <= 0;
					end if;
			  end if;
			  
			  D_OUT <= std_logic_vector(hVecOutTemp);
			  end if;
			  
			when SHIFT =>
			  if(SEL = "01") then NSTATE <= RUNNING;
			  elsif(SEL = "11") then NSTATE <= COUNTER;
			  elsif(SEL = "00") then NSTATE <= IDLE;
			  else NSTATE <= SHIFT;
			   if (shift_cnt < 6) then
					for i in 0 to 6 loop 
						--hVecOutTemp(i+1) <= hVecOutTemp(i); 
						--hVecOutTemp(i) <= '0'; 
						if(hVecOutTemp(i+1) /= hVecOutTemp(i)) then
							hVecOutTemp(i+1) <= hVecOutTemp(i);
							hVecOutTemp(i) <= '0'; 
						end if;
					end loop; --shifting register
					
					shift_cnt <= shift_cnt + 1;
         else
               shift_cnt <= 0;
         end if;
			  --hVecOutTemp <= shift_left(hVecOutTemp);
			  D_OUT <= std_logic_vector(hVecOutTemp);
			  end if;
			  
			when COUNTER =>
			  if(SEL = "01") then NSTATE <= RUNNING;
			  elsif(SEL = "00") then NSTATE <= IDLE;
			  elsif(SEL = "10") then NSTATE <= SHIFT;
			  else NSTATE <= COUNTER;
			  hVecOutRunning <= hVecOutRunning + 1;
			  D_OUT <= hVecOutRunning;
			  end if;
			  
			when others=>  --shouldn't happen
				hVecOutRunning <= "11111111";
				D_OUT <= hVecOutRunning;
		end case;
	end process switch;
	
--	running_state : process(CLK_DIV)
--	begin
--		if( rising_edge(CLK_DIV) and PSTATE = RUNNING)  then  
--			  hVecOutRunning <= hVecOutRunning + 1;
--			  --D_OUT <= hVecOutRunning;
--		end if;
--	end process running_state;
--	
--	idle_state : process(CLK_DIV)
--	begin
--		if( rising_edge(CLK_DIV) and PSTATE = IDLE)  then 
--			hVecOutRunning  <= "00000000";
--			D_OUT <= hVecOutRunning;
--		end if;
--	end process idle_state;

    frequency_divider: process (CLK, RESET) 
	 begin
        if (RESET = '1') then
            temp <= '0';
            count <= "000000000000000";
        elsif( rising_edge(CLK) ) then
            if (count = 249) then --TODO:change to 24999 when finished
                temp <= NOT(temp);
                count <= "000000000000000";
            else
                count <= count + 1;
            end if;
        end if;
    end process frequency_divider;

CLK_DIV <= temp;
--D_OUT <= hVecOutRunning;
end Behavioral;

