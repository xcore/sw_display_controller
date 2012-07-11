Software Requirements
---------------------

Note that it is assumed that there is already knowledge about how to create a new workspace and import the project to the workspace
The below instructions was followed to work with the project

1) The XDE tool set version 11.11.0 is installed
2) A new workspace is created and the projects app_graphics_demo, module_sdram_burst_new and module_lcd were imported to the workspace
3) The project uses the flash libraries (flashlib.h) provided by the XMOS library. To link the flash libraries to the project

    a. The file ``BuildOptions`` available in the folder `..\app_graphics_demo` is opened
    b. The option ``-lflash`` is added to the ``LINKFLAGS``
    c. It should look like:
         LINKFLAGS = $(OPTIMISATION) -Wcodes -lflash -Wall -g
    d. This will link the flash libraries to the project
4) The project is built to generate the .xe file. The app_graphics_demo.xe file will be generated in the folder `..\\app_graphics_demo\\bin`
5) Now the project is ready for programming to the target device
