DOT=dot
FORMAT=png
SRC=Network.dot
OUT=$(patsubst %,images/%,$(subst .dot,.$(FORMAT),$(SRC)))

all: $(OUT)

$(OUT): $(SRC)
	$(DOT) -T$(FORMAT) $^ -o $@

clean:
	rm -f $(OUT)
