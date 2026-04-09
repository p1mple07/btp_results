library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FirstBitDecoder is
    generic (
        PlRegs_g : positive := 1
    );
    port (
        Clk      : in std_logic;
        Rst       : in std_logic;
        In_Data   : in std_logic_vector(InWidth_g - 1 downto 0);
        In_Valid  : in std_logic;
        Out_FirstBit : out unsigned(PlRegs_g-1 downto 0);
        Out_Found  : out std_logic;
        Out_Valid  : out std_logic
    );
    port (
        InReg_g : in std_logic;
        OutReg_g : in std_logic
    );
end entity;

architecture Behavioral of FirstBitDecoder is
    type PipelineStage is array (PlRegs_g-1 downto 0) of std_logic_vector(InWidth_g-1 downto 0);
    signal pipeline : PipelineStage;
    signal next_stage : PipelineStage;
    variable first_bit : boolean := False;
begin
    process(Clk)
        begin
            if rising_edge(Clk) then
                if Rst = '1' then
                    pipeline <= (others & '0');
                    next_stage <= (others & '0');
                    first_bit <= False;
                else
                    if In_Valid = '1' then
                        first_bit := (In_Data(0) = '1');
                    end if;
                    for i in 0 to PlRegs_g-2 loop
                        next_stage(i) <= pipeline(i+1);
                    end loop;
                end if;
            end if;
        end if;
    end process;

    Out_FirstBit  <= to_unsigned(pipeline(0), PlRegs_g);
    Out_Found     <= first_bit;
    Out_Valid     <= first_bit;

    if InReg_g = '1' then
        pipeline <= In_Data;
    end if;

    if OutReg_g = '1' then
        Out_FirstBit  <= pipeline(0);
        Out_Found     <= first_bit;
        Out_Valid     <= first_bit;
    end if;
end architecture;
