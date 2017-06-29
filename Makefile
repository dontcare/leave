.PHONY: compile release clean httpparser r3py git_init http protocol request response build

compile: httpparser r3py http protocol request response build

protocol:
	cython leave/protocol.pyx

request:
	cython leave/request.pyx

response:
	cython leave/response.pyx

git_init:
	git submodule update --init --recursive

httpparser:
	cd vendors/httpparser/ && make pico && make
	pip install -e vendors/httpparser

http:
	 gcc -c leave/http.c -O3 -fpic

build:
	python setup.py build_ext --inplace;

r3py:
	cd vendors/r3py/ && make r3 && make
	pip install -e vendors/r3py

all: clean git_init compile

release: compile
	python setup.py sdist upload -r https://pypi.python.org/pypi/leave;

clean:
	rm -rf build/;
	rm -rf dist/;
	rm -f leave/*.so;
