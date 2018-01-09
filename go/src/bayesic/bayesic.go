package bayesic

type Matcher struct {
  classifications stringSet
  tokensByClassification map[string]stringSet
  classificationsByToken map[string]stringSet
}

type stringSet map[string]bool

func New() Matcher {
  return Matcher{
    classifications: make(stringSet),
    classificationsByToken: make(map[string]stringSet),
    tokensByClassification: make(map[string]stringSet),
  }
}

func (matcher *Matcher) Classify(tokens []string) map[string]float64 {
  probabilities := make(map[string]float64)
  for key := range matcher.classifications {
    probabilities[key] = 1.0 / float64(len(matcher.classifications))
  }
  return probabilities
}

func (matcher *Matcher) Train(tokens []string, class string) {
  matcher.classifications[class] = true
  _, exists := matcher.tokensByClassification[class]
  if !exists {
    matcher.tokensByClassification[class] = make(stringSet)
  }
  for idx := range tokens {
    token := tokens[idx]
    matcher.tokensByClassification[class][token] = true
    _, exists := matcher.classificationsByToken[token]
    if !exists {
      matcher.classificationsByToken[token] = make(stringSet)
    }
    matcher.classificationsByToken[token][class] = true
  }
}
