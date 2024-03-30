`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2024 04:12:19 PM
// Design Name: 
// Module Name: bound_flasher_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bound_flasher_tb();

reg clock;
reg reset_n;
reg flick;

wire [15:0] LED;

bound_flasher uut (reset_n,clock,flick,LED);

initial 
begin

    clock = 1;
    
    reset_n = 0;
    
    flick = 0;
    
    #2
    
    reset_n = 1;
    
    #2
    flick = 1;
    
    #20
    
    flick = 0;
    #600
    
    flick = 0;
    
    #500
    
    reset_n = 0;
    
    #1000
    $finish;
end

always #5 clock = ~ clock;
   
endmodule
