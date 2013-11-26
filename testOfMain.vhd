--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:40:15 11/24/2013
-- Design Name:   
-- Module Name:   /home/default/workspace/LED_driver/testOfMain.vhd
-- Project Name:  LED_driver
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: main
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY testOfMain IS
END testOfMain;
 
ARCHITECTURE behavior OF testOfMain IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT main
    PORT(
         RESET : IN  std_logic;
         SEL : IN  std_logic_vector(1 downto 0);
         CLK : IN  std_logic;
         D_OUT : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal RESET : std_logic := '0';
   signal SEL : std_logic_vector(1 downto 0) := (others => '0');
   signal CLK : std_logic := '0';

 	--Outputs
   signal D_OUT : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: main PORT MAP (
          RESET => RESET,
          SEL => SEL,
          CLK => CLK,
          D_OUT => D_OUT
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 248 ns;	

      wait for CLK_period*1;

      -- insert stimulus here 
		wait until rising_edge(CLK); --apparently inputs have to be in sync
		SEL <= "10";
		wait for 3 ms;	
		SEL <= "00";
		wait for 1 ms;	

		SEL <= "01";
		wait for 3 ms;	
		SEL <= "00";
		wait for 1 ms;	
		
		SEL <= "11";
		wait for 3 ms;	
		SEL <= "00";
		wait for 1 ms;	



      wait;
   end process;

END;
