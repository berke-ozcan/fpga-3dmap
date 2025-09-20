module pattern_drawer(
    input clk,              //25.2 MHz
    input draw_area,        //draw area: x = 0-639, y = 0-479
    input [9:0] xpos,
    input [9:0] ypos,
    input pll_lock,
    output [23:0] bgr24
);
//lookup table for height values
localparam [7:0] map [0:255] = '{
            8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,
            8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,
            8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,
            8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,
            8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,
            8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,
            8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,
            8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,
            8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,
            8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,
            8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,
            8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,
            8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,
            8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,
            8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,
            8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,  8'd50,       8'd50
};

//assign value = map[row*16 + col];

wire [7:0] b_value, g_value, r_value;

//wire screen_side = 1;
wire screen_side = xpos > 319 ? 1 : 0;
wire [4:0] line = screen_side ? (xpos < 440 ? (xpos - 312)>>3 : 0) : (xpos > 200 ? (327 - xpos)>>3 : 0);

//TEST BLOCKS
//wire [4:0] line = (xpos > 200 && xpos < 320) ? (328 - xpos)>>3 : 0; //sadece sol taraf
//wire [4:0] line = (xpos > 319 && xpos < 440) ? (xpos - 312)>>3 : 0; //sadece sağ taraf
//wire [4:0] line = (xpos > 319 && xpos < 349) ? (xpos-314)/6 : 0;
//wire [4:0] line = 5;

//map coordinates of the point (a) according to i and line
wire [3:0] a_mapx = screen_side ? (15) : (16 - line);
wire [3:0] a_mapy = screen_side ? (16 - line) : (15); //31 = error code, xpos is outside the pattern area

