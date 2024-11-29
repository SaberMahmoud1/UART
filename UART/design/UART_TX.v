//////////////////////////////////////////////////////////////////
// the UART Transmitter.  This transmitter is able
// to transmit 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When transmit is complete o_Tx_done will be
// driven high for one clock cycle.
//
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
module UART_sender #(parameter CLKS_PER_BIT) (
    input wire i_clk,           // Clock input
    input wire i_tx_dv,         // Transmit enable input
    input wire [7:0] i_tx_data, // Data to transmit (8 bits)
    output reg o_tx             // UART transmit output
);

    reg [3:0] bit_counter;    // Counter for tracking current bit being transmitted
    reg Start_DATA=0;           // Signal to track the start of transmission
    reg [31:0] wait_bit_time=0;

    // Process triggered on clock edge
    always @(posedge i_clk) begin
       if (wait_bit_time>0) begin          //this will delay the bit time by the number of clks per clock to control the baud rate
            wait_bit_time<=wait_bit_time-1;
            end else begin
            if (i_tx_dv && ~Start_DATA) begin
                o_tx <= 1'b0;     // Transmit start bit
                Start_DATA <= 1; // Set start transmission signal
                bit_counter<=0;
                wait_bit_time<=CLKS_PER_BIT;
            end else if (i_tx_dv && Start_DATA && bit_counter<8) begin
                o_tx <= i_tx_data[bit_counter]; // Transmit data bits sequentially
                bit_counter <= bit_counter + 1; // Increment bit counter
                wait_bit_time<=CLKS_PER_BIT;
            end else if(i_tx_dv && Start_DATA && bit_counter==8) begin
                o_tx <= 1'b1;     // Transmit stop bit or return to idle state
                Start_DATA <= 0; // Reset start transmission signal
                wait_bit_time<=CLKS_PER_BIT;
            end else begin
                o_tx<=1'b1; //stay ideal
            end
        end
    end

endmodule
