Modules that provide higher-level access to Javascript APIs, and also
fallbacks due to browser support or local policies.  They also compile
under UNIX, to make it easier to test logic without having to live in
Javascript-land.

## Usually persistent LocalStorage

The LocalStorage module binds to HTML5 LocalStorage key/value store, with a
fallback to a memory-based version if a persistent store isn't available.

See `lib_test/localstorage_looper.ml` for a demo and make sure you open the
developer console to see the log output.  If you `make` this repo, the built
version of the demo will be in `_build/lib_test/index.html`.

The `lib_test/localstorage_filler.ml` will continuously write until it has
filled up its quota.
