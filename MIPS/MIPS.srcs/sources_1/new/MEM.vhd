----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/11/2025 09:40:10 AM
-- Design Name: 
-- Module Name: MEM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.std_logic_unsigned.ALL; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MEM is
    Port (MemWrite: in std_logic; 
          ALUResIn: in std_logic_vector(31 downto 0);  
          ReadData2: in std_logic_vector(31 downto 0);
          clk: in std_logic;
          Enable: in std_logic;
          
          MemData: out std_logic_vector(31 downto 0);
          ALUResOut: out std_logic_vector(31 downto 0));
end MEM;

architecture Behavioral of MEM is
    
       type typeMEM is array(0 to 63) of std_logic_vector(31 downto 0);
       signal Memory: typeMEM := (  0  => x"00000000", -- result (address 0)
                                    1  => x"00000005", -- N = 5 (address 4)
                                    2  => x"FFFFFFFD", -- -3 (address 8)
                                    3  => x"00000005", -- 5 (address 12)
                                    4  => x"00000002", -- 2 (address 16)
                                    5  => x"FFFFFFFF", -- -1 (address 20)
                                    6  => x"00000007", -- 7 (address 24)
                                    others => x"00000000" );
  
begin

    MEM:process(clk)
    begin
        if rising_edge(clk) then
            if Enable = '1' and MemWrite = '1' then
                Memory(conv_integer(ALUResIn(7 downto 2))) <= ReadData2;
            end if;
        end if;
    end process;
    
MemData <= Memory(conv_integer(ALUREsIn(7 downto 2)));

ALUResOut <= ALUResIn;

end Behavioral;
