module main(
    input sysclk,
    output       tmds_clk_n,
    output       tmds_clk_p,
    output [2:0] tmds_data_n,
    output [2:0] tmds_data_p
);

//clocks
wire clk_5x;
wire pll_lock;
wire clk;

hdmi_pll hdmi_pll( //126 MHz clock
        .clkout(clk_5x), //output clkout
        .lock(pll_lock), //output lock
        .clkin(sysclk) //input clkin
    );

hdmi_clkdiv hdmi_clkdiv( //25.2 MHz clock
        .clkout(clk), //output clkout
        .hclkin(clk_5x), //input hclkin
        .resetn(pll_lock) //input resetn
    );

//640x480 resolution
reg [9:0] xpos; //0-799 x position, 0-639 draw area, 640-655 front porch, 656-751 hsync columns, 752-799 back porch
reg [9:0] ypos; //0-524 y position, 0-479 draw area, 480-489 front porch, 490-491 vsync columns, 492-524 back porch

//draw and sync areas
wire hsync = (655 < xpos) && (xpos < 752);
wire vsync = (489 < ypos) && (ypos < 492);
wire draw_area = (xpos < 640) && (ypos < 480);

//count the pixel positions
always @ (posedge clk) begin
    xpos <= xpos + 1;
    if (xpos == 800) begin
        xpos <= 0;
        ypos <= ypos + 1;
        if (ypos == 525) 
            ypos <= 0;
    end
    if (~pll_lock) begin
        xpos <= 0;
        ypos <= 0;
    end
end

//pattern drawer
wire [23:0] bgr24;
pattern_drawer pattern_drawer(.clk(clk), .draw_area(draw_area), .xpos(xpos), .ypos(ypos), .bgr24(bgr24), .pll_lock(pll_lock));

//encoding
wire [9:0] tmds_b, tmds_g, tmds_r;
tmds_encoder encode_b(.clk(clk), .color_data(bgr24[23:16]), .pll_lock(pll_lock),  .vsync(vsync), .hsync(hsync), .de(draw_area), .out(tmds_b));
tmds_encoder encode_g(.clk(clk), .color_data(bgr24[15:8]),  .pll_lock(pll_lock),  .vsync(0),     .hsync(0),     .de(draw_area), .out(tmds_g));
tmds_encoder encode_r(.clk(clk), .color_data(bgr24[7:0]),   .pll_lock(pll_lock),  .vsync(0),     .hsync(0),     .de(draw_area), .out(tmds_r));

//serialization
wire ser_b, ser_g, ser_r;
OSER10 oser10_b(.Q(ser_b), .PCLK(clk), .FCLK(clk_5x), .RESET(~pll_lock), .D0(tmds_b[0]), .D1(tmds_b[1]), .D2(tmds_b[2]), .D3(tmds_b[3]), .D4(tmds_b[4]), .D5(tmds_b[5]), .D6(tmds_b[6]), .D7(tmds_b[7]), .D8(tmds_b[8]), .D9(tmds_b[9]));
OSER10 oser10_g(.Q(ser_g), .PCLK(clk), .FCLK(clk_5x), .RESET(~pll_lock), .D0(tmds_g[0]), .D1(tmds_g[1]), .D2(tmds_g[2]), .D3(tmds_g[3]), .D4(tmds_g[4]), .D5(tmds_g[5]), .D6(tmds_g[6]), .D7(tmds_g[7]), .D8(tmds_g[8]), .D9(tmds_g[9]));
OSER10 oser10_r(.Q(ser_r), .PCLK(clk), .FCLK(clk_5x), .RESET(~pll_lock), .D0(tmds_r[0]), .D1(tmds_r[1]), .D2(tmds_r[2]), .D3(tmds_r[3]), .D4(tmds_r[4]), .D5(tmds_r[5]), .D6(tmds_r[6]), .D7(tmds_r[7]), .D8(tmds_r[8]), .D9(tmds_r[9]));

//output
ELVDS_OBUF out_c (.I(clk),   .O(tmds_clk_p),     .OB(tmds_clk_n));
ELVDS_OBUF out_r (.I(ser_r), .O(tmds_data_p[2]), .OB(tmds_data_n[2]));
ELVDS_OBUF out_g (.I(ser_g), .O(tmds_data_p[1]), .OB(tmds_data_n[1]));
ELVDS_OBUF out_b (.I(ser_b), .O(tmds_data_p[0]), .OB(tmds_data_n[0]));

endmodule