
// TODO separate sentences and lines
// TODO sort indexes at the end to allow dichotomy

void setup() {

  String databaseUrl = "emptyDatabase.xml";

  // load text to be parsed
  String[] text = loadStrings("text.txt");

  // load xml
  XML xml = loadXML(databaseUrl);

  ArrayList<String> wordsInBook = new ArrayList<String>();

  // explode words and add them to wordsInBook 
  for (int i=0;i<text.length;i++) {
    String[] words = splitTokens(text[i], " ,;:.?!\"'()");
    for (String word:words) wordsInBook.add(word.toLowerCase());
  }

  int[] indexes = new int[wordsInBook.size()];
  int firstFreeIndex=0;

  for  (int w=0;w<wordsInBook.size();w++) {// for each word in book
    String word=wordsInBook.get(w);
    boolean found=false;
    for  (XML wordNode : xml.getChild("dico").getChildren("wd")) {
      if (wordNode.getString("tx").equals(word)) {
        found=true;
        wordNode.setInt("oc", wordNode.getInt("oc")+1);// add one occurence
        indexes[w]=wordNode.getInt("id");
      }
    }
    if (!found) {
      boolean idFound=true;
      while (idFound) { 
        idFound=false;
        for  (XML wordNode : xml.getChild("dico").getChildren("wd")) {
          if (wordNode.getInt("id")==firstFreeIndex) {
            firstFreeIndex++;
            idFound=true;
          }
        }
      }
      indexes[w]=firstFreeIndex;
      XML newWord = new XML("wd");
      newWord.setString("tx", word);
      newWord.setInt("id", firstFreeIndex);
      newWord.setInt("oc", 1);
      xml.getChild("dico").addChild(newWord);
    }
    println("processing indexes for word "+w+"/"+wordsInBook.size()+" word : "+wordsInBook.get(w)+" : index "+indexes[w]);
  }

  int maxArrayLength = 3;// number of previous words to store for each occurence

  for  (int w=0;w<wordsInBook.size();w++) {// for each word in book
    println("processing chains for word "+w+"/"+wordsInBook.size());
    for (int chain=1;chain<=maxArrayLength;chain++) {// for each chain size
      if (w-chain>=0) {// enough room before the word
        boolean structureFound=false;
        for (XML structure : xml.getChild("sts").getChildren("st")) {// for each existing structure
          if (structure.getInt("id")==indexes[w-chain]) {// last n word match
            if (structure.getInt("po")==chain) {// n match
              boolean followerFound=false;
              for (XML follower : structure.getChildren("fw")) {// for each follower
                if (follower.getInt("id")==indexes[w]) {// follower found
                  follower.setInt("oc", follower.getInt("oc")+1);// add one occurence
                  followerFound=true;
                }
              }
              if (!followerFound) {// follower not found
                // add this follower
                XML newFollower = new XML("fw");
                newFollower.setInt("id", indexes[w]);
                newFollower.setInt("oc", 1);
                structure.addChild(newFollower);
              }
              structureFound=true;
            }
          }
        }
        if (!structureFound) {// structure not found
          XML structure = new XML("st");
          structure.setInt("id", indexes[w-chain]);
          structure.setInt("po", chain);
          structure.setString("wo", wordsInBook.get(w-chain));
          XML newFollower = new XML("fw");
          newFollower.setInt("id", indexes[w]);
          newFollower.setInt("oc", 1);
          newFollower.setString("wo", wordsInBook.get(w));
          structure.addChild(newFollower);
          // add this structure with this occurence
          xml.getChild("sts").addChild(structure);
        }
      }
    }
  }

  saveXML(xml, "newBase.xml");
}

void draw() {
}

