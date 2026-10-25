+++
title = "Code Beautifier"
description = "Nach wie vor drucke ich immer noch gerne Dokumente/Sourcecode aus um sie auf Papier zu lesen, mir Anmerkungen reinzuschreiben oder einfach nicht vor dem Rechner sitzen zu müssen um den Text zu lesen. Um Sourcecode zu drucken sollte dieser schön formatiert sein und möglichst auf 80 Zeichen begrenzt sein um ihn besser ausdrucken zu können. Für C/C++ Code liefert die Kombination von indent und a2ps gute Ergebnisse."
date = 2009-03-02

aliases = [
    "/2009/03/code-beautifier",
    "/artikel/tools/code-beautifier",
]
+++

Zum Anfang muss erst einmal der Sourcecode formatiert werden, dafür kann man
folgendes Kommando benutzen:

```shellscript
indent in.cpp -st -bad -bap -bli0 -i4 -l79 -lc79 -ncs -npcs -nut \
-npsl -fca -fc1 > out.cpp
```

Hier einige Details zu den Optionen:

-   -std: Der formatierte Sourcecode wird auf die Standardausgabe geschrieben.
-   -bad: Nach jedem Deklarationsblock wird eine Leerzeile eingefügt.
-   -bap: Nach jeder Funktions/Methodenblock wird eine Leerzeile eingefügt.
-   -bli0: Klammern werden nicht eingerückt.
-   -i4: Einrückung um 4 Leerzeichen.
-   -l79: Max. Länge einer Zeile auf 79 Zeichen festlegen.
-   -lc79: Max. Länge einer Kommentarzeile auf 79 Zeichen festlegen.
-   -ncs: Kein Leerzeichen nach einem Cast.
-   -npcs: Kein Leerzeichen hinter dem Funktionsnamen bei einem Funktionsaufruf.
-   -nut: Keine Tabulatoren verwenden, nur Leerzeichen.
-   -npsl: Rückgabewert einer Funktion in der gleichen Zeile wie den Funktionsnamen belassen.
-   -fca: Alle Kommentare formatieren.
-   -fc1: Kommentare formatieren, die in der ersten Spalte beginnen.

Detailiertere Angaben zu den einzelnen Optionen, inkl. Beispielen, findet man
in der Manpage von indent:

```shellscript
man indent
```

Das Kommando um C/C++ Sourcecode zu formatieren ist fertig, leider kann ich mir
eine solche Anzahl von Optionen über einen längeren Zeitraum nicht merken.
Dafür bietet das indent Kommando eine profile Datei, die man sich in seinem
Home-Verzeichnis anlegen kann.

indent liest die Datei .indent.pro ein, wenn vorhanden. Die einzelnen Optionen
können in dieser Datei gespeichert werden, genauso wie man sie für das Kommando
angeben würde, als eine Zeile in der Datei.

## a2ps

Jetzt geht es ans Drucken. mit folgendem Kommando kann man den gerade
formatierten Sourcecode jetzt drucken:

```shellscript
a2ps out.cpp
```

Hat man keinen Standarddrucker eingestellt oder will man es auf einen anderen
Drucker ausgeben kann man den Druckernamen mitgeben:

```shellscript
a2ps -P <druckername> out.cpp
```

Standardmäßig werden 2 Seiten auf eine DIN-A 4 Seite gedruckt, wer lieber nur
eine Seite im Hochformat gedruckt haben will gibt folgendes an:

```shellscript
a2ps -1 out.cpp
```

## Noch 2 kleine Hinweise

Da a2ps keine UTF-8 Kodierung verarbeiten kann, ist es hilfreich die Dateien,
sofern sie in der UTF-8 Kodierung vorliegen, zuvor umzuwandeln:

```shellscript
recode utf8..latin1 out.cpp
```

Möchte man sein Ergebnis zuerst am Bildschirm betrachten sollte man als Drucker display angeben, so wird die Postscript Ausgabe nur am Bildschirm geöffnet.

```shellscript
a2ps -P display out.cpp
```
