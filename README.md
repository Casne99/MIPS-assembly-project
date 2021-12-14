# MIPS-assembly-project

This is a simple assembly project that uses MIPS ISA and runs on MARS, an IDE for MIPS Assembly Language Programming.  
**You need Java in order to run MARS**.

You can download MARS here: http://courses.missouristate.edu/kenvollmar/mars/download.htm  
You can download Java here: https://www.java.com/it/download/manual.jsp


## What does the program do

The program asks for a *height value* (integer) and *two codes* (either 0 or 1) that you should digit.
The height value determines the height of two pyramids that will be printed on the bitmap display.
Once the height value is inserted you will be asked the left pyramid code: 
                                              code 0 will determine the printing of an empty pyramid, meaning that you will see the perimeter only.
                                              Code 1 will determine the printing of a full pyramid, meaning that you will see the perimeter and the area.
Another code is going to be asked you for the right pyramid.
                                              
                                              
## Instructions:

Download the code from this repository and open it in the MARS simulator.
In order to see the output you should enable the bitmap display under the "Tools" label on the top menu.
Once the bitmap dispaly is placed, make sure that its four settings (Unit width, Unit Height, Display Width, Display Height) match the four ones declared in the code under **.data**

You can change the display's base address, the value must match with the one stored in the *addr* variable under **.data**.  
Now, click on the "Connect to MIPS" button.

You are now ready to run the code:

First of all, **assemble the code**: you can do this by clicking on the icon with a wrench and a screwdriver on the top menu, then click on the icon on the right to run the program.
You will be asked three values as stated in the "What does the program do" label of this README.
Not all pyramids can be printed on the bitmap display. 
On a 256 x 256 display with 8 x 8 units the maximum height value is 15, you can try the program with this settings.

If the height value is too high for a given display or if you insert codes that are different from zero and from 1 an error message will be printed on the console.

You can change the pyramid's color in the **.data** segment by changing the *color* variable with the value of the 24-bit color code you want to use.

