# 05 - External Project

Run:

```sh
../../metatup
```

What it shows:

- The standard `@std//external` helper
- Separate configure, build, and install stages
- Returned prefix/include/bin paths for downstream rules

Outputs:

- `build/ext/external_prefix/include/demo.h`
- `build/ext/external_prefix/bin/demo-tool`
- `app.txt`
