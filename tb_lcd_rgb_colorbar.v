module tb_lcd_rgb_colorbar ();
    
    reg sys_clk;
    reg sys_rst_n;

    wire lcd_clk;
    wire lcd_de;
    wire [23:0] lcd_rgb;
    wire lcd_bl;
    wire lcd_rst;
    wire lcd_hs;
    wire lcd_vs;

    initial begin
        sys_clk = 1'b0;
        sys_rst_n = 1'b0;
        #200;
        sys_rst_n = 1'b1;
    end

    assign lcd_rgb = lcd_de ? {24{1'bz}} : 24'h80;

    always #10 sys_clk = ~sys_clk;


    lcd_rgb_colorbar u_lcd_rgb_colorbar (
    // 输入端口
    .sys_clk    (sys_clk),    // 系统时钟输入
    .sys_rst_n  (sys_rst_n),  // 系统复位输入（低有效）
    
    // 输出端口
    .lcd_clk    (lcd_clk),    // LCD 像素时钟输出
    .lcd_de     (lcd_de),     // LCD 数据使能输出
    .lcd_rgb    (lcd_rgb),    // LCD 24位RGB数据输出
    .lcd_bl     (lcd_bl),     // LCD 背光控制输出
    .lcd_rst    (lcd_rst),    // LCD 复位输出
    .lcd_hs     (lcd_hs),     // LCD 行同步输出
    .lcd_vs     (lcd_vs)      // LCD 场同步输出
    );

endmodule
