
module draw_triangle(
    input screen_side,          //left = 0, right = 1
    input [4:0] line,           //1 to 15
    input [3:0] i_th_triangle,  //0 to 15-line
    input [9:0] xpos,
    input [9:0] ypos,
    input [3:0] a_mapx,
    input [3:0] a_mapy,
    input [7:0] ah,
    input [7:0] bh,
    input [7:0] ch,
    input [7:0] dh,
    output feasible
);
//FEASIBILITY - IF THE PIXEL IS IN THE TRIANGLE THEN THE PIXEL IS FEASIBLE
wire disable_draw = a_mapy - i_th_triangle > 15 | a_mapx - i_th_triangle > 15 | line == 0 | i_th_triangle > 15-line;//15-line = i max
//screen x and y positions of point (a)
wire [8:0] xp = 320 + ((a_mapx - a_mapy) << 3); //x8
wire [8:0] yp = 297 + ((a_mapx + a_mapy - {i_th_triangle,{1'b0}}) << 2); //x4

//point x,y values plus height values (where the corners of the triangle belong on the screen)
wire [8:0] ax = xp;
wire [8:0] ay = yp - ah;

wire [8:0] bx = xp + 8;
wire [8:0] by = yp - 4 - bh;

wire [8:0] cx = xp;
wire [8:0] cy = yp - 8 - ch;

wire [8:0] dx = xp - 8;
wire [8:0] dy = yp - 4 - dh;

//sign of areas - check if xpos,ypos is inside the triangle
//triangle side == 0(left)  then  ab - bc - ca     
//triangle side == 1(right) then  ac - cd - da     
//optimization: ax = cx, it is known that ax <= xpos <= bx, 0<xpos-ax<8, -8<xpos-bx<0, by-ay = ah-4-bh, cy-by = bh-4-ch
//right side
wire signed [3:0] xp_minus_ax = xpos - ax;
wire signed [3:0] bx_minus_xp = bx - xpos;
wire signed [11:0] f_ab = (xp_minus_ax[2] ? (ah-4-bh)<<2 : 0) + (xp_minus_ax[1] ? (ah-4-bh)<<1 : 0) + (xp_minus_ax[0] ? (ah-4-bh) : 0) - ((ypos - ay) << 3); //xXp_minus_ax ve x8
wire signed [11:0] f_bc = ((ypos - by) << 3) - (bx_minus_xp[2] ? (bh-4-ch)<<2 : 0) - (bx_minus_xp[1] ? (bh-4-ch)<<1 : 0) - (bx_minus_xp[0] ? (bh-4-ch) : 0); //x8
//wire signed [11:0] f_ca = ay - cy; //replaced with "if ay>cy" to save logic units
//optimization: ax = cx, it is known that dx <= xpos <= ax, 0<ax-xpos<8, 0<xpos-dx<8, dy-cy=ch+4-dh, ay-dy=dh+4-ah
//left side
wire [2:0] cx_minus_xp = cx - xpos;
wire signed [3:0] xp_minus_dx = xpos - dx;
//wire signed [11:0] f_ac = ay - cy; //equals f_ca
wire signed [11:0] f_cd = ((ypos - cy)<<3) - (cx_minus_xp[2] ? ((ch+4-dh)<<2) : 0) - (cx_minus_xp[1] ? ((ch+4-dh)<<1) : 0) - (cx_minus_xp[0] ? (ch+4-dh) : 0);
wire signed [11:0] f_da = (xp_minus_dx[2] ? ((dh+4-ah)<<2) : 0) + (xp_minus_dx[1] ? ((dh+4-ah)<<1) : 0) + (xp_minus_dx[0] ? (dh+4-ah) : 0) - ((ypos - dy)<<3);

assign feasible = screen_side ? (~disable_draw && ~bx_minus_xp[3] && ~xp_minus_ax[3] && ~f_ab[11] && ~f_bc[11] && ch+8 > ah ? 1 : 0) :
                                (~disable_draw && xp_minus_ax[3] && ~xp_minus_dx[3] && ch+8 > ah && ~f_cd[11] && ~f_da[11] ? 1 : 0);

endmodule