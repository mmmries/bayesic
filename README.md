# Bayesic

A string matching library similar to a NaiveBayes classifier, but optimized for use cases where you have many possible matches.

This is especially useful if you have two large lists of names/titles/descriptions to match with each other.

## Usage

Pull in this library from hex.pm. Then in your project you can do the following.

```elixir
matcher = Bayesic.Trainer.new()
          |> Bayesic.train(["it","was","the","best","of","times"], "novel")
          |> Bayesic.train(["tonight","on","the","seven","o'clock"], "news")
          |> Bayesic.finalize()

Bayesic.classify(matcher, ["the","best","of"])
# => %{"novel" => 1.0, "news" => 0.667}
Bayesic.classify(matcher, ["the","time"])
# => %{"novel" => 0.667, "news" => 0.667}
```

## How It Works

This library uses the basic idea of [Bayes Theorem](https://en.wikipedia.org/wiki/Bayes%27_theorem).

It records which tokens it has seen for each possible classification. Later when you pass a set of tokens and ask for the most likely classification it looks for all potential matches and then ranks them by considering the probabily of any given match according to the tokens that it sees.

Tokens which exist in many records (ie not very unique) have a smaller impact on the probability of a match and more unique tokens have a larger impact.

## Performance

Performance varies a lot depending on the size and type of your data.
I have a built in a benchmark that you can run via `mix run benchmarks/training_and_classifying.exs`.
This benchmark loads in 60k movies and tokenizes their titles by finding all the words (downcased) in the title of the movie.
We benchmark the time it takes to train on that dataset and also the time it takes to do a specific classification as well as a more generic classification.

Currently this benchmark shows the following results on my laptop:

```
Name                    ips        average  deviation         median         99th %
match 1 word         1.21 M     0.00083 ms  ±2729.82%           0 ms           0 ms
match 3 words        0.74 M     0.00136 ms  ±1631.93%           0 ms           0 ms
training          0.00001 M      142.06 ms     ±5.56%      139.68 ms      170.46 ms
```

This means it takes ~1.2sec to train the classifier on 60k titles and 10 - 26µs to do a classification of tokens on that classifier.

## Will It Work For My Dataset?

I don't know, but you can pretty easily test it using the `benchmarks/training_and_matching.exs` script in this project.
Just generate 2 CSV files:

* The first file should have 2 columns `source_string` and `source_id`
* The second file should have 2 columns `match_string` and `source_id`

Then run `mix run benchmarks/test_your_data.exs path/to/first_file.csv path/to/second_file.csv`.

> The benchmark contains a sample tokenizer that breaks strings into words, removes punctuation, throws away single-letter words and downcases. You can replace the `tokenizer` function in the benchmark to try other forms of tokenization.

This will benchmark how long it takes to train a matcher with the data in your first file and it will also benchmark how long it takes to attempt to classify all of the entries in your second file.

> The reported time for matching is the time to match all of the rows in your second file.

I use this in a project where I have ~10k possible matches and currently this libray trains the matcher in ~48ms and each attempt to classify takes ~38µs.
For my use case `26k` matches per second is "fast enough".
