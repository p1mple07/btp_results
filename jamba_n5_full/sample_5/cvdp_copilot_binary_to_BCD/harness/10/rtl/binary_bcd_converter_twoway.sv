library ieee;
use ieee.std_logic_1164.all;

entity binary_bcd_converter_twoway is
    generic(BCD_DIGITS : integer := 3, INPUT_WIDTH : integer := 9);
    port(
        BCD_DIGITS : integer := 3;
        INPUT_WIDTH : integer := 9;
        switch : std_logic := '0';
        bcd_in : in  std_logic_vector(BCD_DIGITS*4 - 1 downto 0);
        binary_in : in  std_logic_vector(INPUT_WIDTH - 1 downto 0);
        binary_out : out std_logic_vector(INPUT_WIDTH - 1 downto 0);
        bcd_out : out std_logic_vector(BCD_DIGITS*4 - 1 downto 0)
    );
end entity;

architecture Behavioral of binary_bcd_converter_twoway is

    signal shift_reg : std_logic_vector(INPUT_WIDTH*2 - 1 downto 0);
    signal current_mode : std_logic := '0';

    function double_dabble(data : std_logic_vector) return std_logic_vector is
        variable temp : std_logic_vector(INPUT_WIDTH*2 - 1 downto 0);
        variable carry : boolean;
        variable i : integer;
    begin
        temp := data;
        for i in 0 to INPUT_WIDTH-1 loop
            if (temp(INPUT_WIDTH*2 - 1 downto INPUT_WIDTH*2 - 1 - i) >= 5) then
                temp(INPUT_WIDTH*2 - 1 downto INPUT_WIDTH*2 - 1 - i) := temp(INPUT_WIDTH*2 - 1 downto INPUT_WIDTH*2 - 1 - i) + 3;
                carry := true;
            end if;
        end loop;
        return temp;
    end function;

begin
    current_mode <= switch;

    if current_mode = '1' then
        -- BCD to binary
        -- Convert BCD_in to binary_out by repeated multiplication and addition
        binary_out <= "0";
    elsif current_mode = '0' then
        -- Binary to BCD
        -- Double dabble with shift register
        shift_reg := '0' & binary_in;

        for i in 0 to 7 loop
            if shift_reg(INPUT_WIDTH - 1 downto 0) >= 5 then
                shift_reg(INPUT_WIDTH - 1 downto 0) := shift_reg(INPUT_WIDTH - 1 downto 0) + 3;
            end if;
            shift_reg := shift_reg << 1;
        end loop;

        bcd_out <= shift_reg(INPUT_WIDTH*2 - 1 downto INPUT_WIDTH*2 - 1);
    end if;
end Behavioral;
