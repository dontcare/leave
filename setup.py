import ast
import os
import re

import setuptools
from setuptools.command.test import test as TestCommand

install_requires = [
    'uvloop',
]

tests_require = install_requires + [
]

ext_modules = [
    setuptools.Extension(
        "leave.protocol",
        sources=[
            "leave/protocol.c",
        ],
        extra_compile_args=['-O3'],
        include_dirs=[
            './vendors/httpparser/httpparser',
            './vendors/r3py/r3py',
        ],
        extra_objects=[
            './vendors/r3py/vendors/r3/src/edge.o',
            './vendors/r3py/vendors/r3/src/match_entry.o',
            './vendors/r3py/vendors/r3/src/memory.o',
            './vendors/r3py/vendors/r3/src/node.o',
            './vendors/r3py/vendors/r3/src/slug.o',
            './vendors/r3py/vendors/r3/src/str.o',
            './vendors/r3py/vendors/r3/src/token.o',
            './vendors/r3py/vendors/r3/3rdparty/libr3ext_la-zmalloc.o'
        ],
        libraries=['pcre'],
    ),
    setuptools.Extension(
        "leave.request",
        sources=[
            "leave/request.c",
        ],
        extra_compile_args=['-O3'],
        extra_objects=[
            './vendors/httpparser/picohttpparser.o',
        ],
        include_dirs=[
            './vendors/httpparser/httpparser',
            './vendors/r3py/r3py',
        ],
    ),
    setuptools.Extension(
        "leave.response",
        sources=[
            "leave/response.c",
        ],
        extra_compile_args=['-O3'],
        extra_objects=[
            './vendors/httpparser/picohttpparser.o',
            './http.o',
        ],
        include_dirs=[
            './vendors/httpparser/httpparser',
            './vendors/r3py/r3py',
        ],
    ),
]

dependency_links = []
entry_points = {}


_version_re = re.compile(r'__version__\s+=\s+(.*)')

with open('leave/__init__.py', 'rb') as f:
    __version__ = str(ast.literal_eval(_version_re.search(
        f.read().decode('utf-8')).group(1)))


class Tox(TestCommand):
    user_options = [('tox-args=', 'a', "Arguments to pass to tox")]

    def initialize_options(self):
        TestCommand.initialize_options(self)
        self.tox_args = None

    def finalize_options(self):
        TestCommand.finalize_options(self)
        self.test_args = []
        self.test_suite = True

    def run_tests(self):
        import tox
        import shlex
        args = self.tox_args
        if args:
            args = shlex.split(self.tox_args)
        tox.cmdline(args=args)


try:
    current_dir = os.path.abspath(os.path.dirname(__file__))
    README = open(os.path.join(current_dir, 'README.md')).read()
    CHANGES = open(os.path.join(current_dir, 'CHANGES.txt')).read()
except IOError:
    README = CHANGES = ''

setuptools.setup(
    name="leave",
    version=__version__,
    description=(""),
    long_description=README + "\n\n" + CHANGES,
    classifiers=[
        'Programming Language :: C',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: Implementation :: CPython',
        'Topic :: Internet :: WWW/HTTP',
    ],
    keywords='',
    author="Aleksei Sargin",
    author_email="alexei.sargin@gmail.com",
    url="https://github.com/dontcare/leave",
    packages=['httpparser'] + setuptools.find_packages(),
    include_package_data=True,
    zip_safe=False,
    install_requires=install_requires,
    tests_require=tests_require,
    dependency_links=dependency_links,
    test_suite='tests',
    entry_points=entry_points,
    cmdclass=dict(test=Tox),
    ext_modules=ext_modules,
)
