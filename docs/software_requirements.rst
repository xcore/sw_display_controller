Software Requirements
---------------------

Note: It is assumed that the user knows how to create a new workspace and import the project to the workspace
Please follow the below instructions to work with the project

1) Install XDE tool set version 11.11.0
2) Create a new workspace and import the projects app_graphics_demo, module_sdram_burst_new and module_lcd
3) The project uses the flash libraries (flashlib.h) provided by the XMOS library. To link the flash libraries to the project

    a. Open the file ``BuildOptions`` available in the folder `..\app_graphics_demo`
    b. Add the option ``-lflash`` to the ``LINKFLAGS``
    c. It should look like:
         LINKFLAGS = $(OPTIMISATION) -Wcodes -lflash -Wall -g
    d. This will link the flash libraries to the project
4) Build the project to generate the .xe file. The app_graphics_demo.xe file will be generated 
   in the folder `..\app_graphics_demo\bin`
5) Now the project is ready for programming to the target device
