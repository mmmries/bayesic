This was a very interesting learning experience, but ultimately my first benchmarks led me to abandon this branch.
I got the basic training and classifying working.
I manually do some benchmarks following the same pattern as `benchmarks/training_and_matching.exs` with a set of ~10k candidate strings and a matching set of 194 string.
I found that it was taking ~320ms to train a matcher on 10k strings, and ~1.4ms per attempt to match.
This is only slightly better than the native elixir performance of 2ms per match with this same data set.
I suspect that the overhead of serializing/deserializing over the port is dampening the peformance improvement of using a mutable map in go.

If anyone (me included) is every interested in trying this further you can test it with the following:

```
$ git clone <this repo>
$ git checkout <this branch>
$ cd bayesic/go
$ export GOPATH=$(PWD)
$ go get github.com/jonas747/etf
$ go get github.com/goerlang/port
$ go build port.go  && mv port ../priv/bayesic_port
$ cd ../
$ mix test
```
