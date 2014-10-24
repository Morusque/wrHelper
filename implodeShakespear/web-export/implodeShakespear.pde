
import java.util.Map;

XML xml;
HashMap<String, Integer> wordIndexes = new HashMap<String, Integer>();
HashMap<Integer, String> wordTexts = new HashMap<Integer, String>();
HashMap<Integer, Integer> indexOccurences = new HashMap<Integer, Integer>();

HashMap<Integer, Float> wordsUsed = new HashMap<Integer, Float>();

void setup() {
  try {
	loadBase("emptyDatabase.xml");
  } 
  catch (Exception e) {
    println(e);
  }
}

void draw() {
}

void loadBase(String url) {
	xml = loadXML(url);
    for (XML word : xml.getChild("dico").getChildren("wd")) {
      wordIndexes.put(word.getString("tx"), word.getInt("id"));
      wordTexts.put(word.getInt("id"), word.getString("tx"));
      indexOccurences.put(word.getInt("id"), word.getInt("oc"));
    }
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

String wordSuggestionFor(String[] txt, String bud) {
  for (int i=0;i<txt.length;i++) txt[i] = txt[i].toLowerCase();
  bud=bud.toLowerCase();
  HashMap<Integer, Float> suggestion = new HashMap<Integer, Float>();
  for (int w=0;w<txt.length;w++) {
    if (wordIndexes.containsKey(txt[w])) {
      int thisTxtIndex = wordIndexes.get(txt[w]);
      for (XML structure : xml.getChild("sts").getChildren("st")) {
        if (structure.getInt("id")==thisTxtIndex) {
          if (structure.getInt("po")==w+1) {
            for (XML follower : structure.getChildren("fw")) {
              if (sameStart(wordTexts.get(follower.getInt("id")), bud)) {
                suggestion.put(follower.getInt("id"), (suggestion.containsKey(follower.getInt("id"))?suggestion.get(follower.getInt("id")):0)+((float)follower.getInt("oc") / ((float)2*w+2)));
              }
            }
          }
        }
      }
    }
  }
  int bestWord=-1;
  float bestScore=0;
  for (Map.Entry word : suggestion.entrySet()) {
    float thisScore = (log((float)1+word.getValue()));
    if (wordsUsed.containsKey(word.getKey())) thisScore/=max(1, wordsUsed.get(word.getKey()));
    if (thisScore-bestScore>0) {
      bestWord=word.getKey();
      bestScore=thisScore;
    }
  }
  if (wordTexts.containsKey(bestWord)) return wordTexts.get(bestWord).substr(bud.length(), wordTexts.get(bestWord).length());
  return "";
}

boolean sameStart(String a, String b) {
  if (a.length()>=b.length()) if (a.substr(0, b.length()).equals(b)) return true;
  if (b.length()>=a.length()) if (b.substr(0, a.length()).equals(a)) return true;
  return false;
}

void informAllWords(String[] words) {
  wordsUsed = new HashMap<Integer, Float>();
  for (int i=0;i<words.length;i++) {
    String word = words[i];
    if (wordIndexes.containsKey(word)) {
      int index=wordIndexes.get(word);
      wordsUsed.put(index, (wordsUsed.containsKey(index)?wordsUsed.get(index):1)+((float)i/words.length));
    }
  }
  /*
  for (Map.entry tWord : wordsUsed.entrySet()) {
    println(wordTexts.get(tWord.getKey())+" "+tWord.getValue());
  }
  */
}

