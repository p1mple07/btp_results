entity dbi_enc is
    Port (
        data_in : in  STD_LOGIC_VECTOR(39 downto 0);
        clk     : in  STD_LOGIC;
        rst_n   : in  STD_LOGIC;
        data_out : out  STD_LOGIC_VECTOR(39 downto 0);
        dbi_cntrl : out  STD_LOGIC_VECTOR(1 downto 0)
    );
end entity;
