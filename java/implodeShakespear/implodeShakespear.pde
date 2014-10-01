
import java.util.Map;

XML xml;
HashMap<String, Integer> wordIndexes = new HashMap<String, Integer>();
HashMap<Integer, Integer> indexOccurences = new HashMap<Integer, Integer>();

void setup() {
  try {
    xml = loadXML("newBase.xml");
    for (XML word : xml.getChild("dico").getChildren("wd")) {
      wordIndexes.put(word.getString("tx"), word.getInt("id"));
      indexOccurences.put(word.getInt("id"), word.getInt("oc"));
    }
  } 
  catch (Exception e) {
    println(e);
  }
}

void draw() {
}

String wordSuggestionFor(String[] txt) {
  HashMap<Integer, Float> suggestion = new HashMap<Integer, Float>();
  for (int w=0;w<txt.length;w++) {
    if (wordIndexes.containsKey(txt[w])) {
      int thisTxtIndex = wordIndexes.get(txt[w]);
      for (XML structure : xml.getChild("sts").getChildren("st")) {
        if (structure.getInt("id")==thisTxtIndex) {
          if (structure.getInt("po")==w+1) {
            for (XML follower : structure.getChildren("fw")) {
              suggestion.put(follower.getInt("id"), (suggestion.containsKey(follower.getInt("id"))?suggestion.get(follower.getInt("id")):0)+((float)follower.getInt("oc")/((float)w+1)));
            }
          }
        }
      }
    }
  }
  int bestWord=-1;
  float bestScore=0;
  for (Map.Entry word : suggestion.entrySet()) {
    if (word.getValue()>bestScore) {
      bestWord=word.getKey();
      bestScore=word.getValue();
    }
  }
  if (bestWord==-1) return "";
  for (Map.Entry word : wordIndexes.entrySet()) {
    if (word.getValue()==bestWord) return word.getKey();
  }
  return "";
}

