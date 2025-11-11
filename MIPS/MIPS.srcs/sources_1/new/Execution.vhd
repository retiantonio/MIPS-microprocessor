----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/11/2025 08:08:41 AM
-- Design Name: 
-- Module Name: Execution - Behavioral
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
use IEEE.numeric_std.ALL;
use IEEE.std_logic_unsigned.all; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Execution is
    Port (readData1: in std_logic_vector(31 downto 0);
          readData2: in std_logic_vector(31 downto 0);
          ALUSrc: in std_logic;
          ExtImm: in std_logic_vector(31 downto 0);
          shiftAmount: in std_logic_vector(4 downto 0);
          func: in std_logic_vector(5 downto 0);
          ALUOp: in std_logic_vector(2 downto 0);
          PCNext: in std_logic_vector(31 downto 0);
          
          GTZ: out std_logic;
          ZERO: out std_logic;
          ALURes: out std_logic_vector(31 downto 0);
          BranchAddress: out std_logic_vector(31 downto 0));
end Execution;

architecture Behavioral of Execution is

signal ALUCtrl: std_logic_vector(2 downto 0) := (others => '0');
signal C: std_logic_vector(31 downto 0) := (others => '0');
signal ZeroFlag: std_logic := '0';

signal B: std_logic_vector(31 downto 0) := (others => '0');

begin

ALUControl: process(ALUOp, func)
begin
    case ALUOp is
        when "000" =>
            case func is
                when "000000" =>  ALUCtrl <= "000"; -- +
                when "000001" => ALUCtrl <= "001"; -- -
                when "000010" => ALUCtrl <= "010"; -- shift left
                when "000011" => ALUCtrl <= "011"; -- shift right
                when "000100" => ALUCtrl <= "100"; -- and
                when "000101" => ALUCtrl <= "101"; -- or
                when "100110" => ALUCtrl <= "110"; --xor
                when others => ALUCtrl <= (others => 'X');
            end case;
            
        when "001" => ALUCtrl <= "000"; -- +
        when "010" => ALUCtrl <= "001"; -- -
        when others => ALUCtrl <= (others => 'X');
    end case;    
 end process;

ALU: process(readData1, readData2, ALUCTRL, shiftAmount)
begin
    case ALUCtrl is
        when "000" => C <= readData1 + B;
        when "001" => C <= readData1 - B;
        when "010" => C <= to_stdlogicvector(to_bitvector(readData2) sll conv_integer(shiftAmount));
        when "011" => C <= to_stdlogicvector(to_bitvector(readData2) srl conv_integer(shiftAmount)); 
        when "100" => C <= readData1 and readData2;
        when "101" => C <= readData1 or readData2; 
        when "110" => C <= readData1 xor readData2;
        when others => C <= (others => 'X');
    end case;
end process;

B <= extImm when ALUSrc = '1' else readData2;

ALURes <= C;

process(C)
begin
    if C = X"00000000" then
        ZeroFlag <= '1';
    else ZeroFlag <= '0';
    end if;
end process;

ZERO <= ZeroFlag;

GTZ <= not(ZeroFlag) and not(C(31));

BranchAddress <= (ExtImm(29 downto 0) & "00") + PCNext;

end Behavioral;