wire f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,f13,f14,f15;
//draw triangle rows one by one
draw_triangle test1(.screen_side(screen_side),.line(line),.i_th_triangle(0),.a_mapx(a_mapx),.a_mapy(a_mapy),.xpos(xpos), .ypos(ypos),
//         vvvvvvv  ts pmo
.ah(map[(({4'b0000, a_mapx})<<4) + a_mapy]),        .bh(map[((a_mapx)<<4) + a_mapy - 1]),    .ch(map[((a_mapx - 1)<<4) + a_mapy - 1]),
.dh(map[((a_mapx - 1)<<4) + a_mapy]),    .feasible(f1));
draw_triangle test2(.screen_side(screen_side),.line(line),.i_th_triangle(1),.a_mapx(a_mapx),.a_mapy(a_mapy),.xpos(xpos),.ypos(ypos),
.ah(map[((a_mapx - 1)<<4) + a_mapy - 1]),.bh(map[((a_mapx - 1)<<4) + a_mapy - 2]),.ch(map[((a_mapx - 2)<<4) + a_mapy - 2]),
.dh(map[((a_mapx - 2)<<4) + a_mapy - 1]), .feasible(f2));
draw_triangle test3(.screen_side(screen_side),.line(line),.i_th_triangle(2),.a_mapx(a_mapx),.a_mapy(a_mapy),.xpos(xpos),.ypos(ypos),
.ah(map[((a_mapx - 2)<<4) + a_mapy - 2]),.bh(map[((a_mapx - 2)<<4) + a_mapy - 3]),.ch(map[((a_mapx - 3)<<4) + a_mapy - 3]),
.dh(map[((a_mapx - 3)<<4) + a_mapy - 2]), .feasible(f3));
draw_triangle test4(.screen_side(screen_side),.line(line),.i_th_triangle(3),.a_mapx(a_mapx),.a_mapy(a_mapy),.xpos(xpos),.ypos(ypos),
.ah(map[((a_mapx - 3)<<4) + a_mapy - 3]),.bh(map[((a_mapx - 3)<<4) + a_mapy - 4]),.ch(map[((a_mapx - 4)<<4) + a_mapy - 4]),
.dh(map[((a_mapx - 4)<<4) + a_mapy - 3]), .feasible(f4));

draw_triangle test5(.screen_side(screen_side),.line(line),.i_th_triangle(4),.a_mapx(a_mapx),.a_mapy(a_mapy),.xpos(xpos),.ypos(ypos),
.ah(map[((a_mapx - 4)<<4) + a_mapy - 4]),.bh(map[((a_mapx - 4)<<4) + a_mapy - 5]),.ch(map[((a_mapx - 5)<<4) + a_mapy - 5]),
.dh(map[((a_mapx - 5)<<4) + a_mapy - 4]), .feasible(f5));
draw_triangle test6(.screen_side(screen_side),.line(line),.i_th_triangle(5),.a_mapx(a_mapx),.a_mapy(a_mapy),.xpos(xpos),.ypos(ypos),
.ah(map[((a_mapx - 5)<<4) + a_mapy - 5]),.bh(map[((a_mapx - 5)<<4) + a_mapy - 6]),.ch(map[((a_mapx - 6)<<4) + a_mapy - 6]),
.dh(map[((a_mapx - 6)<<4) + a_mapy - 5]),.feasible(f6));
draw_triangle test7(.screen_side(screen_side),.line(line),.i_th_triangle(6),.a_mapx(a_mapx),.a_mapy(a_mapy),.xpos(xpos),.ypos(ypos),
.ah(map[((a_mapx - 6)<<4) + a_mapy - 6]),.bh(map[((a_mapx - 6)<<4) + a_mapy - 7]),.ch(map[((a_mapx - 7)<<4) + a_mapy - 7]),
.dh(map[((a_mapx - 7)<<4) + a_mapy - 6]),.feasible(f7));
draw_triangle test8(.screen_side(screen_side),.line(line),.i_th_triangle(7),.a_mapx(a_mapx),.a_mapy(a_mapy),.xpos(xpos),.ypos(ypos),
.ah(map[((a_mapx - 7)<<4) + a_mapy - 7]),.bh(map[((a_mapx - 7)<<4) + a_mapy - 8]),.ch(map[((a_mapx - 8)<<4) + a_mapy - 8]),
.dh(map[((a_mapx - 8)<<4) + a_mapy - 7]),.feasible(f8));

draw_triangle test9(.screen_side(screen_side),.line(line),.i_th_triangle(8),.a_mapx(a_mapx),.a_mapy(a_mapy),.xpos(xpos),.ypos(ypos),
.ah(map[((a_mapx - 8)<<4) + a_mapy - 8]),.bh(map[((a_mapx - 8)<<4) + a_mapy - 9]),.ch(map[((a_mapx - 9)<<4) + a_mapy - 9]),
.dh(map[((a_mapx - 9)<<4) + a_mapy - 8]),.feasible(f9));
draw_triangle test10(.screen_side(screen_side),.line(line),.i_th_triangle(9),.a_mapx(a_mapx),.a_mapy(a_mapy),.xpos(xpos),.ypos(ypos),
.ah(map[((a_mapx - 9)<<4) + a_mapy - 9]),.bh(map[((a_mapx - 9)<<4) + a_mapy - 10]),.ch(map[((a_mapx - 10)<<4) + a_mapy - 10]),
.dh(map[((a_mapx - 10)<<4) + a_mapy - 9]),.feasible(f10));
draw_triangle test11(.screen_side(screen_side),.line(line),.i_th_triangle(10),.a_mapx(a_mapx),.a_mapy(a_mapy),.xpos(xpos),.ypos(ypos),
.ah(map[((a_mapx - 10)<<4) + a_mapy - 10]),.bh(map[((a_mapx - 10)<<4) + a_mapy - 11]),.ch(map[((a_mapx - 11)<<4) + a_mapy - 11]),
.dh(map[((a_mapx - 11)<<4) + a_mapy - 10]),.feasible(f11));
draw_triangle test12(.screen_side(screen_side),.line(line),.i_th_triangle(11),.a_mapx(a_mapx),.a_mapy(a_mapy),.xpos(xpos),.ypos(ypos),
.ah(map[((a_mapx - 11)<<4) + a_mapy - 11]),.bh(map[((a_mapx - 11)<<4) + a_mapy - 12]),.ch(map[((a_mapx - 12)<<4) + a_mapy - 12]),
.dh(map[((a_mapx - 12)<<4) + a_mapy - 11]),.feasible(f12));

draw_triangle test13(.screen_side(screen_side),.line(line),.i_th_triangle(12),.a_mapx(a_mapx),.a_mapy(a_mapy),.xpos(xpos),.ypos(ypos),
.ah(map[((a_mapx - 12)<<4) + a_mapy - 12]),.bh(map[((a_mapx - 12)<<4) + a_mapy - 13]),.ch(map[((a_mapx - 13)<<4) + a_mapy - 13]),
.dh(map[((a_mapx - 13)<<4) + a_mapy - 12]),.feasible(f13));

//draw_triangle test14(.screen_side(screen_side),.line(line),.i_th_triangle(13),.a_mapx(a_mapx),.a_mapy(a_mapy),.xpos(xpos),.ypos(ypos),
//.ah(map[((a_mapx - 13)<<4) + a_mapy - 13]),.bh(map[((a_mapx - 13)<<4) + a_mapy - 14]),.ch(map[((a_mapx - 14)<<4) + a_mapy - 14]),
//.dh(map[((a_mapx - 14)<<4) + a_mapy - 13]),.feasible(f14));
wire [5:0] a_index_for_14 = line==1 ? 34 : screen_side ? 33 : 18;
wire [4:0] c_index_for_14 = line==1 ? 17 : screen_side ? 16 : 1;
wire [4:0] d_index_for_14 = line==1 ? 18 : screen_side ? 17 : 2;
draw_triangle test14(.screen_side(screen_side),.line(line),.i_th_triangle(13),.a_mapx(a_mapx),.a_mapy(a_mapy),.xpos(xpos),.ypos(ypos),
.ah(map[a_index_for_14]),.bh(map[a_index_for_14-1]), .ch(map[c_index_for_14]), 
.dh(map[d_index_for_14]),.feasible(f14));
//optimization: there are only three possible point (a) and its map coordinates are only relative to line(0|1) and screen side(0|1)
draw_triangle test15(.screen_side(screen_side),.line(line),.i_th_triangle(14),.a_mapx(a_mapx),.a_mapy(a_mapy),.xpos(xpos),.ypos(ypos),
.ah(map[17]),.bh(map[16]),.ch(map[0]), .dh(map[1]),.feasible(f15)); 
//optimization: there is only one possible point (a) and its map coordinates are known


assign feasible_all = f1|f2|f3|f4|f5|f6|f7|f8|f9|f10|f11|f12|f13|f14|f15;
assign g_value = feasible_all ? 150 : 0;
//assign g_value = feasible_all ? map[(({4'b0000, a_mapx})<<4) + a_mapy] : 0;
//assign r_value = feasible_all ? map[((a_mapx - i)<<4) + a_mapy - i] : 0;
assign bgr24 = {b_value, g_value, r_value};

endmodule