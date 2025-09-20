//8b -> 10b encoder
module tmds_encoder(
    input clk,                  //25.2 MHz
    input [7:0] color_data,     //8b color data in
    input pll_lock,         
    input vsync,
    input hsync,
    input de,                   //display enable in draw area
    output reg [9:0] out        //10b encoded data out
);

//if pll is not locked then c0 and c1 (hsync and vsync respectively) are zero
wire vsync_r = pll_lock & vsync;
wire hsync_r = pll_lock & hsync;

//STAGE 1
//parity = 1 => xnor, parity = 0 => xor
wire parity = ($countones(color_data) > 4) ? 1 : ((($countones(color_data) == 4) && !color_data[0]) ? 1 : 0);
wire [8:0] q_m; 
assign q_m[0] = color_data[0];
assign q_m[1] = parity ? q_m[0] ^~ color_data[1] : q_m[0] ^ color_data[1];
assign q_m[2] = parity ? q_m[1] ^~ color_data[2] : q_m[1] ^ color_data[2];
assign q_m[3] = parity ? q_m[2] ^~ color_data[3] : q_m[2] ^ color_data[3];
assign q_m[4] = parity ? q_m[3] ^~ color_data[4] : q_m[3] ^ color_data[4];
assign q_m[5] = parity ? q_m[4] ^~ color_data[5] : q_m[4] ^ color_data[5];
assign q_m[6] = parity ? q_m[5] ^~ color_data[6] : q_m[5] ^ color_data[6];
assign q_m[7] = parity ? q_m[6] ^~ color_data[7] : q_m[6] ^ color_data[7];
assign q_m[8] = ~parity;

//STAGE 2
wire signed [4:0] q_m_diff = $countones(q_m[7:0]) * 2 - 8; //ones - zeros in q_m
reg signed [6:0] rd; //ones - zeros total of all bits ever received
wire rd_sign_match = (rd[4] == q_m_diff[4]); //check if they have the same sign, if they do, then invert q_m

//wire blank = ~pll_lock | ~de;
//always @(posedge clk) begin
//    out <= blank ? {~vsync_r, 9'b101010100} ^ {10{hsync_r}} : {rd_sign_match, ~parity, {8{rd_sign_match}} ^ q_m[7:0]};
//    rd <= blank ? 0 : 5'(rd + ({5{rd_sign_match}} ^ q_m_diff) + {3'b0, rd_sign_match^parity, rd_sign_match});
//  end

//{rd_sign_match, ~parity, {8{rd_sign_match}} ^ q_m[7:0]}

always @ (posedge clk) begin
    if (~pll_lock | ~de) begin
        out <= {~vsync_r, 9'b101010100} ^ {10{hsync_r}};
        rd <= 0;
    end else begin
        if (rd_sign_match) begin
            out <= {1'b1, q_m[8], ~{q_m[7:0]}};     // invert edilmiş
            rd  <= rd - q_m_diff - q_m[8];
        end else begin
            out <= {1'b0, q_m};      // invert edilmemiş
            rd  <= rd + q_m_diff + q_m[8];
        end
    end
end

endmodule