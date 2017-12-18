# Bayesic

A string matching library similar to a NaiveBayes classifier, but optimized for use cases where you have many possible matches.

This is especially useful if you have two large lists of names/titles/descriptions to match with each other.

## Usage

Pull in this library from hex.pm. Then in your project you can do the following.

```elixir
matcher = Bayesic.new()
          |> Bayesic.train(["it","was","the","best","of","times"], "novel")
          |> Bayesic.train(["tonight","on","the","seven","o'clock"], "news")

Bayesic.classify(matcher, ["the","best","of"])
# => %{"novel" => 1.0, "news" => 0.667}
Bayesic.classify(matcher, ["the","time"])
# => %{"novel" => 0.667, "news" => 0.667}
```

## How It Works

This library uses the basic idea of [Bayes Theorem](https://en.wikipedia.org/wiki/Bayes%27_theorem).

It records which tokens it has seen for each possible classification. Later when you pass a set of tokens and ask for the most likely classification it looks for all potential matches and then ranks them by considering the probabily of any given match according to the tokens that it sees.

Tokens which exist in many records (ie not very unique) have a smaller impact on the probability of a match and more unique tokens have a larger impact.
