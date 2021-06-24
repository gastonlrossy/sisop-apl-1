all: BillingExe MenuExe

BillingExe: Billing.o
	gcc -o BillingExe Billing.o

MenuExe: Menu.o
	gcc -o MenuExe Menu.o

Menu.o: Menu.c
	gcc -c Menu.c 

Billing.o: Billing.c 
	gcc -c Billing.c
 	
clean:
	rm Billing.o
	rm Menu.o
