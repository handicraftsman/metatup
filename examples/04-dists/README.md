# 04 - Dist Materialization

Run:

```sh
mkdir -p build
cd build
../../../metatup gen runtime -D package=./release
../../../metatup
```

What it shows:

- Functions returning a named dist prefix
- `metatup gen -D` materializing that return into a filesystem prefix
- A simple packaging flow that keeps the install tree in generated outputs

Outputs:

- `build/runtime.build/bin/demo-tool`
- `build/release/bin/demo-tool`
- `build/release/share/README.txt`
