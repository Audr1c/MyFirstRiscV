`timescale 1ns / 1ps
// ==========================================================================
// Module: signExtender
// Description: Extends a smaller width signed number to a larger width,
//              preserving its value.
// ==========================================================================
module signExtender #(parameter WIDTHIN = 16, WIDTHOUT = 32)(
    input   logic [WIDTHIN-1:0]         in,
    output  logic [WIDTHOUT-1:0]        out
);

    // Replicate the sign bit (MSB of the input) for the upper bits of the output,
    // and concatenate it with the original input.
    assign out = {{(WIDTHOUT - WIDTHIN){in[WIDTHIN-1]}}, in};

endmodule