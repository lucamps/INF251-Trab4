module statem(clk, reset, rc, nrc);
input clk, reset; 
input  rc; 
output nrc;
reg  [1:0]state;
parameter r0=2'd0, r1=2'd1, c0=2'd2, c1=2'd3;
  assign nrc = ( state == r0 || state == r1 );
always @(posedge clk or negedge reset)
     begin
          if (reset==0)
               state = r0;
          else
               case (state)
                 r0:
                   if ( rc == 1'b1 ) state = r1;
                 r1:
                   if ( rc == 1'b0 ) state = c0;
                 c0:
                   if ( rc == 1'b1 ) state = c1;
                 c1:
                   if ( rc == 1'b0 ) state = r0;
               endcase
     end
endmodule

module count100(input clk, input rst, input ud, output [6:0] Count, output loop);  reg [6:0] Count;
  always @ (posedge clk or negedge rst)
begin
  if (~rst) 
    Count <= 0;   // reset register
  else if ( Count == 99  & ud) 
    Count <= 0; 
  else if (Count == 0 & ~ud)
    Count <= 99;
  else if (ud)
    Count <= Count + 1;  // increment register
  else
    Count <= Count - 1;
end
assign loop = (Count == 99)&ud |  (Count==0) & ~ud;
endmodule

module count59(input clk, input rst, input ud, output [5:0] Count, output loop);  reg [5:0] Count;
  always @ (posedge clk or negedge rst)
begin
  if (~rst) 
    Count <= 0;   // reset register
  else if ( Count == 59  & ud) 
    Count <= 0; 
  else if (Count == 0 & ~ud)
    Count <= 59;
  else if (ud)
    Count <= Count + 1;  // increment register
  else
    Count <= Count - 1;
end
assign loop = (Count == 59)&ud |  (Count==0) & ~ud;
endmodule


module count23(input clk, input rst, input ud, output [4:0] Count);  reg [4:0] Count;
  always @ (posedge clk or negedge rst)
begin
  if (~rst) 
    Count <= 0;   // reset register
  else if ( Count == 23 & ud) 
    Count <= 0; 
  else if ( Count == 0 & ~ud) 
    Count <= 23; 
  else if (ud)
    Count <= Count + 1;  // increment register
  else
    Count <= Count - 1; 
end
endmodule


module relogio(input clk, res, startstop, zera, ud,
               input rc, output [6:0]centsegundos,output [5:0] segundos,minutos,
               output[4:0] hora);
wire outs,outs1,outs2,routs,routs1,routs2;
wire enable, nr;
wire [6:0] centsc,centsr;	//centesimo de segundo
wire [5:0] sc,sr,mc,mr;
wire [4:0] hc,hr;

assign enable = startstop & clk;
assign nr = res & zera;

/****** Cronometro *******/
count100 centseg(enable,res,ud,centsc,outs);
count59 seg(outs,nr,ud,sc,outs1);
count59 min(~outs1,nr,ud,mc,outs2);
count23 hor(~outs2,nr,ud,hc);

/********* Relogio *********/
count100 rcentseg(clk,res,1'b1,centsr,routs);
count59 rseg(~routs,res,1'b1,sr,routs1);
count59 rmin(~routs1,res,1'b1,mr,routs2);
count23 rhor(~routs2,res,1'b1,hr);

/********* MUX *********/
assign hora = (nrc)? hr:hc;
assign minutos = (nrc)? mr:mc;
assign segundos = (nrc)? sr:sc;
assign centsegundos = (nrc)?centsr:centsc; 

wire nrc;
statem maq(clk,res,rc,nrc);

endmodule

module top(input clk, res, startstop, zera, ud,
               input rc,output [6:0] centsegundos,
               output [5:0] segundos,minutos,
               output[4:0] hora);
  relogio r(clk, res, startstop, zera, ud,
               rc, centsegundos,segundos,minutos,hora);
endmodule
