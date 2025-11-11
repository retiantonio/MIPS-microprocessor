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

entity MIPSPipeline is
    Port (switch: in std_logic_vector(7 downto 0);
          button: in std_logic_vector(1 downto 0); 
          clk: in std_logic;
          led: out std_logic_vector(13 downto 0);
          cat: out std_logic_vector(6 downto 0);
          an: out std_logic_vector(7 downto 0));
end MIPSPipeline;

architecture Behavioral of MIPSPipeline is
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
    
    signal rt: std_logic_vector(4 downto 0) := (others => '0');
    signal rd: std_logic_vector(4 downto 0) := (others => '0');
    signal rWA: std_logic_vector(4 downto 0) := (others => '0');
   
    --All Signals for PipeLine
        --IF/ID
    signal Instruction_IF_ID: std_logic_vector(31 downto 0) := (others => '0');
    signal PCp4_IF_ID: std_logic_vector(31 downto 0) := (others => '0');
    
        --ID/EX
    signal RegDst_ID_EX: std_logic := '0';
    signal Branch_ID_EX: std_logic := '0';
    signal BranchGreater_ID_EX: std_logic := '0';
    signal RegWrite_ID_EX: std_logic := '0';
    signal Rd_ID_EX: std_logic_vector(4 downto 0) := (others => '0');
    signal Rt_ID_EX: std_logic_vector(4 downto 0) := (others => '0');
    signal PCp4_ID_EX: std_logic_vector(31 downto 0) := (others => '0');
    signal ALUSrc_ID_EX: std_logic := '0';
    signal ReadData1_ID_EX: std_logic_vector(31 downto 0) := (others => '0');
    signal ReadData2_ID_EX: std_logic_vector(31 downto 0) := (others => '0');
    signal ExtImm_ID_EX: std_logic_vector(31 downto 0) := (others => '0');
    signal Func_ID_EX: std_logic_vector(5 downto 0) := (others => '0');
    signal ShiftAmount_ID_EX: std_logic_vector(4 downto 0) := (others => '0');
    signal ALUOp_ID_EX: std_logic_vector(2 downto 0) := (others => '0');
    signal MemWrite_ID_EX: std_logic := '0';
    signal MemToReg_ID_EX: std_logic := '0';
    
        --EX/MEM
    signal Branch_EX_MEM: std_logic := '0';
    signal BranchGreater_EX_MEM: std_logic := '0';
    signal RegWrite_EX_MEM: std_logic := '0';
    signal ZeroFlag_EX_MEM: std_logic := '0';
    signal GTZFlag_EX_MEM: std_logic := '0';
    signal WriteAddress_EX_MEM: std_logic_vector(4 downto 0) := (others => '0');
    signal MemToReg_EX_MEM: std_logic := '0';
    signal ReadData2_EX_MEM: std_logic_vector(31 downto 0) := (others => '0');
    signal BranchAddress_EX_MEM: std_logic_vector(31 downto 0) := (others => '0');
    signal ALURes_EX_MEM: std_logic_vector(31 downto 0) := (others => '0');
    signal MemWrite_EX_MEM: std_logic := '0';
 
        --MEM/WB
    signal ALUResOut_MEM_WB: std_logic_vector(31 downto 0) := (others => '0');
    signal MemData_MEM_WB: std_logic_vector(31 downto 0) := (others => '0');                 
    signal WriteAddress_MEM_WB: std_logic_vector(4 downto 0) := (others => '0');                 
    signal MemToReg_MEM_WB: std_logic := '0';
    signal RegWr_MEM_WB: std_logic := '0';
                                                            
    component MPG
        Port ( enable : out STD_LOGIC;
               btn : in STD_LOGIC;
               clk : in STD_LOGIC);
    end component;
    
    component IFPipeline
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
    
    component IDPipeline is
        Port (regWrite: in std_logic;
              instruction: in std_logic_vector(25 downto 0);
              enable: in std_logic;
              extOp: in std_logic;
              writeData: in std_logic_vector(31 downto 0);
              writeAddress: in std_logic_vector(4 downto 0);
              clk: in std_logic;
              
              readData1: out std_logic_vector(31 downto 0);
              readData2: out std_logic_vector(31 downto 0);
              extImm: out std_logic_vector(31 downto 0);
              func: out std_logic_vector( 5 downto 0);
              sa: out std_logic_vector(4 downto 0);
              rt: out std_logic_vector(4 downto 0);
              rd: out std_logic_vector(4 downto 0));
    end component;

  component EXPipeline is
        Port (readData1: in std_logic_vector(31 downto 0);
              readData2: in std_logic_vector(31 downto 0);
              ALUSrc: in std_logic;
              ExtImm: in std_logic_vector(31 downto 0);
              shiftAmount: in std_logic_vector(4 downto 0);
              func: in std_logic_vector(5 downto 0);
              ALUOp: in std_logic_vector(2 downto 0);
              PCNext: in std_logic_vector(31 downto 0);
              rt: in std_logic_vector(4 downto 0);
              rd: in std_logic_vector(4 downto 0);
              regDst: in std_logic;
              
              GTZ: out std_logic;
              ZERO: out std_logic;
              rWA: out std_logic_vector(4 downto 0);
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
    
    REGISTERS: process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                     --MEM/WB
                RegWr_MEM_WB <= RegWrite_EX_MEM;
                ALUResOut_MEM_WB <= ALURes_EX_MEM;
                MemData_MEM_WB <= memData;
                WriteAddress_MEM_WB <= WriteAddress_EX_MEM;
                MemToReg_MEM_WB <= MemToReg_EX_MEM;
                
                     --EX/MEM
                 Branch_EX_MEM <= Branch_ID_EX;
                 BranchGreater_EX_MEM <= BranchGreater_ID_EX;
                 RegWrite_EX_MEM <= RegWrite_ID_EX;
                 ZeroFlag_EX_MEM <= ZERO; 
                 WriteAddress_EX_MEM <= rWA;
                 ReadData2_EX_MEM <= ReadData2_ID_EX;
                 BranchAddress_EX_MEM <= branchAddress;
                 ALURes_EX_MEM <= ALURes;
                 MemToReg_EX_MEM <= MemToReg_ID_EX;
                 GTZFlag_EX_MEM <= GTZ;
                 MemWrite_EX_MEM <= MemWrite_ID_EX;
                 
                         --ID/EX
                RegDst_ID_EX <= regDst;
                Branch_ID_EX <= branchSignal;
                BranchGreater_ID_EX <= branchGreaterSignal;
                RegWrite_ID_EX <= regWrite;
                Rd_ID_EX <= rd;
                Rt_ID_EX <= rt;
                PCp4_ID_EX <= PCp4_IF_ID;
                ALUSrc_ID_EX <= ALUSrc;
                ReadData1_ID_EX <= readData1;
                ReadData2_ID_EX <= readData2;
                ExtImm_ID_EX <= extImm;
                Func_ID_EX <= func;
                ShiftAmount_ID_EX <= shiftAmount;
                ALUOp_ID_EX <= ALUOp;
                MemWrite_ID_EX <= memWrite;
                MemToReg_ID_EX <= memToReg;
                 
                    --IF/ID
                Instruction_IF_ID <= instruction;
                PCp4_IF_ID <= PCNext;
            end if;
        end if;
    end process;
    
    C1: MPG port map(enable => enable, btn => button(0), clk => clk);
  
    C2: IFPipeline port map(jumpSignal => jumpSignal, --complete
                                  jumpAddress => jumpAddress, 
                                  PCSrc => PCSrc, 
                                  branchAddress => BranchAddress_EX_MEM, 
                                  jumpRegister => jumpRegisterSignal,
                                  jumpRegisterAddress => readData1, 
                                  enable => enable, 
                                  reset => button(1), 
                                  clk => clk,
                                  
                                  instruction => instruction, 
                                  PCNext => PCNext);
    
    PCSrc <= (Branch_EX_MEM and ZeroFlag_EX_MEM) or (BranchGreater_EX_MEM  and GTZFlag_EX_MEM);
    jumpAddress <= PCp4_IF_ID(31 downto 28) & (Instruction_IF_ID(25 downto 0) & "00"); -- de verificat
    
    C3: SevenSegment port map(clk => clk, digits => digitsInput, an => an, cat => cat);
    
    C4: UC port map(instruction => Instruction_IF_ID(31 downto 26), --complete
    
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
     
    C5: IDPipeline port map(regWrite => RegWr_MEM_WB,
                          instruction => instruction(25 downto 0),
                          enable => enable,
                          extOp => extOp,
                          writeData => writeData,
                          writeAddress => writeAddress_MEM_WB,
                          clk => clk,
                          
                          readData1 => readData1,
                          readData2 => readData2,
                          extImm => extImm,
                          func => func,
                          sa => shiftAmount,
                          rt => rt, 
                          rd => rd);
    
    C6: EXPipeline port map(readData1 =>  ReadData1_ID_EX, --complete
                          readData2 =>  ReadData2_ID_EX,
                          ALUSrc => ALUSrc_ID_EX,
                          ExtImm => extImm_ID_EX,
                          shiftAmount => ShiftAmount_ID_EX,
                          func => Func_ID_EX,
                          ALUOp => ALUOp_ID_EX,
                          PCNext => PCp4_ID_EX,
                          rt => Rt_ID_EX, 
                          rd => Rd_ID_EX, 
                          regDst => RegDst_ID_EX, 
                          
                          GTZ => GTZ,
                          ZERO => ZERO,
                          rWA => rWA,
                          ALURes => ALURes,
                          BranchAddress => branchAddress);
              
          
    C7: MEM port map(MemWrite => MemWrite_EX_MEM, --complete
                      ALUResIn => ALURes_EX_MEM ,
                      ReadData2 => ReadData2_EX_MEM ,
                      clk => clk,
                      Enable => enable,
                      
                      MemData => memData,
                      ALUResOut => ALURes_EX_MEM);   
                      
     writeData <= ALUResOut_MEM_WB when MemToReg_MEM_WB = '0' else MemData_MEM_WB;
     
     SSDMUX: process(switch)
     begin
        case switch(7 downto 5) is
            when "000" => digitsInput <= instruction;
            when "001" => digitsInput <= PCNext;
            when "010" => digitsInput <= ReadData1_ID_EX;
            when "011" => digitsInput <= ReadData2_ID_EX;
            when "100" => digitsInput <= ExtImm_ID_EX;
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
