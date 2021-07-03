#include "util.h"

int main() {
	int i,k;
	char c;
	char ca[256];
	
	puts("\rHello, MiRiscV\r");

	for (k = 0; k < 10; k++) {
		/* delay loop */
		for (i = 0; i < 3000000; i++) {
			__asm__("");
		}
		/* sign of life */
		putchar('0'+k);
	}
	putchar('\r');
	putchar('\n');
	for (i='A'; i<='Z'; i++)
	{
		ca[i] = (unsigned char)i;
	}
	for (i='A'; i<='Z'; i++)
	{
		c = ca[i];
		putchar(c);
	}
	putchar('\r');
	putchar('\n');
	
	return 0;
}
