# MIPS-assembly-project

This is a simple assembly project that uses MIPS ISA and runs on MARS, an IDE for MIPS Assembly Language Programming.  
**You need Java installed on your computer in order to run MARS**.

DOWNLOAD:
[MARS](http://courses.missouristate.edu/kenvollmar/mars/download.htm)\
[JAVA](https://www.java.com/it/download/manual.jsp)


## What does the program do

The program asks for a **height value** (integer) and **two codes** (either 0 or 1) that you should digit.
The height value determines the height of two pyramids that will be printed on the bitmap display.
Once the height value is inserted you will be asked the left pyramid code: 
                                              code 0 will determine the printing of an empty pyramid, meaning that you will see the perimeter only.
                                              Code 1 will determine the printing of a full pyramid, meaning that you will see the perimeter and the area.
Another code is going to be asked you for the right pyramid.
                                              
                                              
## Instructions:

Download the code from this repository and open it in the MARS simulator.
In order to see the output you should enable the bitmap display under the "Tools" label on the top menu.
Once the bitmap dispaly is placed, make sure that its four settings (Unit width, Unit Height, Display Width, Display Height) match the four ones declared in the code under **.data**.

You can change the display's base address, the value must match with the one stored in the *addr* variable under **.data**.  
Now, click on the "Connect to MIPS" button.

You are now ready to run the code:

First of all, **assemble the code**: you can do this by clicking on the icon with a wrench and a screwdriver on the top menu, then click on the icon on the right to run the program.
You will be asked three values as stated in the "What does the program do" label of this README.  
Insert one value at a time, then return.  
Not all pyramids can be printed on the bitmap display. 
On a 256 x 256 display with 8 x 8 units the maximum height value is 15, you can try the program with these settings.

If the height value is too high for a given display or if you insert codes that are different from 0 and from 1 an error message will be printed on the console.

You can change the pyramid's color in the **.data** segment by assigning to the *color* variable the value of the 24-bit color code you want to use. 
Default is 0x8A33FF.

In order to see how the pyramids are printed I added a sleeptime that causes the process to sleep for the number of milliseconds defined in the *sleeptime* variable under **.data**.  
The sleeptime syscall(code 32) is called in between the printing of every single unit of the pyramids.  
You can modify the *sleeptime* value if you want a faster or slower process.


