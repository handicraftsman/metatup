# 02 - Components, Profiles, and Compiledb

Run:

```sh
mkdir -p build
cd build
../../../metatup gen app -P with-banner
../../../metatup
```

What it shows:

- `MetaTup.yaml` component definitions
- `metatup gen` materializing `TupBuild.yaml`
- Profiles with `set`
- `binds` from generated arguments into Tupfile function arguments
- `case` mapping during binding
- Conditional dependencies with `require_if`
- Local component references like `//tools:banner`
- `auto_compiledb: true`

Outputs:

- `build/app.build/app`
- `build/app__tools_banner.build/tools/banner.txt`
- `build/compile_commands.json`
