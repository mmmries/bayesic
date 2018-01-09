package bayesic

type Matcher struct {
	classifications        stringSet
	tokensByClassification map[string]stringSet
	classificationsByToken map[string]stringSet
}

type stringSet map[string]bool

func New() *Matcher {
	return &Matcher{
		classifications:        make(stringSet),
		classificationsByToken: make(map[string]stringSet),
		tokensByClassification: make(map[string]stringSet),
	}
}

func (matcher *Matcher) Classify(tokens []string) map[string]float64 {
	probabilities := make(map[string]float64)
	for _, token := range tokens {
		_, exists := matcher.classificationsByToken[token]
		if !exists {
			continue
		}
		for class := range matcher.classificationsByToken[token] {
			p_klass, exists := probabilities[class]
			if !exists {
				p_klass = 1.0 / float64(len(matcher.classifications))
			}
			p_not_klass := 1.0 - p_klass
			p_token_given_klass := 1.0
			p_token_given_not_klass := (float64(len(matcher.classificationsByToken[token])) - 1.0) / float64(len(matcher.classifications))
			probabilities[class] = (p_token_given_klass * p_klass) / ((p_token_given_klass * p_klass) + (p_token_given_not_klass * p_not_klass))
		}
	}
	return probabilities
}

func (matcher *Matcher) Train(tokens []string, class string) {
	matcher.classifications[class] = true
	_, exists := matcher.tokensByClassification[class]
	if !exists {
		matcher.tokensByClassification[class] = make(stringSet)
	}
	for _, token := range tokens {
		matcher.tokensByClassification[class][token] = true
		_, exists := matcher.classificationsByToken[token]
		if !exists {
			matcher.classificationsByToken[token] = make(stringSet)
		}
		matcher.classificationsByToken[token][class] = true
	}
}
