entity first_bit_decoder is
    generic (
        PlRegs_g : integer := 1
    );
    port (
        Clk     : in std_logic;
        Rst      : in std_logic;
        In_Data  : in std_logic_vector(InWidth_g - 1 downto 0);
        In_Valid : in std_logic;
        Out_FirstBit : out unsigned(log2(InWidth_g));
        Out_Found : out std_logic;
        Out_Valid : out std_logic
    );
end first_bit_decoder;

architecture Behavioral of first_bit_decoder is
    type pipeline_stage is array (0 to PlRegs_g-1) of unsigned(log2(InWidth_g) downto 0);
    signal current_pipeline : pipeline_stage;
    signal next_pipeline : pipeline_stage;
begin
    current_pipeline <= (others => '0');
    next_pipeline <= (others => '0');

    process(Clk)
    begin
        if rising_edge(Clk) then
            if Rst = '1' then
                current_pipeline <= (others => '0');
                next_pipeline <= (others => '0');
            else
                current_pipeline <= next_pipeline;
                next_pipeline <= (others => '0');
            end if;
        end if;
    end process;

    FirstSetBit: process(current_pipeline)
    begin
        case current_pipeline is
            when "0" =>
                Out_FirstBit <= 0;
                Out_Found <= '0';
                Out_Valid <= '0';
            when others =>
                for i in 0 to log2(InWidth_g) loop
                    if current_pipeline(i) = '1' then
                        Out_FirstBit <= i;
                        Out_Found <= '1';
                        Out_Valid <= '1';
                        exit;
                    end if;
                end loop;
        end case;
    end process;

    Out_Valid <= current_pipeline(0) and current_pipeline(log2(InWidth_g)-1) and Out_Found;

end Behavioral;
