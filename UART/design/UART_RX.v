//////////////////////////////////////////////////////////////////////
//the UART Receiver.  This receiver is able to
// receive 8 bits of serial data, one start bit, one stop bit,
// and no parity bit.  When receive is complete o_rx_dv will be
// driven high for one clock cycle.
// 
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87

module UART_receiver #(parameter  CLKS_PER_BIT) (
    input wire i_clk,           // Clock input signal
    input wire i_rx_serial,       // Received data input signal
    output reg [7:0] o_rx_byte,      // Parallel data output (8 bits)
    output reg o_rx_dv                //output data valid indecator 
);

    reg [31:0] wait_bit_time;
    reg [7:0] Serial_To_Parallel_reg;  // Shift register to store received data bits
    reg [3:0] bit_counter;             // Counter for tracking current bit being received
    reg data_valid_one_cycle;
    reg start=0;
    // Process triggered on clock edge
    always @(posedge i_clk) begin
        if(data_valid_one_cycle)begin       //if condition to make the output of the reciver not valid after one cycle 
            data_valid_one_cycle<=0;
            o_rx_dv<=0;
        end
        else if (wait_bit_time>0) begin          //this will delay the bit time by the number of clks per clock to control the baud rate
            wait_bit_time<=wait_bit_time-1;
        end else begin
            if (i_rx_serial == 1'b0 && ~start) begin
                    bit_counter <= 4'd9;               // Start bit detected, prepare to receive 8 data bits and one stop bit
                    Serial_To_Parallel_reg <= 8'b0;    // Reset shift register for new data reception
                    o_rx_byte <= 8'b0;                        // Clear output before receiving data
                    wait_bit_time<=CLKS_PER_BIT;
                    start<=1;
                    o_rx_dv<=0;
            end else if (start && bit_counter > 0) begin
                    if (bit_counter == 1 && i_rx_serial) begin
                        data_valid_one_cycle<=1;
                        o_rx_byte <= Serial_To_Parallel_reg;  // Output received byte when all bits are received
                        o_rx_dv<= 1 ;                         //indicates the data recived is valid
                        bit_counter<=0;
                        start<=0;
                end else if(start) begin
                        Serial_To_Parallel_reg[9-bit_counter] <= i_rx_serial; // Shift in received data bits
                        wait_bit_time<=CLKS_PER_BIT;
                        bit_counter <= bit_counter - 1;    // Decrement bit counter
                end
            end 
            
        end
    end

endmodule
