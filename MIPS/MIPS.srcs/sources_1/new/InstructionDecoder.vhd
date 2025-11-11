----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/02/2025 10:19:55 AM
-- Design Name: 
-- Module Name: InstructionDecoder - Behavioral
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
use IEEE.std_logic_unsigned.all; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity InstructionDecoder is
    Port (regWrite: in std_logic;
          instruction: in std_logic_vector(25 downto 0);
          regDst: in std_logic;
          enable: in std_logic;
          extOp: in std_logic;
          writeData: in std_logic_vector(31 downto 0);
          clk: in std_logic;
          
          readData1: out std_logic_vector(31 downto 0);
          readData2: out std_logic_vector(31 downto 0);
          extImm: out std_logic_vector(31 downto 0);
          func: out std_logic_vector( 5 downto 0);
          sa: out std_logic_vector(4 downto 0));
end InstructionDecoder;

architecture Behavioral of InstructionDecoder is
    type regmem is array(0 to 31) of std_logic_vector(31 downto 0);
    
    signal registerMemory: regmem := (others => X"00000000");
    signal regWriteAddress: std_logic_vector(4 downto 0) := (others => '0');
    
begin

   regWriteAddress <= instruction(15 downto 11) when regDST = '1' else instruction(20 downto 16);
   
    --register file
    process(clk)
    begin
        if rising_edge(clk) then
            if regWrite = '1' and enable = '1' then
                registerMemory(conv_integer(regWriteAddress)) <= writeData;
            end if;
        end if;    
    end process;
    
    readData1 <= registerMemory(conv_integer(instruction(25 downto 21)));
    readData2 <= registerMemory(conv_integer(instruction(20 downto 16)));
    
    extImm(15 downto 0) <= instruction(15 downto 0);
    extImm(31 downto 16) <= (others => instruction(15)) when extOp = '1' else (others => '0');
    
    func <= instruction(5 downto 0);
    sa <= instruction(10 downto 6);
    
end Behavioral;
