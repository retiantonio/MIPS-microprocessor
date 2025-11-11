----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/26/2025 10:21:50 AM
-- Design Name: 
-- Module Name: InstructionFetch - Behavioral
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

entity IFPipeline is
    Port (jumpSignal: in std_logic;
          jumpAddress: in std_logic_vector(31 downto 0);
          PCSrc: in std_logic;
          branchAddress: in std_logic_vector(31 downto 0);
          jumpRegister: in std_logic;
          jumpRegisterAddress: in std_logic_vector(31 downto 0);
          enable: in std_logic;
          reset: in std_logic;
          clk: in std_logic;
          instruction: out std_logic_vector(31 downto 0);
          PCNext: out std_logic_vector(31 downto 0));
end IFPipeline;

architecture Behavioral of IFPipeline is
    type typeROM is array(0 to 31) of std_logic_vector(31 downto 0);
    
    signal ROM: typeROM := (
        -- Start
    B"100011_00000_01000_0000000000000100",  -- 0x8C080004 lw   $t0, 4($zero)      ; N
    B"001000_00000_01001_0000000000000000",  -- 0x20090000 addi $t1, $zero, 0      ; result = 0
    B"001000_00000_01010_0000000000001000",  -- 0x212A0008 addi $t2, $zero, 8      ; array base addr
    
    B"000000_00000_00000_00000_00000_000000", -- 0x00000000 add $0, $0, $0
    B"000000_00000_00000_00000_00000_000000", -- 0x00000000 add $0, $0, $0

    -- loop:
    B"100011_01010_01011_0000000000000000",  -- 0x8D4B0000 lw   $t3, 0($t2)        ; load array[i]
    B"001000_01010_01010_0000000000000100",  -- 0x214A0004 addi $t2, $t2, 4        ; i++
    B"001000_01000_01000_1111111111111111",  -- 0x2108FFFF addi $t0, $t0, -1       ; N--

    B"000111_01011_00000_0000000000000101",  -- 0x1D600002 bgtz $t3, check_odd     ; if value > 0
    
    B"000000_00000_00000_00000_00000_000000", -- 0x00000000 add $0, $0, $0
    B"000000_00000_00000_00000_00000_000000", -- 0x00000000 add $0, $0, $0
    B"000000_00000_00000_00000_00000_000000", -- 0x00000000 add $0, $0, $0
    
    B"000010_00000000000000000000011001",  -- 0x0800000C j continue              ; else skip inc
    
    B"000000_00000_00000_00000_00000_000000", -- 0x00000000 add $0, $0, $0
    
    -- check_odd:
    B"000000_00000_01011_01100_11111_000010",  -- 0x000B67C2 sll  $t4, $t3, 31       ; shift LSB to MSB
    
    B"000000_00000_00000_00000_00000_000000", -- 0x00000000 add $0, $0, $0
    B"000000_00000_00000_00000_00000_000000", -- 0x00000000 add $0, $0, $0
    
    B"000000_00000_01100_01100_11111_000011",  -- 0x000C67C3 srl  $t4, $t4, 31       ; shift MSB back to LSB
    
    B"000000_00000_00000_00000_00000_000000", -- 0x00000000 add $0, $0, $0
    B"000000_00000_00000_00000_00000_000000", -- 0x00000000 add $0, $0, $0
      
    B"000100_01100_00000_0000000000000100",  -- 0x11800001 beq  $t4, $zero, continue (modified)
    
    B"000000_00000_00000_00000_00000_000000", -- 0x00000000 add $0, $0, $0
    B"000000_00000_00000_00000_00000_000000", -- 0x00000000 add $0, $0, $0
    B"000000_00000_00000_00000_00000_000000", -- 0x00000000 add $0, $0, $0

    B"00100001001010010000000000000001",  -- 0x21290001 addi $t1, $t1, 1        ; result++

    -- continue:
    B"000111_01000_00000_1111111111101011",  -- 0x1D00FFF6 bgtz $t0, loop          ; loop if N > 0
    
    B"000000_00000_00000_00000_00000_000000", -- 0x00000000 add $0, $0, $0
    B"000000_00000_00000_00000_00000_000000", -- 0x00000000 add $0, $0, $0
    B"000000_00000_00000_00000_00000_000000", -- 0x00000000 add $0, $0, $0

    -- end:
    B"101011_00000_01001_0000000000000000",  -- 0xAC090000 sw   $t1, 0($zero)      ; store result
    B"000011_11111_00000_0000000000000000",  -- 0x03E00008 jr   $ra                ; return

    others => B"00000000000000000000000000000000"
);
           
    signal pcAddress: std_logic_vector(31 downto 0) := (others => '0');  
    signal pc4: std_logic_vector(31 downto 0) := (others => '0');
    signal branchMuxOutput: std_logic_vector(31 downto 0) := (others => '0');
    signal jumpMuxOutput: std_logic_vector(31 downto 0) := (others => '0');
    signal jumpRegisterMuxOutput: std_logic_vector(31 downto 0) := (others => '0');
begin

    process(clk, reset, enable, jumpRegisterMuxOutput, pcAddress)
    begin
        if reset = '1' then
            pcAddress <= (others => '0');
        elsif enable = '1' and rising_edge(clk) then
            pcAddress <= jumpRegisterMuxOutput;
        end if;
    end process;
    
    instruction <= ROM(conv_integer(pcAddress(6 downto 2)));
    
    pc4 <= pcAddress + B"100";
    pcNext <= pc4;
    
    branchMuxOutput <= branchAddress when PCSrc = '1' else pc4;
    jumpMuxOutput <= jumpAddress when jumpSignal = '1' else branchMuxOutput;
    jumpRegisterMuxOutput <= jumpRegisterAddress when jumpRegister = '1' else jumpMuxOutput;
    
    
end Behavioral;
