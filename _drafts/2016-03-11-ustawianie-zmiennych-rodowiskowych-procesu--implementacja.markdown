---
layout: post
title: "Ustawianie zmiennych środowiskowych procesu - implementacja"
date: "2016-03-11 18:39:51 +0100"
tags: [dajsiepoznac]
---
Po przydługowamy opisie tego co daje nam Windows przyszła chwila na trochę kodu. Jako, że jednym z celów tego projektu jest poznanie nieznanego postanowiłem wykorzystać **F#**-a  ([http://fsharp.org/](http://fsharp.org/)), czyli funkcjyny język z rodziny .NET.

W czasie pracy staram się wykorzystywać TDD i nie inaczej będzie w przypadku Pathera. Jeśli chodzi o technologię to wybór padł na [xUnit](https://xunit.github.io/) oraz [FsUnit](https://fsprojects.github.io/FsUnit/). Oprócz bibliotek potrzebować będziemy także programu, którego zmienne środowiskowe będą zmieniane. W tym celu napisałem malutki program (również w F#), pozwoli sobą sterować (poprzez standardowe wejście/wyjście) dzięki czemu możliwe będzie napisanie testów:
{% gist b726667ed80b0c7cdeb6 EnvInjectionHelper.fs %}

Komunikacja wygląda następująco:

  1. Program odczytuje jeden znak ozaczający polecenie do wykonania (`E` - echo, `S` -> ustawienie zmiennej, `R` -> odczytanie zmiennej)
  2. W zależności od polecenia odczytywane są kolejne parametry - każdy w oddzielnej linii
  3. Odpowiedź jest odsyłana w formie pojedynczej linii

Po stronie testów korzystne będzie napisanie kilku funkcji, które pozwolą na wygodne sterowanie programem pomocniczym:

{% gist b726667ed80b0c7cdeb6 HelperFunctions.fs %}

Te kilka funkcji pozwoli na napisanie pierwszych testów w bardzo przejrzysty sposób:

{% gist b726667ed80b0c7cdeb6 FirstTests.fs %}

Szczęśliwe po uruchomieniu uzyskujemy dwa zielone testy potwierdzające, że nasz proces pomocniczy działa i będziemy mogli przetestować ustawianie zmiennych środowiskowych z innego procesu.

Ten post zakończy się dwoma testami przedstawiającymi końcową funkcjonalność:

{% gist b726667ed80b0c7cdeb6 FinalTests.fs %}

Jako, ze implementacja funkcji `RemoteProcess.readPath` i `RemoteProcess.setPath` wykonujących to czego potrzebujemy jest rozbudowana, będą one tematem następnego posta.
