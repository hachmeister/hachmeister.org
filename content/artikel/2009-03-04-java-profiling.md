+++
title = "Java Profiling"
description = "Geschwindigkeit spielt in vielen Bereichen eine entscheidende Rolle. Um nicht raten zu müssen, ob eine neue Implementierung eines Problems schneller abgearbeitet wird, sollte jeder professionell vorgehende Softwareentwickler einen Profiler nutzen."
date = 2009-03-04

aliases = [
    "/2009/03/java-profiling",
]
+++

Ein einfach einzusetzender Profiler ist The Java Interactive Profiler.

Alles was dafür gebraucht wird ist die `profile.jar` Datei und eine
`profile.properties` Datei, wie in folgendem Beispiel:

```ini
profiler=on
file=profile.txt
```

Bei dem Start des zu testenden Java Programms müssen nur 2 Parameter mit
angegeben werden:

```
-javaagent:profile.jar -Dprofile.properties=profile.properties
```

Anschließend findet man in dem aktuellen Verzeichnis eine `profile.txt` Datei,
in der die Auswertung zu finden ist.

Am Besten kann man dieses an einem Beispiel sehen. In einer sortierten Liste
versuchen wir einen zufällig erzeugten Wert zu finden, zuerst mit einer
einfachen Iteration über das gesamte Array.

```java
public class JIProfilerTest {

    private static int maxRandom = 10000000;

    private int count = 1000000;

    private int[] nums;

    public static void main(String[] args) {
        Random random = new Random(System.currentTimeMillis());

        JIProfilerTest test = new JIProfilerTest();
        test.init(random);

        int numsFound = 0;

        for (int i = 0; i < 10000; i++) {
            int number = random.nextInt(maxRandom) + 1;

            if (test.search(number) > -1) {
                numsFound++;
            }
        }

        System.out.println(numsFound + " Nummern gefunden.");
    }

    private void init(Random random) {
        nums = new int[count];

        for (int i = 0; i < count; i++) {
            nums[i] = random.nextInt(maxRandom);
        }

        Arrays.sort(nums);
    }

     private int search(int number) {
        for (int i = 0; i < nums.length; i++) {
            if (number == nums[i]) {
                return i;
            }
        }

        return -1;
    }

}
```

Lässt man das oben angezeigt Programm ausführen, erhält man eine `profile.txt`
Datei mit folgendem Inhalt.

```
+----------------------------------------------------------------------
|  File: profile.txt
|  Date: 2009.03.04 20:44:32 PM
+----------------------------------------------------------------------

+------------------------------
| Thread depth limit: Unlimited
+------------------------------
+------------------------------
| Thread: 1
+------------------------------
              Time            Percent
       ----------------- ---------------
 Count    Total      Net   Total     Net  Location
 =====    =====      ===   =====     ===  =========
     1  32923,1    293,8   100,0     0,9  +--JIProfilerTest:main    (jiprof)
     1      0,2      0,2     0,0          | +--JIProfilerTest:<init>    (jiprof)
     1    732,4    732,4     2,2     2,2  | +--JIProfilerTest:init    (jiprof)
 10000  31896,8  31896,8    96,9    96,9  | +--JIProfilerTest:search    (jiprof)

+--------------------------------------
| Most expensive methods (by net time)
| Frame Count Limit: Unlimited
+--------------------------------------

               Net
          ------------
 Count     Time    Pct  Location
 =====     ====    ===  ========
 10000  31896,8   96,9  jiprof.JIProfilerTest:search
     1    732,4    2,2  jiprof.JIProfilerTest:init
     1    293,8    0,9  jiprof.JIProfilerTest:main
     1      0,2    0,0  jiprof.JIProfilerTest:<init>

+--------------------------------------+
| Most expensive methods summarized    |
+--------------------------------------+

               Net
          ------------
 Count     Time    Pct  Location
 =====     ====    ===  ========
 10000  31896,8   96,9  jiprof.JIProfilerTest:search
     1    732,4    2,2  jiprof.JIProfilerTest:init
     1    293,8    0,9  jiprof.JIProfilerTest:main
     1      0,2    0,0  jiprof.JIProfilerTest:<init>
```

