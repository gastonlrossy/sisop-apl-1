all: client4 server4
    
client4:
	g++ -o client4.exe client4.cpp -lpthread -lrt

server4:
	g++ -o server4.exe server4.cpp -lpthread -lrt

clean:
	rm client4 server4 /dev/shm/interaction /dev/shm/clients /dev/shm/sharedMem

