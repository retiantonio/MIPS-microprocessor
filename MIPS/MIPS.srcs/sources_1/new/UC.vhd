----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/02/2025 10:57:30 AM
-- Design Name: 
-- Module Name: UC - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UC is
    Port(instruction: in std_logic_vector(5 downto 0);
         regDst: out std_logic;
         extOp: out std_logic;
         aluSrc: out std_logic;
         branch: out std_logic;
         jump: out std_logic;
         aluOp: out std_logic_vector(2 downto 0);
         memWrite: out std_logic;
         memToReg: out std_logic;
         regWrite: out std_logic;
         jumpR: out std_logic;
         brGreater: out std_logic);
end UC;

architecture Behavioral of UC is

begin
    process(instruction)
    begin
        regDst <= '0'; extOp <= '0'; aluSrc <= '0';
        branch <= '0'; jump <= '0'; aluOp <= "000";
        memWrite <= '0'; memToReg <= '0'; regWrite <= '0';
        jumpR <= '0'; brGreater <= '0';
        
        case instruction is
                --R
             when "000000" => 
                regDst <= '1';
                regWrite <= '1';
                aluOp <= "000";
                
                --ADDI
             when "001000" => 
                extOp <= '1';
                aluSrc <= '1';
                regWrite <= '1';
                aluOp <= "001";
                
                --LW
             when "100011" => 
                extOp <= '1';
                aluSrc <= '1';
                memToReg <= '1';
                regWrite <= '1';
                aluOp <= "001";
                
                --SW   
             when "101011" => 
                extOp <= '1';
                aluSrc <= '1';
                memWrite <= '1';
                aluOp <= "001";
                 
                --BEQ
             when "000100" => 
                extOp <= '1';
                branch <= '1';
                aluOp <= "010";
  
                --BGTZ
             when "000111" => 
                extOp <= '1';
                brGreater <= '1';
                aluOp <= "010";
                
                --JUMP
             when "000010" => 
                jump <= '1';
                
                --JUMPR
             when "000011" =>
                jumpr <= '1';
                
            when others => 
                aluOp <= "000";
        end case; 
    end process;
end Behavioral;
