entity axis_upscale is
    Port (
        clk : in  STD_LOGIC;
        resetn : in  STD_LOGIC;
        dfmt_enable : in  STD_LOGIC;
        dfmt_type : in  STD_LOGIC;
        dfmt_se : in  STD_LOGIC;
        s_axis_valid : in  STD_LOGIC;
        s_axis_data : in  UNSIGNED(23 downto 0);
        m_axis_ready : in  STD_LOGIC;

        s_axis_ready : out  STD_LOGIC;
        m_axis_valid : out  STD_LOGIC;
        m_axis_data : out  UNSIGNED(31 downto 0)
    );
end entity;

architecture Behavioral of axis_upscale is
    signal next_ready : STD_LOGIC;
    signal shifted_data : UNSIGNED(31 downto 0);
begin
    process(clk, resetn)
    begin
        if rising_edge(clk) then
            if resetn = '1' then
                next_ready <= '0';
                shifted_data <= (others => '0');
            else
                next_ready <= '1';
                shifted_data <= s_axis_data;
            end if;
        end if;
    end process;

    s_axis_ready <= next_ready;
    m_axis_valid <= '1';
    m_axis_data <= shifted_data;
end architecture Behavioral;
