
# -----------------------------------------------------------------------------
# imports
# -----------------------------------------------------------------------------

import types


# -----------------------------------------------------------------------------
# test_import_works()
# -----------------------------------------------------------------------------

def test_import_works():
    import mypackage
    assert type(mypackage) == types.ModuleType, "Module wasn't imported as a python module."


# -----------------------------------------------------------------------------
# test_public_api()
# -----------------------------------------------------------------------------

def test_public_api():
    import mypackage
    EXPECTED_API = sorted(['MyExportedClass', 'my_module', 'my_other_module', 'my_public_func', 'package_test'])
    ACTUAL_API = sorted(filter(lambda n: not n.startswith('__'), dir(mypackage)))
    assert ACTUAL_API == EXPECTED_API, "API doesn't match previously defined."

