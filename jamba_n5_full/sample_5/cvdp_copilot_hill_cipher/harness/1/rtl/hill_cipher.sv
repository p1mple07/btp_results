library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hill_cipher is
    generic(clk_freq : integer := 50);
    port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        start : in STD_LOGIC;
        plaintext : in STD_LOGIC_VECTOR(14 downto 0);
        key : in STD_LOGIC_VECTOR(44 downto 0);
        ciphertext : out STD_LOGIC_VECTOR(14 downto 0);
        done : out STD_LOGIC
    );
end entity;

architecture Behavioral of hill_cipher is

    type state_type is (idle, waiting_for_data, encrypting);
    signal current_state : state_type;

    constant clock_period : time := 100 ns;
    constant max_plaintxt_bits : integer := 15;

    signal plaintxt_vec : UNSIGNATED(max_plaintxt_bits*8-1 downto 0);
    signal key_block : UNSIGNATED(max_plaintxt_bits*8-1 downto 0);
    signal ciphertext_vec : UNSIGNATED(max_plaintxt_bits*8-1 downto 0);

    function matmul(a : signed; b : signed) return signed is
        variable result : signed := 0;
    begin
        for i in 0 to 8 loop
            for j in 0 to 8 loop
                result <= result + a(i*8+j) * b(j*8+i);
            end loop;
        end loop;
        return result;
    end function;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_state <= idle;
                done <= '0';
                plaintxt_vec <= (others => '0');
                ciphertext_vec <= (others => '0');
            elsif rising_edge(clk) and current_state = 'idle' then
                current_state <= waiting_for_data;
            elsif rising_edge(clk) and current_state = waiting_for_data then
                current_state <= encrypting;
            elsif rising_edge(clk) and current_state = encrypting then
                if start = '1' then
                    current_state <= encrypting_inside;
                elsif start = '0' then
                    done <= '1';
                end if;
            end if;
        end if;
    end process;

    process(current_state, plaintxt_vec, key_block) is
        variable p_vec : UNSIGNATED(max_plaintxt_bits*8-1 downto 0) := plaintxt_vec;
        variable k_vec : UNSIGNATED(max_plaintxt_bits*8-1 downto 0) := key_block;
        variable p_byte : UNSIGNATED(4 downto 0);
        variable k_byte : UNSIGNATED(4 downto 0);
        variable sum : SIGNED(4 downto 0);
        variable c : SIGNED(4 downto 0);
    begin
        if current_state = encrypting then
            for i in 0 to 2 loop
                for j in 0 to 2 loop
                    p_byte <= to_unsigned(p_vec(i*5 + j*5), 5);
                    k_byte <= to_unsigned(k_vec(j*5 + i*5), 5);
                    sum <= p_byte + k_byte;
                    c <= sum mod 26;
                end loop;
                ciphertext_vec(i*5*8+j*5*8+i*5*8+j*5*8) <= to_unsigned(c, 5);
            end loop;
        end if;
    end process;

    done <= '1' after clock_period / 2;

end architecture Behavioral;
