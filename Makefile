CC = g++
CFLAG = -std = c++11
LIB =-L/usr/local/MATLAB/R2013b/bin/glnxa64 -lmat -lmx -lmex -leng -lmwfl -lmwi18n -lut -L. -lblas  #-lboost_filesystem 
FLAG = -Wl,-rpath,/usr/local/MATLAB/R2013b/bin/glnxa64
INC = -I/usr/local/MATLAB/R2013b/extern/include

main: main.o linear.o tron.o
	$(CC) main.o linear.o tron.o -o main $(LIB) $(FLAG)
main.o:main.cpp linear.h
	$(CC) -c -g main.cpp $(INC)
linear.o:linear.cpp linear.h tron.h
	$(CC) -c -g linear.cpp
tron.o: tron.cpp tron.h
	$(CC) -c -g tron.cpp


clean:
	@echo "cleanning project"
	rm -rf *.o main
	@echo "clean completed"

.PHONY:clean
