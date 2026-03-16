# 06 - vcpkg Manifest

Run:

```sh
../../metatup
```

What it shows:

- The standard `@std//vcpkg` helper
- Manifest inputs tracked explicitly
- A deterministic install root under `build/`
- Returned include/lib/bin prefix paths

Outputs:

- `build/vcpkg_installed/x64-linux/include/fake.h`
- `build/vcpkg_installed/x64-linux/lib/libfake.a`
- `build/vcpkg_installed/x64-linux/bin/fake-tool`
- `app.txt`