An dem Ergebnis kann man sehen, dass allein die search Methode 96,9% der
Rechenzeit verbraucht hat.

Jetzt lassen wir dieses Programm nochmal mit einer etwas intelligenteren
Suchmethode ausführen und schauen uns das Ergebnis danach an.

```java
public class JIProfilerTest {

    private static int maxRandom = 10000000;

    private int count = 1000000;

    private int[] nums;

    public static void main(String[] args) {
        Random random = new Random(System.currentTimeMillis());

        JIProfilerTest test = new JIProfilerTest();
        test.init(random);

        int numsFound = 0;

        for (int i = 0; i < 10000; i++) {
            int number = random.nextInt(maxRandom) + 1;

            if (test.search(number) > -1) {
                numsFound++;
            }
        }

        System.out.println(numsFound + " Nummern gefunden.");
    }

    private void init(Random random) {
        nums = new int[count];

        for (int i = 0; i < count; i++) {
            nums[i] = random.nextInt(maxRandom);
        }

        Arrays.sort(nums);
    }

    private int search(int number) {
        int left, right, midpt;

        left = 0;
        right = nums.length - 1;

        while (left <= right) {
            midpt = (int) ((left + right) / 2);

            if (number == nums[midpt]) {
                return midpt;
            } else if (number > nums[midpt]) {
                left = midpt + 1;
            } else {
                right = midpt - 1;
            }
        }

        return -1;
    }

}
```

Das Ergebnis:

```
+----------------------------------------------------------------------
|  File: profile.txt
|  Date: 2009.03.04 20:49:54 PM
+----------------------------------------------------------------------

+------------------------------
| Thread depth limit: Unlimited
+------------------------------
+------------------------------
| Thread: 1
+------------------------------
              Time            Percent
       ----------------- ---------------
 Count    Total      Net   Total     Net  Location
 =====    =====      ===   =====     ===  =========
     1    551,2    127,7   100,0    23,2  +--JIProfilerTest:main    (jiprof)
     1      0,1      0,1     0,0          | +--JIProfilerTest:<init>    (jiprof)
     1    319,6    319,6    58,0    58,0  | +--JIProfilerTest:init    (jiprof)
 10000    103,8    103,8    18,8    18,8  | +--JIProfilerTest:search    (jiprof)

+--------------------------------------
| Most expensive methods (by net time)
| Frame Count Limit: Unlimited
+--------------------------------------

               Net
          ------------
 Count     Time    Pct  Location
 =====     ====    ===  ========
     1    319,6   58,0  jiprof.JIProfilerTest:init
     1    127,7   23,2  jiprof.JIProfilerTest:main
 10000    103,8   18,8  jiprof.JIProfilerTest:search
     1      0,1    0,0  jiprof.JIProfilerTest:<init>

+--------------------------------------+
| Most expensive methods summarized    |
+--------------------------------------+

               Net
          ------------
 Count     Time    Pct  Location
 =====     ====    ===  ========
     1    319,6   58,0  jiprof.JIProfilerTest:init
     1    127,7   23,2  jiprof.JIProfilerTest:main
 10000    103,8   18,8  jiprof.JIProfilerTest:search
     1      0,1    0,0  jiprof.JIProfilerTest:<init>
```

Dieser zweite Versuch hat schon eine insgesamt viel kürzere Laufzeit, außerdem
benötigt die search Methode jetzt nur noch 18,8%.

Bei diesem Beispiel konnte man sicherlich auch ohne Profiler sagen, dass die
zweite Variante schneller ist. Es gibt aber sicherlich andere Probleme, die
nicht so einfach zu überblicken sind. Speziell wenn man versucht einen
Flaschenhals in einem Programm zu finden kann ein Profiler gute Dienste leisten.

Interessant ist The Java Interactive Profiler sicherlich auch deswegen, da man
ihn remote einsetzen kann und somit auch nützlich für Anwendungen sein kann,
die in einem Servlet Container laufen. Das Einschalten des Profilers kann auch
remote erfolgen, so dass auch nur spezielle Aspekte einer Anwendung getestet
werden können.
