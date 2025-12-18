module lcd_rgb_colorbar (
    
    input sys_clk,
    input sys_rst_n,

    output lcd_clk,
    output lcd_de,
    inout  [23:0] lcd_rgb,
    output lcd_bl,
    output lcd_rst,
    output lcd_hs,
    output lcd_vs

);

    wire [23:0] pixel_data;
    wire [10:0] pixel_xpos;
    wire [10:0] pixel_ypos;
    wire [10:0] h_disp;
    wire [10:0] v_disp;
    wire [15:0] lcd_id;
    wire [23:0] lcd_rgb_i;
    wire [23:0] lcd_rgb_o;


    genvar i;
    generate for (i = 0; i < 24; i = i + 1) 
        begin : IOBUF_LOOP
             IOBUF #(
               .DRIVE(12), // Specify the output drive strength
               .IBUF_LOW_PWR("TRUE"),  // Low Power - "TRUE", High Performance = "FALSE" 
               .IOSTANDARD("DEFAULT"), // Specify the I/O standard
               .SLEW("SLOW") // Specify the output slew rate
            ) IOBUF_inst (
               .O(lcd_rgb_i [i]),     // Buffer output
               .IO(lcd_rgb [i]),   // Buffer inout port (connect directly to top-level port)
               .I(lcd_rgb_o [i]),     // Buffer input
               .T(~lcd_de)      // 3-state enable input, high=input, low=output
            );   
        end
    endgenerate

    //assign lcd_rgb_i = lcd_rgb;
    //assign lcd_rgb = lcd_de ? lcd_rgb :{24{1'bz}};


    lcd_drive u_lcd_drive(

        .lcd_pclk (lcd_pclk),
        .rst_n (sys_rst_n),
        .lcd_id (lcd_id),
        .pixel_data (pixel_data),
        .pixel_xpos (pixel_xpos),
        .pixel_ypos (pixel_ypos),
        .h_disp (h_disp),
        .v_disp (v_disp),
        .lcd_clk (lcd_clk),
        .lcd_de (lcd_de),
        .lcd_rgb (lcd_rgb_o),
        .lcd_bl (lcd_bl),
        .lcd_rst (lcd_rst),
        .lcd_hs (lcd_hs),
        .lcd_vs (lcd_vs)

    );

    lcd_display u_lcd_display (
    
        .lcd_pclk (lcd_pclk),
        .rst_n (sys_rst_n),    

        .pixel_xpos (pixel_xpos),
        .pixel_ypos (pixel_ypos),
        .h_disp (h_disp),
        .v_disp (v_disp),

        .pixel_data (pixel_data)

    );


    clk_div u_clk_div (

        .clk (sys_clk),
        .rst_n (sys_rst_n),

        .lcd_id (lcd_id),

        .lcd_pclk (lcd_pclk)

    );

    rd_id u_rd_id (

        .clk (sys_clk),
        .rst_n (sys_rst_n),

        .lcd_rgb (lcd_rgb_i),

        .lcd_id (lcd_id)

    );

endmodule
