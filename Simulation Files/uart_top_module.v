// uart_top module
// This is the top-level module that integrates the Baud_generator,
// Transmitter, and Receiver modules to form a complete UART system.
// It allows setting the system clock frequency and desired baud rate.
module uart_top #(
    parameter CLK_FREQ = 100_000_000, // System clock frequency in Hz (e.g., 100 MHz)
    parameter BAUD_RATE = 9600        // Desired baud rate (e.g., 9600 bps)
) (
    input clk,           // Main system clock
    input reset,         // System reset input
    input i_data_avail,  // Input to the transmitter: data available flag
    input [7:0] i_data_byte,
    input i_rx, // Input to the transmitter: data byte to send
    output o_tx,         // UART TX line output
    output o_tx_done,    // Output from transmitter: transmission complete flag
    output o_tx_active,  // Output from transmitter: transmission active flag
    output [7:0] o_rx_data_byte, // Output from receiver: received data byte
    output o_rx_data_avail, // Output from receiver: received data available flag
    output error,         // Output from receiver: parity error flag
    output [6:0] seg,
    output [7:0] an
);

    //wire tx_to_rx; // Internal wire connecting Transmitter's TX to Receiver's RX
    //wire baud_tick; // Output from baud generator (not directly used by TX/RX logic)
    // This wire can capture the calculated CLKS_PER_BIT from the Baud_generator,
    // though for parameter passing, a localparam is typically used.
    //wire [($clog2(CLK_FREQ/BAUD_RATE)>1?$clog2(CLK_FREQ/BAUD_RATE):1)-1:0] calculated_clks_per_bit;

    // Calculate CLKS_PER_BIT based on the top-level parameters.
    // This value will be passed to the transmitter and receiver modules.
    localparam TOP_CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    // Instantiate Baud Generator
    // This module calculates the CLKS_PER_BIT value based on the system clock
    // and desired baud rate, and provides it as an output parameter.
//    Baud_generator #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) baud_gen_inst (
//        .clk(clk),
//        .reset(reset),
//        //.baud_tick(baud_tick), // Connect baud_tick output (optional for monitoring)
//        .clks_per_bit_val(calculated_clks_per_bit) // Connect the calculated CLKS_PER_BIT value
//    );

    // Instantiate Transmitter
    // The CLKS_PER_BIT parameter for the transmitter is taken from the
    // calculation performed in the uart_top module.
    transmitter #(.CLKS_PER_BIT(TOP_CLKS_PER_BIT)) tx_inst (
        .i_data_avail(i_data_avail),
        .i_data_byte(i_data_byte),
        .clk(clk),
        .reset(reset), // Pass system reset
        .o_active(o_tx_active),
        .o_done(o_tx_done),
        .o_tx(o_tx) // Connect TX output to internal wire
    );

    // Instantiate Receiver
    // The CLKS_PER_BIT parameter for the receiver is also taken from the
    // calculation performed in the uart_top module.
    receiver #(.CLKS_PER_BIT(TOP_CLKS_PER_BIT)) rx_inst (
        .clk(clk),
        .reset(reset), // Pass system reset
        .i_rx(i_rx), // Connect RX input from internal wire
        .o_data_avail(o_rx_data_avail),
        .o_data_byte(o_rx_data_byte),
        .error(error)
    );
   ascii_to_7seg  asci (
    .ascii_char(o_rx_data_byte),    // Input ASCII character (e.g., 8'h30 for '0', 8'h41 for 'A')
    .seg(seg),          // 7-segment outputs (active LOW for common anode)
    .an(an) );

    // Connect the internal TX wire to the external UART TX output
//    assign o_tx = tx_to_rx;

endmodule
