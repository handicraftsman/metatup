# 01 - Get This Done

Run:

```sh
../../metatup
```

What it shows:

- Function-oriented Tupfiles with `call` and `spawn`
- Local package labels like `//lib`
- `$(globs ...)` to discover inputs
- `$(groups ...)` for returned outputs
- `$(abs ...)` for exported absolute paths
- `$(prefix_paths ...)` to build a downstream path list

Outputs:

- `summary.txt`
- `bundle.txt`
- `merged-abs.txt`
