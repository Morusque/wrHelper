
import java.util.Map;

XML xml;
HashMap<String, Integer> wordIndexes = new HashMap<String, Integer>();
HashMap<Integer, String> wordTexts = new HashMap<Integer, String>();
HashMap<Integer, Integer> indexOccurences = new HashMap<Integer, Integer>();

void setup() {
  try {
    xml = loadXML("newBase.xml");
    for (XML word : xml.getChild("dico").getChildren("wd")) {
      wordIndexes.put(word.getString("tx"), word.getInt("id"));
      wordTexts.put(word.getInt("id"), word.getString("tx"));
      indexOccurences.put(word.getInt("id"), word.getInt("oc"));
    }
  } 
  catch (Exception e) {
    println(e);
  }
}

void draw() {
}

String wordCompletionFor(String txt) {
  txt = txt.toLowerCase();
  HashMap<Integer, Float> suggestion = new HashMap<Integer, Float>();
  for (Map.Entry word : wordIndexes.entrySet()) {
    if (word.getKey().length()>txt.length()) {
      if (word.getKey().substring(0, txt.length()).equals(txt)) {
        suggestion.put(word.getValue(), (float)indexOccurences.get(word.getValue()));
      }
    }
  }
  int bestWord=-1;
  float bestScore=0;
  for (Map.Entry word : suggestion.entrySet()) {
    float thisScore = ((float)word.getValue());
    if (thisScore-bestScore>0) {
      bestWord=word.getKey();
      bestScore=thisScore;
    }
  }
  if (wordTexts.containsKey(bestWord)) return wordTexts.get(bestWord).substring(txt.length(), wordTexts.get(bestWord).length());
  return "";
}

String wordSuggestionFor(String[] txt) {
  for (int i=0;i<txt.length;i++) txt[i] = txt[i].toLowerCase();
  HashMap<Integer, Float> suggestion = new HashMap<Integer, Float>();
  for (int w=0;w<txt.length;w++) {
    if (wordIndexes.containsKey(txt[w])) {
      int thisTxtIndex = wordIndexes.get(txt[w]);
      for (XML structure : xml.getChild("sts").getChildren("st")) {
        if (structure.getInt("id")==thisTxtIndex) {
          if (structure.getInt("po")==w+1) {
            for (XML follower : structure.getChildren("fw")) {
              suggestion.put(follower.getInt("id"), (suggestion.containsKey(follower.getInt("id"))?suggestion.get(follower.getInt("id")):0)+((float)follower.getInt("oc") / ((float)w+2)));
            }
          }
        }
      }
    }
  }
  int bestWord=-1;
  float bestScore=0;
  for (Map.Entry word : suggestion.entrySet()) {
    float thisScore = ((float)word.getValue());
    if (thisScore-bestScore>0) {
      bestWord=word.getKey();
      bestScore=thisScore;
    }
  }
  if (wordTexts.containsKey(bestWord)) return wordTexts.get(bestWord);
  return "";
}

