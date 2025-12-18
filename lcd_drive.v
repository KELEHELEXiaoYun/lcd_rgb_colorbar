module lcd_drive (
    
    input lcd_pclk,
    input rst_n,

    input [23:0] pixel_data,
    input [15:0] lcd_id,

    output reg [10:0] pixel_xpos,
    output reg [10:0] pixel_ypos,
    output reg [10:0] h_disp,
    output reg [10:0] v_disp,

    output lcd_clk,
    output reg lcd_de,
    output [23:0] lcd_rgb,
    output lcd_bl,
    output lcd_rst,
    output lcd_hs,
    output lcd_vs

);
   
    // 4.3' 480*272
    parameter  H_SYNC_4342 = 11'd41;
    parameter  H_BACK_4342 = 11'd2;
    parameter  H_DISP_4342 = 11'd480;
    parameter  H_FRONT_4342 = 11'd2;
    parameter  H_TOTAL_4342 = 11'd525;

    parameter  V_SYNC_4342 = 11'd10;
    parameter  V_BACK_4342 = 11'd2;
    parameter  V_DISP_4342 = 11'd272;
    parameter  V_FRONT_4342 = 11'd2;
    parameter  V_TOTAL_4342 = 11'd286;

    //7' 800*480
    parameter  H_SYNC_7084   = 11'd128;  //行同步
    parameter  H_BACK_7084   = 11'd88;   //行显示后沿
    parameter  H_DISP_7084   = 11'd800;  //行有效数据
    parameter  H_FRONT_7084  = 11'd40;   //行显示前沿
    parameter  H_TOTAL_7084  = 11'd1056; //行扫描周期

    parameter  V_SYNC_7084   = 11'd2;    //场同步
    parameter  V_BACK_7084   = 11'd33;   //场显示后沿
    parameter  V_DISP_7084   = 11'd480;  //场有效数据
    parameter  V_FRONT_7084  = 11'd10;   //场显示前沿
    parameter  V_TOTAL_7084  = 11'd525;  //场扫描周期

    //7' 1024*600
    parameter  H_SYNC_7016   = 11'd20;   //行同步
    parameter  H_BACK_7016   = 11'd140;  //行显示后沿
    parameter  H_DISP_7016   = 11'd1024; //行有效数据
    parameter  H_FRONT_7016  = 11'd160;  //行显示前沿
    parameter  H_TOTAL_7016  = 11'd1344; //行扫描周期

    parameter  V_SYNC_7016   = 11'd3;    //场同步
    parameter  V_BACK_7016   = 11'd20;   //场显示后沿
    parameter  V_DISP_7016   = 11'd600;  //场有效数据
    parameter  V_FRONT_7016  = 11'd12;   //场显示前沿
    parameter  V_TOTAL_7016  = 11'd635;  //场扫描周期

    //10.1' 1280*800
    parameter  H_SYNC_1018    = 11'd10;   //行同步
    parameter  H_BACK_1018    = 11'd80;   //行显示后沿
    parameter  H_DISP_1018    = 11'd1280; //行有效数据
    parameter  H_FRONT_1018   = 11'd70;   //行显示前沿
    parameter  H_TOTAL_1018   = 11'd1440; //行扫描周期

    parameter  V_SYNC_1018    = 11'd3;    //场同步
    parameter  V_BACK_1018    = 11'd10;   //场显示后沿
    parameter  V_DISP_1018    = 11'd800;  //场有效数据
    parameter  V_FRONT_1018   = 11'd10;   //场显示前沿
    parameter  V_TOTAL_1018   = 11'd823;  //场扫描周期

    // 4.3' 800*480
    parameter  H_SYNC_4384    = 11'd128;  // 行同步
    parameter  H_BACK_4384    = 11'd88;   // 行显示后沿
    parameter  H_DISP_4384    = 11'd800;  // 行有效数据
    parameter  H_FRONT_4384   = 11'd40;   // 行显示前沿
    parameter  H_TOTAL_4384   = 11'd1056; // 行扫描周期

    parameter  V_SYNC_4384    = 11'd2;    // 场同步
    parameter  V_BACK_4384    = 11'd33;   // 场显示后沿
    parameter  V_DISP_4384    = 11'd480;  // 场有效数据
    parameter  V_FRONT_4384   = 11'd10;   // 场显示前沿
    parameter  V_TOTAL_4384   = 11'd525;  // 场扫描周期


    reg [10:0] cnt_h;
    reg [9:0] cnt_v;
    reg data_req;
    reg [10:0] h_sync;
    reg [10:0] h_back;
    reg [10:0] h_front;
    reg [10:0] h_total;
    reg [10:0] v_sync;
    reg [10:0] v_back;
    reg [10:0] v_front;
    reg [10:0] v_total;



    assign lcd_clk = lcd_pclk;
    assign lcd_bl  = 1'b1;
    assign lcd_rst = 1'b1;
    assign lcd_hs  = 1'b1;
    assign lcd_vs  = 1'b1;

    assign lcd_rgb = lcd_de ? pixel_data : 24'b0;


    always @(posedge lcd_pclk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_h <= 11'b0;
        end else begin
            if (cnt_h == h_total - 1) begin
                cnt_h <= 11'b0;
            end else begin
                cnt_h <= cnt_h + 1'b1;
            end
        end
    end

    always @(posedge lcd_pclk or negedge rst_n ) begin
        if (!rst_n) begin
            cnt_v <= 10'b0;
        end else begin
            if (cnt_h == h_total - 1) begin
                if (cnt_v == v_total - 1) begin
                    cnt_v <= 10'b0;
                end else begin
                    cnt_v <= cnt_v + 1'b1;
                end
            end else begin
                cnt_v <= cnt_v;
            end
        end
    end

    always @(posedge lcd_pclk or negedge rst_n) begin
        if (!rst_n) begin
           lcd_de <= 1'b0;
        end else begin
           if ((cnt_h > h_sync + h_back - 1) && (cnt_h < h_sync + h_back + h_disp) && (cnt_v > v_sync + v_back - 1) && (cnt_v < v_sync + v_back + v_disp))begin
                lcd_de <= 1'b1;
           end else begin
                lcd_de <= 1'b0;
           end
        end
    end

    always @(posedge lcd_pclk or negedge rst_n) begin
        if (!rst_n) begin
          data_req <= 1'b0;
        end else begin
           if ((cnt_h > h_sync + h_back - 2) && (cnt_h < h_sync + h_back + h_disp - 1) && (cnt_v >v_sync + v_back - 1) && (cnt_v <v_sync + v_back + v_disp))begin
                data_req <= 1'b1;
           end else begin
                data_req <= 1'b0;
           end
        end
    end

    always @(posedge lcd_pclk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_xpos <= 10'b0;
        end else if (data_req) begin
            pixel_xpos <= pixel_xpos + 1'b1;
        end else begin
            pixel_xpos <= 10'b0;
        end 
    end

    always @(posedge lcd_pclk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_ypos <= 10'b0;
        end else if ((cnt_v >=v_sync + v_back) && (cnt_v <v_sync + v_back + v_disp)) begin
            pixel_ypos <= cnt_v + 1'b1 - (v_sync + v_back);
        end else begin
            pixel_ypos <= 10'b0;
        end 
    end

    always @(posedge lcd_pclk) begin
        case (lcd_id)
            16'h4342 : begin
                h_disp <= H_DISP_4342;
                v_disp <= V_DISP_4342;
                h_sync <= H_SYNC_4342;
                h_back <= H_BACK_4342;
                h_front<= H_FRONT_4342;
                h_total<= H_TOTAL_4342;
                v_sync <= V_SYNC_4342;
                v_back <= V_BACK_4342;
                v_front<= V_FRONT_4342;
                v_total<= V_TOTAL_4342;
            end 
            16'h7084 : begin
                h_disp <= H_DISP_7084;
                v_disp <= V_DISP_7084;
                h_sync <= H_SYNC_7084;
                h_back <= H_BACK_7084;
                h_front<= H_FRONT_7084;
                h_total<= H_TOTAL_7084;
                v_sync <= V_SYNC_7084;
                v_back <= V_BACK_7084;
                v_front<= V_FRONT_7084;
                v_total<= V_TOTAL_7084;
            end 
            16'h7016 : begin
                h_disp <= H_DISP_7016;
                v_disp <= V_DISP_7016;
                h_sync <= H_SYNC_7016;
                h_back <= H_BACK_7016;
                h_front<= H_FRONT_7016;
                h_total<= H_TOTAL_7016;
                v_sync <= V_SYNC_7016;
                v_back <= V_BACK_7016;
                v_front<= V_FRONT_7016;
                v_total<= V_TOTAL_7016;
            end 
            16'h1018 : begin
                h_disp <= H_DISP_1018;
                v_disp <= V_DISP_1018;
                h_sync <= H_SYNC_1018;
                h_back <= H_BACK_1018;
                h_front<= H_FRONT_1018;
                h_total<= H_TOTAL_1018;
                v_sync <= V_SYNC_1018;
                v_back <= V_BACK_1018;
                v_front<= V_FRONT_1018;
                v_total<= V_TOTAL_1018;
            end 
            16'h4384 : begin
                h_disp <= H_DISP_4384;
                v_disp <= V_DISP_4384;
                h_sync <= H_SYNC_4384;
                h_back <= H_BACK_4384;
                h_front<= H_FRONT_4384;
                h_total<= H_TOTAL_4384;
                v_sync <= V_SYNC_4384;
                v_back <= V_BACK_4384;
                v_front<= V_FRONT_4384;
                v_total<= V_TOTAL_4384;
            end 
            default: ;
        endcase
    end

endmodule
