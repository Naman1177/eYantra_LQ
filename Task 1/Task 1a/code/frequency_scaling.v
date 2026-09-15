// Logic Quest Bot : Task 1A : Frequency Scaling
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design a module which will scale down the 50MHz Clock Frequency to clk_5MHz

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

//Frequency Scaling
//Inputs : clk_50MHz
//Output : 5MHz


module frequency_scaling (
    input clk_50MHz,
    input reset_n,
    output reg clk_5MHz
);

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////


reg [2:0] counter;
always @(posedge clk_50MHz or negedge reset_n) begin
    if (!reset_n) begin
        
        counter <= 3'd4;
        clk_5MHz <= 1'b0;
    end else begin
           
        if (counter == 3'd4) begin
            counter <= 3'b000;
            clk_5MHz <= ~clk_5MHz; // Toggle the output clock
        end else begin
            counter <= counter + 1'b1;
        end
    end

end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule