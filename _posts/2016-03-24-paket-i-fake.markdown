---
layout: post
title: "Paket i FAKE"
date: "2016-03-24 07:23:12 +0100"
tags: [dajsiepoznac]
---
W świecie .NETowym bardzo wiele rozwiązań pochodzi z Microsoftu. Część z nich naprawdę dobra, część ma pewne wady. Na szczęście społeczność open-source przychodzi z pomocą. W tym poście mam zamiar opowiedzieć o dwóch narzędziach, które starają się poprawić to co w "oficjalnych" nie jest idealne - [Paket](http://fsprojects.github.io/Paket/) oraz [FAKE](http://fsharp.github.io/FAKE/)

## Paket
NuGet jest fantastycznym rozwiązaniem, w którym kilka elementów nie wyszło. Któż z nas nie spędził długich chwil patrząc na aktualizację pakietów czy wyliczanie zależności albo walce ze zmianą platformy na której ma działać aplikacja? Wersja 3.0 wprowadziła kilka kolejnych "udogodnień": brak pakietów tylko z zawartością (to już pojawiło się ponownie w 3.3) czy pakietów solution-only.

Paket jest narzędziem napisanym w F#, który ma na celu poprawić te braki. Nie zastępuje on całej infrastruktury NuGeta, a jedynie część kliencką. Z najbardziej interesujących funkcji warto wymienić:

 * Szybsze rozwiązywanie zależności
 * Zależności opisane w prostych plikach tekstowych
 * Całe drzewo zależności zapisane w oddzielnym pliku (a nie w packages.config)
 * Działa bez Visual Studio
 * W ścieżkach do pakietów nie ma wersji
 * Zamiana platformy docelowej projektu nie wymaga przeinstalowania paczek
 * Szybsze rozwiązywanie zależności
 * Zależnością mogą być paczki NuGeta, pliki, Gisty, repozytoria gitowe

Dwukrotne wymienienie szybkości nie jest przypadkiem, nawet przy prostych operacjach z niewielką liczbą zależności Paket jest zdecydowanie szybszy niż NuGet. Do opisu zależności wykorzystywane są dwa pliki: `paket.dependencies` oraz `paket.references`. Pierwszy z nich jest znajduje się w folderze głównym solucji i opisuje skąd brać paczki oraz jakie są potrzebne. Drugi znajduje się w każdym projekcie i określa, które zależności powinny być przypisane jako referencje (w przypadku binarek). Po wprowadzeniu zmian wystarczy wydać polecenie `paket install` a całość osiągnie pożądany stan.

Na chwilę obecną pliki te dla Pathera wyglądają następująco:

{% gist e0d2fa004fbaf0cd3af1 paket.dependencies %}

{% gist e0d2fa004fbaf0cd3af1 Pather\paket.references  %}

Jak widać są one dość proste, a osoby znające Bundlera zauważą podobieństwo między `Gemfile` a `paket.dependencies`. Jeżeli ktoś nie przepada za konsolą, to jest dodatek do Visual Studio ([https://github.com/fsprojects/Paket.VisualStudio](https://github.com/fsprojects/Paket.VisualStudio)) oraz do Atoma ([https://atom.io/packages/paket](https://atom.io/packages/paket)).

## FAKE
Drugim narzędziem o którym chciałbym wspomnieć jest [Fake](http://fsharp.github.io/FAKE/) pozwalający na pisanie skryptów budujących jako skryptów F#. Każdy kto pisał kiedyś rozbudowane skrypty w MSBuildzie, (N)Antcie doceni swobodę pełnego języka i zwartego zapisu. Dodatkową zaletą jest fakt, że FAKE dystrybuowany jest w formie paczki NuGetowej i łatwo go zainstalować (np. Paketem). Warto też wspomnieć o rozbudowanej bibliotece standardowej dającej takie możliwości jak:

 * Generowanie `AssemblyInfo`
 * Uruchamianie MSBuilda
 * Uruchamianie testów xUnit, NUnit
 * Badanie pokrycia kodu OpenCoverem
 * Pobieranie paczek NuGetowych i uruchamianie Paketa
 * Zipowanie
 * Operowanie na repozytorium Gita
 * Budowanie paczek NuGeta
 * Konfigurowanie IISa
 * ... i wiele, wiele innych

Sam skrypt budujący składa się z **targetów**  będących w zasadzie zwykłymi funkcjami F#. Kolejność wywołania określona jest poprzez zdefinowanie zależności miedzy targetami (podobnie jak w innych narzędziach). Jeżeli skrypt nazwiemy `build.fsx` nie trzeba będzie podawać jego nazwy przy uruchamianiu Fake-a. Skrypt budujący Pathera wygląda następująco:

{% gist e0d2fa004fbaf0cd3af1 build.fs %}

Najbardziej interesujący jest target `WatchTests` - obserwuje on zmiany binarki z testami i automatycznie je uruchamia. Linie 39 - 42 określają kolejność wykonania (najpierw `Build` potem `RunTests`) oraz domyślny target `RunTests`.

Ten post dał zgrubny pogląd dwa narzędzia wykorzystywane w Patherze. W następnym poście postaram się pokazać trochę bardziej rozbudowany skrypt budujący.
