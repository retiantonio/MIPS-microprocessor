----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/24/2025 09:03:55 PM
-- Design Name: 
-- Module Name: MIPS - Behavioral
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

entity MIPS is
    Port (switch: in std_logic_vector(7 downto 0);
          button: in std_logic_vector(1 downto 0); 
          clk: in std_logic;
          led: out std_logic_vector(13 downto 0);
          cat: out std_logic_vector(6 downto 0);
          an: out std_logic_vector(7 downto 0));
end MIPS;

architecture Behavioral of MIPS is
        --ENABLE BUTTON
    signal enable: std_logic := '0';
    
        --SSD OUTPUT
    signal digitsInput: std_logic_vector(31 downto 0) := (others => '0');
        
        --FLAGS
    signal ZERO: std_logic := '0';
    signal GTZ: std_logic := '0';
    
       --ADDRESSES
    signal branchAddress: std_logic_vector(31 downto 0) := X"00000000";
    signal jumpAddress: std_logic_vector(31 downto 0) := X"00000000";
    signal jumpRegisterAddress: std_logic_vector(31 downto 0) := X"00000000";
    
        --SIGNALS
    signal regDst: std_logic := '0';    
    signal extOp: std_logic := '0';
    signal ALUSrc: std_logic := '0';
    signal memWrite: std_logic := '0';    
    signal memToReg: std_logic := '0';    
    signal regWrite: std_logic := '0';        
    signal ALUOp: std_logic_vector(2 downto 0) := (others => '0');
    signal PCSrc: std_logic := '0';
     
    signal jumpSignal: std_logic := '0';
    signal jumpRegisterSignal: std_logic := '0';
    signal branchSignal: std_logic := '0';
    signal branchGreaterSignal: std_logic := '0';
    signal PCNext: std_logic_vector(31 downto 0) := (others => '0');
    
        
        --Instruction Data and Read Data
    signal instruction: std_logic_vector(31 downto 0) := (others => '0');
     
    signal readData1: std_logic_vector(31 downto 0) := (others => '0');
    signal readData2: std_logic_vector(31 downto 0) := (others => '0');
    signal extImm: std_logic_vector(31 downto 0) := (others => '0');
    signal func: std_logic_vector(5 downto 0) := (others => '0');
    signal shiftAmount: std_logic_vector(4 downto 0) := (others => '0');
    signal ALURes: std_logic_vector(31 downto 0) := (others => '0');
    signal memData: std_logic_vector(31 downto 0) := (others => '0');
    signal writeData: std_logic_vector(31 downto 0) := (others => '0');
    
    component MPG
        Port ( enable : out STD_LOGIC;
               btn : in STD_LOGIC;
               clk : in STD_LOGIC);
    end component;
    
    component InstructionFetch
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
    end component;
    
    component InstructionDecoder
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
              func: out std_logic_vector(5 downto 0);
              sa: out std_logic_vector(4 downto 0));
    end component;
    
    component Execution
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
    end component;
    
    component UC
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
    end component;
    
   
    
    component MEM
        Port (MemWrite: in std_logic; 
              ALUResIn: in std_logic_vector(31 downto 0);  
              ReadData2: in std_logic_vector(31 downto 0);
              clk: in std_logic;
              Enable: in std_logic;
              
              MemData: out std_logic_vector(31 downto 0);
              ALUResOut: out std_logic_vector(31 downto 0));
    end component;

    component SevenSegment
        Port ( CLK: in std_logic;
               DIGITS: in std_logic_vector(31 downto 0);
               AN: out std_logic_vector(7 downto 0);
               CAT: out std_logic_vector(6 downto 0));
    end component;
    
begin
    
    C1: MPG port map(enable => enable, btn => button(0), clk => clk);
  
    C2: InstructionFetch port map(jumpSignal => jumpSignal, --complete
                                  jumpAddress => jumpAddress, 
                                  PCSrc => PCSrc, 
                                  branchAddress => branchAddress, 
                                  jumpRegister => jumpRegisterSignal,
                                  jumpRegisterAddress => readData1, 
                                  enable => enable, 
                                  reset => button(1), 
                                  clk => clk,
                                  instruction => instruction, 
                                  PCNext => PCNext);
    
    PCSrc <= (branchSignal and ZERO) or (branchGreaterSignal and GTZ);
    jumpAddress <= PCNext(31 downto 28) & (instruction(25 downto 0) & "00"); -- de verificat
    
    C3: SevenSegment port map(clk => clk, digits => digitsInput, an => an, cat => cat);
    
    C4: UC port map(instruction => instruction(31 downto 26), --complete
                     regDst => regDst,
                     extOp => extOp,
                     aluSrc => ALUSrc,
                     branch => branchSignal,
                     jump => jumpSignal,
                     aluOp => ALUOp,
                     memWrite => memWrite,
                     memToReg => memToReg,
                     regWrite => regWrite,
                     jumpR => jumpRegisterSignal,
                     brGreater => branchGreaterSignal);
     
    C5: InstructionDecoder port map(regWrite => regWrite,
                                  instruction => instruction(25 downto 0),
                                  regDst => regDst,
                                  enable => enable,
                                  extOp => extOp,
                                  writeData => writeData, --AICI UITA-TE
                                  clk => clk,
                                  
                                  readData1 => readData1,
                                  readData2 => readData2,
                                  extImm => extImm,
                                  func => func,
                                  sa => shiftAmount);
    
    C6: Execution port map(readData1 => readData1, --complete
                          readData2 => readData2,
                          ALUSrc => ALUSrc,
                          ExtImm => extImm,
                          shiftAmount => shiftAmount,
                          func => func,
                          ALUOp => ALUOp,
                          PCNext => PCNext,
                          
                          GTZ => GTZ,
                          ZERO => ZERO,
                          ALURes => ALURes,
                          BranchAddress => branchAddress);
              
          
    C7: MEM port map(MemWrite => memWrite, --complete
                      ALUResIn => ALURes,
                      ReadData2 => ReadData2,
                      clk => clk,
                      Enable => enable,
                      
                      MemData => memData,
                      ALUResOut => ALURes);   
                      
     writeData <= ALURes when MemToReg = '0' else memData;
     
     SSDMUX: process(switch)
     begin
        case switch(7 downto 5) is
            when "000" => digitsInput <= instruction;
            when "001" => digitsInput <= PCNext;
            when "010" => digitsInput <= readData1;
            when "011" => digitsInput <= readData2;
            when "100" => digitsInput <= extImm;
            when "101" => digitsInput <= ALURes;
            when "110" => digitsInput <= memData;
            when "111" => digitsInput <= writeData;
            when others => digitsInput <= X"00000000"; 
        end case;
     end process;  
     
    led(13 downto 11) <= ALUOp;
    led(10) <= GTZ;
    led(9) <= regDst;
    led(8) <= extOp;
    led(7) <= ALUSrc;
    led(6) <= branchSignal;
    led(5) <= branchGreaterSignal;
    led(4) <= jumpSignal;     
    led(3) <= jumpRegisterSignal;
    led(2) <= memWrite;
    led(1) <= memToReg;
    led(0) <= regWrite;
    
end Behavioral;
