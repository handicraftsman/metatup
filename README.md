# MetaTup

MetaTup is an expansion of Tup, mostly done with OpenAI Codex, that, while
straying away from original philosophy, adapts the mental model for bigger,
more complex projects, while also improving structural clarity.

Think of MetaTup's relation to Tup as to how C++ is related to C.

## Introduced capabilities

* Functions
  * In-function rules blocks
  * Binds expressions
  * Calling functions calls them in current Tupfile's context, while spawning them - in their own contexts
* `$(globs ...)` syntax for resolving globs in-place, useful when passing inputs to functions
* `$(groups ...)` syntax for expanding built groups for returning from a function
* `$(abs ...)` syntax for returning paths to single files
* TupBuild.yaml files, allowing you to request building one or more functions in given directories
* Dists syntax - for preparing redistributable prefixes faster
  * Something like
    ```tup
    function demo {
      bind brdir := "brdir"

      fbind { "bin": bin } := spawn "./lib/Tupfile" cc_binary ({
        "sources": ""
      })

      -- bins is an internal dist ID
      fbind bins := dist {
        at "$(brdir)" as $(bin) => at "/bin" as $(realname $(bin))
      }

      fbind headers := dist { ... }
      
      fbind dist := dist {
        mounts $(bins) at "/"
        mounts $(headers) at "/"
      }

      return { "dist": "$(dist)" }
    }
    ```
    ```yaml
    builds:
      - name: foo
        ...
        dists:
          # Can have multiple
          - from_return: dist
            path: ./foo.dist
    ```

---

# Tup

http://gittup.org/tup

## About Tup

Tup is a file-based build system for Linux, OSX, and Windows. It takes
as input a list of file changes and a directed acyclic graph (DAG). It
then processes the DAG to execute the appropriate commands required to
update dependent files. Updates are performed with very little overhead
since tup implements powerful build algorithms to avoid doing
unnecessary work. This means you can stay focused on your project rather
than on your build system.

Further information can be found at http://gittup.org/tup
