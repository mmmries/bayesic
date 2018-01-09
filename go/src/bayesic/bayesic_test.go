package bayesic

import "testing"
import "fmt"

func createMatcher() Matcher {
  matcher := New()
  matcher.Train([]string{"once","upon","a","time"}, "story")
  matcher.Train([]string{"tonight","on","the","news"}, "news")
  matcher.Train([]string{"it","was","the","best","of","times"}, "novel")
  return matcher
}

func TestClassifyMatchingTokens(t *testing.T) {
  matcher := createMatcher()
  fmt.Println(matcher.tokensByClassification)
  fmt.Println(matcher.classificationsByToken)
  classification := matcher.Classify([]string{"once","upon","a","time"})
  probability := classification["story"]
  if probability < 0.99 {
    t.Errorf("expected the story probability to be over 99%%, but was %f", probability)
  }
}

func TestClassifyPartialMatch(t *testing.T) {
  matcher := createMatcher()
  classification := matcher.Classify([]string{"the","time"})
  probability := classification["story"]
  if probability < 0.9 {
    t.Errorf("expected the story probability to be over 90%%, but was %f", probability)
  }
}
