CC=gcc

naive-matmul: naive-matmul.c
	$(CC) -o $@ $<

.PHONY: time clean

time: naive-matmul
	time ./naive-matmul

clean:
	rm -f naive-matmul
