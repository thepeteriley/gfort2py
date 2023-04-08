# SPDX-License-Identifier: GPL-2.0+
import ctypes
import numpy as np
import os

from .module_parse import module
from .fVar import *
from .fProc import *

_TEST_FLAG = os.environ.get("_GFORT2PY_TEST_FLAG") is not None


class fFort:
    _initialized = False

    def __init__(self, libname, mod_file):
        self._lib = ctypes.CDLL(libname)
        self._mod_file = mod_file
        self._module = module(self._mod_file)

        self._initialized = True

    def keys(self):
        return self._module.keys()

    def __contains__(self, key):
        return key in self._module.keys()

    def __dir__(self):
        return self.keys()

    def __getattr__(self, key):
        if key in self.__dict__:
            return self.__dict__[key]

        if "_initialized" in self.__dict__:
            if self._initialized:
                if key not in self.keys():
                    raise AttributeError(f"{self._mod_file}  has no attribute {key}")

            if self._module[key].is_variable():
                f = fVar(self._module[key], allobjs=self._module)
                f.in_dll(self._lib)
                return f.value
            elif self._module[key].is_procedure():
                return fProc(self._lib, self._module[key], self._module)
            elif self._module[key].is_parameter():
                return fParam(self._module[key]).value
            else:
                raise NotImplementedError(
                    f"Object type {self._module[key].flavor()} not implemented yet"
                )

    def __setattr__(self, key, value):
        if key in self.__dict__:
            self.__dict__[key] = value
            return

        if "_initialized" in self.__dict__:
            if self._initialized:
                if self._module[key].is_variable():
                    f = fVar(self._module[key], allobjs=self._module)
                    f.in_dll(self._lib)
                    f.value = value
                    return
                elif self._module[key].is_parameter():
                    raise AttributeError("Can not alter a parameter")
                else:
                    raise NotImplementedError(
                        f"Object type {self._module[key].flavor()} not implemented yet"
                    )

        self.__dict__[key] = value

    @property
    def __doc__(self):
        return f"MODULE={self._module.filename}"

    def __str__(self):
        return f"{self._module.filename}"


def mod_info(mod_file):
    return module(mod_file)
