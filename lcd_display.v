module lcd_display (
    
    input lcd_pclk,
    input rst_n,    

    input [10:0] pixel_xpos,
    input [10:0] pixel_ypos,
    input [10:0] h_disp,
    input [10:0] v_disp,

    output reg [23:0] pixel_data

);
    parameter WHITE = 24'hFFFFFF;
    parameter BLACK = 24'h000000;
    parameter RED   = 24'hFF0000;
    parameter GREEN = 24'h00FF00;
    parameter BLUE  = 24'h0000FF;

    always@(posedge lcd_pclk or negedge rst_n)begin
        if(!rst_n)
            pixel_data <= BLACK;
        else begin
            if((pixel_xpos >= 0) && (pixel_xpos < h_disp/5*1)) begin
                pixel_data <= WHITE;
            end else if((pixel_xpos >= h_disp/5*1) && (pixel_xpos < h_disp/5*2)) begin
                pixel_data <= BLACK;
            end else if((pixel_xpos >= h_disp/5*2) && (pixel_xpos < h_disp/5*3)) begin
                pixel_data <= RED;
            end else if((pixel_xpos >= h_disp/5*3) && (pixel_xpos < h_disp/5*4)) begin
                pixel_data <= GREEN;
            end else begin
                pixel_data <= BLUE;
            end
        end
    end 


endmodule