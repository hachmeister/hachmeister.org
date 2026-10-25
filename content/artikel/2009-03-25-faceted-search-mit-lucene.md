+++
title = "Faceted Search mit Lucene"
description = "Lucene ist eine leistungsfähige Volltext-Suchmaschine geschrieben in Java. Faceted Search ist ein immer öfter gefordertes Feature bei dem Einsatz einer Suchmaschine."
date = 2009-03-25T18:00:00

aliases = [
    "/2009/03/faceted-search-mit-lucene",
]
+++

In diesem Artikel möchte ich zeigen, wie man eine einfache Faceted Search mit
Lucene umsetzen kann.

Zum Einsammeln der Facetten benötigen wir eine Implementierung der `HitCollector`
Klasse. Hier wird die `TopFieldDocCollector` Klasse erweitert, wird keine weitere
Sortierung außer nach Relevanz benötigt, so kann man auch die Klasse
`TopDocCollector` nutzen.

Zu beachten ist, dass diese Implementierung einer Faceted Search nur
funktioniert, wenn Felder die zur Facettenbildung benutzt werden, nur einen
einzelnen Wert pro Dokument haben. Andernfalls ist das Verhalten undefiniert,
da die Werte für die Facetten über die Klasse `FieldCache` erzeugt werden. Um
mehrere Werte für Facettenfelder zu erlauben ist eine eigene Implementierung
einer `FieldCache` Klasse notwendig, die mehrere Werte pro Feld enthalten kann.

Hier nun die Implementierung:

```java
public class FacetedCollector extends TopFieldDocCollector {

  private Map<String, String[]> fieldCaches;

  private Map<String, Map<String, Integer>> facetsMap;

  public FacetedCollector(String[] fields, IndexReader reader,
      Sort sort, int numHits) throws IOException {
    super(reader, sort, numHits);

    this.facetsMap = new HashMap<String, Map<String, Integer>>();
    this.fieldCaches = new HashMap<String, String[]>();

    for (String field : fields) {
      facetsMap.put(field, new HashMap<String, Integer>());
      fieldCaches.put(field,
        FieldCache.DEFAULT.getStrings(reader, field));
    }
  }

  @Override
  public void collect(int doc, float score) {
    super.collect(doc, score);

    for (Entry<String, Map<String, Integer>> e
        : facetsMap.entrySet()) {
      Map<String, Integer> values = e.getValue();
      String value = fieldCaches.get(e.getKey())[doc];

      if (value != null) {
        Integer count = values.get(value);

        if (count == null) {
          values.put(value, 1);
        } else {
          values.put(value, count + 1);
        }
      }
    }
  }

  public Map<String, Map<String, Integer>> getFacetsMap() {
    return facetsMap;
  }

}
```

Zusätzlich zu den Parametern des Konstrukturs der Klasse `TopFieldDocCollector`
werden die Feldnamen im Stringarray `fields` übergeben.

Über die `fieldCaches` kann direkt auf den Wert eines Feldes eines bestimmten
Dokumentes zugegriffen werden, ohne im Index suchen zu müssen. Die Arrays für
die Werte der verschiedenen Felder befinden sich direkt im Ram und werden von
der `FieldCache` Klasse bei dem ersten Zugriff erzeugt. Damit dauert die erste
Suche über den `FacetedCollector`, je nach Anzahl der Dokumente im Index, einige
Zeit.

Um den Speicherbedarf möglichst niedrig zu halten sollte versucht werden die
Werte über byte, short oder int Felder im Index abzulegen.

Hier eine beispielhafte Benutzung der `FacetedCollector` Klasse:

```java
public class FacetedSearch {

  public static void main(String[] args) {
    String path = args[0];
    String queryStr = args[1];

    try {
      QueryParser parser = new QueryParser("title",
        new StandardAnalyzer());
      Query query = parser.parse(queryStr);

      IndexSearcher searcher = new IndexSearcher(path);
      String[] fields = { "language", "year" };
      IndexReader reader = searcher.getIndexReader();
      FacetedCollector collector = new FacetedCollector(fields,
        reader, Sort.RELEVANCE, 10);
      searcher.search(query, collector);

      Map<String, Map<String, Integer>> facetsMap =
          collector.getFacetsMap();

      for (Entry<String, Map<String, Integer>> fieldEntry
          : facetsMap.entrySet()) {
        System.out.println(" - " + fieldEntry.getKey());

        for (Entry<String, Integer> valueEntry
            : fieldEntry.getValue().entrySet()) {
          System.out.println("   - " + valueEntry.getKey()
            + " (" + valueEntry.getValue() + ")");
        }
      }

      searcher.close();
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

}
```
