DOT=dot
FORMAT=png
SRC=Network.dot StateMachine.dot
OUT=$(patsubst %,images/%,$(subst .dot,.$(FORMAT),$(SRC)))

all: $(OUT)

images/%.$(FORMAT): %.dot
	$(DOT) -T$(FORMAT) $^ -o $@

clean:
	rm -f $(OUT)
