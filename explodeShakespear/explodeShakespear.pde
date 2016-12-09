
void setup() {
  size(200,200);
}

void draw() {
}

void keyPressed() {
  if (keyCode==UP) buildDatabaseWords("newBase.xml", "text.txt");
  if (keyCode==DOWN) cleanDatabaseWords("newBase.xml");
  if (keyCode==RIGHT) updateDatabaseStructures("newBase.xml", "text.txt");
  if (keyCode==LEFT) cleanStructures("newBase.xml");
  if (keyCode==ENTER) {
    // create new empty xml
    XML xml = loadXML(dataPath("files/emptyDatabase.xml"));
    // TODO add names of the files
    String[] corpus = getAllFilesFrom(dataPath("corpus"));
    for (int i=0; i<corpus.length; i++) {
      XML book = new XML("bk");
      String[] folders = split(corpus[i], "/");
      book.setString("tl", folders[folders.length-1]);
      xml.getChild("corpus").addChild(book);
    } 
    saveXML(xml, "newBase.xml");     
    println("for each text in corpus, buildDatabaseWords()");
    for (int i=0; i<corpus.length; i++) buildDatabaseWords("newBase.xml", corpus[i]);
    println("cleanDatabaseWords()");
    cleanDatabaseWords("newBase.xml");
    println("for each text in corpus, updateDatabaseStructures()");
    for (int i=0; i<corpus.length; i++) updateDatabaseStructures("newBase.xml", corpus[i]);
    println("cleanStructures()");
    cleanStructures("newBase.xml");
  }
}

