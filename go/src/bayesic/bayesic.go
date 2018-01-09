package bayesic

type Matcher struct {
  classifications map[string]bool
}

func New() Matcher {
  return Matcher{classifications: make(map[string]bool)}
}

func (matcher *Matcher) Classify(tokens []string) map[string]float64 {
  probabilities := make(map[string]float64)
  for key := range matcher.classifications {
    probabilities[key] = 0.0
  }
  return probabilities
}

func (matcher *Matcher) Train(tokens []string, class string) {
  matcher.classifications[class] = true
}