void buildDatabaseWords(String resultUrl, String textUrl) {

  String databaseUrl = resultUrl;
  // load text to be parsed
  String[] text = loadStrings(textUrl);

  // load xml
  XML xml = loadXML(databaseUrl);

  ArrayList<String> wordsInBook = new ArrayList<String>();

  // explode words and add them to wordsInBook 
  for (int i=0; i<text.length; i++) {
    String[] words = splitTokens(text[i], " ,;:.?!\"'()«»<>_");
    for (String word : words) wordsInBook.add(word.toLowerCase());
  }

  // TODO separate sentences and lines ?

  int[] indexes = new int[wordsInBook.size()];
  int firstFreeIndex=0;

  for  (int w=0; w<wordsInBook.size (); w++) {// for each word in book
    String word=wordsInBook.get(w);
    boolean found=false;
    for  (XML wordNode : xml.getChild ("dico").getChildren("wd")) {
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
        for  (XML wordNode : xml.getChild ("dico").getChildren("wd")) {
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

  saveXML(xml, resultUrl);
}

void updateDatabaseStructures(String databaseUrl, String textUrl) {

  // load text to be parsed
  String[] text = loadStrings(textUrl);

  // load xml
  XML xml = loadXML(databaseUrl);

  HashMap<String, Integer> indexes = new HashMap<String, Integer>();
  XML[] wordsInBase = xml.getChild("dico").getChildren("wd"); 
  for (int i=0; i<wordsInBase.length; i++) {
    indexes.put(wordsInBase[i].getString("tx"), wordsInBase[i].getInt("id"));
  }

  ArrayList<String> wordsInBook = new ArrayList<String>();

  // explode words and add them to wordsInBook 
  for (int i=0; i<text.length; i++) {
    String[] words = splitTokens(text[i], " ,;:.?!\"'()«»<>_");
    for (String word : words) wordsInBook.add(word.toLowerCase());
  }

  int maxArrayLength = 3;// number of previous words to store for each occurence

  for  (int w=0; w<wordsInBook.size (); w++) {// for each word in book
    println("processing chains for word "+w+"/"+wordsInBook.size());
    if (indexes.containsKey(wordsInBook.get(w))) {// if this word is in the database
      for (int chain=1; chain<=maxArrayLength; chain++) {// for each chain size
        if (w-chain>=0) {// enough room before the word
          boolean structureFound=false;
          for (XML structure : xml.getChild ("sts").getChildren("st")) {// for each existing structure
            if (indexes.containsKey(wordsInBook.get(w-chain))) {// if the last n word exists in database
              if (structure.getInt("id")==indexes.get(wordsInBook.get(w-chain))) {// last n word match
                if (structure.getInt("po")==chain) {// n match
                  boolean followerFound=false;
                  for (XML follower : structure.getChildren ("fw")) {// for each follower
                    if (follower.getInt("id")==indexes.get(wordsInBook.get(w))) {// follower found
                      follower.setInt("oc", follower.getInt("oc")+1);// add one occurence
                      followerFound=true;
                    }
                  }
                  if (!followerFound) {// follower not found
                    // add this follower
                    XML newFollower = new XML("fw");
                    newFollower.setInt("id", indexes.get(wordsInBook.get(w)));
                    newFollower.setInt("oc", 1);
                    structure.addChild(newFollower);
                  }
                  structureFound=true;
                }
              }
            }
          }
          if (!structureFound) {// structure not found
            if (indexes.containsKey(wordsInBook.get(w-chain))) {// if the last n word exists in database
              XML structure = new XML("st");
              structure.setInt("id", indexes.get(wordsInBook.get(w-chain)));
              structure.setInt("po", chain);
              // structure.setString("tx", wordsInBook.get(w-chain));
              XML newFollower = new XML("fw");
              newFollower.setInt("id", indexes.get(wordsInBook.get(w)));
              newFollower.setInt("oc", 1);
              // newFollower.setString("tx", wordsInBook.get(w));
              structure.addChild(newFollower);
              // add this structure with this occurence
              xml.getChild("sts").addChild(structure);
            }
          }
        }
      }
    }
  }

  saveXML(xml, databaseUrl);
}

void cleanDatabaseWords(String databaseUrl) {

  // load xml
  XML xml = loadXML(databaseUrl);

  int maxWords = 3000;

  // remove indexes that do not have enough occurences
  int minOccurence=0;
  int nbWdsRemoved=0;
  XML[] words = xml.getChild ("dico").getChildren("wd");
  while (words.length>maxWords) {
    for (XML word : words) {// for each existing word
      if (word.getInt("oc")<=minOccurence) {
        xml.getChild("dico").removeChild(word);
        nbWdsRemoved++;
      }
    }
    words = xml.getChild ("dico").getChildren("wd");
    minOccurence++;
  }
  println(nbWdsRemoved+" words removed");

  // TODO check each structure to remove structures or followers that do not fit (although there should not be any structure yet anyway at this point)

  // set new sorted indexes
  HashMap<Integer, Integer> sortedIndexes = new HashMap<Integer, Integer>();// old -> new
  int order=0;
  while (sortedIndexes.size ()<words.length) {
    println("defining new indexes "+sortedIndexes.size ()+" / "+words.length);
    int highestOccurence=-1;
    int highestIndex=-1;
    for (XML word : words) {
      if (!sortedIndexes.containsKey(word.getInt("id"))) {
        if (word.getInt("oc")>=highestOccurence) {
          highestOccurence=word.getInt("oc");
          highestIndex=word.getInt("id");
        }
      }
    }
    sortedIndexes.put(highestIndex, order++);
  }
  // apply new indexes
  for (XML word : words) {
    word.setInt("id", sortedIndexes.get(word.getInt("id")));
  }

  println("done defining sorted indexes");

  // apply new indexes to structures
  for (XML structure : xml.getChild ("sts").getChildren("st")) {// for each existing structure
    structure.setInt("id", sortedIndexes.get(structure.getInt("id")));
    for (XML follower : structure.getChildren ("fw")) {
      follower.setInt("id", sortedIndexes.get(follower.getInt("id")));
    }
  }

  // TODO sort indexes in the XML file itself

  saveXML(xml, databaseUrl);

  println("done cleaning the database");
}

void cleanStructures(String databaseUrl) {

  // load xml
  XML xml = loadXML(databaseUrl);

  int minStructOcc=1;

  int maxStructures = 3000;

  int nbStsRemoved=0;
  while (xml.getChild ("sts").getChildren("st").length>maxStructures) {
    // remove indexes with not enough occurences
    for (XML structure : xml.getChild ("sts").getChildren("st")) {// for each existing structure
      int numberOfOccurences = 0;
      for (XML follower : structure.getChildren ("fw")) {
        numberOfOccurences+=follower.getInt("oc");
      }
      if (numberOfOccurences<=minStructOcc) {
        xml.getChild("sts").removeChild(structure);
        nbStsRemoved++;
      }
    }
    minStructOcc++;
  }
  println("removed "+nbStsRemoved+" structures");

  // TODO remove specific followers rather than structures

  // TODO sort indexes at the end to allow dichotomy ?

  saveXML(xml, databaseUrl);

  println("done cleaning the database");
}

String[] getAllFilesFrom(String folderUrl) {
  try {  
    File folder = new File(folderUrl);
    File[] filesPath = folder.listFiles();
    String[] result = new String[filesPath.length];
    for (int i=0; i<filesPath.length; i++) {
      result[i]=filesPath[i].toString();
    }
    return result;
  }
  catch(Exception e) {
    println(e.toString());
    String[] empty = new String[0];
    return empty;
  }
}
